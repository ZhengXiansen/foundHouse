import 'package:flutter/material.dart';

import 'motion.dart';
import 'theme.dart';

/// A quiet cream-to-blush canvas that sits behind every routed page.
class KawaiiBackdrop extends StatelessWidget {
  const KawaiiBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.kawaiiPalette.background,
            context.kawaiiPalette.backgroundBlush,
          ],
          stops: const [0.16, 1],
        ),
      ),
      child: child,
    );
  }
}

/// Small colored sticker used to add warmth without dense illustration.
class KawaiiIconBubble extends StatelessWidget {
  const KawaiiIconBubble({
    super.key,
    required this.icon,
    this.color = AppColors.secondary,
    this.size = 42,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.36),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: size * 0.53),
    );
  }
}

/// A content-first page introduction with one compact cheerful accent.
class KawaiiPageHeading extends StatelessWidget {
  const KawaiiPageHeading({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.eyebrow,
    this.accentColor = AppColors.primary,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? eyebrow;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!,
                  style: textTheme.labelLarge?.copyWith(
                    color: accentColor,
                    letterSpacing: 0.15,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(title, style: textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        KawaiiIconBubble(icon: icon, color: accentColor, size: 54),
      ],
    );
  }
}

/// Gentle press feedback (scale ~ 0.97). Owns no business state.
class KawaiiPressable extends StatefulWidget {
  const KawaiiPressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  @override
  State<KawaiiPressable> createState() => _KawaiiPressableState();
}

class _KawaiiPressableState extends State<KawaiiPressable> {
  var _isHovered = false;
  var _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final disableMotion = AppMotion.animationsDisabled(context);
    final scale = disableMotion
        ? 1.0
        : _isPressed
            ? 0.97
            : 1.0;
    final yOffset = disableMotion
        ? 0.0
        : _isPressed
            ? 1.0
            : _isHovered
                ? -2.0
                : 0.0;

    final content = MouseRegion(
      cursor:
          widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: scale,
        duration: AppMotionHelper.effectiveDuration(
          context,
          AppMotion.softFeedback,
        ),
        curve: AppMotion.softFeedbackCurve,
        child: AnimatedContainer(
          duration: AppMotionHelper.effectiveDuration(
            context,
            AppMotion.softFeedback,
          ),
          curve: AppMotion.softFeedbackCurve,
          transform: Matrix4.translationValues(0, yOffset, 0),
          child: Material(
            color: Colors.transparent,
            borderRadius: widget.borderRadius,
            child: InkWell(
              borderRadius: widget.borderRadius,
              onTap: widget.onTap,
              onHighlightChanged: (pressed) =>
                  setState(() => _isPressed = pressed),
              splashColor:
                  context.kawaiiPalette.primary.withValues(alpha: 0.10),
              highlightColor:
                  context.kawaiiPalette.primary.withValues(alpha: 0.06),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (widget.semanticLabel == null) return content;
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: content,
    );
  }
}

/// Empty state: icon + copy + single primary CTA.
class KawaiiEmptyState extends StatelessWidget {
  const KawaiiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.actionIcon = Icons.add_rounded,
    this.iconColor = AppColors.offline,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData actionIcon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KawaiiIconBubble(icon: icon, color: iconColor, size: 64),
            const SizedBox(height: 16),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with reason + retry.
class KawaiiErrorState extends StatelessWidget {
  const KawaiiErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = '重试',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const KawaiiIconBubble(
              icon: Icons.error_outline_rounded,
              color: AppColors.risk,
              size: 56,
            ),
            const SizedBox(height: 14),
            Text(
              '出了点问题',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Soft skeleton placeholders for list loading.
class KawaiiLoadingList extends StatelessWidget {
  const KawaiiLoadingList({
    super.key,
    this.itemCount = 3,
    this.shrinkWrap = false,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 96),
  });

  final int itemCount;
  final bool shrinkWrap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final soft = context.kawaiiPalette.surfaceSoft;
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          height: index == 0 ? 148 : 112,
          decoration: BoxDecoration(
            color: soft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bone(width: index == 0 ? 96.0 : 140.0, height: 14),
              const SizedBox(height: 12),
              _bone(width: double.infinity, height: 18),
              const SizedBox(height: 10),
              _bone(width: 180, height: 12),
              if (index == 0) ...[
                const Spacer(),
                Row(
                  children: [
                    Expanded(child: _bone(height: 40, radius: 14)),
                    const SizedBox(width: 12),
                    Expanded(child: _bone(height: 40, radius: 14)),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _bone({double? width, required double height, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Metric chip with min width / tabular figures to reduce list jump.
class KawaiiStatChip extends StatelessWidget {
  const KawaiiStatChip({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final int value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final palette = context.kawaiiPalette;
    return Container(
      constraints: const BoxConstraints(minWidth: 72, minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: emphasize
            ? palette.primary.withValues(alpha: 0.10)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: emphasize
              ? palette.primary.withValues(alpha: 0.22)
              : AppColors.divider,
        ),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: '$value',
              style: TextStyle(
                fontSize: 12,
                fontFeatures: const [FontFeature.tabularFigures()],
                fontWeight: FontWeight.w700,
                color: emphasize ? palette.primaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status chip: icon + label (never color-only).
class KawaiiStatusChip extends StatelessWidget {
  const KawaiiStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon = Icons.circle,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
