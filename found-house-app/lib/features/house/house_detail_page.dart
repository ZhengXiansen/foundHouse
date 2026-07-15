// 房源详情页（W1-2 · D6，UI §5.5）。
//
// 职责边界：加载房源聚合根，把复杂信息拆成可折叠模块（基础/费用/房屋/联系人/
// Checklist 摘要/风险/备注），字段改动即本地自动保存（防抖后 updateMain /
// updateFee / updateRoom / updateContact）。现场可轻填、回家可完整补。
//
// 自动保存一致性（关键）：仓库对 1:1 子表整体 upsert（写完整 Companion），
// 故本页持有各 section 的完整工作副本（_fee/_room/_contact），每次保存都写
// 整个对象，避免局部字段互相覆盖。基础信息属主表，用 updateMain 的分字段
// Value 语义，仅写改动字段。
//
// 备注：数据层无房源级备注字段，MVP 复用 ContactInfo.note，与联系人共享
// 同一 _contact 工作副本整体保存（house_form_sections.dart 已说明）。
//
// 敏感字段（门牌/电话/微信/敏感备注）在页面为明文录入，加密由仓库经 FieldCipher
// 完成（F7）；本页不打印明文日志、不接触密文。

import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/kawaii_widgets.dart';
import '../../app/theme.dart';
import '../../data/local_files/photo_store.dart';
import '../../data/models/house_models.dart' as domain;
import '../../data/providers.dart';
import '../../data/repositories/house_repository.dart';
import '../checklist/checklist_page.dart';
import '../checklist/checklist_template.dart';
import '../common/form_widgets.dart';
import '../common/photo_grid.dart';
import 'house_form_sections.dart';

/// 房源详情页：可折叠模块表单 + 本地自动保存。
class HouseDetailPage extends ConsumerStatefulWidget {
  const HouseDetailPage({required this.houseId, super.key});

  /// 房源主键（HouseRecord.id，UUID）。由路由 `/houses/:houseId` 注入。
  final String houseId;

  @override
  ConsumerState<HouseDetailPage> createState() => _HouseDetailPageState();
}

class _HouseDetailPageState extends ConsumerState<HouseDetailPage> {
  // ---- 主表控制器 ----
  final _titleController = TextEditingController();
  final _buildingController = TextEditingController();
  final _addressController = TextEditingController();
  final _roomNoController = TextEditingController();

  // ---- 费用控制器 ----
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  final _managementController = TextEditingController();
  final _internetController = TextEditingController();
  final _waterController = TextEditingController();
  final _electricityController = TextEditingController();
  final _gasController = TextEditingController();
  final _otherController = TextEditingController();

  // ---- 房屋控制器 ----
  final _areaController = TextEditingController();
  final _floorController = TextEditingController();
  final _totalFloorController = TextEditingController();

  // ---- 联系人 / 备注控制器 ----
  final _contactNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _wechatController = TextEditingController();
  final _noteController = TextEditingController();

  // ---- 工作副本（下拉/三态类字段，非文本框） ----
  String? _paymentCycle;
  String? _layout;
  String? _orientation;
  bool? _hasElevator;
  bool? _hasPrivateBathroom;
  bool? _hasKitchen;
  bool? _canCook;
  bool? _canPet;
  String? _contactRole;
  bool? _identityVerified;
  int? _visitedAt;

  // ---- 派生展示数据（Checklist 摘要 / 风险 / 照片，随保存刷新） ----
  List<domain.ChecklistItem> _checklistItems = const [];
  List<domain.RiskFlag> _riskFlags = const [];
  List<domain.PhotoAsset> _photos = const [];

  /// 合并后的展示用缩略图：已归档照片，按拍照顺序。
  List<PhotoThumb> get _photoThumbs =>
      _photos.map(_thumbFromAsset).toList();

  static PhotoThumb _thumbFromAsset(domain.PhotoAsset a) =>
      PhotoThumb(path: a.localPath, tagLabel: _tagLabel(a.tag), takenAt: a.takenAt);

  static const Map<String, String> _tagLabels = {
    PhotoTag.sign: '招租牌',
    PhotoTag.building: '楼栋入口',
    PhotoTag.room: '房间',
    PhotoTag.window: '窗外',
    PhotoTag.bathroom: '厨卫',
    PhotoTag.meter: '水电表',
    PhotoTag.contract: '合同',
    PhotoTag.damage: '问题留证',
  };

