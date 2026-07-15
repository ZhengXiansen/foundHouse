// Checklist 页（W1-2 · D5，UI §5.6）。
//
// 职责边界：从内置模板（checklist_template.dart，镜像 docs/rules/checklist-template.json）
// 加载五模块（房间/厨卫/楼栋/合同/风险）检查项，每项四态分段控件
// （good/ok/bad/not_seen；risk 模块用 hit/not_hit/not_seen），展示各模块完成度。
//
// 数据落库：进入时按 houseId 拉取已存检查项，与模板 key 对齐回填；用户点选某态即
// upsert 该检查项（无则 addChecklistItem，有则 updateChecklistItem）。
//
// 风险联动：risk 模块选「命中」时，除写 ChecklistItem 外，同步 upsert 一条 RiskFlag
// （severity 取模板定义），取消命中则删除对应 RiskFlag——保证详情页风险摘要一致。
//
// 关键约束：仅读写，不做评分/硬筛（那是引擎）。not_seen 计入缺失提醒但不计分（评分轨处理）。

import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/kawaii_widgets.dart';
import '../../app/theme.dart';
import '../../data/models/house_models.dart' as domain;
import '../../data/providers.dart';
import '../../data/repositories/house_repository.dart';
import 'checklist_template.dart';

/// Checklist 页：五模块四态分段控件 + 模块完成度。
class ChecklistPage extends ConsumerStatefulWidget {
  const ChecklistPage({required this.houseId, super.key});

  /// 关联房源主键（HouseRecord.id）。
  final String houseId;

  @override
  ConsumerState<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends ConsumerState<ChecklistPage> {
  /// key -> 已存检查项（含 id，用于更新/删除）。回填与 upsert 判断的依据。
  final Map<String, domain.ChecklistItem> _itemsByKey = {};

  /// key -> 已存风险标记 id（risk 命中时写入，取消命中时删除）。
  final Map<String, String> _riskIdByKey = {};

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  HouseRepository get _repo => ref.read(houseRepositoryProvider);

  Future<void> _load() async {
    final items = await _repo.getChecklistItems(widget.houseId);
    final risks = await _repo.getRiskFlags(widget.houseId);
    if (!mounted) return;
    _itemsByKey
      ..clear()
      ..addEntries(items.map((i) => MapEntry(i.key, i)));
    _riskIdByKey
      ..clear()
      ..addEntries(
        risks
            .where((r) => r.source == 'user')
            .map((r) => MapEntry(r.key, r.id)),
      );
    setState(() => _loaded = true);
  }

  /// 点选某检查项的取值：upsert ChecklistItem；risk 模块联动 RiskFlag。
  Future<void> _select(
    ChecklistModuleTemplate module,
    ChecklistItemTemplate item,
    String value,
  ) async {
    final existing = _itemsByKey[item.key];
    // 再次点击已选项 = 取消（回到未作答，删除该项）。
    final isToggleOff = existing?.value == value;

    if (isToggleOff) {
      if (existing != null) {
        await _repo.deleteChecklistItem(existing.id);
        _itemsByKey.remove(item.key);
      }
    } else if (existing == null) {
      final id = await _repo.addChecklistItem(
        widget.houseId,
        module: module.module,
        key: item.key,
        value: value,
      );
      _itemsByKey[item.key] = domain.ChecklistItem(
        id: id,
        houseId: widget.houseId,
        module: module.module,
        key: item.key,
        value: value,
      );
    } else {
      await _repo.updateChecklistItem(existing.id, value: Value(value));
      _itemsByKey[item.key] = domain.ChecklistItem(
        id: existing.id,
        houseId: existing.houseId,
        module: existing.module,
        key: existing.key,
        value: value,
        note: existing.note,
      );
    }

    // risk 模块联动风险标记：命中 → 建 RiskFlag；非命中/取消 → 删 RiskFlag。
    if (module.module == 'risk') {
      await _syncRiskFlag(item, isToggleOff ? null : value);
    }

    if (!mounted) return;
    setState(() {});
  }

  /// 同步风险标记：value==hit 且尚无标记时新建；否则删除已有标记。
  Future<void> _syncRiskFlag(ChecklistItemTemplate item, String? value) async {
    final hit = value == ChecklistValue.hit;
    final existingId = _riskIdByKey[item.key];
    if (hit && existingId == null) {
      final id = await _repo.addRiskFlag(
        widget.houseId,
        key: item.key,
        severity: item.severity ?? 'warning',
      );
      _riskIdByKey[item.key] = id;
    } else if (!hit && existingId != null) {
      await _repo.deleteRiskFlag(existingId);
      _riskIdByKey.remove(item.key);
    }
  }

  /// 模块完成度：已作答（含 not_seen 也算「看过并记录」）项数 / 模块总项数。
  ///
  /// 注：completion 口径取「是否已作答」；评分层另按 not_seen 不计分处理，两者不冲突。
  String _moduleBadge(ChecklistModuleTemplate module) {
    final total = module.items.length;
    final answered =
        module.items.where((i) => _itemsByKey.containsKey(i.key)).length;
    return '$answered/$total';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('看房清单')),
      body: !_loaded
          ? const KawaiiLoadingList(itemCount: 3)
          : ListView(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: KawaiiPageHeading(
                    eyebrow: '现场对照勾选',
                    title: '看房清单',
                    description: '点选即可保存；红线项命中会同步风险标记。',
                    icon: Icons.checklist_rounded,
                    accentColor: AppColors.mint,
                  ),
                ),
                for (final module in kChecklistTemplate)
                  _ModuleCard(
                    module: module,
                    badge: _moduleBadge(module),
                    valueOf: (key) => _itemsByKey[key]?.value,
                    onSelect: (item, value) => _select(module, item, value),
                  ),
              ],
            ),
    );
  }
}

