// 对比导出服务（W4 · G7，UI §5.10，技术方案 §10.2）。
//
// 职责边界：把选中的房源列表在端侧生成对比 PDF，经系统分享输出，默认不上传云端。
// 所有导出统一先过脱敏：默认隐藏联系人（电话/微信/姓名）、精确门牌 roomNo、
// 精确位置；合同照片（tag=contract）默认不含（本版导出仅表格文本，
// 照片能力后置，但脱敏开关语义先落地）。
//
// 关键约束（隐私红线）：
// - 默认脱敏，敏感字段必须经 [ExportSanitizer] 过滤后才进入 PDF 内容；
// - 严禁把明文电话/微信/门牌/精确位置直接写入导出物（单测覆盖脱敏结果）；
// - 仅依赖 pdf/printing，不做网络上传。

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/house_models.dart' as domain;

/// 导出脱敏开关（默认全部隐藏敏感项，UI §5.10）。
class ExportOptions {
  const ExportOptions({
    this.includeContacts = false,
    this.includeExactRoomNo = false,
    this.includeExactLocation = false,
    this.includeContractPhotos = false,
  });

  /// 是否包含联系人（电话/微信/姓名）。默认隐藏。
  final bool includeContacts;

  /// 是否包含精确门牌 roomNo。默认隐藏（仅保留片区/楼栋级别）。
  final bool includeExactRoomNo;

  /// 是否包含精确位置。默认隐藏。
  final bool includeExactLocation;

  /// 是否包含合同照片（tag=contract）。默认关闭，高敏感需主动开启。
  final bool includeContractPhotos;

  /// 当前隐藏项摘要文案（导出预览顶部提示，UI §5.10）。
  String get hiddenSummary {
    final hidden = <String>[];
    if (!includeContacts) hidden.add('联系人');
    if (!includeExactRoomNo) hidden.add('门牌');
    if (!includeExactLocation) hidden.add('详细地址');
    return hidden.isEmpty ? '未隐藏敏感项' : '已隐藏${hidden.join('、')}';
  }
}

/// 脱敏后的单套房源导出视图（纯数据，便于单测断言）。
///
/// 敏感字段按 [ExportOptions] 过滤：隐藏时统一以占位符/近似值替代，
/// 绝不携带明文。
class SanitizedHouse {
  const SanitizedHouse({
    required this.title,
    required this.location,
    required this.contactLine,
    required this.roomNoLine,
  });

  /// 房源标题（非敏感）。
  final String title;

  /// 位置行：隐藏精确位置时仅显示楼栋/片区，否则显示近似坐标。
  final String location;

  /// 联系人行：隐藏时显示「已隐藏」。
  final String contactLine;

  /// 门牌行：隐藏时显示「已隐藏」。
  final String roomNoLine;
}

/// 导出脱敏器（纯函数，单测覆盖：确认明文敏感字段不外泄）。
class ExportSanitizer {
  const ExportSanitizer();

  /// 隐藏敏感字段占位文案。
  static const String hiddenMark = '已隐藏';

  /// 按开关脱敏单套房源。
  SanitizedHouse sanitize(domain.HouseRecord house, ExportOptions options) {
    return SanitizedHouse(
      title: house.title,
      location: _location(house, options),
      contactLine: _contact(house.contact, options),
      roomNoLine: _roomNo(house.roomNo, options),
    );
  }

  /// 位置：默认只给楼栋/片区级别，不给精确位置。
  String _location(domain.HouseRecord house, ExportOptions options) {
    final building = house.buildingName?.trim();
    final area = (building != null && building.isNotEmpty)
        ? building
        : (house.addressText?.trim() ?? '');
    if (!options.includeExactLocation) {
      return area.isEmpty ? '（近似位置）' : area;
    }
    final lat = house.latitude;
    final lng = house.longitude;
    if (lat == null || lng == null) {
      return area.isEmpty ? '（无坐标）' : area;
    }
    return '$area (${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)})';
  }

  /// 联系人：默认隐藏电话/微信/姓名。
  String _contact(domain.ContactInfo? contact, ExportOptions options) {
    if (!options.includeContacts) return hiddenMark;
    if (contact == null) return '未记录';
    final parts = <String>[];
    if (contact.name?.trim().isNotEmpty == true) {
      parts.add(contact.name!.trim());
    }
    if (contact.phone?.trim().isNotEmpty == true) {
      parts.add(contact.phone!.trim());
    }
    if (contact.wechat?.trim().isNotEmpty == true) {
      parts.add('微信 ${contact.wechat!.trim()}');
    }
    return parts.isEmpty ? '未记录' : parts.join(' / ');
  }

