/**
 * rate-limit 集成测试：用真实 Fastify + @fastify/rate-limit，mock 外部 map service/Redis。
 * 目标是验证业务行为：地图接口 429 错误码、全局兜底限流、多实例共享计数。
 */

import type { FastifyInstance } from 'fastify';
import { afterEach, describe, expect, it, vi } from 'vitest';

type RedisRateLimitCallback = (err: Error | null, result?: [number, number]) => void;

interface FakeRateLimitRedis {
  readonly touchedKeys: string[];
  rateLimit(
    key: string,
    timeWindow: number,
    max: number,
    continueExceeding: boolean,
    exponentialBackoff: boolean,
    cb: RedisRateLimitCallback,
  ): void;
}

const originalRateLimitPerMinute = process.env.RATE_LIMIT_PER_MINUTE;
const originalGlobalRateLimitPerMinute = process.env.RATE_LIMIT_GLOBAL_PER_MINUTE;
const originalPhotoRateLimitPerMinute = process.env.RATE_LIMIT_PHOTO_PER_MINUTE;
const originalRedisUrl = process.env.REDIS_URL;
const originalDatabaseUrl = process.env.DATABASE_URL;

// 照片限流用例需要 OSS 配置齐全，才能让首个请求走到 200 而非 OSS_NOT_CONFIGURED。
const OSS_ENV_KEYS = [
  'ALI_OSS_BUCKET',
  'ALI_OSS_ENDPOINT',
  'ALI_OSS_ACCESS_KEY_ID',
  'ALI_OSS_ACCESS_KEY_SECRET',
  'ALI_OSS_PUBLIC_BASE_URL',
] as const;
const originalOssEnv = new Map(OSS_ENV_KEYS.map((k) => [k, process.env[k]]));

let apps: FastifyInstance[] = [];

afterEach(async () => {
  await Promise.all(apps.map((app) => app.close()));
  apps = [];

  restoreEnv('RATE_LIMIT_PER_MINUTE', originalRateLimitPerMinute);
  restoreEnv('RATE_LIMIT_GLOBAL_PER_MINUTE', originalGlobalRateLimitPerMinute);
  restoreEnv('RATE_LIMIT_PHOTO_PER_MINUTE', originalPhotoRateLimitPerMinute);
  restoreEnv('REDIS_URL', originalRedisUrl);
  restoreEnv('DATABASE_URL', originalDatabaseUrl);
  for (const [k, v] of originalOssEnv) restoreEnv(k, v);

  vi.resetModules();
  vi.restoreAllMocks();
  vi.doUnmock('../modules/map/map.service.js');
  vi.doUnmock('./redis.js');
});

describe('registerRateLimit', () => {
  it('地图接口超过匿名设备阈值时返回 MAP_RATE_LIMITED', async () => {
    const buildApp = await importBuildApp({ perDevice: 1, global: 100 });
    const app = await createReadyApp(buildApp);

    const first = await requestNearbySummary(app, 'device-rate-limit');
    const second = await requestNearbySummary(app, 'device-rate-limit');

    expect(first.statusCode).toBe(200);
    expect(second.statusCode).toBe(429);
    expect(second.json()).toMatchObject({ code: 'MAP_RATE_LIMITED' });
  });

  it('全局分钟阈值限制不同匿名设备的地图请求总量', async () => {
    const buildApp = await importBuildApp({ perDevice: 10, global: 1 });
    const app = await createReadyApp(buildApp);

    const first = await requestNearbySummary(app, 'device-global-a');
    const second = await requestNearbySummary(app, 'device-global-b');

    expect(first.statusCode).toBe(200);
    expect(second.statusCode).toBe(429);
    expect(second.json()).toMatchObject({ code: 'MAP_RATE_LIMITED' });
  });

  it('配置 Redis 时在多个应用实例之间共享地图限流计数', async () => {
    const redis = createFakeRateLimitRedis();
    const buildApp = await importBuildApp({ perDevice: 1, global: 100, redis });
    const firstApp = await createReadyApp(buildApp);
    const secondApp = await createReadyApp(buildApp);

    const first = await requestNearbySummary(firstApp, 'device-shared-redis');
    const second = await requestNearbySummary(secondApp, 'device-shared-redis');

    expect(first.statusCode).toBe(200);
    expect(second.statusCode).toBe(429);
    expect(second.json()).toMatchObject({ code: 'MAP_RATE_LIMITED' });
    expect(redis.touchedKeys.some((key) => key.startsWith('found-house-map-rate-limit:'))).toBe(true);
  });

  it('照片直传意图超过设备阈值时返回 RATE_LIMITED', async () => {
    setValidOssEnv();
    const buildApp = await importBuildApp({ perDevice: 100, global: 100, photoPerDevice: 1 });
    const app = await createReadyApp(buildApp);

    const first = await requestUploadIntent(app, 'device-photo-limit');
    const second = await requestUploadIntent(app, 'device-photo-limit');

    expect(first.statusCode).toBe(200);
    expect(second.statusCode).toBe(429);
    expect(second.json()).toMatchObject({ code: 'RATE_LIMITED' });
  });

  it('照片限流与地图限流分桶隔离，互不挤占配额', async () => {
    setValidOssEnv();
    const buildApp = await importBuildApp({ perDevice: 1, global: 100, photoPerDevice: 1 });
    const app = await createReadyApp(buildApp);

    // 先打满地图配额，照片首个请求仍应放行（独立分桶）。
    const map = await requestNearbySummary(app, 'device-mixed');
    const photo = await requestUploadIntent(app, 'device-mixed');

    expect(map.statusCode).toBe(200);
    expect(photo.statusCode).toBe(200);
  });
});