/// 单个模块卡片：标题 + 完成度 + 各检查项四态分段控件。
class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.badge,
    required this.valueOf,
    required this.onSelect,
  });

  final ChecklistModuleTemplate module;
  final String badge;
  final String? Function(String key) valueOf;
  final void Function(ChecklistItemTemplate item, String value) onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRisk = module.module == 'risk';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    module.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(minHeight: 28),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRisk
                        ? AppColors.risk.withValues(alpha: 0.10)
                        : AppColors.mint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isRisk
                          ? AppColors.risk.withValues(alpha: 0.22)
                          : AppColors.mint.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isRisk ? AppColors.risk : AppColors.mint,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final item in module.items)
              _ChecklistRow(
                module: module,
                item: item,
                value: valueOf(item.key),
                isRisk: isRisk,
                onSelect: (v) => onSelect(item, v),
              ),
          ],
        ),
      ),
    );
  }
}

/// 单个检查项行：左标签（含 blocker 红线标记）+ 右四态分段控件。
class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.module,
    required this.item,
    required this.value,
    required this.isRisk,
    required this.onSelect,
  });

  final ChecklistModuleTemplate module;
  final ChecklistItemTemplate item;
  final String? value;
  final bool isRisk;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBlocker = item.severity == 'blocker';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.label, style: theme.textTheme.bodyMedium),
              ),
              if (isBlocker)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.risk.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '红线',
                    style: TextStyle(fontSize: 11, color: AppColors.risk),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          _ValueSegments(
            options: module.valueOptions,
            module: module.module,
            value: value,
            emphasizeHit: isRisk,
            onSelect: onSelect,
          ),
        ],
      ),
    );
  }
}

/// 四态分段控件：一行等宽分段，选中高亮。
///
/// 普通模块选中用主色；risk 模块「命中」选中用风险红，强调风险语义（UI §4.1）。
class _ValueSegments extends StatelessWidget {
  const _ValueSegments({
    required this.options,
    required this.module,
    required this.value,
    required this.emphasizeHit,
    required this.onSelect,
  });

  final List<String> options;
  final String module;
  final String? value;
  final bool emphasizeHit;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: _SegmentButton(
              label: checklistValueLabel(module, options[i]),
              selected: value == options[i],
              color: emphasizeHit && options[i] == ChecklistValue.hit
                  ? AppColors.risk
                  : context.kawaiiPalette.primary,
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(options[i]);
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// 分段控件的单个按钮。
class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppColors.divider,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
