// Checklist 模板（W1-2 · UI §5.6）。
//
// 数据源为 docs/rules/checklist-template.json（模板版本 mvp-2026-07-02）。
// 因 pubspec.yaml 未把 docs/ 注册为 Flutter asset（且本轨不修改 pubspec），
// 无法在运行时经 rootBundle 加载 JSON，故在此以 Dart 常量镜像模板内容，
// 保持与 JSON 逐项一致。后续里程碑若把模板改为远程下发/asset 加载，
// 应替换本文件为解析层，模块与 key 命名保持不变（与 ChecklistItem.module/key 对齐）。

/// 模板版本（与 checklist-template.json 的 template_version 一致）。
const String kChecklistTemplateVersion = 'mvp-2026-07-02';

/// 四态取值：默认模块用 good/ok/bad/not_seen。
class ChecklistValue {
  const ChecklistValue._();

  static const String good = 'good';
  static const String ok = 'ok';
  static const String bad = 'bad';
  static const String notSeen = 'not_seen';

  /// risk 模块专用取值。
  static const String hit = 'hit';
  static const String notHit = 'not_hit';

  /// 默认模块四态。
  static const List<String> defaults = [good, ok, bad, notSeen];

  /// risk 模块三态。
  static const List<String> risk = [hit, notHit, notSeen];
}

/// 单个检查项模板定义。
class ChecklistItemTemplate {
  const ChecklistItemTemplate({
    required this.key,
    required this.label,
    this.affects,
    this.severity,
    this.critical = false,
  });

  /// 检查项编码（对齐 ChecklistItem.key）。
  final String key;

  /// 中文显示名。
  final String label;

  /// 影响的评分维度（living/cost/risk 等），仅作展示提示。
  final String? affects;

  /// risk 模块严重度（warning/blocker）。
  final String? severity;

  /// 是否关键项（缺失影响硬筛/成本）。
  final bool critical;
}

/// 模块模板定义（room/kitchen/building/contract/risk 之一）。
class ChecklistModuleTemplate {
  const ChecklistModuleTemplate({
    required this.module,
    required this.label,
    required this.items,
  });

  /// 模块编码（对齐 ChecklistItem.module）。
  final String module;

  /// 模块中文名。
  final String label;

  /// 模块下检查项。
  final List<ChecklistItemTemplate> items;

  /// 该模块可选取值：risk 模块用 hit/not_hit/not_seen，其余用 good/ok/bad/not_seen。
  List<String> get valueOptions =>
      module == 'risk' ? ChecklistValue.risk : ChecklistValue.defaults;
}

