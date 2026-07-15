import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Shared confirmation dialog for destructive swipe-delete actions.
Future<bool> confirmDeleteRecord(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('删除'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// A lightweight, in-project partial-reveal swipe action for destructive rows.
///
/// Unlike [Dismissible], this widget never moves the row all the way off-screen.
/// A leftward horizontal drag snaps the foreground content to a fixed-width
/// trailing/right-side delete action, and the actual delete flow only starts
/// after the user taps that explicit action.
class SwipeDeleteAction extends StatefulWidget {
  const SwipeDeleteAction({
    super.key,
    required this.child,
    required this.onDelete,
    this.actionExtent = 88,
    this.actionInsets,
  });

  final Widget child;
  final Future<void> Function() onDelete;
  final double actionExtent;

  /// Insets between this widget's layout bounds and the visible row/card bounds.
  ///
  /// Use this when the child includes list spacing or a [Card.margin]. The red
  /// action area is painted inside these insets so it stays attached to the
  /// visible data row instead of filling the outer spacing.
  final EdgeInsetsGeometry? actionInsets;

  @override
  State<SwipeDeleteAction> createState() => _SwipeDeleteActionState();
}

class _SwipeDeleteActionState extends State<SwipeDeleteAction> {
  double _offset = 0;
  bool _deleting = false;

  void _setOffset(double value) {
    final next = value.clamp(-widget.actionExtent, 0.0).toDouble();
    if (next == _offset) return;
    setState(() => _offset = next);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_deleting) return;
    _setOffset(_offset + details.delta.dx);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_deleting) return;
    final threshold = widget.actionExtent * 0.35;
    if (_offset.abs() < threshold) {
      _setOffset(0);
      return;
    }
    _setOffset(-widget.actionExtent);
  }

  Future<void> _handleDelete() async {
    if (_deleting) return;
    setState(() => _deleting = true);
    try {
      await widget.onDelete();
    } finally {
      if (mounted) {
        setState(() {
          _deleting = false;
          _offset = 0;
        });
      }
    }
  }

  EdgeInsets _resolvedActionInsets(BuildContext context) {
    final geometry =
        widget.actionInsets ?? _defaultActionInsetsFor(widget.child);
    return geometry.resolve(Directionality.of(context));
  }

  EdgeInsetsGeometry _defaultActionInsetsFor(Widget child) {
    if (child is Card) {
      return child.margin ?? const EdgeInsets.all(4);
    }
    return EdgeInsets.zero;
  }

  @override
  Widget build(BuildContext context) {
    final endActionVisible = _offset < 0;
    final actionInsets = _resolvedActionInsets(context);
    return ClipRect(
      child: Stack(
        children: [
          Positioned(
            right: actionInsets.right,
            top: actionInsets.top,
            bottom: actionInsets.bottom,
            width: widget.actionExtent,
            child: _SwipeDeleteActionSlot(
              width: widget.actionExtent,
              visible: endActionVisible,
              semanticsKey: const Key('swipe-delete-end-semantics'),
              actionKey: const Key('swipe-delete-end-action'),
              textDirection: TextDirection.rtl,
              onPressed: _deleting ? null : _handleDelete,
            ),
          ),
          Transform.translate(
            offset: Offset(_offset, 0),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeDeleteActionSlot extends StatelessWidget {
  const _SwipeDeleteActionSlot({
    required this.width,
    required this.visible,
    required this.semanticsKey,
    required this.actionKey,
    required this.textDirection,
    required this.onPressed,
  });

  final double width;
  final bool visible;
  final Key semanticsKey;
  final Key actionKey;
  final TextDirection textDirection;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: IgnorePointer(
        ignoring: !visible,
        child: ExcludeSemantics(
          key: semanticsKey,
          excluding: !visible,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOutCubic,
            child: _SwipeDeleteButton(
              key: actionKey,
              textDirection: textDirection,
              onPressed: visible ? onPressed : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeDeleteButton extends StatelessWidget {
  const _SwipeDeleteButton({
    super.key,
    required this.textDirection,
    required this.onPressed,
  });

  final TextDirection textDirection;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '删除',
      child: Material(
        color: AppColors.risk,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: textDirection,
              children: const [
                Icon(Icons.delete_outline, color: Colors.white),
                SizedBox(width: 6),
                Text('删除', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Legacy Dismissible-style swipe delete background.
///
/// Current village/building/house rows use [SwipeDeleteAction], which exposes
/// a trailing/right-side action via a physical left swipe. [fromEnd] is retained
/// for any older call sites that still need a mirrored background.
Widget swipeDeleteBackground({bool fromEnd = false}) {
  final children = <Widget>[
    const Icon(Icons.delete_outline, color: Colors.white),
    const SizedBox(width: 8),
    const Text('删除', style: TextStyle(color: Colors.white)),
  ];
  return Container(
    alignment: fromEnd ? Alignment.centerRight : Alignment.centerLeft,
    padding: EdgeInsets.only(
      left: fromEnd ? 0 : 20,
      right: fromEnd ? 20 : 0,
    ),
    color: AppColors.risk,
    child: ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: fromEnd ? TextDirection.rtl : TextDirection.ltr,
        children: children,
      ),
    ),
  );
}
