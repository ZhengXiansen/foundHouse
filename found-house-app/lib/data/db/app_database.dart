import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'tables.dart';

// build_runner 生成产物。首次实现后需在本机执行：
//   dart run build_runner build --delete-conflicting-outputs
// 生成 app_database.g.dart。生成前分析器会报缺失，属预期。
part 'app_database.g.dart';

/// Drift 数据库入口（W1-2 · D1，技术方案 §5/§8，冻结项 F9）。
///
/// 职责边界：聚合全部 10 张表、定义 schemaVersion 与迁移策略、开启外键约束，
/// 用 NativeDatabase + sqlite3_flutter_libs 打开本地 SQLite（应用支持目录）。
///
/// 关键约束：仓库层只经此库读写，页面不散落 SQL；敏感字段以密文存储，
/// 加解密统一走 CryptoService（W5 · H1），数据库层不感知明文。
@DriftDatabase(
  tables: [
    Villages,
    Buildings,
    HouseRecords,
    FeeInfos,
    RoomInfos,
    ContactInfos,
    ChecklistItems,
    RiskFlags,
    PhotoAssets,
    MapSnapshots,
    ScoreSnapshots,
    PreferenceProfiles,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 测试注入用构造：传入内存或自定义 executor。
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        beforeOpen: (details) async {
          // SQLite 默认关闭外键约束，级联删除依赖此项（W5 · H3）。
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await _migrateToV2(m);
          }
          if (from < 3) {
            await _migrateToV3(m);
          }
        },
      );

  Future<void> _migrateToV2(Migrator m) async {
    await m.createTable(villages);
    await m.createTable(buildings);
    await m.addColumn(houseRecords, houseRecords.villageId);
    await m.addColumn(houseRecords, houseRecords.buildingId);

    const unassignedId = 'system-unassigned-village';
    final now = DateTime.now().millisecondsSinceEpoch;
    await customStatement(
      'INSERT OR IGNORE INTO village '
      '(id, name, status, created_at, updated_at) '
      'VALUES (?, ?, ?, ?, ?)',
      [unassignedId, '未分组', 'preparing', now, now],
    );
    await customStatement(
      'UPDATE house_record SET village_id = ? WHERE village_id IS NULL',
      [unassignedId],
    );

    // v1 的 photo_asset.house_id 为 NOT NULL。V0.2 要支持楼栋/村照片，
    // 需要重建表，把 house 照片迁移为 owner_type=house / owner_id=house_id。
    await customStatement('ALTER TABLE photo_asset RENAME TO photo_asset_v1');
    await customStatement('''
CREATE TABLE photo_asset (
  id TEXT NOT NULL,
  house_id TEXT NULL REFERENCES house_record(id) ON DELETE CASCADE,
  owner_type TEXT NOT NULL DEFAULT 'house',
  owner_id TEXT NOT NULL,
  local_path TEXT NOT NULL,
  tag TEXT NOT NULL,
  taken_at INTEGER NOT NULL,
  exif_removed INTEGER NOT NULL DEFAULT 0 CHECK (exif_removed IN (0, 1)),
  PRIMARY KEY (id)
)
''');
    await customStatement('''
INSERT INTO photo_asset (
  id, house_id, owner_type, owner_id, local_path, tag, taken_at, exif_removed
)
SELECT id, house_id, 'house', house_id, local_path, tag, taken_at, exif_removed
FROM photo_asset_v1
''');
    await customStatement('DROP TABLE photo_asset_v1');
  }

  /// v2 → v3：为 photo_asset 增加存储位置元信息列（V1.1 云同步显式能力）。
  ///
  /// 旧照片一律为端侧本地文件：storage_provider 回填 'local'，
  /// remote_url / object_key 留空，与领域默认值一致。
  Future<void> _migrateToV3(Migrator m) async {
    await m.addColumn(photoAssets, photoAssets.storageProvider);
    await m.addColumn(photoAssets, photoAssets.remoteUrl);
    await m.addColumn(photoAssets, photoAssets.objectKey);
    await customStatement(
      "UPDATE photo_asset SET storage_provider = 'local' "
      'WHERE storage_provider IS NULL',
    );
  }
}

/// 打开本地数据库连接。
///
/// 路径取 [getApplicationSupportDirectory]（非 Documents，避免被系统备份/暴露），
/// 在后台 isolate 打开以免阻塞 UI；顺带确保 sqlite3 使用应用私有临时目录。
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'found_house.sqlite'));

    // Android 上部分老设备的默认临时目录不可用，显式指向应用私有目录。
    // 注：sqlite3 3.x 起原生库经 build hooks 自动打包，不再需要
    // sqlite3_flutter_libs 及其 applyWorkaroundToOpenSqlite3OnOldAndroidVersions。
    if (Platform.isAndroid) {
      final cacheBase = (await getTemporaryDirectory()).path;
      sqlite3.tempDirectory = cacheBase;
    }

    return NativeDatabase.createInBackground(file);
  });
}
