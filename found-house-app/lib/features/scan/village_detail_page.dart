import 'dart:async';

// 村详情页（V0.2 手动扫楼流程）。
//
// 职责边界：展示单个村的统计、楼栋清单和未分楼栋房源；支持新增楼栋、
// 标记楼栋状态，以及从村/楼栋上下文进入快速记录。

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/kawaii_widgets.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../data/models/house_models.dart' as domain;
import '../../data/providers.dart';
import '../../data/repositories/village_repository.dart';
import '../common/delete_confirmation.dart';
import '../house/house_list_page.dart';
import '../scoring/house_scoring_controller.dart';
import 'quick_record_page.dart';
import 'village_home_page.dart';

class VillageDetailPage extends ConsumerWidget {
  const VillageDetailPage({super.key, required this.villageId});

  final String villageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(villageWithStatsProvider(villageId));
    final buildingsAsync = ref.watch(buildingsForVillageProvider(villageId));
    final housesAsync = ref.watch(housesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: statsAsync.maybeWhen(
          data: (stats) => Text(stats?.village.name ?? '村详情'),
          orElse: () => const Text('村详情'),
        ),
      ),
      body: statsAsync.when(
        loading: () => const KawaiiLoadingList(itemCount: 4),
        error: (e, _) => KawaiiErrorState(
          message: '村详情加载失败：$e',
          onRetry: () => ref.invalidate(villageWithStatsProvider(villageId)),
        ),
        data: (stats) {
          if (stats == null) {
            return KawaiiEmptyState(
              icon: Icons.home_work_outlined,
              title: '找不到这个村',
              description: '可能已被删除，返回首页重新选择。',
              actionLabel: '返回首页',
              actionIcon: Icons.home_outlined,
              onAction: () => context.go(AppRoutes.scan),
              iconColor: AppColors.offline,
            );
          }
          final villageHouses = housesAsync.valueOrNull
                  ?.where((h) => h.villageId == villageId)
                  .toList(growable: false) ??
              const <domain.HouseRecord>[];
          final unassignedHouses = villageHouses
              .where((h) => h.buildingId == null)
              .toList(growable: false);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _StatsCard(stats: stats),
              const SizedBox(height: 12),
              _QuickActions(
                villageId: villageId,
                onCreateBuilding: () => _showCreateBuildingDialog(context, ref),
              ),
              const SizedBox(height: 18),
              _SectionHeader(
                title: '楼栋',
                action: TextButton.icon(
                  onPressed: () => _showCreateBuildingDialog(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('新增楼栋'),
                ),
              ),
              buildingsAsync.when(
                loading: () => const KawaiiLoadingList(
                  itemCount: 2,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 8),
                ),
                error: (e, _) => _InlineError(
                  message: '楼栋加载失败：$e',
                  onRetry: () =>
                      ref.invalidate(buildingsForVillageProvider(villageId)),
                ),
                data: (buildings) => _BuildingList(
                  villageId: villageId,
                  buildings: buildings,
                  onCreateBuilding: () =>
                      _showCreateBuildingDialog(context, ref),
                ),
              ),
              const SizedBox(height: 18),
              _SectionHeader(
                title: '未分楼栋房源',
                subtitle: '${unassignedHouses.length} 条',
              ),
              if (housesAsync.isLoading)
                const KawaiiLoadingList(
                  itemCount: 1,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 8),
                )
              else if (housesAsync.hasError)
                _InlineError(
                  message: '房源加载失败：${housesAsync.error}',
                  onRetry: () => ref.invalidate(housesStreamProvider),
                )
              else
                _UnassignedHouseList(houses: unassignedHouses),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBuildingDialog(context, ref),
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('新增楼栋'),
      ),
    );
  }

  Future<void> _showCreateBuildingDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    var inputName = '';
    var status = BuildingStatus.notScouted;
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('新增楼栋'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: '楼栋/入口名',
                      hintText: '如 1号楼、A入口、东门自建楼',
                    ),
                    textInputAction: TextInputAction.done,
                    onChanged: (value) => inputName = value,
                    onSubmitted: (value) {
                      inputName = value;
                      Navigator.of(dialogContext).pop(true);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(
                      labelText: '初始状态',
                    ),
                    items: _buildingStatusOptions
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option.value,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => status = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
    final name = inputName.trim();
    if (created != true || name.isEmpty) return;
    unawaited(HapticFeedback.selectionClick());
    await ref.read(villageRepositoryProvider).createBuilding(
          villageId: villageId,
          name: name,
          status: status,
        );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final domain.VillageWithStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.kawaiiPalette.surfaceSoft,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const KawaiiIconBubble(
                  icon: Icons.home_work_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stats.village.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            if (stats.village.areaNote?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                stats.village.areaNote!.trim(),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 12),
            VillageStatsWrap(stats: stats),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.villageId,
    required this.onCreateBuilding,
  });

  final String villageId;
  final VoidCallback onCreateBuilding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _openQuickRecord(context, villageId: villageId),
            icon: const Icon(Icons.edit_note_outlined),
            label: const Text('记录房源'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCreateBuilding,
            icon: const Icon(Icons.add_business_outlined),
            label: const Text('新增楼栋'),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle, this.action});

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(
            subtitle!,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}

