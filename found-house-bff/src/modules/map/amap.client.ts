import { request } from 'undici';
import { logger } from '../../infra/logger.js';
import { AppError, ErrorCode } from '../../infra/errors.js';

/**
 * 高德 WebService 客户端。
 *
 * 职责边界（技术方案 §4.3 / §7）：
 * - 仅在服务端持有 WebService Key（AMAP_WEBSERVICE_KEY），绝不下发给客户端。
 * - 只封装「周边搜索」与「路径规划」两类能力，返回业务所需字段，不透传完整第三方响应。
 * - 第三方错误统一转为业务可读 AppError（见 errors.ts），由上层转成脱敏错误响应。
 */

const AMAP_BASE = 'https://restapi.amap.com';

function getKey(): string {
  const key = process.env.AMAP_WEBSERVICE_KEY;
  if (!key) {
    // 配置缺失属于部署问题，记录但不泄露任何密钥内容。
    logger.error('AMAP_WEBSERVICE_KEY 未配置');
    throw new AppError(ErrorCode.MAP_UPSTREAM_UNAVAILABLE, '地图服务暂不可用，可先离线记录');
  }
  return key;
}

/** 高德 status!=='1' 或 infocode!=='10000' 视为上游失败。 */
function assertAmapOk(body: Record<string, unknown>, endpoint: string): void {
  const status = String(body.status ?? '');
  const infocode = String(body.infocode ?? '');
  if (status !== '1' || infocode !== '10000') {
    // 只记录 infocode 与 endpoint，不记录坐标等潜在敏感入参。
    logger.warn({ endpoint, infocode, amapStatus: status }, '高德上游返回非成功状态');
    throw new AppError(
      ErrorCode.MAP_UPSTREAM_UNAVAILABLE,
      '地图服务暂不可用，可稍后重试',
      { infocode },
    );
  }
}

async function amapGet(path: string, params: Record<string, string>): Promise<Record<string, unknown>> {
  const query = new URLSearchParams({ ...params, key: getKey() }).toString();
  const url = `${AMAP_BASE}${path}?${query}`;
  try {
    const res = await request(url, { method: 'GET', headersTimeout: 5000, bodyTimeout: 5000 });
    if (res.statusCode < 200 || res.statusCode >= 300) {
      logger.warn({ path, statusCode: res.statusCode }, '高德 HTTP 非 2xx');
      throw new AppError(ErrorCode.MAP_UPSTREAM_UNAVAILABLE, '地图服务暂不可用，可稍后重试');
    }
    const body = (await res.body.json()) as Record<string, unknown>;
    assertAmapOk(body, path);
    return body;
  } catch (err) {
    if (err instanceof AppError) throw err;
    // 网络层错误（超时/DNS/连接）统一收敛，不外泄堆栈。
    logger.warn({ path, err: (err as Error).message }, '高德请求网络错误');
    throw new AppError(ErrorCode.MAP_UPSTREAM_UNAVAILABLE, '地图服务暂不可用，可先离线记录');
  }
}

export interface AmapPoi {
  name: string;
  typecode: string;
  location: string; // "lng,lat"
  distanceMeters: number;
}

/**
 * 周边搜索（高德 place/around）。
 * @param types 高德 typecode，多个用 '|' 分隔。
 */
export async function searchAround(
  lat: number,
  lng: number,
  radiusMeters: number,
  types: string,
): Promise<AmapPoi[]> {
  const body = await amapGet('/v3/place/around', {
    location: `${lng},${lat}`,
    radius: String(radiusMeters),
    types,
    offset: '25',
    page: '1',
    extensions: 'base',
  });
  const pois = Array.isArray(body.pois) ? (body.pois as Record<string, unknown>[]) : [];
  return pois.map((p) => ({
    name: String(p.name ?? ''),
    typecode: String(p.typecode ?? ''),
    location: String(p.location ?? ''),
    distanceMeters: Number(p.distance ?? 0),
  }));
}

export type CommuteMode = 'walking' | 'bicycling' | 'transit' | 'driving';

export interface CommuteResult {
  mode: CommuteMode;
  durationMinutes: number;
  walkingMeters: number;
  transferCount: number;
}

const ROUTE_PATH: Record<CommuteMode, string> = {
  walking: '/v3/direction/walking',
  bicycling: '/v4/direction/bicycling',
  transit: '/v3/direction/transit/integrated',
  driving: '/v3/direction/driving',
};

/**
 * 路径规划。transit 需要 city 参数；MVP 先取起点城市（由调用方传入或后续用逆地理补全）。
 * 返回统一的时长/步行距离/换乘次数摘要，不透传高德分段明细。
 */
export async function routePlan(
  origin: { lat: number; lng: number },
  dest: { lat: number; lng: number },
  mode: CommuteMode,
  city?: string,
): Promise<CommuteResult> {
  const params: Record<string, string> = {
    origin: `${origin.lng},${origin.lat}`,
    destination: `${dest.lng},${dest.lat}`,
  };
  if (mode === 'transit') {
    // transit 起点城市必填；缺失时上游会报错，收敛为可读错误。
    params.city = city ?? '';
  }
  const body = await amapGet(ROUTE_PATH[mode], params);

  // 不同模式响应结构不同，统一提取最短方案摘要。
  const route = (body.route ?? {}) as Record<string, unknown>;

  if (mode === 'transit') {
    const transits = Array.isArray(route.transits) ? (route.transits as Record<string, unknown>[]) : [];
    if (transits.length === 0) {
      throw new AppError(ErrorCode.MAP_NO_ROUTE, '未找到公交方案');
    }
    const best = transits[0];
    if (!best) throw new AppError(ErrorCode.MAP_NO_ROUTE, '未找到公交方案');
    const durationSec = Number(best.duration ?? 0);
    const walkingMeters = Number(best.walking_distance ?? 0);
    const segments = Array.isArray(best.segments) ? best.segments : [];
    // 换乘次数 ≈ 含 bus 段数 - 1（保守估计，>=0）。
    const busSegs = segments.filter((s) => (s as Record<string, unknown>).bus).length;
    return {
      mode,
      durationMinutes: Math.round(durationSec / 60),
      walkingMeters,
      transferCount: Math.max(0, busSegs - 1),
    };
  }

  // walking / driving / bicycling：取 paths[0] 或 data。
  const paths = Array.isArray(route.paths) ? (route.paths as Record<string, unknown>[]) : [];
  if (mode === 'bicycling') {
    const data = (body.data ?? {}) as Record<string, unknown>;
    const bikePaths = Array.isArray(data.paths) ? (data.paths as Record<string, unknown>[]) : [];
    if (bikePaths.length === 0) throw new AppError(ErrorCode.MAP_NO_ROUTE, '未找到骑行方案');
    const p = bikePaths[0];
    if (!p) throw new AppError(ErrorCode.MAP_NO_ROUTE, '未找到骑行方案');
    return {
      mode,
      durationMinutes: Math.round(Number(p.duration ?? 0) / 60),
      walkingMeters: 0,
      transferCount: 0,
    };
  }
  if (paths.length === 0) throw new AppError(ErrorCode.MAP_NO_ROUTE, '未找到路线方案');
  const p = paths[0];
  if (!p) throw new AppError(ErrorCode.MAP_NO_ROUTE, '未找到路线方案');
  return {
    mode,
    durationMinutes: Math.round(Number(p.duration ?? 0) / 60),
    walkingMeters: mode === 'walking' ? Number(p.distance ?? 0) : 0,
    transferCount: 0,
  };
}
