import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/kawaii_widgets.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../app/theme_preferences.dart';
import '../scoring/score_rule.dart';

/// Settings entry dashboard. Existing route callbacks stay where the user
/// expects them; the theme chooser only owns presentation preference state.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPreset = ref.watch(appThemeControllerProvider);
    final activePalette = context.kawaiiPalette;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KawaiiIconBubble(
              icon: Icons.face_rounded,
              color: activePalette.secondary,
              size: 36,
            ),
            const SizedBox(width: 10),
            const Text('我的'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
        children: [
          KawaiiPageHeading(
            eyebrow: '把扫楼变得轻松一点',
            title: '你的安心小角落',
            description: '偏好、隐私和数据设置都在这里，慢慢调整就好。',
            icon: Icons.favorite_rounded,
            accentColor: activePalette.primary,
          ),
          const SizedBox(height: 24),
          _SettingsGroup(
            title: '界面与心情',
            color: activePalette.primary,
            children: [
              _ThemePickerCard(
                selectedPreset: selectedPreset,
                onChanged: (preset) {
                  ref.read(appThemeControllerProvider.notifier).select(preset);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: '偏好与规则',
            color: activePalette.secondary,
            children: [
              _SettingsEntry(
                icon: Icons.tune_rounded,
                accentColor: activePalette.secondary,
                title: '偏好设置',
                subtitle: '预算、通勤、目的地、硬性条件、评分权重',
                onTap: () => context.goNamed(AppRoutes.preferenceName),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: '隐私与数据',
            color: activePalette.mint,
            children: [
              _SettingsEntry(
                icon: Icons.privacy_tip_outlined,
                accentColor: activePalette.mint,
                title: '隐私设置',
                subtitle: '导出脱敏默认项、本地加密策略',
                onTap: () => context.goNamed(AppRoutes.privacyName),
              ),
              _SettingsEntry(
                icon: Icons.cloud_upload_outlined,
                accentColor: AppColors.commute,
                title: 'OSS 云存储',
                subtitle: '自配阿里云 OSS，开启后照片本地留存并直传云端',
                onTap: () => context.goNamed(AppRoutes.ossSettingsName),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: '关于',
            color: activePalette.sunshine,
            children: [
              _SettingsEntry(
                icon: Icons.storage_outlined,
                accentColor: activePalette.sunshine,
                title: '数据策略',
                subtitle: '本地离线记录，第三方服务关闭',
              ),
              _SettingsEntry(
                icon: Icons.info_outline,
                accentColor: activePalette.sunshine,
                title: '关于扫楼助手',
                subtitle: '个人扫楼记录与房源决策工具 · MVP',
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SettingsEntry(
            icon: Icons.rule_rounded,
            accentColor: activePalette.sunshine,
            title: '评分规则版本',
            subtitle: defaultScoreRule.version,
          ),
        ],
      ),
    );
  }
}

class _ThemePickerCard extends StatelessWidget {
  const _ThemePickerCard({
    required this.selectedPreset,
    required this.onChanged,
  });

  final AppThemePreset selectedPreset;
  final ValueChanged<AppThemePreset> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.kawaiiPalette;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: palette.surfaceSoft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                KawaiiIconBubble(
                  icon: Icons.palette_outlined,
                  color: palette.primary,
                  size: 40,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('界面主题'),
                      SizedBox(height: 2),
                      Text(
                        '选一种今天喜欢的糖果色，立即换上。',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in AppThemePreset.values)
                  ChoiceChip(
                    avatar: Icon(preset.icon, size: 16, color: preset.primary),
                    label: Text(preset.label),
                    selected: preset == selectedPreset,
                    selectedColor: preset.primary.withValues(alpha: 0.18),
                    side: BorderSide(
                      color: preset == selectedPreset
                          ? preset.primary.withValues(alpha: 0.62)
                          : AppColors.divider,
                    ),
                    onSelected: (_) => onChanged(preset),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.title,
    required this.color,
    required this.children,
  });

  final String title;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsEntry extends StatelessWidget {
  const _SettingsEntry({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: KawaiiIconBubble(icon: icon, color: accentColor, size: 40),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: onTap == null
            ? null
            : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );

    if (onTap == null) return card;
    return KawaiiPressable(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      child: card,
    );
  }
}
