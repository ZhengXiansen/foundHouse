// 首次偏好设置页（W1-2 · D6，UI §5.1）。
//
// 职责边界：配置硬筛与评分基准——月总成本上限 maxRentTotal（F1，唯一预算基准，
// 非月租）、最大通勤时间、通勤目的地、首选通勤方式、硬性条件（独卫/厨房/电梯/
// 养宠/最低楼层/押付上限）、评分权重（cost/commute/living/nearby/risk）。
//
// 数据落库：进入时 ensureDefault 拿到（或创建）默认 profile 回填；保存时把
// 硬性条件、目的地、权重序列化为 JSON 存入 PreferenceProfile 对应字段。
//
// 关键约束：仅读写，不做重算（权重变更触发重算并保留旧快照属评分轨，F8）。
// 权重为整数百分比，保存前提示是否为 100%（不强制，仅提醒）。

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/models/house_models.dart' as domain;
import '../../data/providers.dart';
import '../../data/repositories/preference_repository.dart';
import '../common/form_widgets.dart';

/// 硬性条件的 JSON 键（与评分/硬筛引擎约定，snake_case）。
class _RequiredKeys {
  const _RequiredKeys._();
  static const String privateBathroom = 'private_bathroom';
  static const String kitchen = 'kitchen';
  static const String elevator = 'elevator';
  static const String pet = 'pet';
  static const String minFloor = 'min_floor';
  static const String maxPaymentUpfront = 'max_payment_upfront';
}

/// 权重维度键（与 score-rule-v0.json 一致）。
const List<String> _weightKeys = [
  'cost',
  'commute',
  'living',
  'nearby',
  'risk',
];

const Map<String, String> _weightLabels = {
  'cost': '成本',
  'commute': '通勤',
  'living': '居住',
  'nearby': '周边',
  'risk': '风险',
};

/// 首选通勤方式选项（value 对齐通勤配置，F5）。
const Map<String, String> _commuteModes = {
  'transit': '公交/地铁',
  'walking': '步行',
  'bicycling': '骑行',
  'driving': '驾车',
};

/// 偏好设置页：预算/通勤/硬条件/权重配置。
class PreferencePage extends ConsumerStatefulWidget {
  const PreferencePage({super.key});

  @override
  ConsumerState<PreferencePage> createState() => _PreferencePageState();
}

class _PreferencePageState extends ConsumerState<PreferencePage> {
  final _maxRentTotalController = TextEditingController();
  final _maxCommuteController = TextEditingController();
  final _destinationController = TextEditingController();

  /// 首选通勤方式；空 = transit（F5）。
  String? _commuteMode;

  /// 硬性条件三态：true 必须 / false 必须没有（如「不要顶楼」类语义暂不建模，保留 false=明确不要）/ null 不限。
  bool? _requirePrivateBathroom;
  bool? _requireKitchen;
  bool? _requireElevator;
  bool? _requirePet;

  /// 最低楼层与押付上限（可空，不限时留空）。
  final _minFloorController = TextEditingController();
  final _maxPaymentUpfrontController = TextEditingController();