  /// 门牌：默认隐藏精确门牌。
  String _roomNo(String? roomNo, ExportOptions options) {
    if (!options.includeExactRoomNo) return hiddenMark;
    final t = roomNo?.trim();
    return (t == null || t.isEmpty) ? '未记录' : t;
  }
}

/// 对比导出服务：生成脱敏对比 PDF 并走系统分享。
class ExportService {
  const ExportService({
    ExportSanitizer? sanitizer,
    Future<pw.Font> Function()? cjkFontLoader,
  })  : _sanitizer = sanitizer ?? const ExportSanitizer(),
        _cjkFontLoader = cjkFontLoader;

  final ExportSanitizer _sanitizer;
  final Future<pw.Font> Function()? _cjkFontLoader;

  /// 导出房源对比（默认脱敏）。生成 PDF 后经系统分享输出，不上传云端。
  ///
  /// [includeContacts] / [includeContractPhotos] 默认关闭（隐私红线）。
  Future<void> exportComparison(
    List<domain.HouseRecord> houses, {
    bool includeContacts = false,
    bool includeContractPhotos = false,
  }) async {
    final options = ExportOptions(
      includeContacts: includeContacts,
      includeContractPhotos: includeContractPhotos,
    );
    final bytes = await buildPdf(houses, options);
    await Printing.sharePdf(bytes: bytes, filename: 'house_comparison.pdf');
  }

  /// 生成脱敏对比 PDF 字节（抽出便于单测校验内容不含明文敏感字段）。
  Future<Uint8List> buildPdf(
    List<domain.HouseRecord> houses,
    ExportOptions options,
  ) async {
    final sanitized =
        houses.map((h) => _sanitizer.sanitize(h, options)).toList();
    final cjkFont = await _loadCjkFont();

    final doc = pw.Document(
      theme: cjkFont == null
          ? null
          : pw.ThemeData.withFont(
              base: cjkFont,
              bold: cjkFont,
              fontFallback: [cjkFont],
            ),
    );
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Text(
              '房源对比',
              style: const pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            // 顶部脱敏状态提示（UI §5.10：预览页显示隐私状态）。
            pw.Text(
              options.hiddenSummary,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 12),
            _buildTable(sanitized),
          ];
        },
      ),
    );
    return doc.save();
  }

  /// 对比表：行=指标，列=房源。当前覆盖标题/位置/联系人/门牌（脱敏后）。
  pw.Widget _buildTable(List<SanitizedHouse> houses) {
    final headers = ['指标', for (final h in houses) h.title];
    final rows = <List<String>>[
      ['位置', for (final h in houses) h.location],
      ['联系人', for (final h in houses) h.contactLine],
      ['门牌', for (final h in houses) h.roomNoLine],
    ];
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle:
          const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    );
  }

  Future<pw.Font?> _loadCjkFont() async {
    final injected = _cjkFontLoader;
    if (injected != null) {
      final font = await injected();
      if (await _canRenderCjk(font)) return font;
    }

    final local = await _loadLocalCjkFont();
    if (local != null) return local;

    try {
      WidgetsFlutterBinding.ensureInitialized();
      final font = await PdfGoogleFonts.notoSansSCRegular();
      return await _canRenderCjk(font) ? font : null;
    } catch (_) {
      return null;
    }
  }

  Future<pw.Font?> _loadLocalCjkFont() async {
    const candidates = [
      r'C:\Windows\Fonts\msyh.ttc',
      r'C:\Windows\Fonts\Noto Sans SC (TrueType).otf',
      '/System/Library/Fonts/PingFang.ttc',
      '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc',
      '/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc',
    ];
    for (final path in candidates) {
      final file = File(path);
      if (!file.existsSync()) continue;
      final bytes = await file.readAsBytes();
      final font = pw.Font.ttf(bytes.buffer.asByteData());
      if (await _canRenderCjk(font)) return font;
    }
    return null;
  }

  Future<bool> _canRenderCjk(pw.Font font) async {
    return runZoned(
      () async {
        try {
          final doc = pw.Document(
            theme: pw.ThemeData.withFont(
              base: font,
              bold: font,
              fontFallback: [font],
            ),
          );
          doc.addPage(
            pw.Page(
              build: (_) => pw.Text('房'),
            ),
          );
          await doc.save();
          return true;
        } catch (_) {
          return false;
        }
      },
      zoneSpecification: ZoneSpecification(
        print: (_, __, ___, ____) {},
      ),
    );
  }
}
