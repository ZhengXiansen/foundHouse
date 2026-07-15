/**
 * 地图代理路由（Fastify 插件）。
 *
 * 职责：
 * - 校验 HTTP body（zod schema）→ 失败收敛为 AppError(VALIDATION_FAILED)。
 * - 调用 map.service，返回业务摘要（不透传高德原始响应）。
 * - 读取匿名设备 token（x-anon-device）仅用于限流分桶，不落库、不返回。
 *
 * 不在此处做限流本身（由 @fastify/rate-limit 全局插件承担，见 infra/rate-limit）。
 */

import type { FastifyInstance, FastifyRequest } from 'fastify';
import { z } from 'zod';
import { AppError, ErrorCode } from '../../infra/errors.js';
import { nearbySummarySchema, commuteSchema } from './map.schema.js';
import { nearbySummary, commuteSummary } from './map.service.js';

/**
 * 用 zod schema 解析请求体；失败统一转成 AppError(VALIDATION_FAILED)，
 * 只暴露字段路径级别的可读信息，不泄露原始输入值。
 */
function parseBody<S extends z.ZodTypeAny>(schema: S, body: unknown): z.infer<S> {
  const result = schema.safeParse(body);
  if (!result.success) {
    const fields = result.error.issues.map((i) => i.path.join('.') || '(root)');
    throw new AppError(
      ErrorCode.VALIDATION_FAILED,
      `请求参数校验失败: ${[...new Set(fields)].join(', ')}`,
    );
  }
  return result.data;
}

/**
 * 读取匿名设备标识，仅供可观测/限流上下文使用；不做鉴权、不落库。
 * 缺失或格式非法时返回 undefined（限流插件会回退到 IP）。
 */
function anonDevice(req: FastifyRequest): string | undefined {
  const dev = req.headers['x-anon-device'];
  if (typeof dev === 'string' && dev.length >= 8 && dev.length <= 64) return dev;
  return undefined;
}

export async function mapRoutes(app: FastifyInstance): Promise<void> {
  app.post('/api/map/nearby-summary', async (req) => {
    const input = parseBody(nearbySummarySchema, req.body);
    req.log.debug({ anonDevice: anonDevice(req), radii: input.radii }, 'nearby-summary');
    return nearbySummary(input.lat, input.lng, input.radii, input.categories);
  });

  app.post('/api/map/commute', async (req) => {
    const input = parseBody(commuteSchema, req.body);
    req.log.debug(
      { anonDevice: anonDevice(req), destCount: input.destinations.length, modes: input.modes },
      'commute',
    );
    return commuteSummary({
      origin: input.origin,
      destinations: input.destinations,
      modes: input.modes,
      city: input.city,
    });
  });
}
