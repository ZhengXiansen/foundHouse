// 阿里云 OSS 本地配置（端侧直配密钥模式，用户自行填写，无后端）。
//
// 用户在「我的 → OSS 云存储」页填写 endpoint/bucket/accessKeyId/accessKeySecret
// 与可选的自定义域名、路径前缀，并用开关决定是否启用。启用且配置完整时，
// 照片经 [AliyunOssDirectUploader] 端侧签名直传 OSS；否则纯本地存储。
//
// 存储策略：整份配置含 accessKeySecret（敏感凭据），统一存
// flutter_secure_storage（复用 crypto_service 的 [KeyStore] 抽象），
// 不落 SQLite，避免明文密钥入库与 Drift 迁移。

import 'dart:convert';

import '../../data/crypto/crypto_service.dart';

/// OSS 配置在安全存储中的键名。
const String _kOssConfigStorageKey = 'found_house_oss_config_v1';

/// 阿里云 OSS 端侧直传配置。不可变值对象。
///
/// [enabled] 为用户显式开关；[isComplete] 判定必填项是否齐全；
/// 仅 [isActive]（enabled && isComplete）为真时才实际直传 OSS。
class OssConfig {
  const OssConfig({
    this.enabled = false,
    this.endpoint = '',
    this.bucket = '',
    this.accessKeyId = '',
    this.accessKeySecret = '',
    this.customDomain = '',
    this.pathPrefix = '',
  });

  /// 空配置（首启默认：未启用、各项为空）。
  static const OssConfig empty = OssConfig();

  /// 用户是否启用 OSS 上传。
  final bool enabled;

  /// OSS 地域节点，如 `oss-cn-shenzhen.aliyuncs.com`（不含 bucket 前缀与协议）。
  final String endpoint;

  /// Bucket 名称。
  final String bucket;

  /// AccessKeyId。
  final String accessKeyId;

  /// AccessKeySecret（敏感凭据）。
  final String accessKeySecret;

  /// 可选自定义域名（CDN），如 `cdn.example.com`。为空则用 bucket.endpoint 拼公网地址。
  final String customDomain;

  /// 可选对象键前缀，如 `photos/`。归一化时保证不以 `/` 开头、以 `/` 结尾（非空时）。
  final String pathPrefix;

  /// 必填项是否齐全（endpoint/bucket/accessKeyId/accessKeySecret 均非空）。
  bool get isComplete =>
      endpoint.trim().isNotEmpty &&
      bucket.trim().isNotEmpty &&
      accessKeyId.trim().isNotEmpty &&
      accessKeySecret.trim().isNotEmpty;

  /// 是否应实际直传 OSS：已启用且配置完整。
  bool get isActive => enabled && isComplete;

  /// 归一化路径前缀：去首尾空白与首个 `/`，非空时补尾 `/`。
  String get normalizedPrefix {
    var prefix = pathPrefix.trim();
    while (prefix.startsWith('/')) {
      prefix = prefix.substring(1);
    }
    if (prefix.isEmpty) return '';
    return prefix.endsWith('/') ? prefix : '$prefix/';
  }

  /// bucket 直传主机名：`<bucket>.<endpoint>`。
  String get bucketHost => '${bucket.trim()}.${endpoint.trim()}';

  /// PostObject 直传目标地址（始终走 bucket.endpoint，签名基于此主机）。
  Uri get uploadUri => Uri.parse('https://$bucketHost');

  /// 由对象键拼公网可读地址：优先自定义域名，否则用 bucket.endpoint。
  String publicUrlFor(String objectKey) {
    final domain = customDomain.trim();
    if (domain.isNotEmpty) {
      final host = domain.replaceFirst(RegExp(r'^https?://'), '');
      return 'https://$host/$objectKey';
    }
    return 'https://$bucketHost/$objectKey';
  }

  OssConfig copyWith({
    bool? enabled,
    String? endpoint,
    String? bucket,
    String? accessKeyId,
    String? accessKeySecret,
    String? customDomain,
    String? pathPrefix,
  }) {
    return OssConfig(
      enabled: enabled ?? this.enabled,
      endpoint: endpoint ?? this.endpoint,
      bucket: bucket ?? this.bucket,
      accessKeyId: accessKeyId ?? this.accessKeyId,
      accessKeySecret: accessKeySecret ?? this.accessKeySecret,
      customDomain: customDomain ?? this.customDomain,
      pathPrefix: pathPrefix ?? this.pathPrefix,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'enabled': enabled,
        'endpoint': endpoint,
        'bucket': bucket,
        'accessKeyId': accessKeyId,
        'accessKeySecret': accessKeySecret,
        'customDomain': customDomain,
        'pathPrefix': pathPrefix,
      };

  factory OssConfig.fromJson(Map<String, Object?> json) => OssConfig(
        enabled: json['enabled'] as bool? ?? false,
        endpoint: json['endpoint'] as String? ?? '',
        bucket: json['bucket'] as String? ?? '',
        accessKeyId: json['accessKeyId'] as String? ?? '',
        accessKeySecret: json['accessKeySecret'] as String? ?? '',
        customDomain: json['customDomain'] as String? ?? '',
        pathPrefix: json['pathPrefix'] as String? ?? '',
      );
}

/// OSS 配置读写：基于平台安全存储（[KeyStore]），JSON 序列化单条配置。
///
/// 复用 crypto_service 的 [KeyStore] 抽象，生产走 flutter_secure_storage，
/// 单测注入内存实现，不依赖平台通道。
class OssConfigStore {
  OssConfigStore(this._keyStore);

  final KeyStore _keyStore;

  /// 读取配置；未保存过或解析失败时返回 [OssConfig.empty]。
  Future<OssConfig> load() async {
    final raw = await _keyStore.read(_kOssConfigStorageKey);
    if (raw == null || raw.isEmpty) return OssConfig.empty;
    try {
      final json = jsonDecode(raw) as Map<String, Object?>;
      return OssConfig.fromJson(json);
    } catch (_) {
      // 存储损坏时退回空配置，避免阻断（本地优先，OSS 仅增强）。
      return OssConfig.empty;
    }
  }

  /// 保存配置（整份覆盖）。
  Future<void> save(OssConfig config) async {
    await _keyStore.write(
      _kOssConfigStorageKey,
      jsonEncode(config.toJson()),
    );
  }
}
