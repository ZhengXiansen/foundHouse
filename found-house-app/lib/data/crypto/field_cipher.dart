// 字段级加解密钩子（W5 · 冻结项 F7）。
//
// 敏感字段（roomNo/phone/wechat/敏感 note）在 schema 层以密文存储，
// 仓库读写统一经此接口，禁止页面直接读写密文（F7）。
//
// 生产默认实现 [CryptoFieldCipher] 基于 [CryptoService] 做 AES-256-GCM
// 加密；[NoopFieldCipher] 仅保留给单测或显式兼容场景。

import 'dart:async';

import 'crypto_service.dart';

const String _kEncryptedFieldPrefix = 'fh:v1:';

/// 字段加解密接口。实现须保证 null 入参返回 null（不加密空值）。
abstract class FieldCipher {
  /// 加密明文；[plaintext] 为 null 时返回 null。
  FutureOr<String?> encrypt(String? plaintext);

  /// 解密密文；[ciphertext] 为 null 时返回 null。
  FutureOr<String?> decrypt(String? ciphertext);
}

/// 透传实现：不做任何加解密，明文即密文。
///
/// 仅用于 W5 接入真实 CryptoService 之前的占位，使仓库层加解密钩子
/// 可先行落地并被单测覆盖往返一致性。
class NoopFieldCipher implements FieldCipher {
  const NoopFieldCipher();

  @override
  String? encrypt(String? plaintext) => plaintext;

  @override
  String? decrypt(String? ciphertext) => ciphertext;
}

/// 基于 [CryptoService] 的字段级 AES-256-GCM 实现。
///
/// 新写入的密文带版本前缀，用于和历史 Noop 明文区分；读取到无前缀值时
/// 按历史明文返回，避免默认接入加密后旧本地数据无法打开。带前缀但解密
/// 失败会继续抛错，防止篡改或 DEK 不匹配被静默吞掉。
class CryptoFieldCipher implements FieldCipher {
  CryptoFieldCipher(this._crypto);

  final CryptoService _crypto;

  @override
  Future<String?> encrypt(String? plaintext) async {
    if (plaintext == null) return null;
    if (plaintext.isEmpty) return '';
    final encrypted = await _crypto.encryptField(plaintext);
    return '$_kEncryptedFieldPrefix$encrypted';
  }

  @override
  Future<String?> decrypt(String? ciphertext) async {
    if (ciphertext == null) return null;
    if (ciphertext.isEmpty) return '';
    if (!ciphertext.startsWith(_kEncryptedFieldPrefix)) {
      return ciphertext;
    }
    final payload = ciphertext.substring(_kEncryptedFieldPrefix.length);
    return _crypto.decryptField(payload);
  }
}