function restoreEnv(name: string, value: string | undefined): void {
  if (value === undefined) {
    delete process.env[name];
  } else {
    process.env[name] = value;
  }
}

/** 配齐 OSS 环境，使照片直传意图端点能返回 200（否则先命中 OSS_NOT_CONFIGURED）。 */
function setValidOssEnv(): void {
  process.env.ALI_OSS_BUCKET = 'found-house-test';
  process.env.ALI_OSS_ENDPOINT = 'oss-cn-shenzhen.aliyuncs.com';
  process.env.ALI_OSS_ACCESS_KEY_ID = 'test-key';
  process.env.ALI_OSS_ACCESS_KEY_SECRET = 'test-secret';
  process.env.ALI_OSS_PUBLIC_BASE_URL = 'https://cdn.example.com';
}

async function importBuildApp(options: {
  perDevice: number;
  global: number;
  photoPerDevice?: number;
  redis?: FakeRateLimitRedis;
}): Promise<() => Promise<FastifyInstance>> {
  vi.resetModules();
  process.env.RATE_LIMIT_PER_MINUTE = String(options.perDevice);
  process.env.RATE_LIMIT_GLOBAL_PER_MINUTE = String(options.global);
  if (options.photoPerDevice !== undefined) {
    process.env.RATE_LIMIT_PHOTO_PER_MINUTE = String(options.photoPerDevice);
  } else {
    delete process.env.RATE_LIMIT_PHOTO_PER_MINUTE;
  }
  delete process.env.DATABASE_URL;

  vi.doMock('../modules/map/map.service.js', () => ({
    nearbySummary: vi.fn().mockResolvedValue({
      provider: 'amap',
      fetchedAt: '2026-07-03T00:00:00.000Z',
      summary: { '300': { metro: 1 } },
      topPois: [],
    }),
    commuteSummary: vi.fn().mockResolvedValue({ provider: 'amap', results: [] }),
  }));

  if (options.redis) {
    process.env.REDIS_URL = 'redis://rate-limit-test';
    vi.doMock('./redis.js', () => ({
      getRedis: () => options.redis,
      closeRedis: vi.fn(),
    }));
  } else {
    delete process.env.REDIS_URL;
  }

  const { buildApp } = await import('../app.js');
  return buildApp;
}

async function createReadyApp(buildApp: () => Promise<FastifyInstance>): Promise<FastifyInstance> {
  const app = await buildApp();
  await app.ready();
  apps.push(app);
  return app;
}

async function requestNearbySummary(app: FastifyInstance, deviceId: string) {
  return app.inject({
    method: 'POST',
    url: '/api/map/nearby-summary',
    headers: { 'x-anon-device': deviceId },
    payload: {
      lat: 22.5431,
      lng: 114.0579,
      radii: [300],
      categories: ['metro'],
    },
  });
}

async function requestUploadIntent(app: FastifyInstance, deviceId: string) {
  return app.inject({
    method: 'POST',
    url: '/api/photos/upload-intent',
    headers: { 'x-anon-device': deviceId },
    payload: {
      ownerType: 'house',
      ownerId: 'house-1',
      tag: 'room',
      contentType: 'image/jpeg',
      contentLength: 12345,
    },
  });
}

function createFakeRateLimitRedis(): FakeRateLimitRedis {
  const counters = new Map<string, { current: number; expiresAt: number }>();
  const touchedKeys: string[] = [];

  return {
    touchedKeys,
    rateLimit(
      key: string,
      timeWindow: number,
      max: number,
      continueExceeding: boolean,
      _exponentialBackoff: boolean,
      cb: RedisRateLimitCallback,
    ): void {
      const now = Date.now();
      let counter = counters.get(key);
      if (!counter || counter.expiresAt <= now) {
        counter = { current: 0, expiresAt: now + timeWindow };
        counters.set(key, counter);
      }

      counter.current += 1;
      if (counter.current === 1 || (continueExceeding && counter.current > max)) {
        counter.expiresAt = now + timeWindow;
      }

      touchedKeys.push(key);
      cb(null, [counter.current, Math.max(1, counter.expiresAt - now)]);
    },
  };
}
