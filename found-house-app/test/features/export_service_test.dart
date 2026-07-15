// 导出脱敏单测（W4 · G7，隐私红线）。
//
// 核心断言：默认导出绝不携带明文电话/微信/门牌/精确位置；
// 显式开启后才包含。PDF 字节可正常生成，且中文文本必须使用 CJK 字体避免缺字警告。

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/models/house_models.dart' as domain;
import 'package:found_house_app/features/compare/export_service.dart';
import 'package:pdf/widgets.dart' as pw;

domain.HouseRecord sensitiveHouse() {
  return const domain.HouseRecord(
    id: 'h1',
    title: '城中村东栋 3 楼',
    latitude: 22.54312,
    longitude: 114.05791,
    buildingName: '幸福小区 A 栋',
    roomNo: '3A-08',
    createdAt: 1,
    updatedAt: 1,
    contact: domain.ContactInfo(
      name: '张先生',
      phone: '13800001111',
      wechat: 'zhang_wx',
    ),
  );
}

void main() {
  const sanitizer = ExportSanitizer();

  group('默认脱敏（隐私红线）', () {
    test('默认隐藏联系人电话/微信/姓名', () {
      final s = sanitizer.sanitize(sensitiveHouse(), const ExportOptions());
      expect(s.contactLine, ExportSanitizer.hiddenMark);
      expect(s.contactLine.contains('13800001111'), isFalse);
      expect(s.contactLine.contains('zhang_wx'), isFalse);
      expect(s.contactLine.contains('张先生'), isFalse);
    });

    test('默认隐藏精确门牌', () {
      final s = sanitizer.sanitize(sensitiveHouse(), const ExportOptions());
      expect(s.roomNoLine, ExportSanitizer.hiddenMark);
      expect(s.roomNoLine.contains('3A-08'), isFalse);
    });

    test('默认隐藏精确位置，仅保留楼栋级别', () {
      final s = sanitizer.sanitize(sensitiveHouse(), const ExportOptions());
      expect(s.location.contains('114.05'), isFalse);
      expect(s.location.contains('22.54'), isFalse);
      expect(s.location, contains('幸福小区 A 栋'));
    });
  });

  group('显式开启后包含', () {
    test('开启联系人后包含电话', () {
      final s = sanitizer.sanitize(
        sensitiveHouse(),
        const ExportOptions(includeContacts: true),
      );
      expect(s.contactLine, contains('13800001111'));
    });

    test('开启精确门牌后包含门牌', () {
      final s = sanitizer.sanitize(
        sensitiveHouse(),
        const ExportOptions(includeExactRoomNo: true),
      );
      expect(s.roomNoLine, contains('3A-08'));
    });
  });

  group('隐藏摘要文案', () {
    test('默认摘要列出隐藏项', () {
      const options = ExportOptions();
      expect(options.hiddenSummary, contains('联系人'));
      expect(options.hiddenSummary, contains('门牌'));
      expect(options.hiddenSummary, contains('详细地址'));
      expect(options.hiddenSummary, isNot(contains('经纬度')));
    });
  });

  group('PDF 生成', () {
    test('默认脱敏生成 PDF 字节非空', () async {
      const service = ExportService();
      final bytes = await service.buildPdf(
        [sensitiveHouse()],
        const ExportOptions(),
      );
      expect(bytes, isNotEmpty);
      // PDF 文件魔数 %PDF。
      expect(bytes.sublist(0, 4), [0x25, 0x50, 0x44, 0x46]);
    });

    test(
      '配置中文字体后生成 PDF 不输出缺字警告',
      () async {
        final fontFile = File(r'C:\Windows\Fonts\Noto Sans SC (TrueType).otf');
        final service = ExportService(
          cjkFontLoader: () async {
            final bytes = await fontFile.readAsBytes();
            return pw.Font.ttf(bytes.buffer.asByteData());
          },
        );
        final printed = <String>[];

        final bytes = await runZoned(
          () => service.buildPdf([sensitiveHouse()], const ExportOptions()),
          zoneSpecification: ZoneSpecification(
            print: (_, __, ___, line) => printed.add(line),
          ),
        );

        expect(bytes, isNotEmpty);
        expect(
          printed.where(
            (line) =>
                line.contains('Unable to find a font') ||
                line.contains('has no Unicode support'),
          ),
          isEmpty,
        );
      },
      skip: !File(r'C:\Windows\Fonts\Noto Sans SC (TrueType).otf').existsSync(),
    );
  });
}
