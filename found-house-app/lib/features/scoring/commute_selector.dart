// 主要通勤选择（W4，冻结项 F5）。
//
// 规则：先按 primary destination 过滤；再默认取 transit；
// 用户 preferredCommuteMode 优先；无 transit（或无首选方式）结果时回退 driving。
// 仅依赖 dart:core。

import 'scoring_models.dart';

/// 从多方式通勤结果中挑选主要口径（F5）。
class CommuteSelector {
  const CommuteSelector();

  /// [options] 为各出行方式的通勤结果，[preferredMode] 为用户首选（可空）。
  /// [primaryDestinationId] 为偏好中 primary=true 的目的地 id；旧快照没有
  /// destinationId 时不做过滤，保持兼容。
  ///
  /// 优先级：preferredMode（若有对应结果）→ transit → driving → 任一可用。
  /// 全部无结果时返回 CommuteSelection.empty()。
  CommuteSelection select(
    List<CommuteOption> options, {
    String? preferredMode,
    String? primaryDestinationId,
  }) {
    if (options.isEmpty) return const CommuteSelection.empty();

    final scopedOptions = _byDestination(options, primaryDestinationId);
    if (scopedOptions.isEmpty) return const CommuteSelection.empty();

    CommuteOption? pick;

    // 1) 用户首选优先。
    if (preferredMode != null && preferredMode.isNotEmpty) {
      pick = _byMode(scopedOptions, preferredMode);
    }
    // 2) 默认 transit。
    pick ??= _byMode(scopedOptions, 'transit');
    // 3) 回退 driving。
    pick ??= _byMode(scopedOptions, 'driving');
    // 4) 兜底取第一条可用。
    pick ??= scopedOptions.first;

    return CommuteSelection(
      hasResult: true,
      destinationId: pick.destinationId,
      mode: pick.mode,
      minutes: pick.minutes,
      transferCount: pick.transferCount,
      walkingMeters: pick.walkingMeters,
    );
  }

  List<CommuteOption> _byDestination(
    List<CommuteOption> options,
    String? destinationId,
  ) {
    if (destinationId == null || destinationId.isEmpty) return options;

    final hasDestinationIds = options.any((o) => o.destinationId != null);
    if (!hasDestinationIds) return options;

    return [
      for (final o in options)
        if (o.destinationId == destinationId) o,
    ];
  }

  CommuteOption? _byMode(List<CommuteOption> options, String mode) {
    for (final o in options) {
      if (o.mode == mode) return o;
    }
    return null;
  }
}
