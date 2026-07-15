/**
 * map.schema 单元测试：合法/非法入参分支。
 * 只测校验行为，不触网。
 */

import { describe, it, expect } from 'vitest';
import { nearbySummarySchema, commuteSchema } from './map.schema.js';

describe('nearbySummarySchema', () => {
  it('接受合法入参并对 radii 去重升序', () => {
    const r = nearbySummarySchema.safeParse({
      lat: 22.5431,
      lng: 114.0579,
      radii: [800, 300, 800, 1500],
      categories: ['metro', 'bus'],
    });
    expect(r.success).toBe(true);
    if (r.success) {
      expect(r.data.radii).toEqual([300, 800, 1500]);
      expect(r.data.categories).toEqual(['metro', 'bus']);
    }
  });

  it('拒绝超出经纬度范围', () => {
    const r = nearbySummarySchema.safeParse({
      lat: 200,
      lng: 114.0579,
      radii: [300],
      categories: ['metro'],
    });
    expect(r.success).toBe(false);
  });

  it('拒绝空 categories', () => {
    const r = nearbySummarySchema.safeParse({
      lat: 22.5,
      lng: 114.0,
      radii: [300],
      categories: [],
    });
    expect(r.success).toBe(false);
  });

  it('拒绝非法 category 枚举值', () => {
    const r = nearbySummarySchema.safeParse({
      lat: 22.5,
      lng: 114.0,
      radii: [300],
      categories: ['casino'],
    });
    expect(r.success).toBe(false);
  });

  it('拒绝超大半径', () => {
    const r = nearbySummarySchema.safeParse({
      lat: 22.5,
      lng: 114.0,
      radii: [99999],
      categories: ['metro'],
    });
    expect(r.success).toBe(false);
  });

  it('拒绝未知字段（strict）', () => {
    const r = nearbySummarySchema.safeParse({
      lat: 22.5,
      lng: 114.0,
      radii: [300],
      categories: ['metro'],
      houseId: 'x-should-not-be-here',
    });
    expect(r.success).toBe(false);
  });
});

describe('commuteSchema', () => {
  it('接受合法入参', () => {
    const r = commuteSchema.safeParse({
      origin: { lat: 22.5431, lng: 114.0579 },
      destinations: [{ id: 'work', lat: 22.5333, lng: 114.0666 }],
      modes: ['transit', 'walking'],
    });
    expect(r.success).toBe(true);
  });

  it('modes 省略时默认 transit（F5 主要通勤口径）', () => {
    const r = commuteSchema.safeParse({
      origin: { lat: 22.5431, lng: 114.0579 },
      destinations: [{ id: 'work', lat: 22.5333, lng: 114.0666 }],
    });
    expect(r.success).toBe(true);
    if (r.success) expect(r.data.modes).toEqual(['transit']);
  });

  it('拒绝空 destinations', () => {
    const r = commuteSchema.safeParse({
      origin: { lat: 22.5431, lng: 114.0579 },
      destinations: [],
      modes: ['transit'],
    });
    expect(r.success).toBe(false);
  });

  it('拒绝缺失 destination id', () => {
    const r = commuteSchema.safeParse({
      origin: { lat: 22.5431, lng: 114.0579 },
      destinations: [{ lat: 22.5333, lng: 114.0666 }],
      modes: ['transit'],
    });
    expect(r.success).toBe(false);
  });

  it('拒绝非法通勤方式', () => {
    const r = commuteSchema.safeParse({
      origin: { lat: 22.5431, lng: 114.0579 },
      destinations: [{ id: 'work', lat: 22.5333, lng: 114.0666 }],
      modes: ['teleport'],
    });
    expect(r.success).toBe(false);
  });
});
