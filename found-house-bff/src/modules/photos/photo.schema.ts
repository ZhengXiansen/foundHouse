/**
 * 照片直传意图入参校验（zod）。
 *
 * 契约来源：客户端 OssPhotoUploader._fetchUploadIntent 发送的请求体，
 * 以及 photo.routes.test 的约定：
 *   { ownerType, ownerId, tag, contentType, contentLength }
 *
 * 所有外部输入（HTTP body）必须先经此层校验；校验失败由路由层收敛为
 * AppError(VALIDATION_FAILED)，绝不把 zod 原始报错透传给客户端。
 *
 * 枚举与客户端保持单一同源，避免漂移：
 * - ownerType 对齐 lib/data/models/house_models.dart PhotoOwnerType。
 * - tag 对齐 lib/data/local_files/photo_store.dart PhotoTag。
 * - contentType 仅允许受支持的图片类型（与客户端 _contentTypeFor 一致）。
 */

import { z } from 'zod';

/** 照片归属类型（对齐客户端 PhotoOwnerType）。 */
export const photoOwnerTypeEnum = z.enum(['village', 'building', 'house']);

/** 照片标签（对齐客户端 PhotoTag）。 */
export const photoTagEnum = z.enum([
  'sign',
  'building',
  'room',
  'window',
  'bathroom',
  'meter',
  'contract',
  'damage',
]);

/**
 * 受支持的图片 content-type → 对象键后缀。
 * 与客户端 OssPhotoUploader._contentTypeFor 保持一致，防止上传非图片文件。
 */
export const CONTENT_TYPE_EXTENSIONS: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
  'image/heic': 'heic',
};

const contentTypeEnum = z.enum(
  Object.keys(CONTENT_TYPE_EXTENSIONS) as [string, ...string[]],
);

/**
 * POST /api/photos/upload-intent 入参。
 * ownerId 为客户端本地 id（非 PII）；contentLength 上限由环境变量约束，
 * 此处仅保证为正整数，真实上限在 service 层按 ALI_OSS_MAX_UPLOAD_BYTES 判定。
 */
export const uploadIntentSchema = z
  .object({
    ownerType: photoOwnerTypeEnum,
    ownerId: z.string().min(1).max(64),
    tag: photoTagEnum,
    contentType: contentTypeEnum,
    contentLength: z.number().int().positive(),
    // 客户端原始文件名，仅用于可观测；对象键由服务端生成，不采用此值。
    fileName: z.string().min(1).max(255).optional(),
  })
  .strict();

export type UploadIntentInput = z.infer<typeof uploadIntentSchema>;
