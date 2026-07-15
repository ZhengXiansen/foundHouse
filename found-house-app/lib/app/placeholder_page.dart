import 'package:flutter/material.dart';

/// 占位页面脚手架，供 W1-W4 尚未实现的页面统一复用。
///
/// 职责边界：仅提供一致的占位视觉（标题 + 待实现说明），
/// 不含任何业务逻辑。各页面实现时应删除对本组件的依赖，
/// 替换为真实内容。集中一处避免各页面 copy-paste 占位样板。
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    required this.description,
    this.showAppBar = true,
    this.milestone,
  });

  /// 页面标题。
  final String title;

  /// 该页面后续职责说明（对应设计文档章节）。
  final String description;

  /// 是否显示 AppBar。一级 Tab 页通常自带顶部区域，可传 false。
  final bool showAppBar;

  /// 所属里程碑（如 "W1-2"），用于占位提示。
  final String? milestone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (milestone != null) ...[
              const SizedBox(height: 12),
              Chip(label: Text('待实现 · $milestone')),
            ],
          ],
        ),
      ),
    );

    if (!showAppBar) {
      return SafeArea(child: content);
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: content,
    );
  }
}