class _BuildingList extends ConsumerWidget {
  const _BuildingList({
    required this.villageId,
    required this.buildings,
    required this.onCreateBuilding,
  });

  final String villageId;
  final List<domain.Building> buildings;
  final VoidCallback onCreateBuilding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(villageRepositoryProvider);
    if (buildings.isEmpty) {
      return _InlineEmpty(
        icon: Icons.apartment_outlined,
        message: '还没有楼栋，可以先新增楼栋，也可以先记录未分楼栋房源。',
        actionLabel: '新增楼栋',
        onAction: onCreateBuilding,
      );
    }
    return Column(
      children: [
        for (final building in buildings)
          SwipeDeleteAction(
            key: ValueKey('building-${building.id}'),
            actionInsets: const EdgeInsets.symmetric(vertical: 6),
            onDelete: () async {
              final confirmed = await confirmDeleteRecord(
                context,
                title: '删除楼栋',
                message: '确认删除「${building.name}」？该楼栋下的房源和照片都会删除。',
              );
              if (!confirmed) return;
              try {
                await repository.deleteBuilding(building.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('楼栋已删除')),
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
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: KawaiiPressable(
                borderRadius: BorderRadius.circular(24),
                semanticLabel:
                    '${building.name}，${_buildingStatusLabel(building.status)}',
                onTap: () => _openBuildingHouseList(
                  context,
                  villageId: villageId,
                  building: building,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const KawaiiIconBubble(
                            icon: Icons.apartment_outlined,
                            color: AppColors.secondary,
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  building.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _buildingSubtitle(building),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: '标记状态',
                            initialValue: building.status,
                            onSelected: (status) {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(villageRepositoryProvider)
                                  .updateBuildingStatus(
                                    building.id,
                                    status: status,
                                  );
                            },
                            itemBuilder: (context) => [
                              for (final option in _buildingStatusOptions)
                                PopupMenuItem<String>(
                                  value: option.value,
                                  child: Text(option.label),
                                ),
                            ],
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: _BuildingStatusBadge(
                                status: building.status,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => _openQuickRecord(
                            context,
                            villageId: villageId,
                            buildingId: building.id,
                            buildingName: building.name,
                          ),
                          icon: const Icon(Icons.edit_note_outlined),
                          label: const Text('在此楼记录房源'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _UnassignedHouseList extends ConsumerWidget {
  const _UnassignedHouseList({required this.houses});

  final List<domain.HouseRecord> houses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(houseRepositoryProvider);
    if (houses.isEmpty) {
      return const _InlineEmpty(
        icon: Icons.meeting_room_outlined,
        message: '暂无未分楼栋房源。',
      );
    }
    return Column(
      children: [
        for (final house in houses)
          SwipeDeleteAction(
            key: ValueKey('house-${house.id}'),
            actionInsets: const EdgeInsets.symmetric(vertical: 4),
            onDelete: () async {
              final confirmed = await confirmDeleteRecord(
                context,
                title: '删除房源',
                message: '确认删除「${house.title}」？该房源的照片和补充信息都会删除。',
              );
              if (!confirmed) return;
              try {
                await repository.delete(house.id);
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
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: KawaiiPressable(
                borderRadius: BorderRadius.circular(24),
                semanticLabel: house.title,
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.pushNamed(
                    AppRoutes.houseDetailName,
                    pathParameters: {'houseId': house.id},
                  );
                },
                child: ListTile(
                  leading: const KawaiiIconBubble(
                    icon: Icons.meeting_room_outlined,
                    color: AppColors.sunshine,
                    size: 40,
                  ),
                  title: Text(
                    house.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: house.buildingName?.trim().isNotEmpty == true
                      ? Text('楼栋备注：${house.buildingName!.trim()}')
                      : const Text('未绑定楼栋'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BuildingStatusBadge extends StatelessWidget {
  const _BuildingStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      BuildingStatus.hasVacancy => (
          '有空房',
          AppColors.primary,
          Icons.meeting_room_outlined,
        ),
      BuildingStatus.contacting => (
          '联系中',
          AppColors.primary,
          Icons.phone_in_talk_outlined,
        ),
      BuildingStatus.needsRevisit => (
          '待复访',
          AppColors.warning,
          Icons.replay_outlined,
        ),
      BuildingStatus.noVacancy => (
          '无空房',
          AppColors.risk,
          Icons.block_outlined,
        ),
      BuildingStatus.abandoned => (
          '放弃',
          AppColors.risk,
          Icons.cancel_outlined,
        ),
      _ => (
          '未扫',
          AppColors.offline,
          Icons.flag_outlined,
        ),
    };
    return KawaiiStatusChip(label: label, color: color, icon: icon);
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.kawaiiPalette.surfaceSoft,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            KawaiiIconBubble(
              icon: icon,
              color: AppColors.offline,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.risk.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.risk),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.risk, height: 1.35),
              ),
            ),
            if (onRetry != null)
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('重试'),
              ),
          ],
        ),
      ),
    );
  }
}

class _BuildingStatusOption {
  const _BuildingStatusOption(this.value, this.label);

  final String value;
  final String label;
}

const _buildingStatusOptions = [
  _BuildingStatusOption(BuildingStatus.notScouted, '未扫'),
  _BuildingStatusOption(BuildingStatus.noVacancy, '无空房'),
  _BuildingStatusOption(BuildingStatus.hasVacancy, '有空房'),
  _BuildingStatusOption(BuildingStatus.contacting, '联系中'),
  _BuildingStatusOption(BuildingStatus.needsRevisit, '待复访'),
  _BuildingStatusOption(BuildingStatus.abandoned, '放弃'),
];

String _buildingStatusLabel(String status) {
  for (final option in _buildingStatusOptions) {
    if (option.value == status) return option.label;
  }
  return '未扫';
}

String _buildingSubtitle(domain.Building building) {
  final parts = <String>[_buildingStatusLabel(building.status)];
  if (building.entranceNote?.trim().isNotEmpty == true) {
    parts.add(building.entranceNote!.trim());
  }
  if (building.tags.isNotEmpty) {
    parts.add(building.tags.join('、'));
  }
  if (building.note?.trim().isNotEmpty == true) {
    parts.add(building.note!.trim());
  }
  return parts.join(' · ');
}

void _openBuildingHouseList(
  BuildContext context, {
  required String villageId,
  required domain.Building building,
}) {
  HapticFeedback.selectionClick();
  final router = GoRouter.maybeOf(context);
  if (router == null) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HouseListPage(
          fixedVillageId: villageId,
          fixedBuildingId: building.id,
          fixedBuildingName: building.name,
        ),
      ),
    );
    return;
  }

  router.pushNamed(
    AppRoutes.buildingHouseListName,
    pathParameters: {
      'villageId': villageId,
      'buildingId': building.id,
    },
    queryParameters: {
      if (building.name.trim().isNotEmpty) 'buildingName': building.name,
    },
  );
}

void _openQuickRecord(
  BuildContext context, {
  required String villageId,
  String? buildingId,
  String? buildingName,
}) {
  HapticFeedback.selectionClick();
  final router = GoRouter.maybeOf(context);
  if (router == null) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuickRecordPage(
          villageId: villageId,
          buildingId: buildingId,
          buildingName: buildingName,
        ),
      ),
    );
    return;
  }
  router.pushNamed(
    AppRoutes.quickRecordName,
    queryParameters: {
      'villageId': villageId,
      if (buildingId?.trim().isNotEmpty == true) 'buildingId': buildingId!,
      if (buildingName?.trim().isNotEmpty == true)
        'buildingName': buildingName!,
    },
  );
}
