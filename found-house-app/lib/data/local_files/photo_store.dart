// 照片存储（W1-2 · D4，技术方案 §8「所有照片操作通过 PhotoStore」，UI §5.4）。
//
// 职责边界：统一管理端侧照片文件的落盘、按房源归档、8 类标签、删除清理。
// 仅负责文件读写与目录结构，不含数据库行的增删（PhotoAsset 行由 HouseRepository 管理）。
//
// 目录结构：<applicationSupportDirectory>/photos/<houseId>/<uuid><ext>
// 用 applicationSupportDirectory（非 Documents，避免被系统备份/暴露），与数据库同级。

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// 照片标签常量（8 类，与字段字典 PhotoAsset.tag 对齐）。
///
/// sign 招租牌 / building 楼栋入口 / room 房间 / window 窗外 /
/// bathroom 厨卫 / meter 水电表 / contract 合同 / damage 问题留证。
class PhotoTag {
  const PhotoTag._();

  static const String sign = 'sign';
  static const String building = 'building';
  static const String room = 'room';
  static const String window = 'window';
  static const String bathroom = 'bathroom';
  static const String meter = 'meter';
  static const String contract = 'contract';
  static const String damage = 'damage';

  /// 全部合法标签，供校验与 UI 选择。
  static const List<String> all = [
    sign,
    building,
    room,
    window,
    bathroom,
    meter,
    contract,
    damage,
  ];

  /// 校验标签是否合法。
  static bool isValid(String tag) => all.contains(tag);
}

/// 照片落盘结果：新文件路径与生成的资源 id。
///
/// [assetId] 供上层写入 PhotoAsset 行；[localPath] 为归档后的最终路径。
class SavedPhoto {
  const SavedPhoto({required this.assetId, required this.localPath});

  final String assetId;
  final String localPath;
}

/// 端侧照片文件管理。避免路径散落在页面代码（编码规范）。
class PhotoStore {
  PhotoStore({Uuid? uuid, Directory? baseDirOverride})
      : _uuid = uuid ?? const Uuid(),
        _baseDirOverride = baseDirOverride;

  final Uuid _uuid;

  /// 测试注入用根目录；生产为 null，走 [getApplicationSupportDirectory]。
  final Directory? _baseDirOverride;

  /// 照片根目录：<支持目录>/photos。
  Future<Directory> _photosRoot() async {
    final base = _baseDirOverride ?? await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'photos'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 某房源的旧版照片目录：`<支持目录>/photos/<houseId>`。
  Future<Directory> _houseDir(String houseId) async {
    final root = await _photosRoot();
    final dir = Directory(p.join(root.path, houseId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 通用 owner 照片目录：`<支持目录>/photos/<ownerType>/<ownerId>`。
  Future<Directory> _ownerDir(String ownerType, String ownerId) async {
    if (ownerType.trim().isEmpty) {
      throw ArgumentError.value(ownerType, 'ownerType', '照片归属类型不能为空');
    }
    if (ownerId.trim().isEmpty) {
      throw ArgumentError.value(ownerId, 'ownerId', '照片归属对象不能为空');
    }
    final root = await _photosRoot();
    final dir = Directory(p.join(root.path, ownerType, ownerId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<SavedPhoto> _copyPhotoToDir(
    Directory dir,
    String sourcePath,
    String tag,
  ) async {
    if (!PhotoTag.isValid(tag)) {
      throw ArgumentError.value(tag, 'tag', '非法照片标签');
    }
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw ArgumentError.value(sourcePath, 'sourcePath', '源照片文件不存在');
    }
    final assetId = _uuid.v4();
    final ext = p.extension(sourcePath);
    final destPath = p.join(dir.path, '$assetId$ext');
    await source.copy(destPath);
    return SavedPhoto(assetId: assetId, localPath: destPath);
  }

  /// 将 [sourcePath] 处的照片复制归档到 [houseId] 目录下，返回资源 id 与新路径。
  ///
  /// [tag] 必须为 [PhotoTag.all] 之一，否则抛 [ArgumentError]。
  /// 保留源文件扩展名；文件名用新 uuid，避免冲突与信息泄露。
  Future<SavedPhoto> savePhoto(
    String houseId,
    String sourcePath,
    String tag,
  ) async {
    final dir = await _houseDir(houseId);
    return _copyPhotoToDir(dir, sourcePath, tag);
  }

  /// 将照片复制归档到通用 owner 目录下。
  ///
  /// 目录结构：`photos/<ownerType>/<ownerId>/<uuid><ext>`，用于村/楼栋/房源
  /// 的新 owner-aware 照片能力。旧的 [savePhoto] 保持 `photos/<houseId>`
  /// 兼容路径，避免破坏已存在的房源照片目录。
  Future<SavedPhoto> savePhotoForOwner(
    String ownerType,
    String ownerId,
    String sourcePath,
    String tag,
  ) async {
    final dir = await _ownerDir(ownerType, ownerId);
    return _copyPhotoToDir(dir, sourcePath, tag);
  }

  /// 列出某房源目录下的所有照片文件路径（不含子目录）。
  ///
  /// 目录不存在时返回空列表。用于校验与孤儿文件清理，房源展示以数据库行为准。
  Future<List<String>> listByHouse(String houseId) async {
    final root = await _photosRoot();
    final dir = Directory(p.join(root.path, houseId));
    if (!await dir.exists()) {
      return const [];
    }
    final entries = await dir.list().toList();
    return entries.whereType<File>().map((f) => f.path).toList()..sort();
  }

  /// 列出通用 owner 目录下的所有照片文件路径（不含子目录）。
  Future<List<String>> listByOwner(String ownerType, String ownerId) async {
    final root = await _photosRoot();
    final dir = Directory(p.join(root.path, ownerType, ownerId));
    if (!await dir.exists()) {
      return const [];
    }
    final entries = await dir.list().toList();
    return entries.whereType<File>().map((f) => f.path).toList()..sort();
  }

  /// 删除某房源的照片目录及全部照片文件（级联清理，W5 · H3）。
  ///
  /// 目录不存在时静默返回。
  Future<void> deleteByHouse(String houseId) async {
    final root = await _photosRoot();
    final dir = Directory(p.join(root.path, houseId));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// 删除通用 owner 照片目录及全部照片文件。
  Future<void> deleteByOwner(String ownerType, String ownerId) async {
    final root = await _photosRoot();
    final dir = Directory(p.join(root.path, ownerType, ownerId));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// 删除单个照片文件（按绝对路径）。文件不存在时静默返回。
  Future<void> deleteFile(String localPath) async {
    final file = File(localPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
