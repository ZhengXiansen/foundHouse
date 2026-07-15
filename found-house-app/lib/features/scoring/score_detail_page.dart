// 评分详情页（W4 · G4，UI §5.8）。
//
// 职责边界：加载单套房源的组合评分视图（houseScoreViewProvider），展示：
//   - 100 分制总分（环形/大字）+ 硬筛状态；命中 blocker 时红线置顶「已淘汰」；
//   - 5 维横条（cost/commute/living/nearby/risk，权重 30/20/25/15/10）；
//   - 扣分来源（按影响排序，来自 ScoreResult.explanations）；
//   - 缺失信息提示（costCapped/commuteMissing 等）；
//   - 「关闭自动评分」开关（本地状态，不落库）。
//
// 关键约束：本页只读展示，不改库、不含评分业务（编排在 house_scoring_controller）。
// 权重取自 defaultScoreRule，不在页面硬编码魔法权重。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import 'house_scoring_controller.dart';
import 'score_rule.dart';
import 'scoring_models.dart';

/// 单维展示定义：键、标签、分值取值器、权重取值器。
typedef _DimValue = double Function(ScoreBreakdown b);
typedef _DimWeight = double Function(ScoreWeights w);

class _DimDef {
  const _DimDef({
    required this.label,
    required this.value,
    required this.weight,
    required this.color,
  });

  final String label;
  final _DimValue value;
  final _DimWeight weight;
  final Color color;
}

/// 5 维展示顺序与取值（权重从 ScoreWeights 读取，不硬编码）。
const List<_DimDef> _dims = [
  _DimDef(
    label: '总成本',
    value: _costValue,
    weight: _costWeight,
    color: AppColors.primary,
  ),
  _DimDef(
    label: '通勤',
    value: _commuteValue,
    weight: _commuteWeight,
    color: AppColors.commute,
  ),
  _DimDef(
    label: '居住',
    value: _livingValue,
    weight: _livingWeight,
    color: AppColors.primary,
  ),
  _DimDef(
    label: '周边',
    value: _nearbyValue,
    weight: _nearbyWeight,
    color: AppColors.primary,
  ),
  _DimDef(
    label: '风险',
    value: _riskValue,
    weight: _riskWeight,
    color: AppColors.warning,
  ),
];

double _costValue(ScoreBreakdown b) => b.cost;
double _commuteValue(ScoreBreakdown b) => b.commute;
double _livingValue(ScoreBreakdown b) => b.living;
double _nearbyValue(ScoreBreakdown b) => b.nearby;
double _riskValue(ScoreBreakdown b) => b.risk;

double _costWeight(ScoreWeights w) => w.cost;
double _commuteWeight(ScoreWeights w) => w.commute;
double _livingWeight(ScoreWeights w) => w.living;
double _nearbyWeight(ScoreWeights w) => w.nearby;
double _riskWeight(ScoreWeights w) => w.risk;

/// 评分详情页。
class ScoreDetailPage extends ConsumerStatefulWidget {
  const ScoreDetailPage({required this.houseId, super.key});

  /// 关联房源主键（HouseRecord.id）。由路由 `/houses/:houseId/score` 注入。
  final String houseId;

  @override
  ConsumerState<ScoreDetailPage> createState() => _ScoreDetailPageState();
}

class _ScoreDetailPageState extends ConsumerState<ScoreDetailPage> {
  /// 自动评分开关（本地状态，关闭后隐藏分数区，UI §5.8「关闭自动评分」）。
  bool _autoScore = true;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(houseScoreViewProvider(widget.houseId));

    return Scaffold(
      appBar: AppBar(title: const Text('评分详情')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('评分加载失败：$e', textAlign: TextAlign.center),
          ),
        ),
        data: (view) {
          if (view == null) {
            return const Center(child: Text('房源不存在或已删除。'));
          }
          return _buildBody(context, view);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, HouseScoreView view) {
    final weights = defaultScoreRule.weights;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        if (view.hasBlocker) _BlockerBanner(view: view),
        _AutoScoreToggle(
          value: _autoScore,
          onChanged: (v) => setState(() => _autoScore = v),
        ),
        const SizedBox(height: 12),
        if (_autoScore) ...[
          _TotalSummary(view: view),
          const SizedBox(height: 20),
          const _SectionTitle('维度分'),
          const SizedBox(height: 8),
          for (final d in _dims)
            _DimBar(
              label: d.label,
              score: d.value(view.score.breakdown),
              weightPercent: (d.weight(weights) * 100).round(),
              color: d.color,
            ),
          const SizedBox(height: 20),
          const _SectionTitle('扣分来源与说明'),
          const SizedBox(height: 8),
          _Explanations(view: view),
          const SizedBox(height: 20),
          const _SectionTitle('缺失信息'),
          const SizedBox(height: 8),
          _MissingInfo(view: view),
        ] else
          const _AutoScoreOffHint(),
      ],
    );
  }
}

/// 红线置顶横幅：命中 blocker 时显著提示「已淘汰，高分不能抵消」。
class _BlockerBanner extends StatelessWidget {
  const _BlockerBanner({required this.view});

