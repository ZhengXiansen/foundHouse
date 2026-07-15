/**
 * 地图接口入参校验（zod）。
 *
 * 契约来源：技术方案 §7.2 API 设计。字段与 map.service 的函数签名保持一致：
 * - nearby-summary: { lat, lng, radii, categories }
 * - commute:        { origin, destinations, modes, city? }
 *
 * 所有外部输入（HTTP body）必须先经此层校验；校验失败由路由层收敛为
 * AppError(VALIDATION_FAILED)，绝不把 zod 原始报错透传给客户端。
 *
 * F5（主要通勤口径）：默认 transit；若无 modes 显式指定，回退到 transit。
 * 具体「无公交回退 driving」的选路降级逻辑在 map.service.commuteSummary 内处理，
 * 此处只负责保证 modes 合法且非空。
 */

import { z } from 'zod';
import { AMAP_TYPECODES, type PoiCategory } from './poi-category-map.js';

/** 经度：中国及全球通用范围。 */
const lng = z.number().gte(-180).lte(180);
/** 纬度。 */
const lat = z.number().gte(-90).lte(90);

/** 支持的 POI 业务类别（与 poi-category-map 单一同源，避免枚举漂移）。 */
const poiCategories = Object.keys(AMAP_TYPECODES) as [PoiCategory, ...PoiCategory[]];
export const poiCategoryEnum = z.enum(poiCategories);

/** 通勤方式（与 amap.client CommuteMode 对齐）。 */
export const commuteModeEnum = z.enum(['walking', 'bicycling', 'transit', 'driving']);

/**
 * POST /api/map/nearby-summary 入参。
 * radii 单位米，正整数，去重后升序；上限 5000m 防止刷大范围拖垮上游配额。
 */
export const nearbySummarySchema = z
  .object({
    lat,
    lng,
    radii: z
      .array(z.number().int().positive().max(5000))
      .min(1)
      .max(5)
      .transform((rs) => [...new Set(rs)].sort((a, b) => a - b)),
    categories: z.array(poiCategoryEnum).min(1).max(poiCategories.length),
  })
  .strict();

export type NearbySummaryInput = z.infer<typeof nearbySummarySchema>;

/**
 * POST /api/map/commute 入参。
 * destinations 每项需带稳定 id（客户端本地 id，非 PII）；modes 非空。
 * modes 省略时默认 ['transit']，对齐 F5 主要通勤口径。
 */
export const commuteSchema = z
  .object({
    origin: z.object({ lat, lng }).strict(),
    destinations: z
      .array(
        z
          .object({
            id: z.string().min(1).max(64),
            lat,
            lng,
          })
          .strict(),
      )
      .min(1)
      .max(10),
    modes: z.array(commuteModeEnum).min(1).max(4).default(['transit']),
    city: z.string().min(1).max(64).optional(),
  })
  .strict();

export type CommuteInput = z.infer<typeof commuteSchema>;
