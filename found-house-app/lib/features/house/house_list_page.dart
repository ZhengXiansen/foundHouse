// 房源列表页（W4 · G5，UI §5.7）。
//
// 职责边界：全部记录的复盘主入口。watch 房源流 + 偏好流，对每套房源调用
// HouseScoringService 得到组合视图（硬筛 + 总分 + 成本 + 通勤），按所选排序
// 展示。硬筛通过的按总分降序；淘汰（rejected/blocker）降权置底并显示淘汰原因
// （不隐藏，UI §5.7）。点击卡片进入房源详情。
//
// 关键约束：本页只读展示与排序，不改库、不含评分业务（映射与编排在
// house_scoring_controller）。敏感字段（门牌等）不在卡片直接展示明文。

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/kawaii_widgets.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../data/models/house_models.dart' as domain;
import '../../data/providers.dart';
import '../common/delete_confirmation.dart';
import '../scoring/house_scoring_controller.dart';

/// 列表排序方式（UI §5.7 排序分段：推荐/价格/通勤/最近）。
enum HouseSort {
  recommended('推荐'),
  price('价格'),
  commute('通勤'),
  recent('最近');

  const HouseSort(this.label);

  /// 分段控件显示标签。
  final String label;
}

/// 房源列表页：排序分段 + 卡片列表 + 空状态引导。
class HouseListPage extends ConsumerStatefulWidget {
  const HouseListPage({
    super.key,
    this.fixedVillageId,
    this.fixedVillageName,
    this.fixedBuildingId,
    this.fixedBuildingName,
  });

  final String? fixedVillageId;
  final String? fixedVillageName;
  final String? fixedBuildingId;
  final String? fixedBuildingName;

  @override
  ConsumerState<HouseListPage> createState() => _HouseListPageState();
}

class _HouseListPageState extends ConsumerState<HouseListPage> {
  HouseSort _sort = HouseSort.recommended;
  String? _selectedVillageId;

  bool get _hasFixedVillage => widget.fixedVillageId?.trim().isNotEmpty == true;

  bool get _hasFixedBuilding =>
      widget.fixedBuildingId?.trim().isNotEmpty == true;

  bool get _hasFixedContext => _hasFixedVillage || _hasFixedBuilding;

  String get _title {
    if (_hasFixedBuilding) {
      final name = widget.fixedBuildingName?.trim();
      return '${name?.isNotEmpty == true ? name : '该楼栋'}房源';
    }
    if (_hasFixedVillage) {
      final name = widget.fixedVillageName?.trim();
      return '${name?.isNotEmpty == true ? name : '该村'}房源';
    }
    return '房源';
  }

  String get _emptyFilteredTitle =>
      _hasFixedBuilding ? '这个楼栋还没有房源记录' : '这个村还没有房源记录';