  static String? _tagLabel(String tag) => _tagLabels[tag];

  /// 首帧加载完成前不渲染表单，避免控制器空值闪烁。
  bool _loaded = false;

  /// 房源状态：draft/active/shortlisted/rejected/chosen。
  String _status = 'draft';

  /// 加载失败（房源不存在或读库异常）。
  bool _notFound = false;

  /// 各分区防抖计时器：文本框输入停顿后再落库，降低写频。
  Timer? _mainDebounce;
  Timer? _feeDebounce;
  Timer? _roomDebounce;
  Timer? _contactDebounce;

  /// 自动保存反馈时间戳文案。
  String? _savedHint;

  static const Duration _debounce = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _mainDebounce?.cancel();
    _feeDebounce?.cancel();
    _roomDebounce?.cancel();
    _contactDebounce?.cancel();
    for (final c in [
      _titleController,
      _buildingController,
      _addressController,
      _roomNoController,
      _rentController,
      _depositController,
      _managementController,
      _internetController,
      _waterController,
      _electricityController,
      _gasController,
      _otherController,
      _areaController,
      _floorController,
      _totalFloorController,
      _contactNameController,
      _phoneController,
      _wechatController,
      _noteController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  HouseRepository get _repo => ref.read(houseRepositoryProvider);

  /// 加载房源聚合根，回填全部控制器与工作副本。
  Future<void> _load() async {
    final house = await _repo.getById(widget.houseId);
    if (!mounted) return;
    if (house == null) {
      setState(() => _notFound = true);
      return;
    }
    _status = house.status;
    _titleController.text = house.title;
    _buildingController.text = house.buildingName ?? '';
    _addressController.text = house.addressText ?? '';
    _roomNoController.text = house.roomNo ?? '';
    _visitedAt = house.visitedAt;

    final fee = house.fee;
    _rentController.text = _intText(fee?.rentMonthly);
    _depositController.text = _intText(fee?.deposit);
    _managementController.text = _intText(fee?.managementFee);
    _internetController.text = _intText(fee?.internetFee);
    _waterController.text = _doubleText(fee?.waterUnitPrice);
    _electricityController.text = _doubleText(fee?.electricityUnitPrice);
    _gasController.text = _intText(fee?.gasFee);
    _otherController.text = _intText(fee?.otherFee);
    _paymentCycle = fee?.paymentCycle;

    final room = house.room;
    _layout = room?.layout;
    _areaController.text = _doubleText(room?.area);
    _floorController.text = _intText(room?.floor);
    _totalFloorController.text = _intText(room?.totalFloor);
    _orientation = room?.orientation;
    _hasElevator = room?.hasElevator;
    _hasPrivateBathroom = room?.hasPrivateBathroom;
    _hasKitchen = room?.hasKitchen;
    _canCook = room?.canCook;
    _canPet = room?.canPet;

    final contact = house.contact;
    _contactNameController.text = contact?.name ?? '';
    _contactRole = contact?.role;
    _phoneController.text = contact?.phone ?? '';
    _wechatController.text = contact?.wechat ?? '';
    _identityVerified = contact?.identityVerified;
    _noteController.text = contact?.note ?? '';

    _checklistItems = house.checklistItems;
    _riskFlags = house.riskFlags;
    _photos = house.photos;

    _attachListeners();
    setState(() => _loaded = true);
  }

  /// 回填完成后统一注册文本框监听：改动触发对应分区防抖保存。
  ///
  /// 必须在 [_load] 回填 text 之后注册，避免回填本身触发一次多余保存。
  void _attachListeners() {
    for (final c in [
      _titleController,
      _buildingController,
      _addressController,
      _roomNoController,
    ]) {
      c.addListener(_scheduleMainSave);
    }
    for (final c in [
      _rentController,
      _depositController,
      _managementController,
      _internetController,
      _waterController,
      _electricityController,
      _gasController,
      _otherController,
    ]) {
      c.addListener(_scheduleFeeSave);
    }
    for (final c in [
      _areaController,
      _floorController,
      _totalFloorController,
    ]) {
      c.addListener(_scheduleRoomSave);
    }
    for (final c in [
      _contactNameController,
      _phoneController,
      _wechatController,
      _noteController,
    ]) {
      c.addListener(_scheduleContactSave);
    }
  }

  // -------------------------------------------------------------------------
  // 保存：主表分字段 / 子表整体 upsert
  // -------------------------------------------------------------------------

  /// 主表防抖保存（标题/楼栋/地址/门牌，均来自文本框）。
  void _scheduleMainSave() {
    _mainDebounce?.cancel();
    _mainDebounce = Timer(_debounce, () async {
      await _repo.updateMain(
        widget.houseId,
        title: Value(
          _titleController.text.trim().isEmpty
              ? '未命名房源'
              : _titleController.text.trim(),
        ),
        buildingName: Value(_nullIfBlank(_buildingController.text)),
        addressText: Value(_nullIfBlank(_addressController.text)),
        roomNo: Value(_nullIfBlank(_roomNoController.text)),
      );
      _markSaved();
    });
  }

  /// 看房时间即时保存（选择器结果，非文本框，无需防抖）。
  Future<void> _saveVisitedAt(int? ts) async {
    setState(() => _visitedAt = ts);
    await _repo.updateMain(widget.houseId, visitedAt: Value(ts));
    _markSaved();
  }

  /// 费用整体保存：读全部费用控制器 + 押付副本，构造完整 FeeInfo 后 upsert。
  ///
  /// estimatedTotalMonthly 由评分引擎写回，此处不覆写（传 null 会清空，故不构造该字段——
  /// FeeInfo 默认 null，仓库整体 upsert 会写 null）。MVP 录入轨不触发重算，
  /// 该字段的写回归属评分轨；此处保持为空，避免录入误清引擎结果的问题留待评分轨接入时协调。
  domain.FeeInfo _buildFee() {
    return domain.FeeInfo(
      rentMonthly: _parseInt(_rentController.text),
      deposit: _parseInt(_depositController.text),
      paymentCycle: _paymentCycle,
      managementFee: _parseInt(_managementController.text),
      internetFee: _parseInt(_internetController.text),
      waterUnitPrice: _parseDouble(_waterController.text),
      electricityUnitPrice: _parseDouble(_electricityController.text),
      gasFee: _parseInt(_gasController.text),
      otherFee: _parseInt(_otherController.text),
    );
  }

  void _scheduleFeeSave() {
    _feeDebounce?.cancel();
    _feeDebounce = Timer(_debounce, () async {
      await _repo.updateFee(widget.houseId, _buildFee());
      _markSaved();
    });
  }

  /// 押付方式即时保存（Chip 选择）。
  Future<void> _savePaymentCycle(String? v) async {
    setState(() => _paymentCycle = v);
    await _repo.updateFee(widget.houseId, _buildFee());
    _markSaved();
  }

  domain.RoomInfo _buildRoom() {
    return domain.RoomInfo(
      layout: _layout,
      area: _parseDouble(_areaController.text),
      floor: _parseInt(_floorController.text),
      totalFloor: _parseInt(_totalFloorController.text),
      hasElevator: _hasElevator,
      orientation: _orientation,
      hasPrivateBathroom: _hasPrivateBathroom,
      hasKitchen: _hasKitchen,
      canCook: _canCook,
      canPet: _canPet,
    );
  }

  void _scheduleRoomSave() {
    _roomDebounce?.cancel();
    _roomDebounce = Timer(_debounce, () async {
      await _repo.updateRoom(widget.houseId, _buildRoom());
      _markSaved();
    });
  }

  /// 房屋非文本字段（房型/朝向/三态）即时保存。
  Future<void> _saveRoomNow() async {
    await _repo.updateRoom(widget.houseId, _buildRoom());
    _markSaved();
  }

  domain.ContactInfo _buildContact() {
    return domain.ContactInfo(
      name: _nullIfBlank(_contactNameController.text),
      role: _contactRole,
      phone: _nullIfBlank(_phoneController.text),
      wechat: _nullIfBlank(_wechatController.text),
      identityVerified: _identityVerified,
      note: _nullIfBlank(_noteController.text),
    );
  }

  void _scheduleContactSave() {
    _contactDebounce?.cancel();
    _contactDebounce = Timer(_debounce, () async {
      await _repo.updateContact(widget.houseId, _buildContact());
      _markSaved();
    });
  }

  /// 联系人非文本字段（角色/身份核验）即时保存。
  Future<void> _saveContactNow() async {
    await _repo.updateContact(widget.houseId, _buildContact());
    _markSaved();
  }

  // -------------------------------------------------------------------------
  // 照片：拍/选/删，落盘经 PhotoStore，元信息经仓库，UI 由 _photos 驱动
  // -------------------------------------------------------------------------

  Future<void> _addPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 2000,
        imageQuality: 85,
      );
      if (picked == null) return;
      final store = ref.read(photoStoreProvider);
      final saved = await store.savePhoto(widget.houseId, picked.path, PhotoTag.room);
      final photoId = await _repo.addPhotoAsset(
        widget.houseId,
        localPath: saved.localPath,
        tag: PhotoTag.room,
      );
      // 本地优先：落盘与元信息已就绪，云直传作为非阻塞增强，失败不影响记录。
      unawaited(
        _repo.tryUploadPhotoAsset(
          photoId,
          ownerType: domain.PhotoOwnerType.house,
          ownerId: widget.houseId,
          tag: PhotoTag.room,
          localPath: saved.localPath,
        ),
      );
      await _refreshPhotos();
      if (!mounted) return;
      _markSaved();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('照片保存失败，点击重试。')),
      );
    }
  }

  Future<void> _refreshPhotos() async {
    final photos = await _repo.getPhotoAssets(widget.houseId);
    if (!mounted) return;
    setState(() => _photos = photos);
  }

  Future<void> _removePhoto(int index) async {
    if (index < 0 || index >= _photos.length) return;
    final asset = _photos[index];
    await ref.read(photoStoreProvider).deleteFile(asset.localPath);
    await _repo.deletePhotoAsset(asset.id);
    await _refreshPhotos();
  }

  void _markSaved() {
    if (!mounted) return;
    setState(() => _savedHint = '已保存 ${_formatTime(DateTime.now())}');
  }

  // -------------------------------------------------------------------------
  // 导航：Checklist / 评分
  // -------------------------------------------------------------------------

  /// 打开 Checklist（root Navigator push，无独立路由，返回后刷新摘要）。
  Future<void> _openChecklist() async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => ChecklistPage(houseId: widget.houseId),
      ),
    );
    // 返回后刷新 checklist / 风险摘要（Checklist 页可能改动 risk 命中）。
    final items = await _repo.getChecklistItems(widget.houseId);
    final risks = await _repo.getRiskFlags(widget.houseId);
    if (!mounted) return;
    setState(() {
      _checklistItems = items;
      _riskFlags = risks;
    });
  }

  /// 看房时间选择：日期 + 时间，组合为毫秒时间戳。
  Future<void> _pickVisitedAt() async {
    final now = DateTime.now();
    final base = _visitedAt == null
        ? now
        : DateTime.fromMillisecondsSinceEpoch(_visitedAt!);
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (!mounted) return;
    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
    await _saveVisitedAt(picked.millisecondsSinceEpoch);
  }

  // -------------------------------------------------------------------------
  // 完成度徽标
  // -------------------------------------------------------------------------

  String _basicBadge() {
    var filled = 0;
    if (_titleController.text.trim().isNotEmpty) filled++;
    if (_buildingController.text.trim().isNotEmpty) filled++;
    if (_addressController.text.trim().isNotEmpty) filled++;
    if (_roomNoController.text.trim().isNotEmpty) filled++;
    if (_visitedAt != null) filled++;
    return '$filled/5';
  }

  String _feeBadge() {
    final vals = [
      _rentController.text,
      _depositController.text,
      _managementController.text,
      _internetController.text,
      _waterController.text,
      _electricityController.text,
      _gasController.text,
      _otherController.text,
    ];
    final filled = vals.where((v) => v.trim().isNotEmpty).length +
        (_paymentCycle != null ? 1 : 0);
    return '$filled/9';
  }

  String _roomBadge() {
    var filled = 0;
    if (_layout != null) filled++;
    if (_areaController.text.trim().isNotEmpty) filled++;
    if (_floorController.text.trim().isNotEmpty) filled++;
    if (_totalFloorController.text.trim().isNotEmpty) filled++;
    if (_orientation != null) filled++;
    if (_hasElevator != null) filled++;
    if (_hasPrivateBathroom != null) filled++;
    if (_hasKitchen != null) filled++;
    if (_canCook != null) filled++;
    if (_canPet != null) filled++;
    return '$filled/10';
  }

  String _contactBadge() {
    var filled = 0;
    if (_contactNameController.text.trim().isNotEmpty) filled++;
    if (_contactRole != null) filled++;
    if (_phoneController.text.trim().isNotEmpty) filled++;
    if (_wechatController.text.trim().isNotEmpty) filled++;
    if (_identityVerified != null) filled++;
    return '$filled/5';
  }

  /// Checklist 摘要徽标：已填项 / 模板总项。
  String _checklistBadge() {
    final total = kChecklistTemplate.fold<int>(
      0,
      (sum, m) => sum + m.items.length,
    );
    final answered = _checklistItems
        .where((i) => i.value != null && i.value != ChecklistValue.notSeen)
        .length;
    return '$answered/$total';
  }

  // -------------------------------------------------------------------------
  // 构建
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('房源详情'),
        actions: [
          if (_loaded)
            IconButton(
              tooltip: '评分详情',
              onPressed: () {
                HapticFeedback.selectionClick();
                context.push('/houses/${widget.houseId}/score');
              },
              icon: const Icon(Icons.insights_outlined),
            ),
          if (_savedHint != null && _loaded)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_done_outlined,
                      size: 16,
                      color: context.kawaiiPalette.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _savedHint!,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.kawaiiPalette.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: _notFound
          ? const _NotFoundState()
          : !_loaded
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(context),
      bottomNavigationBar: (!_loaded || _notFound)
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  context.push('/houses/${widget.houseId}/score');
                },
                icon: const Icon(Icons.insights_outlined),
                label: const Text('查看评分'),
              ),
            ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _titleController.text.trim().isEmpty
                      ? '未命名房源'
                      : _titleController.text.trim(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _HouseStatusChip(status: _status),
            ],
          ),
        ),
        BasicInfoSection(
          titleController: _titleController,
          buildingController: _buildingController,
          addressController: _addressController,
          roomNoController: _roomNoController,
          visitedAtLabel: _visitedAt == null
              ? '未记录'
              : _formatDateTime(
                  DateTime.fromMillisecondsSinceEpoch(_visitedAt!),
                ),
          onPickVisitedAt: _pickVisitedAt,
          badge: _basicBadge(),
        ),
        _PhotosSection(
          thumbs: _photoThumbs,
          onAdd: _addPhoto,
          onRemove: _removePhoto,
        ),
        FeeSection(
          rentController: _rentController,
          depositController: _depositController,
          managementController: _managementController,
          internetController: _internetController,
          waterController: _waterController,
          electricityController: _electricityController,
          gasController: _gasController,
          otherController: _otherController,
          paymentCycle: _paymentCycle,
          onPaymentCycleChanged: _savePaymentCycle,
          badge: _feeBadge(),
        ),
        RoomSection(
          areaController: _areaController,
          floorController: _floorController,
          totalFloorController: _totalFloorController,
          layout: _layout,
          onLayoutChanged: (v) {
            setState(() => _layout = v);
            unawaited(_saveRoomNow());
          },
          orientation: _orientation,
          onOrientationChanged: (v) {
            setState(() => _orientation = v);
            unawaited(_saveRoomNow());
          },
          hasElevator: _hasElevator,
          onElevatorChanged: (v) {
            setState(() => _hasElevator = v);
            unawaited(_saveRoomNow());
          },
          hasPrivateBathroom: _hasPrivateBathroom,
          onPrivateBathroomChanged: (v) {
            setState(() => _hasPrivateBathroom = v);
            unawaited(_saveRoomNow());
          },
          hasKitchen: _hasKitchen,
          onKitchenChanged: (v) {
            setState(() => _hasKitchen = v);
            unawaited(_saveRoomNow());
          },
          canCook: _canCook,
          onCanCookChanged: (v) {
            setState(() => _canCook = v);
            unawaited(_saveRoomNow());
          },
          canPet: _canPet,
          onCanPetChanged: (v) {
            setState(() => _canPet = v);
            unawaited(_saveRoomNow());
          },
          badge: _roomBadge(),
        ),
        ContactSection(
          nameController: _contactNameController,
          phoneController: _phoneController,
          wechatController: _wechatController,
          role: _contactRole,
          onRoleChanged: (v) {
            setState(() => _contactRole = v);
            unawaited(_saveContactNow());
          },
          identityVerified: _identityVerified,
          onIdentityChanged: (v) {
            setState(() => _identityVerified = v);
            unawaited(_saveContactNow());
          },
          badge: _contactBadge(),
        ),
        _ChecklistSummarySection(
          badge: _checklistBadge(),
          onOpen: _openChecklist,
        ),
        _RiskSummarySection(riskFlags: _riskFlags, onOpen: _openChecklist),
        NotesSection(
          noteController: _noteController,
          filled: _noteController.text.trim().isNotEmpty,
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // 数值/字符串解析辅助
  // -------------------------------------------------------------------------

  static String _intText(int? v) => v?.toString() ?? '';
  static String _doubleText(double? v) => v?.toString() ?? '';

  static int? _parseInt(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  static double? _parseDouble(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  static String? _nullIfBlank(String raw) {
    final t = raw.trim();
    return t.isEmpty ? null : t;
  }

  String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}';
  }

  String _formatDateTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }
}

