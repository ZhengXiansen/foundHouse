// OssConfig / OssConfigStore 单测（端侧直配密钥模式）。
//
// 覆盖：存取往返一致、未保存时返回 empty、损坏 JSON 退回 empty、
// isComplete / isActive 判定、normalizedPrefix 归一化、publicUrlFor 取址。
// 用内存 KeyStore 注入，不触碰平台安全存储通道。

import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/crypto/crypto_service.dart';
import 'package:found_house_app/integrations/oss/oss_config.dart';

/// 内存版 KeyStore，供单测使用，不触碰平台通道。
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
  late _InMemoryKeyStore keyStore;
  late OssConfigStore store;

  setUp(() {
    keyStore = _InMemoryKeyStore();
    store = OssConfigStore(keyStore);
  });

  test('未保存过返回 empty 且未启用', () async {
    final config = await store.load();
    expect(config.enabled, isFalse);
    expect(config.isComplete, isFalse);
    expect(config.isActive, isFalse);
  });

  test('存取往返保留全部字段', () async {
    const config = OssConfig(
      enabled: true,
      endpoint: 'oss-cn-shenzhen.aliyuncs.com',
      bucket: 'my-found-house',
      accessKeyId: 'LTAI-test',
      accessKeySecret: 'secret-test',
      customDomain: 'cdn.example.com',
      pathPrefix: 'photos/',
    );
    await store.save(config);

    final loaded = await store.load();
    expect(loaded.enabled, isTrue);
    expect(loaded.endpoint, 'oss-cn-shenzhen.aliyuncs.com');
    expect(loaded.bucket, 'my-found-house');
    expect(loaded.accessKeyId, 'LTAI-test');
    expect(loaded.accessKeySecret, 'secret-test');
    expect(loaded.customDomain, 'cdn.example.com');
    expect(loaded.pathPrefix, 'photos/');
  });

  test('损坏 JSON 退回 empty', () async {
    await keyStore.write('found_house_oss_config_v1', '{not-json');
    final config = await store.load();
    expect(config.enabled, isFalse);
    expect(config.isComplete, isFalse);
  });

  test('isActive 仅在启用且配置完整时为真', () {
    const incomplete = OssConfig(enabled: true, endpoint: 'ep', bucket: 'b');
    expect(incomplete.isComplete, isFalse);
    expect(incomplete.isActive, isFalse);

    const disabledButComplete = OssConfig(
      endpoint: 'ep',
      bucket: 'b',
      accessKeyId: 'id',
      accessKeySecret: 'secret',
    );
    expect(disabledButComplete.isComplete, isTrue);
    expect(disabledButComplete.isActive, isFalse);

    final active = disabledButComplete.copyWith(enabled: true);
    expect(active.isActive, isTrue);
  });

  test('normalizedPrefix 去首斜杠并补尾斜杠', () {
    expect(const OssConfig(pathPrefix: '').normalizedPrefix, '');
    expect(const OssConfig(pathPrefix: 'photos').normalizedPrefix, 'photos/');
    expect(const OssConfig(pathPrefix: '/photos/').normalizedPrefix, 'photos/');
    expect(
      const OssConfig(pathPrefix: '  photos  ').normalizedPrefix,
      'photos/',
    );
  });

  test('publicUrlFor 优先自定义域名，否则用 bucket.endpoint', () {
    const withDomain = OssConfig(
      endpoint: 'oss-cn-shenzhen.aliyuncs.com',
      bucket: 'b',
      customDomain: 'cdn.example.com',
    );
    expect(
      withDomain.publicUrlFor('photos/house/h1/a.jpg'),
      'https://cdn.example.com/photos/house/h1/a.jpg',
    );

    const noDomain = OssConfig(
      endpoint: 'oss-cn-shenzhen.aliyuncs.com',
      bucket: 'b',
    );
    expect(
      noDomain.publicUrlFor('photos/house/h1/a.jpg'),
      'https://b.oss-cn-shenzhen.aliyuncs.com/photos/house/h1/a.jpg',
    );
  });
}