  @override
  Widget build(BuildContext context) {
    final housesAsync = ref.watch(housesStreamProvider);
    final villagesAsync = ref.watch(villagesWithStatsProvider);
    final prefAsync = ref.watch(preferenceProfileProvider);
    final service = ref.watch(houseScoringServiceProvider);
    final houseRepository = ref.read(houseRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_hasFixedContext ? 48 : 96),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_hasFixedContext) ...[
                  _VillageFilterBar(
                    villagesAsync: villagesAsync,
                    selectedVillageId: _selectedVillageId,
                    onChanged: (id) => setState(() => _selectedVillageId = id),
                  ),
                  const SizedBox(height: 8),
                ],
                _SortBar(
                  value: _sort,
                  onChanged: (s) => setState(() => _sort = s),
                ),
              ],
            ),
          ),
        ),
      ),
      body: housesAsync.when(
        loading: () => const KawaiiLoadingList(itemCount: 4),
        error: (e, _) => KawaiiErrorState(
          message: '房源加载失败：$e',
          onRetry: () => ref.invalidate(housesStreamProvider),
        ),
        data: (houses) {
          if (houses.isEmpty && !_hasFixedContext) return const _EmptyState();
          final filteredHouses = _filterHouses(houses);
          if (filteredHouses.isEmpty) {
            return _EmptyFilteredState(title: _emptyFilteredTitle);
          }
          final pref = prefAsync.valueOrNull;
          final views = _buildSortedViews(filteredHouses, pref, service);
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 96),
            itemCount: views.length,
            itemBuilder: (context, index) {
              final entry = views[index];
              return SwipeDeleteAction(
                key: ValueKey('house-${entry.house.id}'),
                actionInsets: _HouseCard.cardMargin,
                onDelete: () async {
                  final confirmed = await confirmDeleteRecord(
                    context,
                    title: '删除房源',
                    message: '确认删除「${entry.house.title}」？该房源的照片和补充信息都会删除。',
                  );
                  if (!confirmed) return;
                  try {
                    await houseRepository.delete(entry.house.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('房源已删除')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('删除失败：$e')),
                      );
                    }
                  }
                },
                child: _HouseCard(
                  house: entry.house,
                  view: entry.view,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.pushNamed(
                      AppRoutes.houseDetailName,
                      pathParameters: {'houseId': entry.house.id},
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<domain.HouseRecord> _filterHouses(List<domain.HouseRecord> houses) {
    final fixedBuildingId = widget.fixedBuildingId?.trim();
    if (fixedBuildingId?.isNotEmpty == true) {
      final fixedVillageId = widget.fixedVillageId?.trim();
      return houses
          .where(
            (house) =>
                house.buildingId == fixedBuildingId &&
                (fixedVillageId?.isNotEmpty != true ||
                    house.villageId == fixedVillageId),
          )
          .toList(growable: false);
    }

    final fixedVillageId = widget.fixedVillageId?.trim();
    if (fixedVillageId?.isNotEmpty == true) {
      return houses
          .where((house) => house.villageId == fixedVillageId)
          .toList(growable: false);
    }

    final selectedVillageId = _selectedVillageId;
    if (selectedVillageId == null) return houses;
    return houses
        .where((house) => house.villageId == selectedVillageId)
        .toList(growable: false);
  }

  /// 对每套房源算分并按所选排序返回。
  ///
  /// 推荐排序：先按「是否通过硬筛」分组（通过在前），组内按总分降序；
  /// 淘汰组整体置底（降权保留，不隐藏）。价格/通勤/最近为单一维度排序。
  List<_HouseEntry> _buildSortedViews(
    List<domain.HouseRecord> houses,
    domain.PreferenceProfile? pref,
    HouseScoringService service,
  ) {
    final entries = houses
        .map((h) => _HouseEntry(house: h, view: service.evaluate(h, pref)))
        .toList();

    switch (_sort) {
      case HouseSort.recommended:
        entries.sort((a, b) {
          // 淘汰组整体置底。
          if (a.view.rejected != b.view.rejected) {
            return a.view.rejected ? 1 : -1;
          }
          // 组内按总分降序。
          return b.view.total.compareTo(a.view.total);
        });
      case HouseSort.price:
        // 月总成本升序（低成本优先）。
        entries.sort(
          (a, b) => a.view.estimatedTotalMonthly
              .compareTo(b.view.estimatedTotalMonthly),
        );
      case HouseSort.commute:
        // 有通勤数据的按时长升序在前，无数据置底。
        entries.sort((a, b) {
          final am = a.view.primaryCommuteMinutes;
          final bm = b.view.primaryCommuteMinutes;
          if (am == null && bm == null) return 0;
          if (am == null) return 1;
          if (bm == null) return -1;
          return am.compareTo(bm);
        });
      case HouseSort.recent:
        // 最近更新在前。
        entries.sort((a, b) => b.house.updatedAt.compareTo(a.house.updatedAt));
    }
    return entries;
  }
}

/// 房源 + 其组合评分视图的临时配对。
class _HouseEntry {
  const _HouseEntry({required this.house, required this.view});

  final domain.HouseRecord house;
  final HouseScoreView view;
}

/// 村筛选条：默认全部，选择某个村后仅复盘该村房源。
class _VillageFilterBar extends StatelessWidget {
  const _VillageFilterBar({
    required this.villagesAsync,
    required this.selectedVillageId,
    required this.onChanged,
  });

  final AsyncValue<List<domain.VillageWithStats>> villagesAsync;
  final String? selectedVillageId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final villages =
        villagesAsync.valueOrNull ?? const <domain.VillageWithStats>[];
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('全部'),
              selected: selectedVillageId == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          for (final village in villages)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(village.village.name),
                selected: selectedVillageId == village.village.id,
                onSelected: (_) => onChanged(village.village.id),
              ),
            ),
        ],
      ),
    );
  }
}

/// 排序分段控件。
class _SortBar extends StatelessWidget {
  const _SortBar({required this.value, required this.onChanged});

