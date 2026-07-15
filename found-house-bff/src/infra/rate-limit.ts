import type { FastifyInstance, FastifyRequest } from 'fastify';
import rateLimit from '@fastify/rate-limit';
import { AppError, ErrorCode } from './errors.js';
import { getRedis } from './redis.js';

/**
 * 限流配置（技术方案 §9）。
 *
 * 目标：
 * 1. 防刷、守住高德 WebService 日配额。
 * 2. 无用户 ID（BFF 不存身份）——按「匿名设备 token」限流。
 * 3. 照片直传意图端点无鉴权（BFF 不存身份），靠限流把「无限制签发直传凭证」
 *    的滥用面收敛到可接受范围；配合 policy 短时效/大小/前缀约束形成纵深防护。
 *
 * 匿名设备标识：客户端在请求头携带 `x-anon-device`（首启生成的随机 UUID，
 * 不含任何 PII，仅用于限流分桶）。缺失时回退到 IP。
 */

/** 每设备每分钟允许的地图相关请求数。 */
export const PER_DEVICE_PER_MINUTE = Number(process.env.RATE_LIMIT_PER_MINUTE ?? 30);

/** 全局每分钟上限（对齐高德日配额的分钟级保护，粗粒度兜底）。 */
export const GLOBAL_PER_MINUTE = Number(process.env.RATE_LIMIT_GLOBAL_PER_MINUTE ?? 600);

/** 每设备每分钟允许的照片直传意图请求数（一次拍照对应一次签发，阈值可低于地图）。 */
export const PHOTO_PER_DEVICE_PER_MINUTE = Number(
  process.env.RATE_LIMIT_PHOTO_PER_MINUTE ?? 20,
);

const RATE_LIMIT_WINDOW = '1 minute';
const MAP_RATE_LIMIT_NAMESPACE = 'found-house-map-rate-limit:';
const MAP_RATE_LIMITED_MESSAGE = '请求过于频繁，请稍后再试。可先离线记录，地图结果稍后补全。';

/** 从请求提取匿名限流键：优先匿名设备 token，回退 IP。 */
function anonKey(req: FastifyRequest): string {
  const dev = req.headers['x-anon-device'];
  if (typeof dev === 'string' && dev.length >= 8 && dev.length <= 64) {
    return `dev:${dev}`;
  }
  return `ip:${req.ip}`;
}

function mapGlobalKey(): string {
  return 'map:global';
}

/** 照片限流键与地图分桶隔离，避免相互挤占配额。 */
function photoAnonKey(req: FastifyRequest): string {
  return `photo:${anonKey(req)}`;
}

function isMapRequest(req: FastifyRequest): boolean {
  return req.url.startsWith('/api/map/');
}

function isPhotoIntentRequest(req: FastifyRequest): boolean {
  return req.url.startsWith('/api/photos/upload-intent');
}

function mapRateLimitError(): AppError {
  return new AppError(ErrorCode.MAP_RATE_LIMITED, MAP_RATE_LIMITED_MESSAGE);
}

/** 照片端点用通用 429，客户端 OssPhotoUploader 遇非 2xx 会静默回退本地存储。 */
function photoRateLimitError(): AppError {
  return new AppError(ErrorCode.RATE_LIMITED);
}

async function throwIfExceeded(
  result: Awaited<ReturnType<ReturnType<FastifyInstance['createRateLimit']>>>,
  errorFactory: () => AppError,
): Promise<void> {
  if (!result.isAllowed && (result.isExceeded || result.isBanned)) {
    throw errorFactory();
  }
}

export async function registerRateLimit(app: FastifyInstance): Promise<void> {
  const redis = getRedis();

  await app.register(rateLimit, {
    global: false,
    redis: redis ?? undefined,
    nameSpace: MAP_RATE_LIMIT_NAMESPACE,
    skipOnError: true,
    max: PER_DEVICE_PER_MINUTE,
    timeWindow: RATE_LIMIT_WINDOW,
    keyGenerator: anonKey,
    addHeadersOnExceeding: { 'x-ratelimit-limit': true, 'x-ratelimit-remaining': true },
    errorResponseBuilder: () => mapRateLimitError(),
  });

  const globalLimiter = app.createRateLimit({
    max: GLOBAL_PER_MINUTE,
    timeWindow: RATE_LIMIT_WINDOW,
    keyGenerator: mapGlobalKey,
  });
  const perDeviceLimiter = app.createRateLimit({
    max: PER_DEVICE_PER_MINUTE,
    timeWindow: RATE_LIMIT_WINDOW,
    keyGenerator: anonKey,
  });
  const photoLimiter = app.createRateLimit({
    max: PHOTO_PER_DEVICE_PER_MINUTE,
    timeWindow: RATE_LIMIT_WINDOW,
    keyGenerator: photoAnonKey,
  });

  app.addHook('onRequest', async (req) => {
    if (isMapRequest(req)) {
      await throwIfExceeded(await globalLimiter(req), mapRateLimitError);
      await throwIfExceeded(await perDeviceLimiter(req), mapRateLimitError);
      return;
    }

    if (isPhotoIntentRequest(req)) {
      await throwIfExceeded(await photoLimiter(req), photoRateLimitError);
    }
  });
}
