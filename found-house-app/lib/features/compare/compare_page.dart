// 对比页（W4 · G6，UI §5.9）。
//
// 职责边界：从全部房源里选择 ≥2 套横向对比。列=房源、行=维度（月总成本/通勤/
// 各维度分/风险），每行最优值绿底高亮，风险行明确标注，底部给一句综合结论。
// 导出按钮调用 ExportService（默认脱敏）。
//
// 关键约束：本页只读展示 + 选择，不改库、不含评分业务（编排在
// house_scoring_controller）。导出统一走脱敏服务（隐私红线）。

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/kawaii_widgets.dart';
import '../../app/theme.dart';
import '../../data/models/house_models.dart' as domain;
import '../scoring/house_scoring_controller.dart';
import 'export_service.dart';

/// 对比页：候选选择器 + 横向对比表 + 结论句 + 导出。
class ComparePage extends ConsumerStatefulWidget {
  const ComparePage({super.key});

  @override
  ConsumerState<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends ConsumerState<ComparePage> {
  /// 已选房源 id 集合（保持选择顺序即为列顺序）。
  final List<String> _selectedIds = [];

  @override
  Widget build(BuildContext context) {
    final housesAsync = ref.watch(housesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('对比')),
      body: housesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('房源加载失败：$e', textAlign: TextAlign.center),
          ),
        ),
        data: (houses) {
          if (houses.length < 2) {
            return const _NotEnoughState();
          }
          // 清理已删除房源的选中态。
          final validIds = houses.map((h) => h.id).toSet();
          _selectedIds.removeWhere((id) => !validIds.contains(id));

          final pref = ref.watch(preferenceProfileProvider).valueOrNull;
          final service = ref.watch(houseScoringServiceProvider);

          final selected = _selectedIds
              .map((id) => houses.firstWhere((h) => h.id == id))
              .toList();

          return Column(
            children: [
              _CandidatePicker(
                houses: houses,
                selectedIds: _selectedIds,
                onToggle: _toggle,
              ),
              const Divider(height: 1),
              Expanded(
                child: selected.length < 2
                    ? const _PickHint()
                    : _ComparisonBody(
                        houses: selected,
                        service: service,
                        pref: pref,
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _selectedIds.length >= 2
          ? _ExportBar(
              onExport: () => _export(context),
            )
          : null,
    );
  }

  void _toggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _export(BuildContext context) async {
    final housesAsync = ref.read(housesStreamProvider);
    final houses = housesAsync.valueOrNull;
    if (houses == null) return;
    final selected =
        _selectedIds.map((id) => houses.firstWhere((h) => h.id == id)).toList();

    // 默认全部脱敏导出（隐私红线：联系人/合同照片默认关闭）。
    const service = ExportService();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await service.exportComparison(selected);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('导出失败：$e')),
      );
    }
  }
}

/// 候选选择器：横向可滚动的房源选择 chip。
class _CandidatePicker extends StatelessWidget {
  const _CandidatePicker({
    required this.houses,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<domain.HouseRecord> houses;
  final List<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择要对比的房源（至少 2 套）',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final h in houses)
                FilterChip(
                  label: Text(
                    h.title,
                    style: const TextStyle(fontSize: 13),
                  ),
                  selected: selectedIds.contains(h.id),
                  selectedColor: AppColors.primary.withValues(alpha: 0.16),
                  checkmarkColor: AppColors.primary,
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    onToggle(h.id);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 对比表主体：行=指标，列=房源，最优值绿底。
class _ComparisonBody extends StatelessWidget {
  const _ComparisonBody({
    required this.houses,
    required this.service,
    required this.pref,
  });

  final List<domain.HouseRecord> houses;
  final HouseScoringService service;
  final domain.PreferenceProfile? pref;

  @override
  Widget build(BuildContext context) {
    final views = houses.map((h) => service.evaluate(h, pref)).toList();
    final rows = _buildRows(views);
    final conclusion = _conclusion(houses, views);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _Table(houses: houses, rows: rows),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _ConclusionCard(text: conclusion),
          ),
        ],
      ),
    );
  }

