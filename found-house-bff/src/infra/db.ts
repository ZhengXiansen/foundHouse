/**
 * PostgreSQL 连接池（node-postgres / pg）。
 *
 * BFF 仅用 PG 存储：地图缓存（可选，Redis 为主）、远程配置版本、匿名统计事件。
 * 严禁存储个人房源详情、联系人 PII、精确门牌、原始照片、用户扫楼轨迹明细。
 * 见技术方案 §4.3「不建议后端在 MVP 存储」。
 */
import pg from 'pg';
import { logger } from './logger.js';

const { Pool } = pg;

/**
 * 连接串从环境变量读取，禁止硬编码。
 * 开发环境示例见 docker-compose（DATABASE_URL=postgres://found:found@localhost:5432/found_bff）。
 */
const connectionString = process.env.DATABASE_URL;

let pool: pg.Pool | null = null;

/**
 * 惰性初始化连接池。未配置 DATABASE_URL 时返回 null，
 * 调用方需容忍「PG 不可用」——MVP 阶段地图缓存以 Redis 为主，PG 缺失不应阻断地图代理。
 */
export function getPool(): pg.Pool | null {
  if (pool) return pool;
  if (!connectionString) {
    logger.warn('DATABASE_URL 未配置，PG 连接池未初始化（MVP 可降级：缓存走 Redis）');
    return null;
  }
  pool = new Pool({
    connectionString,
    max: Number(process.env.PG_POOL_MAX ?? 10),
    idleTimeoutMillis: 30_000,
    connectionTimeoutMillis: 5_000,
  });
  pool.on('error', (err) => {
    // 空闲连接错误不应崩溃进程，仅记录。
    logger.error({ err }, 'PG 空闲连接异常');
  });
  return pool;
}

/** 优雅关闭，供进程退出时调用。 */
export async function closePool(): Promise<void> {
  if (pool) {
    await pool.end();
    pool = null;
  }
}
