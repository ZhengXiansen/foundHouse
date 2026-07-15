/**
 * map.routes 集成测试：用 fastify.inject() 打请求，map.service 被 mock（不触网）。
 * 覆盖 /health、两个接口的入参校验分支与成功透传分支、未知路由。
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import type { FastifyInstance } from 'fastify';

// 在 import buildApp 之前 mock，确保路由拿到的是 mock 版 service。
const nearbySummaryMock = vi.fn();
const commuteSummaryMock = vi.fn();
vi.mock('./map.service.js', () => ({
  nearbySummary: (...args: unknown[]) => nearbySummaryMock(...args),
  commuteSummary: (...args: unknown[]) => commuteSummaryMock(...args),
}));

// 禁用 Redis/PG，避免测试触碰外部连接。
delete process.env.REDIS_URL;
delete process.env.DATABASE_URL;

const { buildApp } = await import('../../app.js');

let app: FastifyInstance;

beforeEach(async () => {
  nearbySummaryMock.mockReset();
  commuteSummaryMock.mockReset();
  app = await buildApp();
  await app.ready();
});

describe('GET /health', () => {
  it('返回 ok', async () => {
    const res = await app.inject({ method: 'GET', url: '/health' });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ status: 'ok' });
  });
});

describe('未知路由', () => {
  it('返回统一 404 错误体', async () => {
    const res = await app.inject({ method: 'GET', url: '/nope' });
    expect(res.statusCode).toBe(404);
    expect(res.json()).toMatchObject({ code: 'BAD_REQUEST' });
  });
});

describe('POST /api/map/nearby-summary', () => {
  it('合法入参：调用 service 并透传摘要', async () => {
    const summary = {
      provider: 'amap',
      fetchedAt: '2026-07-03T00:00:00.000Z',
      summary: { '300': { metro: 1 } },
      topPois: [],
    };
    nearbySummaryMock.mockResolvedValue(summary);

    const res = await app.inject({
      method: 'POST',
      url: '/api/map/nearby-summary',
      payload: { lat: 22.5431, lng: 114.0579, radii: [300, 800], categories: ['metro', 'bus'] },
    });

    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ provider: 'amap' });
    expect(nearbySummaryMock).toHaveBeenCalledOnce();
    expect(nearbySummaryMock).toHaveBeenCalledWith(22.5431, 114.0579, [300, 800], ['metro', 'bus']);
  });

  it('非法入参：返回 VALIDATION_FAILED，不调用 service', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/api/map/nearby-summary',
      payload: { lat: 999, lng: 114.0579, radii: [], categories: [] },
    });
    expect(res.statusCode).toBe(400);
    expect(res.json()).toMatchObject({ code: 'VALIDATION_FAILED' });
    expect(nearbySummaryMock).not.toHaveBeenCalled();
  });

  it('非法 JSON：收敛为校验失败', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/api/map/nearby-summary',
      headers: { 'content-type': 'application/json' },
      payload: '{bad json',
    });
    expect(res.statusCode).toBe(400);
    expect(res.json()).toMatchObject({ code: 'VALIDATION_FAILED' });
  });
});

describe('POST /api/map/commute', () => {
  it('合法入参：调用 service 并透传结果', async () => {
    commuteSummaryMock.mockResolvedValue({ provider: 'amap', results: [] });

    const res = await app.inject({
      method: 'POST',
      url: '/api/map/commute',
      payload: {
        origin: { lat: 22.5431, lng: 114.0579 },
        destinations: [{ id: 'work', lat: 22.5333, lng: 114.0666 }],
        modes: ['transit'],
      },
    });

    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ provider: 'amap' });
    expect(commuteSummaryMock).toHaveBeenCalledOnce();
  });

  it('modes 省略：默认 transit 传入 service', async () => {
    commuteSummaryMock.mockResolvedValue({ provider: 'amap', results: [] });

    const res = await app.inject({
      method: 'POST',
      url: '/api/map/commute',
      payload: {
        origin: { lat: 22.5431, lng: 114.0579 },
        destinations: [{ id: 'work', lat: 22.5333, lng: 114.0666 }],
      },
    });

    expect(res.statusCode).toBe(200);
    expect(commuteSummaryMock).toHaveBeenCalledOnce();
    const arg = commuteSummaryMock.mock.calls[0]![0] as { modes: string[] };
    expect(arg.modes).toEqual(['transit']);
  });

  it('非法入参：空 destinations 返回 VALIDATION_FAILED', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/api/map/commute',
      payload: {
        origin: { lat: 22.5431, lng: 114.0579 },
        destinations: [],
        modes: ['transit'],
      },
    });
    expect(res.statusCode).toBe(400);
    expect(res.json()).toMatchObject({ code: 'VALIDATION_FAILED' });
    expect(commuteSummaryMock).not.toHaveBeenCalled();
  });

  it('service 抛 AppError：按 code 与状态码收敛', async () => {
    const { AppError, ErrorCode } = await import('../../infra/errors.js');
    commuteSummaryMock.mockRejectedValue(new AppError(ErrorCode.MAP_UPSTREAM_UNAVAILABLE));

    const res = await app.inject({
      method: 'POST',
      url: '/api/map/commute',
      payload: {
        origin: { lat: 22.5431, lng: 114.0579 },
        destinations: [{ id: 'work', lat: 22.5333, lng: 114.0666 }],
        modes: ['transit'],
      },
    });

    expect(res.statusCode).toBe(502);
    expect(res.json()).toMatchObject({ code: 'MAP_UPSTREAM_UNAVAILABLE' });
  });
});
