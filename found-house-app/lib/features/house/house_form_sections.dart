// 房源详情表单分区（W1-2 · D6，UI §5.5）。
//
// 职责边界：房源详情页各可折叠模块的**表现层** Widget（基础/费用/房屋/联系人/
// 备注），只负责渲染字段与向上抛出改动，不直接读写仓库。
//
// 自动保存的一致性约束（关键）：HouseRepository 对 1:1 子表（fee/room/contact）
// 采用整体 upsert（insertOnConflictUpdate 写入完整 Companion）。因此**不能**在
// 各 Section 内各自 save 局部对象，否则会互相覆盖字段。持有完整工作副本、
// 每次保存整对象的职责统一收敛在 house_detail_page.dart，本文件仅上抛单字段改动。
//
// 敏感字段（门牌/电话/微信/敏感备注）在此仅作明文录入，加密由仓库经 FieldCipher
// 完成（F7），本文件不接触密文、不打印明文日志。

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../common/form_widgets.dart';

/// 基础信息模块：标题、楼栋/村名、地址、门牌（敏感）、看房时间。
class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({
    super.key,
    required this.titleController,
    required this.buildingController,
    required this.addressController,
    required this.roomNoController,
    required this.visitedAtLabel,
    required this.onPickVisitedAt,
    required this.badge,
    this.initiallyExpanded = true,
  });

  final TextEditingController titleController;
  final TextEditingController buildingController;
  final TextEditingController addressController;
  final TextEditingController roomNoController;

  /// 看房时间展示文案（未设置为「未记录」）。
  final String visitedAtLabel;
  final VoidCallback onPickVisitedAt;
  final String badge;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '基础信息',
      icon: Icons.home_outlined,
      badge: badge,
      initiallyExpanded: initiallyExpanded,
      child: Column(
        children: [
          LabeledField(
            label: '标题',
            controller: titleController,
            hintText: '如 城中村单间 · 白石洲',
          ),
          LabeledField(
            label: '楼栋 / 村名',
            controller: buildingController,
            hintText: '如 3 栋 / 新围村',
          ),
          LabeledField(
            label: '地址',
            controller: addressController,
            hintText: '街道门牌或大致位置',
          ),
          LabeledField(
            label: '门牌（本地加密，导出默认隐藏）',
            controller: roomNoController,
            hintText: '如 302',
          ),
          _PickerTile(
            label: '看房时间',
            value: visitedAtLabel,
            icon: Icons.event_outlined,
            onTap: onPickVisitedAt,
          ),
        ],
      ),
    );
  }
}

/// 费用模块：月租、押金、押付、管理费、网费、水电单价、燃气、其他。
class FeeSection extends StatelessWidget {
  const FeeSection({
    super.key,
    required this.rentController,
    required this.depositController,
    required this.managementController,
    required this.internetController,
    required this.waterController,
    required this.electricityController,
    required this.gasController,
    required this.otherController,
    required this.paymentCycle,
    required this.onPaymentCycleChanged,
    required this.badge,
  });

  final TextEditingController rentController;
  final TextEditingController depositController;
  final TextEditingController managementController;
  final TextEditingController internetController;
  final TextEditingController waterController;
  final TextEditingController electricityController;
  final TextEditingController gasController;
  final TextEditingController otherController;
  final String? paymentCycle;
  final ValueChanged<String?> onPaymentCycleChanged;
  final String badge;

  /// 常见押付方式。
  static const List<String> _cycleOptions = [
    '押一付一',
    '押一付三',
    '押二付一',
    '押二付三',
    '半年付',
    '年付',
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '费用',
      icon: Icons.payments_outlined,
      badge: badge,
      child: Column(
        children: [
          LabeledField(
            label: '月租',
            controller: rentController,
            keyboardType: TextInputType.number,
            suffixText: '元/月',
          ),
          LabeledField(
            label: '押金',
            controller: depositController,
            keyboardType: TextInputType.number,
            suffixText: '元',
          ),
          ChoiceChipsField(
            label: '押付方式',
            options: _cycleOptions,
            value: paymentCycle,
            onChanged: onPaymentCycleChanged,
          ),
          LabeledField(
            label: '管理费',
            controller: managementController,
            keyboardType: TextInputType.number,
            suffixText: '元/月',
          ),
          LabeledField(
            label: '网费',
            controller: internetController,
            keyboardType: TextInputType.number,
            suffixText: '元/月',
          ),
          LabeledField(
            label: '水费单价（缺失会按保守值估算成本）',
            controller: waterController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixText: '元/吨',
          ),
          LabeledField(
            label: '电费单价（缺失会按保守值估算成本）',
            controller: electricityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixText: '元/度',
          ),
          LabeledField(
            label: '燃气费',
            controller: gasController,
            keyboardType: TextInputType.number,
            suffixText: '元/月',
          ),
          LabeledField(
            label: '其他固定费用',
            controller: otherController,
            keyboardType: TextInputType.number,
            suffixText: '元/月',
          ),
        ],
      ),
    );
  }
}

