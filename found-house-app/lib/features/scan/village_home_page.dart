import 'dart:async';

// 村首页（V0.2 手动扫楼流程）。
//
// 职责边界：替代原地图工作台，作为「首页」Tab 的根页面。这里只做村列表、
// 继续扫楼入口、新增村与统计展示；房源与楼栋的具体编辑交给 QuickRecord /
// VillageDetail。全流程本地读写，不依赖定位、地图或第三方 API。

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
import 'quick_record_page.dart';

class VillageHomePage extends ConsumerWidget {
  const VillageHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final villagesAsync = ref.watch(villagesWithStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KawaiiIconBubble(
              icon: Icons.home_work_rounded,
              color: AppColors.primary,
              size: 36,
            ),
            SizedBox(width: 10),
            Text('首页'),
          ],
        ),
        actions: [
          Semantics(
            button: true,
            label: '新增村',
            child: TextButton.icon(
              onPressed: () => _showCreateVillageDialog(context, ref),
              icon: const Icon(Icons.add_home_work_outlined),
              label: const Text('新增村'),
            ),
          ),
        ],
      ),
      body: villagesAsync.when(
        loading: () => const KawaiiLoadingList(itemCount: 3),
        error: (e, _) => KawaiiErrorState(
          message: '村列表加载失败：$e',
          onRetry: () => ref.invalidate(villagesWithStatsProvider),
        ),
        data: (villages) {
          if (villages.isEmpty) {
            return KawaiiEmptyState(
              icon: Icons.home_work_outlined,
              title: '还没有村',
              description:
                  '还没有村，先添加你正在扫的城中村/小区。离线也能记楼栋和房源。',
              actionLabel: '新增村',
              onAction: () => _showCreateVillageDialog(context, ref),
              iconColor: context.kawaiiPalette.primary,
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              const KawaiiPageHeading(
                eyebrow: '今天也要顺利扫楼',
                title: '从一个村开始',
                description: '离线记录楼栋和房源，慢慢把选择变清楚。',
                icon: Icons.auto_awesome_rounded,
                accentColor: AppColors.secondary,
              ),
              const SizedBox(height: 18),
              _ContinueCard(village: villages.first),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    '村列表',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    '${villages.length} 个村',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final village in villages) _VillageCard(village: village),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateVillageDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('新增村'),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.village});

  final domain.VillageWithStats village;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceSoft,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const KawaiiIconBubble(
                  icon: Icons.play_circle_outline,
                  color: AppColors.primary,
                  size: 38,
                ),
                const SizedBox(width: 8),
                Text(
                  '继续扫楼',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              village.village.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            VillageStatsWrap(stats: village),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openQuickRecord(
                      context,
                      villageId: village.village.id,
                    ),
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text('记录房源'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openVillageDetail(context, village),
                    icon: const Icon(Icons.apartment_outlined),
                    label: const Text('进入村'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VillageCard extends ConsumerWidget {
  const _VillageCard({required this.village});

  final domain.VillageWithStats village;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(villageRepositoryProvider);
    return SwipeDeleteAction(
      key: ValueKey('village-${village.village.id}'),
      actionInsets: const EdgeInsets.symmetric(vertical: 6),
      onDelete: () async {
        final confirmed = await confirmDeleteRecord(
          context,
          title: '删除村',
          message: '确认删除「${village.village.name}」？该村下的楼栋、房源和照片都会删除。',
        );
        if (!confirmed) return;
        try {
          await repository.deleteVillage(village.village.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('村已删除')),
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
              '${village.village.name}，${village.buildingCount} 栋，${village.houseCount} 套房源',
          onTap: () => _openVillageDetail(context, village),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        village.village.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    _VillageStatusBadge(status: village.village.status),
                  ],
                ),
                const SizedBox(height: 8),
                VillageStatsWrap(stats: village),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openQuickRecord(
                        context,
                        villageId: village.village.id,
                      ),
                      icon: const Icon(Icons.edit_note_outlined),
                      label: const Text('记录房源'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _openVillageDetail(context, village),
                      child: const Text('查看楼栋'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VillageStatsWrap extends StatelessWidget {
  const VillageStatsWrap({super.key, required this.stats});

  final domain.VillageWithStats stats;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatChip(label: '楼栋', value: stats.buildingCount),
        _StatChip(label: '房源', value: stats.houseCount, emphasize: stats.houseCount > 0),
        _StatChip(label: '候选', value: stats.shortlistedCount),
        _StatChip(label: '待复访', value: stats.revisitCount),
        _StatChip(label: '未分楼栋', value: stats.unassignedHouseCount),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, this.emphasize = false});

  final String label;
  final int value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return KawaiiStatChip(label: label, value: value, emphasize: emphasize);
  }
}


class _VillageStatusBadge extends StatelessWidget {
  const _VillageStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final palette = context.kawaiiPalette;
    final (label, color, icon) = switch (status) {
      VillageStatus.scouting => (
          '扫楼中',
          palette.primary,
          Icons.directions_walk_rounded,
        ),
      VillageStatus.paused => (
          '暂停',
          AppColors.warning,
          Icons.pause_circle_outline_rounded,
        ),
      VillageStatus.completed => (
          '完成',
          AppColors.mint,
          Icons.check_circle_outline_rounded,
        ),
      VillageStatus.archived => (
          '归档',
          AppColors.offline,
          Icons.inventory_2_outlined,
        ),
      _ => (
          '准备中',
          palette.secondary,
          Icons.flag_outlined,
        ),
    };
    return KawaiiStatusChip(label: label, color: color, icon: icon);
  }
}


Future<void> _showCreateVillageDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  var inputName = '';
  final created = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('新增村'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '村名',
            hintText: '如 上沙村、白石洲',
          ),
          textInputAction: TextInputAction.done,
          onChanged: (value) => inputName = value,
          onSubmitted: (value) {
            inputName = value;
            Navigator.of(dialogContext).pop(true);
          },
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
  final name = inputName.trim();
  if (created != true || name.isEmpty) return;
  unawaited(HapticFeedback.selectionClick());
  await ref.read(villageRepositoryProvider).createVillage(
        name: name,
        status: VillageStatus.scouting,
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

void _openVillageDetail(BuildContext context, domain.VillageWithStats village) {
  HapticFeedback.selectionClick();
  context.pushNamed(
    AppRoutes.villageDetailName,
    pathParameters: {'villageId': village.village.id},
  );
}


