// 字段级加密服务（W5 · H1，技术方案 §5.2，冻结项 F7）。
//
// 对敏感字段（ContactInfo.phone/wechat/note、HouseRecord.roomNo）做
// 字段级 AES-256-GCM 加密。DEK（256 位数据加密密钥）由平台安全存储
// （flutter_secure_storage）托管，不落 SQLite、不进日志、不参与云同步。
//
// 密文自包含格式（base64）：nonce(12B) || ciphertext || mac(16B)，
// 每次加密用独立随机 nonce，故同一明文两次加密密文不同。
//
// 加解密边界：读写敏感字段统一经此服务，数据库层不感知明文（F7）。
// 禁止在日志打印明文或密文。

import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// DEK 在安全存储中的键名。
const String _kDekStorageKey = 'found_house_field_dek_v1';

/// AES-GCM nonce 长度（字节）。GCM 标准 96 位。
const int _kNonceLength = 12;

/// 密钥存取抽象。
///
/// 生产实现走 flutter_secure_storage（平台安全存储）；单测注入内存实现，
/// 避免依赖平台通道（测试环境 secure storage 不可用）。
abstract class KeyStore {
  /// 读取指定键的值；不存在返回 null。
  Future<String?> read(String key);

  /// 写入键值。
  Future<void> write(String key, String value);
}

/// 基于 flutter_secure_storage 的生产实现（iOS Keychain / Android Keystore）。
class SecureStorageKeyStore implements KeyStore {
  SecureStorageKeyStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

/// 字段级 AES-256-GCM 加密服务。
///
/// 使用前需 [ensureKey] 完成 DEK 初始化；[encryptField] / [decryptField]
/// 内部按需惰性加载 DEK，故也可直接调用（首次会自动 [ensureKey]）。
class CryptoService {
  CryptoService(this._keyStore);

  final KeyStore _keyStore;
  final AesGcm _algorithm = AesGcm.with256bits();

  /// 内存缓存的 DEK，避免每次加解密都读安全存储。
  SecretKey? _cachedKey;

  /// 确保 DEK 就绪：已存在则复用，否则生成 256 位随机密钥并持久化。
  Future<void> ensureKey() async {
    if (_cachedKey != null) return;

    final existing = await _keyStore.read(_kDekStorageKey);
    if (existing != null && existing.isNotEmpty) {
      _cachedKey = SecretKey(base64Decode(existing));
      return;
    }

    // 首启生成 256 位随机 DEK。
    final generated = await _algorithm.newSecretKey();
    final bytes = await generated.extractBytes();
    await _keyStore.write(_kDekStorageKey, base64Encode(bytes));
    _cachedKey = SecretKey(bytes);
  }

  /// 加密明文，输出自包含 base64 密文（nonce || ciphertext || mac）。
  ///
  /// 空串返回空串（不加密空值，与 [FieldCipher] 语义对齐）。
  Future<String> encryptField(String plaintext) async {
    if (plaintext.isEmpty) return '';
    await ensureKey();

    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: _cachedKey!,
      nonce: nonce,
    );

    // 拼接 nonce + 密文 + mac，整体 base64 编码，便于单字段存储。
    final combined = Uint8List(
      nonce.length + secretBox.cipherText.length + secretBox.mac.bytes.length,
    );
    var offset = 0;
    combined.setRange(offset, offset + nonce.length, nonce);
    offset += nonce.length;
    combined.setRange(
      offset,
      offset + secretBox.cipherText.length,
      secretBox.cipherText,
    );
    offset += secretBox.cipherText.length;
    combined.setRange(
      offset,
      offset + secretBox.mac.bytes.length,
      secretBox.mac.bytes,
    );

    return base64Encode(combined);
  }

  /// 解密自包含 base64 密文，还原明文。
  ///
  /// 空串返回空串。密文被篡改或 DEK 不匹配时抛出异常（GCM 认证失败）。
  Future<String> decryptField(String ciphertext) async {
    if (ciphertext.isEmpty) return '';
    await ensureKey();

    final combined = base64Decode(ciphertext);
    const macLength = 16; // AES-GCM 认证标签固定 16 字节。
    final nonce = combined.sublist(0, _kNonceLength);
    final cipherText = combined.sublist(
      _kNonceLength,
      combined.length - macLength,
    );
    final macBytes = combined.sublist(combined.length - macLength);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    final clearBytes = await _algorithm.decrypt(
      secretBox,
      secretKey: _cachedKey!,
    );
    return utf8.decode(clearBytes);
  }
}

/// CryptoService 的 Riverpod Provider（Riverpod 2.x 经典 API）。
///
/// 默认使用平台安全存储托管 DEK；测试可 override 传入内存 KeyStore。
final cryptoServiceProvider = Provider<CryptoService>((ref) {
  return CryptoService(SecureStorageKeyStore());
});
