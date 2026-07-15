/**
 * 照片直传意图路由（Fastify 插件）。
 *
 * 职责：
 * - 校验 HTTP body（zod schema）→ 失败收敛为 AppError(VALIDATION_FAILED)。
 * - 读取 OSS 配置：未配置时抛 AppError(OSS_NOT_CONFIGURED)，客户端回退纯本地存储。
 * - 生成受限 PostObject 直传意图并返回；AccessKeySecret 绝不外泄。
 *
 * 安全提醒：本端点签发的是可直传对象存储的临时凭证，上线前必须置于鉴权之后
 * （匿名设备 token 或用户会话），否则任何人都能获取直传能力。当前仅做入参校验。
 */

import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { AppError, ErrorCode } from '../../infra/errors.js';
import { uploadIntentSchema } from './photo.schema.js';
import { readOssConfig, buildUploadIntent } from './photo.service.js';

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

export async function photoRoutes(app: FastifyInstance): Promise<void> {
  app.post('/api/photos/upload-intent', async (req) => {
    const cfg = readOssConfig();
    if (!cfg) {
      throw new AppError(ErrorCode.OSS_NOT_CONFIGURED);
    }
    const input = parseBody(uploadIntentSchema, req.body);
    req.log.debug(
      { ownerType: input.ownerType, tag: input.tag, contentType: input.contentType },
      'photo upload-intent',
    );
    return buildUploadIntent(cfg, input);
  });
}