  final HouseScoreView view;

  @override
  Widget build(BuildContext context) {
    final blockerReasons =
        view.filter.reasons.where((r) => r.ruleId == 'hit_blocker_risk');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.risk.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.risk.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.block, color: AppColors.risk),
              const SizedBox(width: 8),
              Text(
                '已淘汰：命中红线风险',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.risk,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '红线风险不可被高分抵消，建议优先排除。',
            style: TextStyle(color: AppColors.risk, fontSize: 13),
          ),
          for (final r in blockerReasons) ...[
            const SizedBox(height: 6),
            Text(
              '· ${r.message}',
              style: const TextStyle(color: AppColors.risk, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

/// 自动评分开关行。
class _AutoScoreToggle extends StatelessWidget {
  const _AutoScoreToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: const Text('自动评分'),
        subtitle: Text(
          value ? '按评分规则展示总分与维度分' : '已关闭自动评分，仅保留硬筛结论',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        activeThumbColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}

/// 关闭自动评分后的占位提示。
class _AutoScoreOffHint extends StatelessWidget {
  const _AutoScoreOffHint();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.visibility_off_outlined,
            size: 40,
            color: AppColors.offline,
          ),
          SizedBox(height: 12),
          Text(
            '自动评分已关闭',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 4),
          Text(
            '可随时重新打开查看总分与维度分',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// 总分摘要：大字总分 + 环形进度 + 硬筛状态 + 规则版本。
class _TotalSummary extends StatelessWidget {
  const _TotalSummary({required this.view});

  final HouseScoreView view;

  @override
  Widget build(BuildContext context) {
    final rejected = view.rejected;
    final total = view.total;
    final ringColor = rejected ? AppColors.risk : AppColors.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      value: (total / 100).clamp(0, 1),
                      strokeWidth: 8,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        total.round().toString(),
                        style: TextStyle(
                          fontSize: 30,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          color: ringColor,
                        ),
                      ),
                      const Text(
                        '总分',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        rejected ? Icons.block : Icons.verified_outlined,
                        size: 18,
                        color: rejected ? AppColors.risk : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        rejected ? '硬筛：已淘汰' : '硬筛：通过',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: rejected ? AppColors.risk : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rejected ? '总分仅供参考，硬筛未通过。' : '已通过硬筛，可进入对比。',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '规则版本 ${view.score.ruleVersion}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单维横条：标签 + 权重 + 分值条。
class _DimBar extends StatelessWidget {
  const _DimBar({
    required this.label,
    required this.score,
    required this.weightPercent,
    required this.color,
  });

  final String label;
  final double score;
  final int weightPercent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '权重 $weightPercent%',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                score.round().toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (score / 100).clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

/// 扣分来源与说明：来自 ScoreResult.explanations，硬筛淘汰原因优先置顶。
class _Explanations extends StatelessWidget {
  const _Explanations({required this.view});

  final HouseScoreView view;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    // 硬筛淘汰原因优先（影响最大）。
    for (final r in view.filter.reasons) {
      rows.add(
        _line(
          icon: Icons.error_outline,
          color: AppColors.risk,
          text: r.message,
        ),
      );
    }
    // 评分解释文案（缺失/来源/修正等）。
    for (final e in view.score.explanations) {
      rows.add(
        _line(
          icon: _iconFor(e.code),
          color: _colorFor(e.code),
          text: e.message,
        ),
      );
    }

    if (rows.isEmpty) {
      return const Text(
        '暂无扣分或提示，信息较完整。',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(children: rows),
      ),
    );
  }

  Widget _line({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String code) {
    switch (code) {
      case 'user_correction':
        return Icons.edit_outlined;
      case 'commute_source':
        return Icons.directions_transit_outlined;
      case 'cost_capped':
        return Icons.info_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color _colorFor(String code) {
    // 用户主观修正用蓝色标识（UI §5.8「你已修正」）。
    if (code == 'user_correction' || code == 'commute_source') {
      return AppColors.commute;
    }
    if (code == 'cost_capped') return AppColors.warning;
    if (code.endsWith('_missing')) return AppColors.textSecondary;
    return AppColors.textSecondary;
  }
}

/// 缺失信息提示：cost 封顶 / 各维度中性默认。
class _MissingInfo extends StatelessWidget {
  const _MissingInfo({required this.view});

  final HouseScoreView view;

  @override
  Widget build(BuildContext context) {
    final b = view.score.breakdown;
    final items = <String>[
      if (b.costCapped) '费用信息不完整，成本维度被封顶，建议补问水电单价。',
      if (b.commuteMissing) '暂无通勤数据，通勤维度按中性默认计分，可补通勤后重算。',
      if (b.livingMissing) '暂无有效居住检查项，居住维度按中性默认计分。',
      if (b.nearbyMissing) '暂无周边数据，周边维度按中性默认计分。',
    ];
    if (items.isEmpty) {
      return const Text(
        '关键信息较完整。',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            for (final t in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.help_outline,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(t, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 分区小标题。
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
