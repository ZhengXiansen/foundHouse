import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/crypto/field_cipher.dart';
import 'package:found_house_app/data/db/app_database.dart';
import 'package:found_house_app/data/local_files/photo_store.dart';
import 'package:found_house_app/data/models/house_models.dart' as domain;
import 'package:found_house_app/data/repositories/house_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('v1 数据库升级到 v2 时回填村归属并迁移旧房源照片归属', () async {
    final dir = await Directory.systemTemp.createTemp('found_house_migration_');
    addTearDown(() async {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    });

    final file = File('${dir.path}${Platform.pathSeparator}legacy_v1.sqlite');
    _createLegacyV1Database(file);

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    // 触发 Drift 打开数据库并执行 onUpgrade。
    await db.customSelect('SELECT 1').get();

    final houseRow = await db
        .customSelect(
          "SELECT village_id, building_id FROM house_record WHERE id = 'house-old'",
        )
        .getSingle();
    expect(
      houseRow.data['village_id'],
      domain.VillageDefaults.unassignedVillageId,
    );
    expect(houseRow.data['building_id'], isNull);

    final villageRow = await db
        .customSelect(
          "SELECT name, status FROM village WHERE id = '${domain.VillageDefaults.unassignedVillageId}'",
        )
        .getSingle();
    expect(villageRow.data['name'], '未分组');
    expect(villageRow.data['status'], domain.VillageStatus.preparing);

    final photoRow = await db
        .customSelect(
          "SELECT house_id, owner_type, owner_id, local_path, tag FROM photo_asset WHERE id = 'photo-old'",
        )
        .getSingle();
    expect(photoRow.data['house_id'], 'house-old');
    expect(photoRow.data['owner_type'], domain.PhotoOwnerType.house);
    expect(photoRow.data['owner_id'], 'house-old');
    expect(photoRow.data['local_path'], '/tmp/legacy-room.jpg');
    expect(photoRow.data['tag'], PhotoTag.room);

    final repo = HouseRepository(
      db: db,
      cipher: const NoopFieldCipher(),
      photoStore: PhotoStore(baseDirOverride: dir),
    );
    final photos = await repo.getPhotoAssets('house-old');
    expect(photos, hasLength(1));
    expect(photos.single.id, 'photo-old');
    expect(photos.single.houseId, 'house-old');
    expect(photos.single.ownerType, domain.PhotoOwnerType.house);
    expect(photos.single.ownerId, 'house-old');
  });

  test('v2 数据库升级到 v3 时为旧照片补本地存储默认值', () async {
    final dir = await Directory.systemTemp.createTemp('found_house_migration_v2_');
    addTearDown(() async {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    });

    final file = File('${dir.path}${Platform.pathSeparator}legacy_v2.sqlite');
    _createLegacyV2Database(file);

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    await db.customSelect('SELECT 1').get();

    final photoRow = await db
        .customSelect(
          "SELECT storage_provider, remote_url, object_key FROM photo_asset WHERE id = 'photo-v2'",
        )
        .getSingle();
    expect(photoRow.data['storage_provider'], domain.PhotoStorageProvider.local);
    expect(photoRow.data['remote_url'], isNull);
    expect(photoRow.data['object_key'], isNull);

    final repo = HouseRepository(
      db: db,
      cipher: const NoopFieldCipher(),
      photoStore: PhotoStore(baseDirOverride: dir),
    );
    final photos = await repo.getPhotoAssets('house-v2');
    expect(photos.single.storageProvider, domain.PhotoStorageProvider.local);
    expect(photos.single.remoteUrl, isNull);
    expect(photos.single.objectKey, isNull);
  });
}

void _createLegacyV1Database(File file) {
  final db = sqlite.sqlite3.open(file.path);
  try {
    db.execute('PRAGMA foreign_keys = ON');
    db.execute('''
CREATE TABLE house_record (
  id TEXT NOT NULL,
  title TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft',
  latitude REAL NULL,
  longitude REAL NULL,
  address_text TEXT NULL,
  building_name TEXT NULL,
  room_no TEXT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  visited_at INTEGER NULL,
  PRIMARY KEY (id)
)
''');
    db.execute('''
CREATE TABLE photo_asset (
  id TEXT NOT NULL,
  house_id TEXT NOT NULL REFERENCES house_record(id) ON DELETE CASCADE,
  local_path TEXT NOT NULL,
  tag TEXT NOT NULL,
  taken_at INTEGER NOT NULL,
  exif_removed INTEGER NOT NULL DEFAULT 0 CHECK (exif_removed IN (0, 1)),
  PRIMARY KEY (id)
)
''');
    db.execute(
      "INSERT INTO house_record (id, title, status, created_at, updated_at) VALUES ('house-old', '旧流程房源', 'draft', 1000, 1000)",
    );
    db.execute(
      "INSERT INTO photo_asset (id, house_id, local_path, tag, taken_at, exif_removed) VALUES ('photo-old', 'house-old', '/tmp/legacy-room.jpg', '${PhotoTag.room}', 1000, 1)",
    );
    db.execute('PRAGMA user_version = 1');
  } finally {
    db.close();
  }
}

void _createLegacyV2Database(File file) {
  final db = sqlite.sqlite3.open(file.path);
  try {
    db.execute('PRAGMA foreign_keys = ON');
    db.execute('''
CREATE TABLE village (
  id TEXT NOT NULL,
  name TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'preparing',
  area_note TEXT NULL,
  commute_minutes INTEGER NULL,
  commute_note TEXT NULL,
  surroundings_tags TEXT NULL,
  surroundings_score INTEGER NULL,
  environment_score INTEGER NULL,
  safety_score INTEGER NULL,
  noise_score INTEGER NULL,
  note TEXT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  last_visited_at INTEGER NULL,
  PRIMARY KEY (id)
)
''');
    db.execute('''
CREATE TABLE building (
  id TEXT NOT NULL,
  village_id TEXT NOT NULL REFERENCES village(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'not_scouted',
  entrance_note TEXT NULL,
  floor_count INTEGER NULL,
  has_elevator INTEGER NULL CHECK (has_elevator IN (0, 1)),
  note TEXT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  last_visited_at INTEGER NULL,
  PRIMARY KEY (id)
)
''');
    db.execute('''
CREATE TABLE house_record (
  id TEXT NOT NULL,
  title TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft',
  village_id TEXT NULL REFERENCES village(id) ON DELETE SET NULL,
  building_id TEXT NULL REFERENCES building(id) ON DELETE SET NULL,
  latitude REAL NULL,
  longitude REAL NULL,
  address_text TEXT NULL,
  building_name TEXT NULL,
  room_no TEXT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  visited_at INTEGER NULL,
  PRIMARY KEY (id)
)
''');
    db.execute('''
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
    db.execute(
      "INSERT INTO village (id, name, status, created_at, updated_at) VALUES ('village-v2', '旧村', 'preparing', 1000, 1000)",
    );
    db.execute(
      "INSERT INTO house_record (id, title, status, village_id, created_at, updated_at) VALUES ('house-v2', '旧 v2 房源', 'draft', 'village-v2', 1000, 1000)",
    );
    db.execute(
      "INSERT INTO photo_asset (id, house_id, owner_type, owner_id, local_path, tag, taken_at, exif_removed) VALUES ('photo-v2', 'house-v2', 'house', 'house-v2', '/tmp/v2-room.jpg', '${PhotoTag.room}', 1000, 0)",
    );
    db.execute('PRAGMA user_version = 2');
  } finally {
    db.close();
  }
}
