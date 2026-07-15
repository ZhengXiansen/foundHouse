// 录入闭环通用表单组件（W1-2 · UI §5.5/§5.6）。
//
// 职责边界：仅提供录入轨各页面复用的无状态 UI 构件（可折叠区块、带标签字段、
// 三态布尔选择、单选 Chip 组），不含任何仓库读写或业务逻辑。
// 集中一处避免快速记录 / 房源详情 / Checklist / 偏好各页 copy-paste 样板（DRY）。
//
// 视觉取值统一走 AppColors（lib/app/theme.dart），禁止在此另写魔法色值。

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// 可折叠区块卡片：标题 + 右侧完成度徽标 + 折叠内容。
///
/// 用于房源详情的「基础/费用/房屋/联系人/风险/备注」等模块，标题右侧
/// 展示形如「5/9」的完成度（UI §5.5「模块标题右侧显示完成度」）。
/// [maintainState] 默认 true，保证折叠时子字段控制器状态不丢失。
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.badge,
    this.icon,
    this.initiallyExpanded = false,
    this.maintainState = true,
    this.trailingAction,
  });

  /// 区块标题。
  final String title;

  /// 折叠内容。
  final Widget child;

  /// 右侧完成度徽标文本（如「5/9」）；为空不展示。
  final String? badge;

  /// 标题左侧图标。
  final IconData? icon;

  /// 首次是否展开。
  final bool initiallyExpanded;

  /// 折叠时是否保留子树状态。
  final bool maintainState;

  /// 标题行尾部自定义动作（如「去填写」按钮）；与 [badge] 二选一时优先并存展示。
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Theme(
        // 去掉 ExpansionTile 默认的上下分割线，贴合卡片圆角。
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          maintainState: maintainState,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: icon == null
              ? null
              : Icon(icon, color: AppColors.textSecondary, size: 22),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailingAction != null) trailingAction!,
              if (badge != null) ...[
                const SizedBox(width: 8),
                _CompletionBadge(text: badge!),
              ],
            ],
          ),
          children: [child],
        ),
      ),
    );
  }
}

/// 完成度徽标。
class _CompletionBadge extends StatelessWidget {
  const _CompletionBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// 带标签的文本/数字输入行。
///
/// 上方标签、下方输入框的竖排布局，适合表单密集填写。数字输入由调用方
/// 通过 [keyboardType] 与 [suffixText] 指定，本组件不做类型转换（转换在页面层）。
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.keyboardType,
    this.hintText,
    this.suffixText,
    this.maxLines = 1,
    this.autofocus = false,
    this.focusNode,
    this.fieldKey,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? suffixText;
  final int maxLines;
  final bool autofocus;
  final FocusNode? focusNode;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            key: fieldKey,
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            maxLines: maxLines,
            autofocus: autofocus,
            focusNode: focusNode,
            decoration: InputDecoration(
              isDense: false,
              hintText: hintText,
              suffixText: suffixText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 三态布尔选择：有 / 无 / 未知（映射 true / false / null）。
///
/// 用于房屋硬性条件（独卫/厨房/电梯/宠物/做饭）等 `bool?` 字段：
/// 未选择保持 null（未知），不默认假定为 false（避免误判硬筛，F1）。
class TriStateField extends StatelessWidget {
  const TriStateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.trueLabel = '有',
    this.falseLabel = '无',
    this.unknownLabel = '未知',
  });

  final String label;
  final bool? value;
  final ValueChanged<bool?> onChanged;
  final String trueLabel;
  final String falseLabel;
  final String unknownLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          _SegmentChip(
            label: trueLabel,
            selected: value == true,
            onTap: () => onChanged(value == true ? null : true),
          ),
          const SizedBox(width: 6),
          _SegmentChip(
            label: falseLabel,
            selected: value == false,
            onTap: () => onChanged(value == false ? null : false),
          ),
          const SizedBox(width: 6),
          _SegmentChip(
            label: unknownLabel,
            selected: value == null,
            onTap: () => onChanged(null),
          ),
        ],
      ),
    );
  }
}

/// 单选 Chip 组：从 [options] 选一个值，可清空。
///
/// 用于房型、朝向、联系人角色、付款周期等有限枚举字段。
class ChoiceChipsField extends StatelessWidget {
  const ChoiceChipsField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final String? value;

  /// 选中返回该值；再次点击已选项返回 null（清空）。
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final opt in options)
                _SegmentChip(
                  label: opt,
                  selected: value == opt,
                  onTap: () => onChanged(value == opt ? null : opt),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 通用可选中 Chip（内部复用）。
class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.kawaiiPalette;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Material(
      color: selected ? palette.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? palette.primary : AppColors.divider,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: selected ? onPrimary : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 表单内轻量分组小标题。
class FieldGroupLabel extends StatelessWidget {
  const FieldGroupLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
