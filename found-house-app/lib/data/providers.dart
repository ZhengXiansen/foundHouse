// 数据层 Riverpod providers（W1-2 · 2.x 经典 API）。
//
// 暴露 AppDatabase 单例、FieldCipher、PhotoStore 及各仓库的 provider，
// 供 features 层通过 ref.watch/read 获取，避免手动装配依赖。
//
// 说明：flutter_riverpod 锁定 2.x，使用 Provider（同步、单例）经典写法，
// 不用 codegen/@riverpod 注解。AppDatabase 需随应用生命周期释放，
// 用 ref.onDispose 关闭连接。

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../integrations/amap/amap_client.dart';
import '../integrations/oss/aliyun_oss_uploader.dart';
import '../integrations/oss/oss_config.dart';
import '../integrations/oss/oss_photo_uploader.dart';
import 'crypto/crypto_service.dart';
import 'crypto/field_cipher.dart';
import 'db/app_database.dart';
import 'local_files/photo_store.dart';
import 'models/house_models.dart' as domain;
import 'repositories/house_repository.dart';
import 'repositories/map_repository.dart';
import 'repositories/preference_repository.dart';
import 'repositories/village_repository.dart';

/// AppDatabase 单例。应用退出/provider 释放时关闭连接。
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// 字段加解密实现。生产默认使用 AES-256-GCM，DEK 由平台安全存储托管。
final fieldCipherProvider = Provider<FieldCipher>((ref) {
  return CryptoFieldCipher(ref.watch(cryptoServiceProvider));
});

/// 端侧照片文件管理。
final photoStoreProvider = Provider<PhotoStore>((ref) {
  return PhotoStore();
});

/// OSS 本地配置读写（端侧直配密钥模式）。凭据存平台安全存储（[KeyStore]）。
///
/// 与 [cryptoServiceProvider] 同构：生产走 flutter_secure_storage，
/// 测试可 override 注入内存 KeyStore。
final ossConfigStoreProvider = Provider<OssConfigStore>((ref) {
  return OssConfigStore(SecureStorageKeyStore());
});

/// 照片对象存储上传器：阿里云 OSS 端侧签名直传（端侧直配密钥模式）。
///
/// 每次上传惰性读 [ossConfigStoreProvider] 配置：用户在「我的 → OSS 云存储」
/// 启用并填全配置时才实际直传，否则抛 not-configured 异常，由
/// [HouseRepository.tryUploadPhotoAsset] 吞掉回退纯本地存储（本地优先，
/// 默认不上传）。开关即时生效，无需重建 provider 链。
final photoUploaderProvider = Provider<PhotoUploader>((ref) {
  final uploader = AliyunOssDirectUploader(
    configStore: ref.watch(ossConfigStoreProvider),
  );
  ref.onDispose(uploader.close);
  return uploader;
});

/// 房源读写仓库。
final houseRepositoryProvider = Provider<HouseRepository>((ref) {
  return HouseRepository(
    db: ref.watch(appDatabaseProvider),
    cipher: ref.watch(fieldCipherProvider),
    photoStore: ref.watch(photoStoreProvider),
    uploader: ref.watch(photoUploaderProvider),
  );
});

/// 村 / 楼栋读写仓库。
final villageRepositoryProvider = Provider<VillageRepository>((ref) {
  return VillageRepository(
    db: ref.watch(appDatabaseProvider),
    photoStore: ref.watch(photoStoreProvider),
  );
});

/// 村列表统计流。首页、房源筛选等只读场景复用同一数据源。
final villagesWithStatsProvider =
    StreamProvider<List<domain.VillageWithStats>>((ref) {
  return ref.watch(villageRepositoryProvider).watchVillagesWithStats();
});

/// 单个村统计流。查询覆盖村、楼栋、房源三张表，子表变化会刷新统计。
final villageWithStatsProvider =
    StreamProvider.family<domain.VillageWithStats?, String>((ref, villageId) {
  return ref.watch(villageRepositoryProvider).watchVillageWithStats(villageId);
});

/// 村内楼栋流。
final buildingsForVillageProvider =
    StreamProvider.family<List<domain.Building>, String>((ref, villageId) {
  return ref
      .watch(villageRepositoryProvider)
      .watchBuildingsForVillage(villageId);
});

/// 偏好读写仓库。
final preferenceRepositoryProvider = Provider<PreferenceRepository>((ref) {
  return PreferenceRepository(db: ref.watch(appDatabaseProvider));
});

/// 地图 BFF HTTP 客户端。base url 可在构建时通过 --dart-define 覆盖。
///
/// 正式构建如果暂时没有 BFF 地址，不再默认访问 localhost；地图刷新会
/// 返回可读的“未配置”错误，本地记录/列表/对比等离线能力不受影响。
final mapApiClientProvider = Provider<MapApiClient>((ref) {
  const configuredBaseUrl = String.fromEnvironment('FOUND_HOUSE_BFF_BASE_URL');
  final baseUrl = configuredBaseUrl.trim();
  if (baseUrl.isEmpty) {
    return const OfflineMapApiClient();
  }

  final client = AMapBffClient(
    baseUri: Uri.parse(baseUrl),
    anonDeviceToken: _anonDeviceToken(),
  );
  ref.onDispose(client.close);
  return client;
});

/// 地图快照仓库。
final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepository(
    client: ref.watch(mapApiClientProvider),
    houses: ref.watch(houseRepositoryProvider),
  );
});

String _anonDeviceToken() {
  return 'fh-${DateTime.now().millisecondsSinceEpoch}';
}