/// 房源状态 chip：图标 + 文案，避免仅靠颜色表达。
class _HouseStatusChip extends StatelessWidget {
  const _HouseStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final palette = context.kawaiiPalette;
    final (label, color, icon) = switch (status) {
      'shortlisted' => ('候选', palette.primary, Icons.star_outline_rounded),
      'chosen' => ('已选', AppColors.mint, Icons.check_circle_outline_rounded),
      'rejected' => ('淘汰', AppColors.risk, Icons.block_rounded),
      'active' => ('跟进中', palette.secondary, Icons.flag_outlined),
      _ => ('草稿', AppColors.offline, Icons.edit_note_outlined),
    };
    return KawaiiStatusChip(label: label, color: color, icon: icon);
  }
}

/// Checklist 摘要卡片：显示完成度，点击进入 Checklist 页。
class _ChecklistSummarySection extends StatelessWidget {
  const _ChecklistSummarySection({required this.badge, required this.onOpen});

  final String badge;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: const Icon(
          Icons.checklist_outlined,
          color: AppColors.textSecondary,
        ),
        title: Text(
          '看房清单',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('已填 $badge 项'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          HapticFeedback.selectionClick();
          onOpen();
        },
      ),
    );
  }
}

/// 风险摘要卡片：列出已命中的风险标记，点击进入 Checklist 风险模块补录。
class _RiskSummarySection extends StatelessWidget {
  const _RiskSummarySection({required this.riskFlags, required this.onOpen});