  /// 权重工作副本（整数百分比）。
  final Map<String, int> _weights = Map.of(PreferenceRepository.defaultWeights);

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _maxRentTotalController.dispose();
    _maxCommuteController.dispose();
    _destinationController.dispose();
    _minFloorController.dispose();
    _maxPaymentUpfrontController.dispose();
    super.dispose();
  }

  PreferenceRepository get _repo => ref.read(preferenceRepositoryProvider);

  Future<void> _load() async {
    final profile = await _repo.ensureDefault();
    if (!mounted) return;
    _maxRentTotalController.text = profile.maxRentTotal?.toString() ?? '';
    _maxCommuteController.text = profile.maxCommuteMinutes?.toString() ?? '';
    _commuteMode = profile.preferredCommuteMode;

    _restoreDestination(profile.destinationsJson);
    _restoreRequired(profile.requiredFeaturesJson);
    _restoreWeights(profile.weightsJson);

    setState(() => _loaded = true);
  }

  /// 回填目的地：MVP 仅支持单个主要目的地的 label（lat/lng 待 W3 地图接入）。
  void _restoreDestination(String? json) {
    if (json == null || json.isEmpty) return;
    try {
      final list = jsonDecode(json);
      if (list is List && list.isNotEmpty) {
        final first = list.first;
        if (first is Map && first['label'] is String) {
          _destinationController.text = first['label'] as String;
        }
      }
    } catch (_) {
      // 容错：解析失败视为无目的地，不阻断偏好其余字段。
    }
  }

  void _restoreRequired(String? json) {
    if (json == null || json.isEmpty) return;
    try {
      final map = jsonDecode(json);
      if (map is! Map) return;
      _requirePrivateBathroom = map[_RequiredKeys.privateBathroom] as bool?;
      _requireKitchen = map[_RequiredKeys.kitchen] as bool?;
      _requireElevator = map[_RequiredKeys.elevator] as bool?;
      _requirePet = map[_RequiredKeys.pet] as bool?;
      final minFloor = map[_RequiredKeys.minFloor];
      if (minFloor is int) _minFloorController.text = minFloor.toString();
      final maxUpfront = map[_RequiredKeys.maxPaymentUpfront];
      if (maxUpfront is int) {
        _maxPaymentUpfrontController.text = maxUpfront.toString();
      }
    } catch (_) {
      // 容错同上。
    }
  }

  void _restoreWeights(String? json) {
    if (json == null || json.isEmpty) return;
    try {
      final map = jsonDecode(json);
      if (map is! Map) return;
      for (final k in _weightKeys) {
        final v = map[k];
        if (v is int) _weights[k] = v;
        if (v is double) _weights[k] = v.round();
      }
    } catch (_) {
      // 容错：解析失败保留默认权重。
    }
  }

  /// 组装并保存偏好（save 强制主键为 default）。
  Future<void> _save({bool thenPop = false}) async {
    final maxRentTotal = int.tryParse(_maxRentTotalController.text.trim());
    final maxCommute = int.tryParse(_maxCommuteController.text.trim());

    final required = <String, Object?>{
      _RequiredKeys.privateBathroom: _requirePrivateBathroom,
      _RequiredKeys.kitchen: _requireKitchen,
      _RequiredKeys.elevator: _requireElevator,
      _RequiredKeys.pet: _requirePet,
      _RequiredKeys.minFloor: int.tryParse(_minFloorController.text.trim()),
      _RequiredKeys.maxPaymentUpfront:
          int.tryParse(_maxPaymentUpfrontController.text.trim()),
    }..removeWhere((_, v) => v == null);

    final destLabel = _destinationController.text.trim();
    final destinations = destLabel.isEmpty
        ? <Map<String, Object?>>[]
        : [
            {
              'id': 'primary',
              'label': destLabel,
              'lat': null,
              'lng': null,
              'primary': true,
            },
          ];

    final profile = domain.PreferenceProfile(
      id: PreferenceRepository.defaultProfileId,
      maxRentTotal: maxRentTotal,
      maxCommuteMinutes: maxCommute,
      destinationsJson: destinations.isEmpty ? null : jsonEncode(destinations),
      requiredFeaturesJson: required.isEmpty ? null : jsonEncode(required),
      weightsJson: jsonEncode(_weights),
      preferredCommuteMode: _commuteMode,
    );
    await _repo.save(profile);
    if (!mounted) return;
    if (thenPop) {
      // 用 Navigator.maybePop：go_router 的 push 页在其上，可正常返回；
      // 无可返回页时安全 no-op（如作为根页嵌入测试/首启引导）。
      unawaited(Navigator.of(context).maybePop());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('偏好已保存')),
      );
    }
  }

  int get _weightSum => _weights.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('偏好设置'),
        actions: [
          TextButton(
            onPressed: _loaded ? () => _save(thenPop: true) : null,
            child: const Text('保存'),
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    '这些偏好用于硬性筛选与打分。可先填预算和通勤，其余随时再调。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                // 预算与通勤
                SectionCard(
                  title: '预算与通勤',
                  icon: Icons.savings_outlined,
                  initiallyExpanded: true,
                  child: Column(
                    children: [
                      LabeledField(
                        label: '月总成本上限（含水电杂费，非仅月租）',
                        controller: _maxRentTotalController,
                        keyboardType: TextInputType.number,
                        hintText: '如 2500',
                        suffixText: '元/月',
                      ),
                      LabeledField(
                        label: '最大可接受通勤时间',
                        controller: _maxCommuteController,
                        keyboardType: TextInputType.number,
                        hintText: '如 45',
                        suffixText: '分钟',
                      ),
                      LabeledField(
                        label: '通勤目的地（如 公司/学校名称）',
                        controller: _destinationController,
                        hintText: '如 科技园',
                      ),
                      ChoiceChipsField(
                        label: '首选通勤方式',
                        options: _commuteModes.values.toList(),
                        value: _commuteMode == null
                            ? null
                            : _commuteModes[_commuteMode],
                        onChanged: (label) {
                          setState(() {
                            _commuteMode = label == null
                                ? null
                                : _commuteModes.entries
                                    .firstWhere((e) => e.value == label)
                                    .key;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // 硬性条件
                SectionCard(
                  title: '硬性条件',
                  icon: Icons.rule_outlined,
                  child: Column(
                    children: [
                      const FieldGroupLabel('「必须」项不满足会被硬筛淘汰；「不限」不参与筛选'),
                      TriStateField(
                        label: '独立卫生间',
                        value: _requirePrivateBathroom,
                        onChanged: (v) =>
                            setState(() => _requirePrivateBathroom = v),
                        trueLabel: '必须',
                        falseLabel: '不要',
                        unknownLabel: '不限',
                      ),
                      TriStateField(
                        label: '厨房',
                        value: _requireKitchen,
                        onChanged: (v) => setState(() => _requireKitchen = v),
                        trueLabel: '必须',
                        falseLabel: '不要',
                        unknownLabel: '不限',
                      ),
                      TriStateField(
                        label: '电梯',
                        value: _requireElevator,
                        onChanged: (v) => setState(() => _requireElevator = v),
                        trueLabel: '必须',
                        falseLabel: '不要',
                        unknownLabel: '不限',
                      ),
                      TriStateField(
                        label: '可养宠物',
                        value: _requirePet,
                        onChanged: (v) => setState(() => _requirePet = v),
                        trueLabel: '必须',
                        falseLabel: '不要',
                        unknownLabel: '不限',
                      ),
                      LabeledField(
                        label: '最低楼层（低于此楼层淘汰，不限留空）',
                        controller: _minFloorController,
                        keyboardType: TextInputType.number,
                        hintText: '如 2',
                        suffixText: '层',
                      ),
                      LabeledField(
                        label: '押付上限（如最多接受押二付三填 3，不限留空）',
                        controller: _maxPaymentUpfrontController,
                        keyboardType: TextInputType.number,
                        hintText: '如 3',
                        suffixText: '个月',
                      ),
                    ],
                  ),
                ),
                // 评分权重
                SectionCard(
                  title: '评分权重',
                  icon: Icons.tune_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldGroupLabel(
                        '各维度占比（当前合计 $_weightSum%）'
                        '${_weightSum == 100 ? '' : '，建议调整到 100%'}',
                      ),
                      for (final k in _weightKeys)
                        _WeightSlider(
                          label: _weightLabels[k]!,
                          value: _weights[k]!,
                          onChanged: (v) => setState(() => _weights[k] = v),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _weights
                                ..clear()
                                ..addAll(PreferenceRepository.defaultWeights);
                            });
                          },
                          child: const Text('恢复默认 30/20/25/15/10'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: FilledButton(
                    onPressed: () => _save(thenPop: true),
                    child: const Text('保存偏好'),
                  ),
                ),
              ],
            ),
    );
  }
}

/// 单维度权重滑块（0-100，步进 5）。
class _WeightSlider extends StatelessWidget {
  const _WeightSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: '$value%',
              activeColor: AppColors.primary,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '$value%',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
