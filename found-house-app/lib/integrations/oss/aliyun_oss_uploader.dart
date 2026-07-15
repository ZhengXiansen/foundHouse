// 阿里云 OSS 端侧签名直传（端侧直配密钥模式，无后端 signer）。
//
// 与 [OssPhotoUploader]（后端 signer 两段式）不同：本实现直接读取用户在
// 「我的 → OSS 云存储」保存的 [OssConfig]，端侧生成 PostObject policy 并用
// AccessKeySecret 做 HMAC-SHA1 签名，再直传 OSS。适合个人用户自备 bucket、
// 不搭后端的场景。
//
// 安全权衡：AccessKeySecret 驻留端侧（存 flutter_secure_storage）。文档已提示
// 用户使用最小权限子账号 / RAM 授权。密钥仅用于本地签名，不外发第三方。
//
// 开关即时生效：每次 [uploadPhoto] 惰性读配置，未启用或配置不完整立即抛
// OSS_PHOTO_UPLOAD_NOT_CONFIGURED；[HouseRepository.tryUploadPhotoAsset] 吞该
// 异常回退纯本地存储，故无需在配置变更时重建 provider。

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../data/models/house_models.dart' as domain;
import 'oss_config.dart';
import 'oss_photo_uploader.dart';

/// PostObject 策略有效期（分钟）：从发起上传起算，足够单次直传。
const int _kPolicyExpiryMinutes = 5;

/// 阿里云 OSS 端侧签名直传实现。依赖 [OssConfigStore] 惰性读用户配置。
class AliyunOssDirectUploader extends PhotoUploader {
  AliyunOssDirectUploader({
    required OssConfigStore configStore,
    HttpClient? httpClient,
    Uuid? uuid,
    DateTime Function()? clock,
  })  : _configStore = configStore,
        _client = httpClient ?? HttpClient(),
        _uuid = uuid ?? const Uuid(),
        _clock = clock ?? DateTime.now;

  final OssConfigStore _configStore;
  final HttpClient _client;
  final Uuid _uuid;
  final DateTime Function() _clock;

  /// 关闭底层 HTTP 客户端。上层不再使用本实例时调用。
  void close() => _client.close(force: true);

  /// PostObject 直传目标地址。默认取 [OssConfig.uploadUri]（https://bucket.endpoint）。
  ///
  /// 抽为可覆写方法，仅供测试用本地 http mock server 重定向；生产不覆写。
  @visibleForTesting
  Uri resolveUploadUri(OssConfig config) => config.uploadUri;

  @override
  Future<PhotoUploadResult> uploadPhoto({
    required String ownerType,
    required String ownerId,
    required String tag,
    required String localPath,
  }) async {
    final config = await _configStore.load();
    if (!config.isActive) {
      // 未启用或配置不完整：与 OfflinePhotoUploader 同码，回退纯本地存储。
      throw const PhotoUploadException(
        statusCode: 0,
        code: 'OSS_PHOTO_UPLOAD_NOT_CONFIGURED',
        message: '未启用或未完整配置 OSS，保持端侧本地存储',
      );
    }

    final file = File(localPath);
    if (!await file.exists()) {
      throw PhotoUploadException(
        statusCode: 0,
        code: 'OSS_PHOTO_UPLOAD_FILE_MISSING',
        message: '待上传文件不存在：$localPath',
      );
    }
    final bytes = await file.readAsBytes();
    final contentType = _contentTypeFor(localPath);
    final objectKey = _buildObjectKey(
      config: config,
      ownerType: ownerType,
      ownerId: ownerId,
      tag: tag,
      localPath: localPath,
    );

    final policy = _buildPolicy(bucket: config.bucket, objectKey: objectKey);
    final encodedPolicy = base64.encode(utf8.encode(jsonEncode(policy)));
    final signature = _sign(encodedPolicy, config.accessKeySecret);

    final formFields = <String, Object?>{
      'key': objectKey,
      'OSSAccessKeyId': config.accessKeyId,
      'policy': encodedPolicy,
      'Signature': signature,
      'success_action_status': '200',
      'Content-Type': contentType,
    };

    await _postToOss(
      uploadUri: resolveUploadUri(config),
      formFields: formFields,
      fileBytes: bytes,
      fileName: p.basename(localPath),
      contentType: contentType,
    );

    return PhotoUploadResult(
      storageProvider: domain.PhotoStorageProvider.oss,
      remoteUrl: config.publicUrlFor(objectKey),
      objectKey: objectKey,
    );
  }

  /// 生成对象键：`<前缀><ownerType>/<ownerId>/<uuid><ext>`。
  ///
  /// 用新 uuid 命名，避免门牌等敏感信息进入对象键，且防冲突（与 PhotoStore 同理）。
  String _buildObjectKey({
    required OssConfig config,
    required String ownerType,
    required String ownerId,
    required String tag,
    required String localPath,
  }) {
    final ext = p.extension(localPath);
    final name = '${_uuid.v4()}$ext';
    return '${config.normalizedPrefix}$ownerType/$ownerId/$name';
  }

  /// 构建 PostObject 策略文档：限定对象键精确匹配与过期时间。
  Map<String, Object?> _buildPolicy({
    required String bucket,
    required String objectKey,
  }) {
    final expiration = _clock()
        .toUtc()
        .add(const Duration(minutes: _kPolicyExpiryMinutes))
        .toIso8601String();
    // toIso8601String 产出形如 2026-07-09T10:00:00.000Z；OSS 接受该 ISO8601 UTC 格式。
    return <String, Object?>{
      'expiration': expiration,
      'conditions': <Object?>[
        <String>['eq', r'$key', objectKey],
        <String>['eq', r'$bucket', bucket],
      ],
    };
  }

  /// 对 base64 policy 做 HMAC-SHA1，输出 base64 签名（OSS PostObject 规范）。
  String _sign(String encodedPolicy, String accessKeySecret) {
    final hmac = Hmac(sha1, utf8.encode(accessKeySecret));
    final digest = hmac.convert(utf8.encode(encodedPolicy));
    return base64.encode(digest.bytes);
  }

  Future<void> _postToOss({
    required Uri uploadUri,
    required Map<String, Object?> formFields,
    required List<int> fileBytes,
    required String fileName,
    required String contentType,
  }) async {
    final boundary = '----foundHouseBoundary${_clock().microsecondsSinceEpoch}';
    final body = buildOssMultipartBody(
      boundary: boundary,
      formFields: formFields,
      fileBytes: fileBytes,
      fileName: fileName,
      contentType: contentType,
    );
    final request = await _client.postUrl(uploadUri);
    request.headers.contentType = ContentType(
      'multipart',
      'form-data',
      parameters: <String, String>{'boundary': boundary},
    );
    request.headers.contentLength = body.length;
    request.add(body);
    final response = await request.close();
    final respBody = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PhotoUploadException(
        statusCode: response.statusCode,
        code: 'OSS_PHOTO_UPLOAD_PUT_FAILED',
        message: '对象存储直传失败：$respBody',
      );
    }
  }

  static String _contentTypeFor(String path) {
    final ext = p.extension(path).toLowerCase();
    switch (ext) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.heic':
        return 'image/heic';
      case '.jpg':
      case '.jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
