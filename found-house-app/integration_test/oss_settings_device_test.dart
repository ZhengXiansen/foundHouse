// OSS 云存储设置真机流程覆盖（端侧直配密钥模式）。
//
// 覆盖：从「我的」进入 OSS 云存储入口 → 表单字段可见 → 未填全时启用被校验拦截
// → 填全并启用保存后配置持久化到 store 且 isActive 为真 → 重进页面回填。
// 用内存 KeyStore override ossConfigStoreProvider，不触碰真机 secure storage 通道。

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/app/app.dart';
import 'package:found_house_app/data/crypto/crypto_service.dart';
import 'package:found_house_app/data/crypto/field_cipher.dart';
import 'package:found_house_app/data/db/app_database.dart';
import 'package:found_house_app/data/local_files/photo_store.dart';
import 'package:found_house_app/data/providers.dart';
import 'package:found_house_app/integrations/oss/oss_config.dart';
import 'package:integration_test/integration_test.dart';

/// 内存版 KeyStore，供真机测试注入，不触碰平台安全存储通道。
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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OSS 云存储：入口可达、未填全启用被拦截、填全启用保存并持久化', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    final ossStore = OssConfigStore(_InMemoryKeyStore());

    Future<void> pumpFrames([int count = 8]) async {
      for (var i = 0; i < count; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> pumpUntilFound(Finder finder, {int maxFrames = 50}) async {
      for (var i = 0; i < maxFrames; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (finder.evaluate().isNotEmpty) return;
      }
      expect(finder, findsWidgets);
    }

    Future<void> enterByLabel(String label, String value) async {
      final finder = find.widgetWithText(TextFormField, label);
      await tester.ensureVisible(finder.first);
      await pumpFrames(2);
      expect(finder, findsWidgets, reason: '应找到输入框：$label');
      await tester.enterText(finder.first, value);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpFrames(3);
    }

    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpFrames(2);
      await db.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          fieldCipherProvider.overrideWithValue(const NoopFieldCipher()),
          photoStoreProvider.overrideWithValue(
            PhotoStore(baseDirOverride: Directory.systemTemp),
          ),
          ossConfigStoreProvider.overrideWithValue(ossStore),
        ],
        child: const FoundHouseApp(),
      ),
    );
    await pumpFrames(12);

    // 进入「我的」Tab。
    await tester.tap(find.text('我的'));
    await pumpUntilFound(find.text('OSS 云存储'));
    expect(find.text('OSS 云存储'), findsWidgets);

    // 打开 OSS 云存储设置页。
    await tester.tap(find.text('OSS 云存储').hitTestable().first);
    await pumpUntilFound(find.text('启用 OSS 上传'));
    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Endpoint'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Bucket'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'AccessKeyId'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'AccessKeySecret'),
      findsOneWidget,
    );

    // 负向：只开启开关但不填配置，保存应被校验拦截，配置不启用。
    await tester.tap(find.byType(SwitchListTile));
    await pumpFrames(4);
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await pumpFrames(6);
    expect(
      find.textContaining('启用 OSS 需填全'),
      findsWidgets,
      reason: '未填全时启用保存应弹出校验提示',
    );
    expect((await ossStore.load()).isActive, isFalse);

    // 正向：填全必填项后保存，配置应持久化且 isActive。
    await enterByLabel('Endpoint', 'oss-cn-shenzhen.aliyuncs.com');
    await enterByLabel('Bucket', 'my-found-house');
    await enterByLabel('AccessKeyId', 'LTAI-test-id');
    await enterByLabel('AccessKeySecret', 'test-secret');
    await enterByLabel('路径前缀', 'photos/');
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await pumpFrames(8);

    final saved = await ossStore.load();
    expect(saved.enabled, isTrue);
    expect(saved.isComplete, isTrue);
    expect(saved.isActive, isTrue);
    expect(saved.endpoint, 'oss-cn-shenzhen.aliyuncs.com');
    expect(saved.bucket, 'my-found-house');
    expect(saved.accessKeyId, 'LTAI-test-id');
    expect(saved.accessKeySecret, 'test-secret');
    expect(saved.normalizedPrefix, 'photos/');
    expect(
      saved.publicUrlFor('photos/house/h1/a.jpg'),
      'https://my-found-house.oss-cn-shenzhen.aliyuncs.com/photos/house/h1/a.jpg',
    );
  });
}