/// 房屋模块：房型、面积、楼层、朝向、电梯、独卫、厨房、做饭、养宠。
class RoomSection extends StatelessWidget {
  const RoomSection({
    super.key,
    required this.areaController,
    required this.floorController,
    required this.totalFloorController,
    required this.layout,
    required this.onLayoutChanged,
    required this.orientation,
    required this.onOrientationChanged,
    required this.hasElevator,
    required this.onElevatorChanged,
    required this.hasPrivateBathroom,
    required this.onPrivateBathroomChanged,
    required this.hasKitchen,
    required this.onKitchenChanged,
    required this.canCook,
    required this.onCanCookChanged,
    required this.canPet,
    required this.onCanPetChanged,
    required this.badge,
  });

  final TextEditingController areaController;
  final TextEditingController floorController;
  final TextEditingController totalFloorController;

  final String? layout;
  final ValueChanged<String?> onLayoutChanged;
  final String? orientation;
  final ValueChanged<String?> onOrientationChanged;

  final bool? hasElevator;
  final ValueChanged<bool?> onElevatorChanged;
  final bool? hasPrivateBathroom;
  final ValueChanged<bool?> onPrivateBathroomChanged;
  final bool? hasKitchen;
  final ValueChanged<bool?> onKitchenChanged;
  final bool? canCook;
  final ValueChanged<bool?> onCanCookChanged;
  final bool? canPet;
  final ValueChanged<bool?> onCanPetChanged;

  final String badge;

  static const List<String> _layoutOptions = [
    '单间',
    '一房一厅',
    '两房一厅',
    '三房一厅',
    '合租主卧',
    '合租次卧',
    '公寓',
  ];

  static const List<String> _orientationOptions = [
    '朝南',
    '朝北',
    '朝东',
    '朝西',
    '东南',
    '西南',
    '东北',
    '西北',
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '房屋',
      icon: Icons.meeting_room_outlined,
      badge: badge,
      child: Column(
        children: [
          ChoiceChipsField(
            label: '房型',
            options: _layoutOptions,
            value: layout,
            onChanged: onLayoutChanged,
          ),
          LabeledField(
            label: '面积',
            controller: areaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixText: '㎡',
          ),
          Row(
            children: [
              Expanded(
                child: LabeledField(
                  label: '所在楼层',
                  controller: floorController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LabeledField(
                  label: '总楼层',
                  controller: totalFloorController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          ChoiceChipsField(
            label: '朝向',
            options: _orientationOptions,
            value: orientation,
            onChanged: onOrientationChanged,
          ),
          const Divider(height: 20),
          const FieldGroupLabel('硬性条件（用于筛选）'),
          TriStateField(
            label: '电梯',
            value: hasElevator,
            onChanged: onElevatorChanged,
          ),
          TriStateField(
            label: '独立卫生间',
            value: hasPrivateBathroom,
            onChanged: onPrivateBathroomChanged,
          ),
          TriStateField(
            label: '厨房',
            value: hasKitchen,
            onChanged: onKitchenChanged,
          ),
          TriStateField(
            label: '能否做饭',
            value: canCook,
            onChanged: onCanCookChanged,
          ),
          TriStateField(
            label: '能否养宠',
            value: canPet,
            onChanged: onCanPetChanged,
          ),
        ],
      ),
    );
  }
}

/// 联系人模块：称呼、角色、电话（敏感）、微信（敏感）、身份核验。
class ContactSection extends StatelessWidget {
  const ContactSection({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.wechatController,
    required this.role,
    required this.onRoleChanged,
    required this.identityVerified,
    required this.onIdentityChanged,
    required this.badge,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController wechatController;
  final String? role;
  final ValueChanged<String?> onRoleChanged;
  final bool? identityVerified;
  final ValueChanged<bool?> onIdentityChanged;
  final String badge;

  static const List<String> _roleOptions = [
    '房东',
    '管理员',
    '中介',
    '二房东',
    '未知',
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '联系人',
      icon: Icons.person_outline,
      badge: badge,
      child: Column(
        children: [
          LabeledField(
            label: '称呼',
            controller: nameController,
            hintText: '如 陈姐',
          ),
          ChoiceChipsField(
            label: '角色',
            options: _roleOptions,
            value: role,
            onChanged: onRoleChanged,
          ),
          LabeledField(
            label: '电话（本地加密）',
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),
          LabeledField(
            label: '微信（本地加密）',
            controller: wechatController,
          ),
          TriStateField(
            label: '身份已核验（看过证件/授权）',
            value: identityVerified,
            onChanged: onIdentityChanged,
            trueLabel: '已核验',
            falseLabel: '未核验',
            unknownLabel: '未知',
          ),
        ],
      ),
    );
  }
}

/// 备注模块：自由文本备注。
///
/// 数据层无房源级备注字段，MVP 复用 ContactInfo.note（唯一自由文本备注字段，
/// 字段字典标注可选敏感）。与联系人模块共享同一 ContactInfo 工作副本，
/// 由详情页整体保存，避免局部 upsert 互相覆盖。
class NotesSection extends StatelessWidget {
  const NotesSection({
    super.key,
    required this.noteController,
    required this.filled,
  });

  final TextEditingController noteController;

  /// 是否已填写（用于完成度徽标）。
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '备注',
      icon: Icons.notes_outlined,
      badge: filled ? '已填' : '空',
      child: LabeledField(
        label: '备注（含敏感信息时本地加密）',
        controller: noteController,
        hintText: '看房印象、待补问事项、口头承诺等',
        maxLines: 4,
      ),
    );
  }
}

/// 选择型信息行：左标题、右当前值 + 右箭头，点击触发外部选择器。
class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label, style: theme.textTheme.bodyMedium),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