  final List<domain.RiskFlag> riskFlags;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRisk = riskFlags.isNotEmpty;
    final blockerCount = riskFlags.where((r) => r.severity == 'blocker').length;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(
          hasRisk ? Icons.warning_amber_rounded : Icons.verified_outlined,
          color: hasRisk ? AppColors.risk : AppColors.primary,
        ),
        title: Text(
          '风险',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          hasRisk
              ? '已标记 ${riskFlags.length} 项'
                  '${blockerCount > 0 ? '，含 $blockerCount 项红线' : ''}'
              : '暂无风险标记',
          style: TextStyle(
            color: hasRisk ? AppColors.risk : AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          HapticFeedback.selectionClick();
          onOpen();
        },
      ),
    );
  }
}

/// 照片模块：拍/选入口 + 缩略图网格（可删、可点开预览）。
class _PhotosSection extends StatelessWidget {
  const _PhotosSection({
    required this.thumbs,
    required this.onAdd,
    required this.onRemove,
  });

  final List<PhotoThumb> thumbs;
  final ValueChanged<ImageSource> onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: '照片',
      icon: Icons.photo_library_outlined,
      badge: thumbs.isEmpty ? '空' : '${thumbs.length}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onAdd(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('拍照'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onAdd(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('相册'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (thumbs.isEmpty)
            Text(
              '暂无照片，现场拍摄或从相册上传。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            PhotoGrid(photos: thumbs, onRemove: onRemove),
        ],
      ),
    );
  }
}

/// 房源不存在态。
class _NotFoundState extends StatelessWidget {
  const _NotFoundState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const KawaiiIconBubble(
              icon: Icons.search_off_rounded,
              color: AppColors.offline,
              size: 56,
            ),
            const SizedBox(height: 12),
            const Text('房源不存在或已删除。'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
