// 照片对象存储直传（V1.1 云同步显式开启能力，技术方案「照片端侧优先，可选云上传」）。
//
// 直传两段式，端侧不持有 OSS 密钥：
//   1. 向后端 signer（/api/photos/upload-intent）取直传意图，拿到 uploadUrl、
//      formFields、publicUrl、objectKey；
//   2. 按 formFields 组 multipart/form-data 直传对象存储，file 字段置末尾。
//
// 未配置云上传时用 [OfflinePhotoUploader]，抛稳定错误码，调用方据此回退纯本地存储。

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../data/models/house_models.dart' as domain;

/// 照片上传异常。[statusCode] 为 0 表示未发起网络请求（如未配置）。
class PhotoUploadException implements Exception {
  const PhotoUploadException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  /// HTTP 状态码；未发起请求时为 0。
  final int statusCode;

  /// 稳定错误码，供调用方分支处理。
  final String code;

  /// 面向日志的错误说明。
  final String message;

  @override
  String toString() => 'PhotoUploadException($statusCode, $code): $message';
}

/// 照片上传结果：远端存储位置与访问元信息，供落库到 PhotoAsset。
class PhotoUploadResult {
  const PhotoUploadResult({
    required this.storageProvider,
    required this.remoteUrl,
    required this.objectKey,
  });

  /// 存储位置：[domain.PhotoStorageProvider.oss]。
  final String storageProvider;

  /// 公网可读地址。
  final String remoteUrl;

  /// 远端对象键。
  final String objectKey;
}

/// 组 multipart/form-data 请求体：先写全部表单字段，file 字段置末尾（OSS 要求）。
///
/// 顶层函数，供后端 signer 直传（[OssPhotoUploader]）与端侧签名直传
/// （AliyunOssDirectUploader）复用（DRY）。
List<int> buildOssMultipartBody({
  required String boundary,
  required Map<String, Object?> formFields,
  required List<int> fileBytes,
  required String fileName,
  required String contentType,
}) {
  final builder = BytesBuilder();
  void writeLine(String line) => builder.add(utf8.encode('$line\r\n'));

  formFields.forEach((key, value) {
    writeLine('--$boundary');
    writeLine('Content-Disposition: form-data; name="$key"');
    writeLine('');
    writeLine('$value');
  });

  writeLine('--$boundary');
  writeLine(
    'Content-Disposition: form-data; name="file"; filename="$fileName"',
  );
  writeLine('Content-Type: $contentType');
  writeLine('');
  builder.add(fileBytes);
  builder.add(utf8.encode('\r\n'));
  writeLine('--$boundary--');
  return builder.takeBytes();
}

/// 照片上传器接口。
abstract class PhotoUploader {
  const PhotoUploader();

  /// 上传 [localPath] 处照片，返回远端元信息。失败抛 [PhotoUploadException]。
  Future<PhotoUploadResult> uploadPhoto({
    required String ownerType,
    required String ownerId,
    required String tag,
    required String localPath,
  });
}

/// 未配置云上传时的占位实现：始终抛稳定错误码，调用方据此保持纯本地存储。
class OfflinePhotoUploader extends PhotoUploader {
  const OfflinePhotoUploader();

  @override
  Future<PhotoUploadResult> uploadPhoto({
    required String ownerType,
    required String ownerId,
    required String tag,
    required String localPath,
  }) async {
    throw const PhotoUploadException(
      statusCode: 0,
      code: 'OSS_PHOTO_UPLOAD_NOT_CONFIGURED',
      message: '未配置照片云上传能力，保持端侧本地存储',
    );
  }
}

/// 对象存储直传实现。[signerUri] 指向后端直传意图接口。
class OssPhotoUploader extends PhotoUploader {
  OssPhotoUploader({required this.signerUri, HttpClient? httpClient})
      : _client = httpClient ?? HttpClient();

  /// 后端直传意图接口地址（POST）。
  final Uri signerUri;

  final HttpClient _client;

  @override
  Future<PhotoUploadResult> uploadPhoto({
    required String ownerType,
    required String ownerId,
    required String tag,
    required String localPath,
  }) async {
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

    final intent = await _fetchUploadIntent(
      ownerType: ownerType,
      ownerId: ownerId,
      tag: tag,
      contentType: contentType,
      contentLength: bytes.length,
    );

    await _putToObjectStorage(
      uploadUrl: Uri.parse(intent['uploadUrl']! as String),
      formFields: (intent['formFields']! as Map).cast<String, Object?>(),
      fileBytes: bytes,
      fileName: p.basename(localPath),
      contentType: contentType,
    );

    return PhotoUploadResult(
      storageProvider: domain.PhotoStorageProvider.oss,
      remoteUrl: intent['publicUrl']! as String,
      objectKey: intent['objectKey']! as String,
    );
  }

  /// 关闭底层 HTTP 客户端。上层不再使用本实例时调用。
  void close() => _client.close(force: true);

  Future<Map<String, Object?>> _fetchUploadIntent({
    required String ownerType,
    required String ownerId,
    required String tag,
    required String contentType,
    required int contentLength,
  }) async {
    final request = await _client.postUrl(signerUri);
    request.headers.contentType = ContentType.json;
    request.write(
      jsonEncode(<String, Object?>{
        'ownerType': ownerType,
        'ownerId': ownerId,
        'tag': tag,
        'contentType': contentType,
        'contentLength': contentLength,
      }),
    );
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PhotoUploadException(
        statusCode: response.statusCode,
        code: 'OSS_PHOTO_UPLOAD_INTENT_FAILED',
        message: '取直传意图失败：$body',
      );
    }
    return jsonDecode(body) as Map<String, Object?>;
  }

  Future<void> _putToObjectStorage({
    required Uri uploadUrl,
    required Map<String, Object?> formFields,
    required List<int> fileBytes,
    required String fileName,
    required String contentType,
  }) async {
    final boundary =
        '----foundHouseBoundary${DateTime.now().microsecondsSinceEpoch}';
    final body = _buildMultipartBody(
      boundary: boundary,
      formFields: formFields,
      fileBytes: fileBytes,
      fileName: fileName,
      contentType: contentType,
    );
    final request = await _client.postUrl(uploadUrl);
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

  /// 组 multipart/form-data 请求体：委托顶层 [buildOssMultipartBody]（DRY）。
  List<int> _buildMultipartBody({
    required String boundary,
    required Map<String, Object?> formFields,
    required List<int> fileBytes,
    required String fileName,
    required String contentType,
  }) {
    return buildOssMultipartBody(
      boundary: boundary,
      formFields: formFields,
      fileBytes: fileBytes,
      fileName: fileName,
      contentType: contentType,
    );
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