/// 完整模板：五模块，与 docs/rules/checklist-template.json 逐项对齐。
const List<ChecklistModuleTemplate> kChecklistTemplate = [
  ChecklistModuleTemplate(
    module: 'room',
    label: '房间',
    items: [
      ChecklistItemTemplate(
        key: 'room_lighting',
        label: '采光',
        affects: 'living',
      ),
      ChecklistItemTemplate(
        key: 'room_ventilation',
        label: '通风',
        affects: 'living',
      ),
      ChecklistItemTemplate(key: 'room_noise', label: '噪音', affects: 'living'),
      ChecklistItemTemplate(key: 'room_damp', label: '潮湿', affects: 'living'),
      ChecklistItemTemplate(key: 'room_wall', label: '墙面', affects: 'living'),
      ChecklistItemTemplate(
        key: 'room_socket',
        label: '插座',
        affects: 'living',
      ),
      ChecklistItemTemplate(
        key: 'room_signal',
        label: '手机信号',
        affects: 'living',
      ),
    ],
  ),
  ChecklistModuleTemplate(
    module: 'kitchen',
    label: '厨卫',
    items: [
      ChecklistItemTemplate(
        key: 'kitchen_drainage',
        label: '排水',
        affects: 'living',
      ),
      ChecklistItemTemplate(
        key: 'kitchen_hotwater',
        label: '热水',
        affects: 'living',
      ),
      ChecklistItemTemplate(
        key: 'kitchen_odor',
        label: '异味',
        affects: 'living',
      ),
      ChecklistItemTemplate(
        key: 'kitchen_smoke',
        label: '油烟',
        affects: 'living',
      ),
      ChecklistItemTemplate(
        key: 'kitchen_private_bath',
        label: '独卫',
        affects: 'living',
      ),
      ChecklistItemTemplate(
        key: 'kitchen_can_cook',
        label: '能否做饭',
        affects: 'living',
      ),
    ],
  ),
  ChecklistModuleTemplate(
    module: 'building',
    label: '楼栋',
    items: [
      ChecklistItemTemplate(
        key: 'building_elevator',
        label: '电梯',
        affects: 'living',
      ),
      ChecklistItemTemplate(
        key: 'building_access',
        label: '门禁',
        affects: 'risk',
      ),
      ChecklistItemTemplate(
        key: 'building_fire_exit',
        label: '消防通道',
        affects: 'risk',
      ),
      ChecklistItemTemplate(
        key: 'building_garbage',
        label: '垃圾点',
        affects: 'living',
      ),
      ChecklistItemTemplate(
        key: 'building_corridor_light',
        label: '楼道照明',
        affects: 'risk',
      ),
    ],
  ),
  ChecklistModuleTemplate(
    module: 'contract',
    label: '合同',
    items: [
      ChecklistItemTemplate(
        key: 'contract_deposit_refund',
        label: '押金退还',
        affects: 'risk',
        critical: true,
      ),
      ChecklistItemTemplate(
        key: 'contract_utility_price',
        label: '水电单价',
        affects: 'cost',
        critical: true,
      ),
      ChecklistItemTemplate(
        key: 'contract_sublet_limit',
        label: '转租限制',
        affects: 'risk',
      ),
      ChecklistItemTemplate(
        key: 'contract_repair_duty',
        label: '维修责任',
        affects: 'risk',
      ),
    ],
  ),
  ChecklistModuleTemplate(
    module: 'risk',
    label: '风险',
    items: [
      ChecklistItemTemplate(
        key: 'risk_second_landlord',
        label: '二房东',
        severity: 'warning',
      ),
      ChecklistItemTemplate(
        key: 'risk_identity_unverified',
        label: '身份不明',
        severity: 'warning',
      ),
      ChecklistItemTemplate(
        key: 'risk_fee_ambiguous',
        label: '费用口径矛盾',
        severity: 'warning',
      ),
      ChecklistItemTemplate(
        key: 'risk_no_contract',
        label: '拒绝写合同',
        severity: 'warning',
      ),
      ChecklistItemTemplate(
        key: 'risk_non_residential',
        label: '非居住空间',
        severity: 'blocker',
      ),
      ChecklistItemTemplate(
        key: 'risk_refuse_identity',
        label: '拒绝出示证件',
        severity: 'blocker',
      ),
      ChecklistItemTemplate(
        key: 'risk_deposit_unclear',
        label: '押金规则完全不清',
        severity: 'blocker',
      ),
      ChecklistItemTemplate(
        key: 'risk_fire_safety',
        label: '消防/楼栋安全异常',
        severity: 'blocker',
      ),
      ChecklistItemTemplate(
        key: 'risk_fee_contradiction',
        label: '费用矛盾且无法写入合同',
        severity: 'blocker',
      ),
    ],
  ),
];

/// 四态取值的中文短标签（分段控件展示用）。
String checklistValueLabel(String module, String value) {
  if (module == 'risk') {
    switch (value) {
      case ChecklistValue.hit:
        return '命中';
      case ChecklistValue.notHit:
        return '未命中';
      case ChecklistValue.notSeen:
        return '未看';
    }
  }
  switch (value) {
    case ChecklistValue.good:
      return '好';
    case ChecklistValue.ok:
      return '一般';
    case ChecklistValue.bad:
      return '差';
    case ChecklistValue.notSeen:
      return '未看';
  }
  return value;
}
