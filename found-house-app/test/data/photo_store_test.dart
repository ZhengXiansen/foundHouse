// PhotoStore 单测（W1-2）。
//
// 用临时目录作为 baseDirOverride，覆盖：保存归档、按房源列出、
// 标签校验、级联删除、单文件删除。不触碰 path_provider（生产路径）。

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/local_files/photo_store.dart';
import 'package:found_house_app/data/models/house_models.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tmp;
  late PhotoStore store;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('found_house_photo_test');
    store = PhotoStore(baseDirOverride: tmp);
  });

  tearDown(() async {
    if (await tmp.exists()) {
      await tmp.delete(recursive: true);
    }
  });

  /// 造一个源图片文件。
  Future<String> makeSource(String name) async {
    final f = File(p.join(tmp.path, name));
    await f.writeAsBytes([1, 2, 3]);
    return f.path;
  }

  test('savePhoto 归档到 photos/<houseId> 并返回 assetId 与新路径', () async {
    final src = await makeSource('src.jpg');
    final saved = await store.savePhoto('h1', src, PhotoTag.room);

    expect(saved.assetId, isNotEmpty);
    expect(await File(saved.localPath).exists(), true);
    expect(saved.localPath, contains('photos'));
    expect(saved.localPath, contains('h1'));
    expect(p.extension(saved.localPath), '.jpg');
  });

  test('savePhoto 非法标签抛 ArgumentError', () async {
    final src = await makeSource('src2.jpg');
    expect(
      () => store.savePhoto('h1', src, 'invalid_tag'),
      throwsArgumentError,
    );
  });

  test('savePhoto 源文件不存在抛 ArgumentError', () async {
    expect(
      () => store.savePhoto('h1', p.join(tmp.path, 'nope.jpg'), PhotoTag.sign),
      throwsArgumentError,
    );
  });

  test('listByHouse 列出该房源全部照片；空目录返回空', () async {
    expect(await store.listByHouse('empty'), isEmpty);

    final s1 = await makeSource('a.jpg');
    final s2 = await makeSource('b.png');
    await store.savePhoto('h2', s1, PhotoTag.building);
    await store.savePhoto('h2', s2, PhotoTag.window);

    final list = await store.listByHouse('h2');
    expect(list.length, 2);
  });

  test('deleteByHouse 清空该房源目录', () async {
    final s1 = await makeSource('c.jpg');
    await store.savePhoto('h3', s1, PhotoTag.meter);
    expect((await store.listByHouse('h3')).length, 1);

    await store.deleteByHouse('h3');
    expect(await store.listByHouse('h3'), isEmpty);

    // 目录不存在时二次删除静默。
    await store.deleteByHouse('h3');
  });

  test('deleteFile 删除单个文件', () async {
    final src = await makeSource('d.jpg');
    final saved = await store.savePhoto('h4', src, PhotoTag.damage);
    expect(await File(saved.localPath).exists(), true);

    await store.deleteFile(saved.localPath);
    expect(await File(saved.localPath).exists(), false);

    // 文件不存在时静默。
    await store.deleteFile(saved.localPath);
  });

  test('owner-aware photos 归档到 photos/<ownerType>/<ownerId>', () async {
    final src = await makeSource('building-owner.jpg');
    final saved = await store.savePhotoForOwner(
      PhotoOwnerType.building,
      'b1',
      src,
      PhotoTag.building,
    );

    expect(await File(saved.localPath).exists(), true);
    expect(
      saved.localPath,
      contains(p.join('photos', PhotoOwnerType.building, 'b1')),
    );

    expect(
      await store.listByOwner(PhotoOwnerType.building, 'missing'),
      isEmpty,
    );
    expect(
      await store.listByOwner(PhotoOwnerType.building, 'b1'),
      [saved.localPath],
    );

    await store.deleteByOwner(PhotoOwnerType.building, 'b1');
    expect(await store.listByOwner(PhotoOwnerType.building, 'b1'), isEmpty);
  });

  test('PhotoTag.all 含 8 类标签', () {
    expect(PhotoTag.all.length, 8);
    expect(PhotoTag.isValid(PhotoTag.contract), true);
    expect(PhotoTag.isValid('nope'), false);
  });
}
