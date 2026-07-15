import { searchAround, routePlan, type CommuteMode, type CommuteResult } from './amap.client.js';
import { CATEGORY_TO_TYPECODE, type PoiCategory } from './poi-category-map.js';
import { getRedis } from '../../infra/redis.js';
import { logger } from '../../infra/logger.js';

/**
 * 地图业务服务。
 *
 * 隐私边界（技术方案 §7.3）：
 * - 不接收也不存储 userId / houseId，只按经纬度网格缓存。
 * - 缓存 key 用网格化坐标（6 位小数≈0.1m 太精确，这里降到 4 位小数≈11m 网格），
 *   降低精确住址在缓存层的可复原性。
 */

/** 坐标网格化：4 位小数 ≈ 11m，用于缓存 key，避免明文精确坐标散落。 */
function grid(v: number): string {
  return v.toFixed(4);
}

const NEARBY_TTL_SEC = 60 * 60 * 24; // POI 摘要缓存 24h
const COMMUTE_TTL_SEC = 60 * 60 * 6; // 路线缓存 6h

export interface NearbySummary {
  provider: 'amap';
  fetchedAt: string;
  summary: Record<string, Partial<Record<PoiCategory, number>>>;
  topPois: { name: string; category: PoiCategory; distanceMeters: number }[];
}

/**
 * 周边 POI 统计摘要。按 radii × categories 聚合计数，返回每半径分类计数 + Top POI。
 */
export async function nearbySummary(
  lat: number,
  lng: number,
  radii: number[],
  categories: PoiCategory[],
): Promise<NearbySummary> {
  const cacheKey = `nearby:${grid(lat)}:${grid(lng)}:${radii.join(',')}:${categories.sort().join(',')}`;
  const redis = getRedis();
  if (redis) {
    const cached = await redis.get(cacheKey).catch(() => null);
    if (cached) {
      logger.debug({ cacheKey }, 'nearby 命中缓存');
      return JSON.parse(cached) as NearbySummary;
    }
  }

  const maxRadius = Math.max(...radii);
  const typecodes = categories.map((c) => CATEGORY_TO_TYPECODE[c]).filter(Boolean).join('|');

  // 单次取最大半径的 POI，本地按距离分桶到各半径，减少高德调用次数。
  const pois = await searchAround(lat, lng, maxRadius, typecodes);

  const typecodeToCategory = new Map<string, PoiCategory>();
  for (const cat of categories) {
    for (const tc of CATEGORY_TO_TYPECODE[cat].split('|')) {
      typecodeToCategory.set(tc, cat);
    }
  }
  function categoryOf(typecode: string): PoiCategory | null {
    // 高德 typecode 为 6 位，前缀匹配到大类。
    for (const [tc, cat] of typecodeToCategory) {
      if (typecode.startsWith(tc.slice(0, 4))) return cat;
    }
    return null;
  }

  const summary: Record<string, Partial<Record<PoiCategory, number>>> = {};
  for (const r of radii) summary[String(r)] = {};

  const topPois: NearbySummary['topPois'] = [];
  for (const poi of pois) {
    const cat = categoryOf(poi.typecode);
    if (!cat) continue;
    for (const r of radii) {
      if (poi.distanceMeters <= r) {
        const bucket = summary[String(r)];
        if (bucket) bucket[cat] = (bucket[cat] ?? 0) + 1;
      }
    }
    if (topPois.length < 10) {
      topPois.push({ name: poi.name, category: cat, distanceMeters: poi.distanceMeters });
    }
  }

  const result: NearbySummary = {
    provider: 'amap',
    fetchedAt: new Date().toISOString(),
    summary,
    topPois: topPois.sort((a, b) => a.distanceMeters - b.distanceMeters),
  };

  if (redis) {
    await redis.set(cacheKey, JSON.stringify(result), 'EX', NEARBY_TTL_SEC).catch(() => {});
  }
  return result;
}

export interface CommuteRequest {
  origin: { lat: number; lng: number };
  destinations: { id: string; lat: number; lng: number }[];
  modes: CommuteMode[];
  city?: string;
}

export interface CommuteSummary {
  provider: 'amap';
  results: (CommuteResult & { destinationId: string; summary: string })[];
}

function humanSummary(r: CommuteResult): string {
  if (r.mode === 'transit') {
    const walkMin = Math.round(r.walkingMeters / 80); // 约 80m/min 步行
    return `步行 ${walkMin} 分钟 + 公交/地铁 ${r.transferCount} 次换乘`;
  }
  const label: Record<CommuteMode, string> = {
    walking: '步行', bicycling: '骑行', transit: '公交', driving: '驾车',
  };
  return `${label[r.mode]} ${r.durationMinutes} 分钟`;
}

/**
 * 多目的地 × 多模式通勤查询。每个 (dest,mode) 独立缓存。
 */
export async function commuteSummary(req: CommuteRequest): Promise<CommuteSummary> {
  const redis = getRedis();
  const results: CommuteSummary['results'] = [];

  for (const dest of req.destinations) {
    for (const mode of req.modes) {
      const cacheKey = `commute:${grid(req.origin.lat)}:${grid(req.origin.lng)}:${grid(dest.lat)}:${grid(dest.lng)}:${mode}`;
      let r: CommuteResult | null = null;

      if (redis) {
        const cached = await redis.get(cacheKey).catch(() => null);
        if (cached) r = JSON.parse(cached) as CommuteResult;
      }
      if (!r) {
        try {
          r = await routePlan(req.origin, dest, mode, req.city);
          if (redis) await redis.set(cacheKey, JSON.stringify(r), 'EX', COMMUTE_TTL_SEC).catch(() => {});
        } catch (err) {
          // 单个模式无路线不应中断整体，跳过该模式。
          logger.debug({ mode, err: (err as Error).message }, '单模式路线失败，跳过');
          continue;
        }
      }
      results.push({ ...r, destinationId: dest.id, summary: humanSummary(r) });
    }
  }

  return { provider: 'amap', results };
}