  final HouseSort value;
  final ValueChanged<HouseSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: SegmentedButton<HouseSort>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 13),
          visualDensity: VisualDensity.compact,
        ),
        segments: [
          for (final s in HouseSort.values)
            ButtonSegment<HouseSort>(value: s, label: Text(s.label)),
        ],
        selected: {value},
        onSelectionChanged: (set) => onChanged(set.first),
      ),
    );
  }
}

/// 单套房源卡片。
class _HouseCard extends StatelessWidget {
  const _HouseCard({
    required this.house,
    required this.view,
    required this.onTap,
  });

  static const EdgeInsetsGeometry cardMargin = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );

  final domain.HouseRecord house;
  final HouseScoreView view;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rejected = view.rejected;

    return Opacity(
      // 淘汰卡片降低视觉权重（UI §5.7），但不隐藏。
      opacity: rejected ? 0.72 : 1,
      child: Card(
        margin: cardMargin,
        child: KawaiiPressable(
          borderRadius: BorderRadius.circular(24),
          semanticLabel: house.title,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            house.title,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (house.addressText != null &&
                              house.addressText!.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              house.addressText!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 6),
                          _MetaRow(house: house, view: view),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ScoreBadge(view: view),
                  ],
                ),
                if (rejected) ...[
                  const SizedBox(height: 10),
                  _RejectReasons(view: view),
                ] else
                  _WarningTags(house: house),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 成本 + 通勤元信息行。
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.house, required this.view});

  final domain.HouseRecord house;
  final HouseScoreView view;

  @override
  Widget build(BuildContext context) {
    final minutes = view.primaryCommuteMinutes;
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _MetaChip(
          icon: Icons.payments_outlined,
          text: '月总 ${view.estimatedTotalMonthly} 元'
              '${view.cost.hasMissingFee ? '（含估算）' : ''}',
          color: AppColors.textSecondary,
        ),
        _MetaChip(
          icon: Icons.directions_transit_outlined,
          text: minutes == null ? '通勤待补' : '通勤 $minutes 分钟',
          color: minutes == null ? AppColors.textSecondary : AppColors.commute,
        ),
      ],
    );
  }
}

/// 元信息小项（图标 + 文案）。
class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}

/// 右侧总分/淘汰徽标。
class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.view});

  final HouseScoreView view;

  @override
  Widget build(BuildContext context) {
    if (view.rejected) {
      return const KawaiiStatusChip(
        label: '已淘汰',
        color: AppColors.risk,
        icon: Icons.block_rounded,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          view.total.round().toString(),
          style: const TextStyle(
            fontSize: 26,
            height: 1,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const Text(
          '总分',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// 淘汰原因列表（保留「为什么淘汰」，UI §5.7）。
class _RejectReasons extends StatelessWidget {
  const _RejectReasons({required this.view});

  final HouseScoreView view;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.risk.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final r in view.filter.reasons)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 14,
                    color: AppColors.risk,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      r.message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.risk,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 通过硬筛时展示的风险/缺失提示标签（可补救问题，橙色）。
class _WarningTags extends StatelessWidget {
  const _WarningTags({required this.house});

  final domain.HouseRecord house;

  @override
  Widget build(BuildContext context) {
    final warnings =
        house.riskFlags.where((r) => r.severity == 'warning').toList();
    if (warnings.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          for (final w in warnings)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                w.note?.trim().isNotEmpty == true ? w.note!.trim() : w.key,
                style: const TextStyle(fontSize: 11, color: AppColors.warning),
              ),
            ),
        ],
      ),
    );
  }
}

/// 空列表状态：村/房源手动记录引导。
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return KawaiiEmptyState(
      icon: Icons.home_work_outlined,
      title: '还没有房源记录',
      description: '先在首页新增一个村，再记录你现场看到的候选房。离线也能记。',
      actionLabel: '开始扫楼',
      actionIcon: Icons.dashboard_outlined,
      onAction: () => context.go(AppRoutes.scan),
      iconColor: context.kawaiiPalette.primary,
    );
  }
}

/// 当前村筛选下暂无房源。
class _EmptyFilteredState extends StatelessWidget {
  const _EmptyFilteredState({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return KawaiiEmptyState(
      icon: Icons.meeting_room_outlined,
      title: title,
      description: '回到首页或村详情继续记录房源。',
      actionLabel: '回到首页',
      actionIcon: Icons.home_outlined,
      onAction: () => context.go(AppRoutes.scan),
      iconColor: AppColors.offline,
    );
  }
}