  /// 组装对比行。每行标注「最优列索引」用于绿底高亮；-1 表示无最优（如并列或不可比）。
  List<_CompareRow> _buildRows(List<HouseScoreView> views) {
    return [
      _CompareRow(
        label: '月总成本',
        cells: [
          for (final v in views)
            '${v.estimatedTotalMonthly} 元${v.cost.hasMissingFee ? '(估)' : ''}',
        ],
        // 成本越低越好。
        bestIndex: _minIndex([
          for (final v in views) v.estimatedTotalMonthly.toDouble(),
        ]),
      ),
      _CompareRow(
        label: '通勤',
        cells: [
          for (final v in views)
            v.primaryCommuteMinutes == null
                ? '待补'
                : '${v.primaryCommuteMinutes} 分钟',
        ],
        // 通勤越短越好；无数据不参与最优。
        bestIndex: _minIndex([
          for (final v in views)
            v.primaryCommuteMinutes?.toDouble() ?? double.infinity,
        ]),
      ),
      _CompareRow(
        label: '总分',
        cells: [for (final v in views) v.total.round().toString()],
        bestIndex: _maxIndex([for (final v in views) v.total]),
      ),
      _CompareRow(
        label: '成本分',
        cells: [
          for (final v in views) v.score.breakdown.cost.round().toString(),
        ],
        bestIndex: _maxIndex([for (final v in views) v.score.breakdown.cost]),
      ),
      _CompareRow(
        label: '通勤分',
        cells: [
          for (final v in views) v.score.breakdown.commute.round().toString(),
        ],
        bestIndex:
            _maxIndex([for (final v in views) v.score.breakdown.commute]),
      ),
      _CompareRow(
        label: '居住分',
        cells: [
          for (final v in views) v.score.breakdown.living.round().toString(),
        ],
        bestIndex: _maxIndex([for (final v in views) v.score.breakdown.living]),
      ),
      _CompareRow(
        label: '周边分',
        cells: [
          for (final v in views) v.score.breakdown.nearby.round().toString(),
        ],
        bestIndex: _maxIndex([for (final v in views) v.score.breakdown.nearby]),
      ),
      _CompareRow(
        label: '风险分',
        cells: [
          for (final v in views) v.score.breakdown.risk.round().toString(),
        ],
        bestIndex: _maxIndex([for (final v in views) v.score.breakdown.risk]),
      ),
      _CompareRow(
        label: '风险/淘汰',
        cells: [for (final v in views) _riskCell(v)],
        bestIndex: -1,
        isRisk: true,
      ),
    ];
  }

  String _riskCell(HouseScoreView v) {
    if (v.hasBlocker) return '已淘汰(红线)';
    if (v.rejected) return '已淘汰';
    final reasonCount = v.filter.reasons.length;
    if (reasonCount > 0) return '$reasonCount 项问题';
    return '通过';
  }

  /// 结论句：优先推荐「通过硬筛且总分最高」，全被淘汰时给排除提示。
  String _conclusion(
    List<domain.HouseRecord> houses,
    List<HouseScoreView> views,
  ) {
    var bestIdx = -1;
    var bestScore = -1.0;
    for (var i = 0; i < views.length; i++) {
      if (views[i].rejected) continue;
      if (views[i].total > bestScore) {
        bestScore = views[i].total;
        bestIdx = i;
      }
    }
    if (bestIdx < 0) {
      return '所选房源均未通过硬筛，建议先排除红线与超预算/超通勤项，或调整偏好后再对比。';
    }
    return '综合最优：${houses[bestIdx].title}（总分 ${views[bestIdx].total.round()}，已通过硬筛）。'
        '最终选择请结合你最看重的维度。';
  }

