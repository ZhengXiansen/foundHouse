/**
 * BFF 应用入口。
 *
 * 装配顺序（技术方案 §9）：
 * 1. logger（pino + PII 脱敏，见 infra/logger）
 * 2. rate-limit（匿名设备/IP 分桶，见 infra/rate-limit）
 * 3. 全局 error handler：把 AppError 映射为 { code, message } + 对应 HTTP 状态；
 *    非 AppError 一律收敛为 INTERNAL_ERROR，绝不外泄堆栈/原始输入。
 * 4. 路由：GET /health、map.routes。
 *
 * 导出 buildApp() 工厂供测试用 fastify.inject()；直接运行时才 listen。
 */

import { pathToFileURL } from 'node:url';
import Fastify, { type FastifyBaseLogger, type FastifyInstance } from 'fastify';
import { logger } from './infra/logger.js';
import { registerRateLimit } from './infra/rate-limit.js';
import { AppError, ErrorCode, ERROR_META } from './infra/errors.js';
import { mapRoutes } from './modules/map/map.routes.js';
import { photoRoutes } from './modules/photos/photo.routes.js';
import { closeRedis } from './infra/redis.js';
import { closePool } from './infra/db.js';

/**
 * 构建并装配 Fastify 实例。
 * 注意：把 pino 实例断言为 FastifyBaseLogger，避免 Fastify 按具体 Logger 收窄
 * logger 泛型，导致与 registerRateLimit/mapRoutes 期望的默认实例类型不兼容。
 */
export async function buildApp(): Promise<FastifyInstance> {
  const app = Fastify({
    // 复用统一 pino 实例，保证 PII 脱敏路径在请求日志同样生效。
    loggerInstance: logger as FastifyBaseLogger,
    // 生成请求 id 便于排障；不含任何 PII。
    genReqId: () => crypto.randomUUID(),
    // body 上限，防止超大请求；地图入参很小，1MB 足够宽松。
    bodyLimit: 1 * 1024 * 1024,
  });

  await registerRateLimit(app);

  /**
   * 全局错误处理：单一出口，保证对外错误体形状恒为 { code, message }。
   * - AppError：按其 code/httpStatus 输出，details 仅进日志不外泄。
   * - 其他（含 fastify 内建 400/415 等）：收敛为 INTERNAL_ERROR，仅日志留痕。
   */
  app.setErrorHandler((err, req, reply) => {
    if (err instanceof AppError) {
      if (err.httpStatus >= 500) {
        req.log.error({ code: err.code, details: err.details }, err.message);
      } else {
        req.log.warn({ code: err.code, details: err.details }, err.message);
      }
      return reply.code(err.httpStatus).send({ code: err.code, message: err.message });
    }

    // 限流插件抛出的 429 带有 statusCode，转成统一错误码。
    if ((err as { statusCode?: number }).statusCode === 429) {
      const meta = ERROR_META[ErrorCode.MAP_RATE_LIMITED];
      return reply.code(meta.httpStatus).send({ code: ErrorCode.MAP_RATE_LIMITED, message: meta.message });
    }

    // fastify 内建的请求体解析错误（如非法 JSON）归为 400 校验失败。
    if ((err as { statusCode?: number }).statusCode === 400) {
      const meta = ERROR_META[ErrorCode.VALIDATION_FAILED];
      req.log.warn({ err: (err as Error).message }, '请求体解析失败');
      return reply
        .code(meta.httpStatus)
        .send({ code: ErrorCode.VALIDATION_FAILED, message: meta.message });
    }

    // 兜底：不外泄任何内部细节。
    req.log.error({ err }, '未处理异常');
    const meta = ERROR_META[ErrorCode.INTERNAL_ERROR];
    return reply
      .code(meta.httpStatus)
      .send({ code: ErrorCode.INTERNAL_ERROR, message: meta.message });
  });

  // 找不到路由也走统一错误体。
  app.setNotFoundHandler((_req, reply) => {
    const meta = ERROR_META[ErrorCode.BAD_REQUEST];
    return reply.code(404).send({ code: ErrorCode.BAD_REQUEST, message: meta.message });
  });

  app.get('/health', async () => ({ status: 'ok', ts: new Date().toISOString() }));

  await app.register(mapRoutes);
  await app.register(photoRoutes);

  return app;
}

/** 是否为直接运行入口（而非被测试/其他模块 import）。跨平台用 pathToFileURL 归一化。 */
function isMainModule(): boolean {
  const entry = process.argv[1];
  if (!entry) return false;
  return import.meta.url === pathToFileURL(entry).href;
}

async function main(): Promise<void> {
  const app = await buildApp();
  const port = Number(process.env.PORT ?? 3000);
  const host = process.env.HOST ?? '0.0.0.0';

  // 进程退出时优雅关闭外部连接，避免泄漏。
  const shutdown = async (signal: string): Promise<void> => {
    app.log.info({ signal }, '收到退出信号，开始优雅关闭');
    await app.close();
    await closeRedis();
    await closePool();
    process.exit(0);
  };
  process.on('SIGINT', () => void shutdown('SIGINT'));
  process.on('SIGTERM', () => void shutdown('SIGTERM'));

  try {
    await app.listen({ port, host });
  } catch (err) {
    app.log.error({ err }, '启动失败');
    process.exit(1);
  }
}

if (isMainModule()) {
  void main();
}
