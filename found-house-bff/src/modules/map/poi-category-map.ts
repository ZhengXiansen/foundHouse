/**
 * POI 分类 → 高德 POI typecode 映射（服务端）。
 * 与客户端 docs/rules/poi-category-map.json 保持同源；此处为 BFF 调用高德周边搜索时使用。
 *
 * 高德 POI typecode 为官方分类编码（https://lbs.amap.com POI 分类编码表）。
 * ⚠️ 下列 typecode 需在接入高德账号后按最新《POI分类编码》核对一次再上线。
 */

export type PoiCategory =
  | 'metro'
  | 'bus'
  | 'supermarket'
  | 'market'
  | 'pharmacy'
  | 'hospital'
  | 'restaurant'
  | 'police';

/**
 * 每个业务类别对应一组高德 typecode（用 | 拼接传给高德 types 参数）。
 * 说明：
 * - metro 地铁站 150500；bus 公交站 150700。
 * - supermarket 综合超市 060400；market 农贸市场 060700。
 * - pharmacy 药店 090601；hospital 综合医院 090100。
 * - restaurant 餐饮 050000（大类）；police 警务室/派出所 130100。
 */
export const AMAP_TYPECODES: Record<PoiCategory, string[]> = {
  metro: ['150500'],
  bus: ['150700'],
  supermarket: ['060400'],
  market: ['060700'],
  pharmacy: ['090601'],
  hospital: ['090100'],
  restaurant: ['050000'],
  police: ['130100'],
};

/** 把业务类别数组转成高德 types 查询串（去重、以 | 连接）。 */
export function toAmapTypes(categories: PoiCategory[]): string {
  const codes = new Set<string>();
  for (const c of categories) {
    for (const code of AMAP_TYPECODES[c] ?? []) codes.add(code);
  }
  return [...codes].join('|');
}

/**
 * 每个业务类别对应的高德 types 查询串（同类 typecode 以 | 连接）。
 * map.service 直接按类别取串，避免重复拼接逻辑。
 */
export const CATEGORY_TO_TYPECODE: Record<PoiCategory, string> = Object.fromEntries(
  (Object.keys(AMAP_TYPECODES) as PoiCategory[]).map((c) => [c, AMAP_TYPECODES[c].join('|')]),
) as Record<PoiCategory, string>;

/** 判断给定字符串是否为受支持的业务类别。 */
export function isPoiCategory(value: string): value is PoiCategory {
  return value in AMAP_TYPECODES;
}
