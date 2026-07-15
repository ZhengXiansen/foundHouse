/**
 * 照片直传意图生成（阿里云 OSS PostObject 直传签名）。
 *
 * 安全边界（技术方案「端侧不持有 OSS 密钥」）：
 * - AccessKeySecret 只在后端参与 HMAC-SHA1 签名，绝不出现在响应体中。
 * - 返回给客户端的是受限的 PostObject 表单：policy 用 conditions 锁死
 *   key 前缀、content-length 范围、Content-Type，防止越权写入任意对象。
 * - 客户端拿到 formFields 后直传对象存储，后端不经手照片字节。
 *
 * PostObject 协议参考：客户端按 multipart/form-data 提交，file 字段置末尾，
 * 表单需含 key/policy/OSSAccessKeyId/Signature/success_action_status 等字段。
 */

import { createHmac, randomUUID } from 'node:crypto';
import { AppError, ErrorCode } from '../../infra/errors.js';
import { CONTENT_TYPE_EXTENSIONS, type UploadIntentInput } from './photo.schema.js';

/** OSS 直传所需配置（全部来自环境变量，缺一即视为未配置）。 */
interface OssConfig {
  bucket: string;
  endpoint: string;
  accessKeyId: string;
  accessKeySecret: string;
  publicBaseUrl: string;
  maxUploadBytes: number;
  uploadExpiresSeconds: number;
}

/** 直传意图响应体（与客户端 OssPhotoUploader 期望字段一致）。 */
export interface UploadIntent {
  method: 'POST';
  uploadUrl: string;
  formFields: Record<string, string>;
  publicUrl: string;
  objectKey: string;
  expiresAt: string;
}

const DEFAULT_MAX_UPLOAD_BYTES = 5 * 1024 * 1024;
const DEFAULT_UPLOAD_EXPIRES_SECONDS = 900;

/**
 * 从环境变量读取 OSS 配置。任一必填项缺失返回 null，路由层据此回 OSS_NOT_CONFIGURED，
 * 客户端回退纯本地存储（本地优先原则）。
 */
export function readOssConfig(): OssConfig | null {
  const bucket = process.env.ALI_OSS_BUCKET;
  const endpoint = process.env.ALI_OSS_ENDPOINT;
  const accessKeyId = process.env.ALI_OSS_ACCESS_KEY_ID;
  const accessKeySecret = process.env.ALI_OSS_ACCESS_KEY_SECRET;
  const publicBaseUrl = process.env.ALI_OSS_PUBLIC_BASE_URL;

  if (!bucket || !endpoint || !accessKeyId || !accessKeySecret || !publicBaseUrl) {
    return null;
  }

  const maxUploadBytes = positiveIntEnv(
    process.env.ALI_OSS_MAX_UPLOAD_BYTES,
    DEFAULT_MAX_UPLOAD_BYTES,
  );
  const uploadExpiresSeconds = positiveIntEnv(
    process.env.ALI_OSS_UPLOAD_EXPIRES_SECONDS,
    DEFAULT_UPLOAD_EXPIRES_SECONDS,
  );

  return {
    bucket,
    endpoint,
    accessKeyId,
    accessKeySecret,
    publicBaseUrl,
    maxUploadBytes,
    uploadExpiresSeconds,
  };
}

/**
 * 生成受限 PostObject 直传意图。
 * @param cfg   已校验存在的 OSS 配置。
 * @param input 已经过 zod 校验的入参。
 * @param now   注入当前时间，便于测试；默认 new Date()。
 */
export function buildUploadIntent(
  cfg: OssConfig,
  input: UploadIntentInput,
  now: Date = new Date(),
): UploadIntent {
  // contentLength 超过配置上限直接拒绝，避免签发无效的直传凭证。
  if (input.contentLength > cfg.maxUploadBytes) {
    throw new AppError(
      ErrorCode.VALIDATION_FAILED,
      `照片超过大小上限：${input.contentLength} > ${cfg.maxUploadBytes}`,
    );
  }

  const ext = CONTENT_TYPE_EXTENSIONS[input.contentType];
  const keyPrefix = `photos/${input.ownerType}/${input.ownerId}/`;
  const objectKey = `${keyPrefix}${randomUUID()}.${ext}`;

  const expiration = new Date(now.getTime() + cfg.uploadExpiresSeconds * 1000);
  const expiresAt = expiration.toISOString();

  // PostObject policy：conditions 锁死可写范围，客户端无法越权写入其他对象。
  const policyDoc = {
    expiration: expiresAt,
    conditions: [
      ['starts-with', '$key', keyPrefix],
      ['content-length-range', 1, cfg.maxUploadBytes],
      ['eq', '$Content-Type', input.contentType],
    ],
  };
  const policy = Buffer.from(JSON.stringify(policyDoc), 'utf8').toString('base64');

  // 签名只在服务端用 AccessKeySecret 完成；secret 绝不进入响应体。
  const signature = createHmac('sha1', cfg.accessKeySecret).update(policy).digest('base64');

  const uploadUrl = `https://${cfg.bucket}.${cfg.endpoint}/`;
  const publicUrl = `${stripTrailingSlash(cfg.publicBaseUrl)}/${objectKey}`;

  return {
    method: 'POST',
    uploadUrl,
    formFields: {
      key: objectKey,
      OSSAccessKeyId: cfg.accessKeyId,
      policy,
      Signature: signature,
      success_action_status: '201',
      'Content-Type': input.contentType,
    },
    publicUrl,
    objectKey,
    expiresAt,
  };
}

/** 解析正整数环境变量；非法或缺失时回退默认值。 */
function positiveIntEnv(raw: string | undefined, fallback: number): number {
  if (!raw) return fallback;
  const n = Number(raw);
  return Number.isInteger(n) && n > 0 ? n : fallback;
}

function stripTrailingSlash(url: string): string {
  return url.endsWith('/') ? url.slice(0, -1) : url;
}
