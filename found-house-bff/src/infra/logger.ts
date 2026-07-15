/**
 * 日志与 PII 脱敏规范（M8）。
 *
 * 铁律（技术方案 §9、§13）：
 * - 禁止记录手机号、微信号、精确坐标（经纬度）、精确门牌、房源备注全文。
 * - 经纬度若必须记录用于排障，只保留网格化后的低精度值（截断到 2 位小数）。
 * - 匿名事件只收行为，不收房源内容。
 *
 * 本模块提供一个 pino 实例 + redact 配置，以及坐标网格化工具。
 */

import pino from 'pino';

/**
 * pino redact：命中路径的字段值替换为 [REDACTED]。
 * 覆盖常见 PII 字段名，防止透传的上游/请求体意外落日志。
 */
const REDACT_PATHS = [
  'phone',
  'wechat',
  'contact',
  'contact.phone',
  'contact.wechat',
  'room_no',
  'roomNo',
  'address_text',
  'addressText',
  'note',
  'notes',
  'userNotes',
  '*.phone',
  '*.wechat',
  '*.room_no',
  '*.note',
  'req.headers.authorization',
  'req.headers.cookie',
];

export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
  redact: {
    paths: REDACT_PATHS,
    censor: '[REDACTED]',
  },
  // 生产用 JSON；本地开发可通过 pino-pretty（devDependency 按需加）美化。
  timestamp: pino.stdTimeFunctions.isoTime,
});

/**
 * 坐标网格化：把经纬度截断到指定小数位，降低精确住址暴露。
 * 默认 2 位（约 1.1km 网格），仅用于日志/缓存 key，不用于返回给客户端的真实结果。
 */
export function coarseCoord(value: number, fractionDigits = 2): number {
  const factor = 10 ** fractionDigits;
  return Math.round(value * factor) / factor;
}

/**
 * 生成用于日志的安全坐标标签，绝不打印原始高精度坐标。
 */
export function coordLabel(lat: number, lng: number): string {
  return `grid(${coarseCoord(lat)},${coarseCoord(lng)})`;
}