  /// 最小值所在列索引；全为 infinity（无有效值）时返回 -1。
  int _minIndex(List<double> values) {
    var idx = -1;
    var best = double.infinity;
    for (var i = 0; i < values.length; i++) {
      if (values[i] < best) {
        best = values[i];
        idx = i;
      }
    }
    return best.isFinite ? idx : -1;
  }

  /// 最大值所在列索引。
  int _maxIndex(List<double> values) {
    var idx = -1;
    var best = double.negativeInfinity;
    for (var i = 0; i < values.length; i++) {
      if (values[i] > best) {
        best = values[i];
        idx = i;
      }
    }
    return idx;
  }
}

/// 单条对比行数据。
class _CompareRow {
  const _CompareRow({
    required this.label,
    required this.cells,
    required this.bestIndex,
    this.isRisk = false,
  });

  /// 指标名。
  final String label;

  /// 各列取值文案。
  final List<String> cells;

  /// 最优列索引（绿底高亮），-1 表示无最优。
  final int bestIndex;

  /// 是否风险行（红字标注）。
  final bool isRisk;
}

/// 横向对比表：首行房源名，随后每行一个指标。
class _Table extends StatelessWidget {
  const _Table({required this.houses, required this.rows});

  final List<domain.HouseRecord> houses;
  final List<_CompareRow> rows;

  static const double _labelWidth = 84;
  static const double _cellWidth = 120;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 表头：房源名称行。
        Row(
          children: [
            _headerCell('房源', width: _labelWidth),
            for (final h in houses) _headerCell(h.title, width: _cellWidth),
          ],
        ),
        for (final row in rows) _buildRow(row),
      ],
    );
  }

  Widget _buildRow(_CompareRow row) {
    // IntrinsicHeight 约束 Row 高度，令 stretch 生效同时避免嵌套滚动视图下
    // 的无限高度（水平 + 垂直 SingleChildScrollView 双向无界）。
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _labelCell(row.label),
          for (var i = 0; i < row.cells.length; i++)
            _valueCell(
              row.cells[i],
              best: i == row.bestIndex,
              isRisk: row.isRisk,
            ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _labelCell(String text) {
    return Container(
      width: _labelWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _valueCell(String text, {required bool best, required bool isRisk}) {
    final isRejectCell = isRisk && text.contains('淘汰');
    return Container(
      width: _cellWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        // 最优值绿色轻底（UI §5.9）。
        color: best ? AppColors.mint.withValues(alpha: 0.14) : null,
        border: const Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          if (isRejectCell) ...[
            const Icon(Icons.block, size: 13, color: AppColors.risk),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isRisk && isRejectCell
                    ? AppColors.risk
                    : (best ? AppColors.mint : AppColors.textPrimary),
                fontWeight: best ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 结论卡片。
class _ConclusionCard extends StatelessWidget {
  const _ConclusionCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 18,
            color: context.kawaiiPalette.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// 导出操作栏（默认脱敏，UI §5.10）。
class _ExportBar extends StatelessWidget {
  const _ExportBar({required this.onExport});

  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                '导出默认隐藏联系人、门牌、详细地址',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            FilledButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.ios_share, size: 18),
              label: const Text('导出对比'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 房源不足 2 套时的提示。
class _NotEnoughState extends StatelessWidget {
  const _NotEnoughState();

  @override
  Widget build(BuildContext context) {
    return const KawaiiEmptyState(
      icon: Icons.compare_arrows_rounded,
      title: '至少需要 2 套房源才能对比',
      description: '去扫楼页多记录几套候选房，再到这里并排比较。',
      iconColor: AppColors.offline,
    );
  }
}

/// 已有房源但未选够 2 套时的提示。
class _PickHint extends StatelessWidget {
  const _PickHint();

  @override
  Widget build(BuildContext context) {
    return const KawaiiEmptyState(
      icon: Icons.touch_app_outlined,
      title: '选择房源开始对比',
      description: '在上方至少选择 2 套房源。导出默认脱敏联系人与门牌。',
      iconColor: AppColors.offline,
    );
  }
}
