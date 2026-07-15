/**
 * 错误码枚举表（M8 端-云契约单一事实源）。
 *
 * 约定：
 * - code 为稳定字符串，客户端据此映射 UI §8 错误态文案，不依赖 message 文本。
 * - httpStatus 为对外 HTTP 状态码。
 * - message 为服务端日志/调试用的英文描述，不直接展示给用户（用户文案在客户端按 code 本地化）。
 * - 所有对外错误必须使用本表定义的 code，不得裸抛第三方错误。
 */

export const ErrorCode = {
  // 通用
  BAD_REQUEST: 'BAD_REQUEST',
  VALIDATION_FAILED: 'VALIDATION_FAILED',
  RATE_LIMITED: 'RATE_LIMITED',
  INTERNAL_ERROR: 'INTERNAL_ERROR',

  // 地图代理
  MAP_RATE_LIMITED: 'MAP_RATE_LIMITED',
  MAP_UPSTREAM_UNAVAILABLE: 'MAP_UPSTREAM_UNAVAILABLE',
  MAP_UPSTREAM_TIMEOUT: 'MAP_UPSTREAM_TIMEOUT',
  MAP_QUOTA_EXCEEDED: 'MAP_QUOTA_EXCEEDED',
  MAP_NO_ROUTE: 'MAP_NO_ROUTE',

  // 配置
  CONFIG_NOT_FOUND: 'CONFIG_NOT_FOUND',

  // 照片直传
  OSS_NOT_CONFIGURED: 'OSS_NOT_CONFIGURED',
} as const;

export type ErrorCode = (typeof ErrorCode)[keyof typeof ErrorCode];

interface ErrorMeta {
  httpStatus: number;
  message: string;
}

/**
 * 错误码 → HTTP 状态 + 默认描述。
 * 客户端文案边界见 UI §8：不给法律结论，使用可操作句式（如「地图暂不可用，可先离线记录」）。
 */
export const ERROR_META: Record<ErrorCode, ErrorMeta> = {
  [ErrorCode.BAD_REQUEST]: { httpStatus: 400, message: 'Bad request.' },
  [ErrorCode.VALIDATION_FAILED]: { httpStatus: 400, message: 'Request validation failed.' },
  [ErrorCode.RATE_LIMITED]: { httpStatus: 429, message: 'Too many requests.' },
  [ErrorCode.INTERNAL_ERROR]: { httpStatus: 500, message: 'Internal server error.' },
  [ErrorCode.MAP_RATE_LIMITED]: { httpStatus: 429, message: 'Map requests rate limited.' },
  [ErrorCode.MAP_UPSTREAM_UNAVAILABLE]: { httpStatus: 502, message: 'Map upstream unavailable.' },
  [ErrorCode.MAP_UPSTREAM_TIMEOUT]: { httpStatus: 504, message: 'Map upstream timeout.' },
  [ErrorCode.MAP_QUOTA_EXCEEDED]: { httpStatus: 429, message: 'Map provider quota exceeded.' },
  [ErrorCode.MAP_NO_ROUTE]: { httpStatus: 200, message: 'No route found for the given mode.' },
  [ErrorCode.CONFIG_NOT_FOUND]: { httpStatus: 404, message: 'Config not found.' },
  [ErrorCode.OSS_NOT_CONFIGURED]: { httpStatus: 503, message: 'Object storage not configured.' },
};

/**
 * 统一业务错误。抛出后由全局 error handler 转成 { code, message } 响应体。
 */
export class AppError extends Error {
  readonly code: ErrorCode;
  readonly httpStatus: number;
  /** 仅用于服务端日志/调试的附加信息，绝不透传给客户端（响应体只含 code + message）。 */
  readonly details?: unknown;

  constructor(code: ErrorCode, message?: string, details?: unknown) {
    const meta = ERROR_META[code];
    super(message ?? meta.message);
    this.name = 'AppError';
    this.code = code;
    this.httpStatus = meta.httpStatus;
    this.details = details;
  }
}
