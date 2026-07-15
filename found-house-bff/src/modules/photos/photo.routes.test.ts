import { createHmac } from 'node:crypto';
import type { FastifyInstance } from 'fastify';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';

// 禁用 Redis/PG，避免测试触碰外部连接。
delete process.env.REDIS_URL;
delete process.env.DATABASE_URL;

const { buildApp } = await import('../../app.js');

let app: FastifyInstance;

beforeEach(async () => {
  clearOssEnv();
});

afterEach(async () => {
  await app?.close();
  clearOssEnv();
});

describe('POST /api/photos/upload-intent', () => {
  it('OSS 环境未配置时返回 OSS_NOT_CONFIGURED', async () => {
    app = await buildApp();
    await app.ready();

    const res = await app.inject({
      method: 'POST',
      url: '/api/photos/upload-intent',
      payload: validPayload(),
    });

    expect(res.statusCode).toBe(503);
    expect(res.json()).toMatchObject({ code: 'OSS_NOT_CONFIGURED' });
  });

  it('非法入参返回 VALIDATION_FAILED', async () => {
    setValidOssEnv();
    app = await buildApp();
    await app.ready();

    const res = await app.inject({
      method: 'POST',
      url: '/api/photos/upload-intent',
      payload: { ...validPayload(), contentType: 'application/pdf', contentLength: 0 },
    });

    expect(res.statusCode).toBe(400);
    expect(res.json()).toMatchObject({ code: 'VALIDATION_FAILED' });
  });

  it('配置完整时生成受限 PostObject 表单且不泄露 AccessKey Secret', async () => {
    setValidOssEnv();
    app = await buildApp();
    await app.ready();

    const res = await app.inject({
      method: 'POST',
      url: '/api/photos/upload-intent',
      payload: validPayload(),
    });

    expect(res.statusCode).toBe(200);
    const body = res.json() as {
      method: string;
      uploadUrl: string;
      formFields: {
        key: string;
        OSSAccessKeyId: string;
        policy: string;
        Signature: string;
        success_action_status: string;
        'Content-Type': string;
      };
      publicUrl: string;
      objectKey: string;
      expiresAt: string;
    };

    expect(JSON.stringify(body)).not.toContain('test-secret');
    expect(body.method).toBe('POST');
    expect(body.uploadUrl).toBe('https://found-house-test.oss-cn-shenzhen.aliyuncs.com/');
    expect(body.objectKey).toMatch(/^photos\/house\/house-1\/[a-f0-9-]+\.jpg$/);
    expect(body.publicUrl).toBe(`https://cdn.example.com/${body.objectKey}`);
    expect(body.formFields.key).toBe(body.objectKey);
    expect(body.formFields.OSSAccessKeyId).toBe('test-key');
    expect(body.formFields.success_action_status).toBe('201');
    expect(body.formFields['Content-Type']).toBe('image/jpeg');

    const policyField = body.formFields.policy;
    const policy = JSON.parse(Buffer.from(policyField, 'base64').toString('utf8')) as {
      expiration: string;
      conditions: unknown[];
    };
    expect(new Date(policy.expiration).toString()).not.toBe('Invalid Date');
    expect(policy.conditions).toContainEqual(['starts-with', '$key', 'photos/house/house-1/']);
    expect(policy.conditions).toContainEqual(['content-length-range', 1, 5 * 1024 * 1024]);
    expect(policy.conditions).toContainEqual(['eq', '$Content-Type', 'image/jpeg']);

    const expectedSignature = createHmac('sha1', 'test-secret')
      .update(policyField)
      .digest('base64');
    expect(body.formFields.Signature).toBe(expectedSignature);
  });
});

function validPayload() {
  return {
    ownerType: 'house',
    ownerId: 'house-1',
    tag: 'room',
    contentType: 'image/jpeg',
    contentLength: 12345,
    fileName: 'room.jpg',
  };
}

function setValidOssEnv() {
  process.env.ALI_OSS_BUCKET = 'found-house-test';
  process.env.ALI_OSS_ENDPOINT = 'oss-cn-shenzhen.aliyuncs.com';
  process.env.ALI_OSS_ACCESS_KEY_ID = 'test-key';
  process.env.ALI_OSS_ACCESS_KEY_SECRET = 'test-secret';
  process.env.ALI_OSS_PUBLIC_BASE_URL = 'https://cdn.example.com';
  process.env.ALI_OSS_MAX_UPLOAD_BYTES = `${5 * 1024 * 1024}`;
  process.env.ALI_OSS_UPLOAD_EXPIRES_SECONDS = '900';
}

function clearOssEnv() {
  delete process.env.ALI_OSS_BUCKET;
  delete process.env.ALI_OSS_ENDPOINT;
  delete process.env.ALI_OSS_ACCESS_KEY_ID;
  delete process.env.ALI_OSS_ACCESS_KEY_SECRET;
  delete process.env.ALI_OSS_PUBLIC_BASE_URL;
  delete process.env.ALI_OSS_MAX_UPLOAD_BYTES;
  delete process.env.ALI_OSS_UPLOAD_EXPIRES_SECONDS;
}
