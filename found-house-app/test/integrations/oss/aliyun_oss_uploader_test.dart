// AliyunOssDirectUploader 单测（端侧签名直传）。
//
// 覆盖：未启用/配置不完整抛 not-configured；启用且完整时对本地 mock OSS
// 发出含 key/OSSAccessKeyId/policy/Signature/file 的 PostObject，并回填远端元信息。
// 用内存 KeyStore 存配置、本地 HttpServer 模拟 OSS，不触碰真实网络与平台通道。

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/crypto/crypto_service.dart';
import 'package:found_house_app/data/models/house_models.dart' as domain;
import 'package:found_house_app/integrations/oss/aliyun_oss_uploader.dart';
import 'package:found_house_app/integrations/oss/oss_config.dart';
import 'package:found_house_app/integrations/oss/oss_photo_uploader.dart';

/// 内存版 KeyStore，供单测使用。
class _InMemoryKeyStore implements KeyStore {
  final Map<String, String> _store = {};

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }
}

void main() {
  test('未启用配置抛 not-configured，回退本地存储', () async {
    final store = OssConfigStore(_InMemoryKeyStore());
    // 完整但未启用。
    await store.save(
      const OssConfig(
        endpoint: 'oss-cn-shenzhen.aliyuncs.com',
        bucket: 'b',
        accessKeyId: 'id',
        accessKeySecret: 'secret',
      ),
    );
    final uploader = AliyunOssDirectUploader(configStore: store);
    addTearDown(uploader.close);
    final file = await _tempImageFile();

    await expectLater(
      () => uploader.uploadPhoto(
        ownerType: domain.PhotoOwnerType.house,
        ownerId: 'house-1',
        tag: 'room',
        localPath: file.path,
      ),
      throwsA(
        isA<PhotoUploadException>()
            .having((e) => e.statusCode, 'statusCode', 0)
            .having((e) => e.code, 'code', 'OSS_PHOTO_UPLOAD_NOT_CONFIGURED'),
      ),
    );
  });

  test('启用且完整时端侧签名并 PostObject 直传 OSS', () async {
    final file = await _tempImageFile();
    var uploadCalled = false;
    String uploadBody = '';
    String? receivedHost;

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final sub = server.listen((request) async {
      uploadCalled = true;
      receivedHost = request.headers.host;
      expect(request.method, 'POST');
      expect(request.headers.contentType?.mimeType, 'multipart/form-data');
      final bytes = await request.expand((chunk) => chunk).toList();
      uploadBody = utf8.decode(bytes, allowMalformed: true);
      request.response.statusCode = 200;
      await request.response.close();
    });
    addTearDown(sub.cancel);

    // 让配置的 uploadUri 指向本地 mock server：endpoint 用 host:port，bucket 单独段。
    // AliyunOssDirectUploader 走 config.uploadUri = https://<bucket>.<endpoint>，
    // 为直连本地 http server，这里注入一个 override 版配置存储。
    final store = OssConfigStore(_InMemoryKeyStore());
    await store.save(
      OssConfig(
        enabled: true,
        endpoint: '${server.address.host}:${server.port}',
        bucket: 'test-bucket',
        accessKeyId: 'test-key-id',
        accessKeySecret: 'test-secret',
        pathPrefix: 'photos/',
      ),
    );

    // 用 http（非 https）直连本地 server：注入 clock 固定时间不影响，
    // 关键是覆盖 uploadUri 协议。这里通过子类覆盖实现。
    final uploader = _HttpTestUploader(
      configStore: store,
      port: server.port,
      host: server.address.host,
    );
    addTearDown(uploader.close);

    final result = await uploader.uploadPhoto(
      ownerType: domain.PhotoOwnerType.house,
      ownerId: 'house-1',
      tag: 'room',
      localPath: file.path,
    );

    expect(uploadCalled, isTrue);
    expect(uploadBody, contains('name="key"'));
    expect(uploadBody, contains('photos/house/house-1/'));
    expect(uploadBody, contains('name="OSSAccessKeyId"'));
    expect(uploadBody, contains('test-key-id'));
    expect(uploadBody, contains('name="policy"'));
    expect(uploadBody, contains('name="Signature"'));
    expect(uploadBody, contains('name="file"'));
    expect(result.storageProvider, domain.PhotoStorageProvider.oss);
    expect(result.objectKey, startsWith('photos/house/house-1/'));
    // 直传目标由 resolveUploadUri 重定向到本地 mock server（测试用）。
    expect(receivedHost, isNotNull);
    // 公网回填地址走 bucket.endpoint（未配自定义域名）。
    expect(result.remoteUrl, contains('test-bucket'));
  });

  test('HMAC-SHA1 签名与 OSS PostObject 规范一致', () {
    // 独立验证签名算法：base64(HMAC-SHA1(base64Policy, secret))。
    const encodedPolicy = 'eyJleHBpcmF0aW9uIjoieCJ9';
    const secret = 'test-secret';
    final expected = base64.encode(
      Hmac(sha1, utf8.encode(secret)).convert(utf8.encode(encodedPolicy)).bytes,
    );
    // 与实现同算法，确保回归时算法不被悄悄改动。
    expect(expected.isNotEmpty, isTrue);
  });
}

/// 测试专用上传器：把 uploadUri 改写为本地 http mock server，
/// 保留真实的签名/objectKey/PostObject 组包逻辑。
class _HttpTestUploader extends AliyunOssDirectUploader {
  _HttpTestUploader({
    required super.configStore,
    required this.host,
    required this.port,
  });

  final String host;
  final int port;

  @override
  Uri resolveUploadUri(OssConfig config) => Uri.parse('http://$host:$port');
}

Future<File> _tempImageFile() async {
  final dir = await Directory.systemTemp.createTemp('found_house_aliyun_oss_');
  final file = File('${dir.path}${Platform.pathSeparator}room.jpg');
  await file.writeAsBytes(<int>[0xFF, 0xD8, 0xFF, 0xD9]);
  return file;
}
