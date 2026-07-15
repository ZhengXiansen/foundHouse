// Redis 连接（可选）。用于 POI/路线短期缓存，未配置时优雅降级为无缓存。
// 技术方案 §4.3：Cache 可选；§7 地图缓存按经纬度网格做键。
import Redis from 'ioredis';
import { logger } from './logger.js';

let client: Redis | null = null;

/**
 * 获取 Redis 客户端。未配置 REDIS_URL 时返回 null，调用方须按“无缓存”路径工作。
 * 缓存是优化项，不可成为地图能力的硬依赖。
 */
export function getRedis(): Redis | null {
  if (client) return client;

  const url = process.env.REDIS_URL;
  if (!url) {
    logger.warn('REDIS_URL 未配置，POI/路线缓存已禁用（降级为直连高德）');
    return null;
  }

  client = new Redis(url, {
    // 连接失败不阻塞进程：地图缓存失效应静默降级，而非拖垮请求。
    lazyConnect: false,
    maxRetriesPerRequest: 2,
    enableOfflineQueue: false,
  });

  client.on('error', (err) => {
    // 缓存故障降级为 warn，不上升为请求错误。
    logger.warn({ err: err.message }, 'Redis 连接异常，本次走无缓存路径');
  });

  return client;
}

/** 优雅关闭（进程退出时调用）。 */
export async function closeRedis(): Promise<void> {
  if (client) {
    await client.quit();
    client = null;
  }
}
