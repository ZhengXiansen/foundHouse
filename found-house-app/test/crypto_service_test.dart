// CryptoService 单测（W5 · H1，冻结项 F7）。
//
// 覆盖：加解密往返一致、空串处理、密文不等于明文、
// 同一明文两次加密因 nonce 不同而密文不同。
// 用内存 KeyStore 注入，不依赖平台安全存储通道。

import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/crypto/crypto_service.dart';

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
  late CryptoService crypto;
  late _InMemoryKeyStore keyStore;

  setUp(() {
    keyStore = _InMemoryKeyStore();
    crypto = CryptoService(keyStore);
  });

  test('加解密往返一致', () async {
    const plaintext = '13800138000';
    final cipher = await crypto.encryptField(plaintext);
    final restored = await crypto.decryptField(cipher);
    expect(restored, plaintext);
  });

  test('中文明文往返一致', () async {
    const plaintext = '深圳市南山区某城中村 3 栋 502 · 微信 abc_123';
    final cipher = await crypto.encryptField(plaintext);
    expect(await crypto.decryptField(cipher), plaintext);
  });

  test('空串加密返回空串', () async {
    expect(await crypto.encryptField(''), '');
  });

  test('空串解密返回空串', () async {
    expect(await crypto.decryptField(''), '');
  });

  test('密文不等于明文', () async {
    const plaintext = 'wechat_id_888';
    final cipher = await crypto.encryptField(plaintext);
    expect(cipher, isNot(plaintext));
  });

  test('同一明文两次加密密文不同（nonce 随机）', () async {
    const plaintext = '同一段敏感门牌';
    final first = await crypto.encryptField(plaintext);
    final second = await crypto.encryptField(plaintext);
    expect(first, isNot(second));
    // 但两者都能正确解回原文。
    expect(await crypto.decryptField(first), plaintext);
    expect(await crypto.decryptField(second), plaintext);
  });

  test('ensureKey 幂等：DEK 只生成一次并复用', () async {
    await crypto.ensureKey();
    final firstKey = await keyStore.read('found_house_field_dek_v1');
    await crypto.ensureKey();
    final secondKey = await keyStore.read('found_house_field_dek_v1');
    expect(firstKey, isNotNull);
    expect(secondKey, firstKey);
  });

  test('复用已有 DEK：新实例可解旧实例的密文', () async {
    const plaintext = '跨实例解密';
    final cipher = await crypto.encryptField(plaintext);
    // 用同一 keyStore 构造新实例，模拟应用重启后复用已持久化 DEK。
    final another = CryptoService(keyStore);
    expect(await another.decryptField(cipher), plaintext);
  });
}
