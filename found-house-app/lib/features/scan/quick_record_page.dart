// 快速记录页（PRD v1.2 手动扫楼流程）。
//
// 职责边界：从村/楼栋上下文进入后仅展示本地表单，不自动创建草稿；
// 用户显式保存且月租、门牌/房号、房型三个必填项有效后，才创建/更新房源。
// 村级入口可选择已有楼栋或输入新楼栋名，楼栋入口不重复填写楼栋。

import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/motion.dart';
import '../../app/theme.dart';
import '../../data/local_files/photo_store.dart';
import '../../data/models/house_models.dart' as domain;
import '../../data/providers.dart';
import '../common/form_widgets.dart';
import '../common/photo_grid.dart';
import '../house/house_detail_page.dart';

/// 快速记录页：显式保存后才落库，避免空表单产生无效房源。
class QuickRecordPage extends ConsumerStatefulWidget {
  const QuickRecordPage({
    super.key,
    required this.villageId,
    this.buildingId,
    this.buildingName,
  });

  final String villageId;
  final String? buildingId;
  final String? buildingName;

  @override
  ConsumerState<QuickRecordPage> createState() => _QuickRecordPageState();
}

class _QuickRecordPageState extends ConsumerState<QuickRecordPage> {
  String? _houseId;
  bool _saving = false;

  final _rentController = TextEditingController();
  final _buildingNameController = TextEditingController();
  final _roomNoController = TextEditingController();
  final _rentFocus = FocusNode();

  String? _layout;
  String? _feedbackMessage;
  bool _feedbackIsError = false;

  /// 暂存照片：保存前拍的暂留本页，保存时归档。
  final List<String> _pendingPhotoPaths = [];

  /// 已归档照片（落库的 PhotoAsset），保存房源后从仓库回填。
  List<domain.PhotoAsset> _savedPhotos = const [];

  /// 合并后的展示用缩略图：已归档在前，暂存在后，顺序即拍照顺序。
  List<PhotoThumb> get _photoThumbs => [
        ..._savedPhotos.map(_thumbFromAsset),
        ..._pendingPhotoPaths.map(_thumbFromPath),
      ];

  static PhotoThumb _thumbFromAsset(domain.PhotoAsset a) =>
      PhotoThumb(path: a.localPath, tagLabel: _tagLabel(a.tag), takenAt: a.takenAt);

  static PhotoThumb _thumbFromPath(String p) =>
      PhotoThumb(path: p, tagLabel: '待归档');

  static String? _tagLabel(String tag) {
    const map = <String, String>{
      PhotoTag.sign: '招租牌',
      PhotoTag.building: '楼栋入口',
      PhotoTag.room: '房间',
      PhotoTag.window: '窗外',
      PhotoTag.bathroom: '厨卫',
      PhotoTag.meter: '水电表',
      PhotoTag.contract: '合同',
      PhotoTag.damage: '问题留证',
    };
    return map[tag];
  }

  int get _photoCount => _savedPhotos.length + _pendingPhotoPaths.length;

  static const List<String> _layoutOptions = [
    '单间',
    '一房一厅',
    '两房一厅',
    '三房一厅',
    '合租主卧',
    '合租次卧',
    '公寓',
  ];

  bool get _hasVillageContext => widget.villageId.trim().isNotEmpty;

  bool get _hasBuildingContext => widget.buildingId?.trim().isNotEmpty == true;

  @override
  void initState() {
    super.initState();
    if (_hasBuildingContext) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _rentFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _rentController.dispose();
    _buildingNameController.dispose();
    _roomNoController.dispose();
    _rentFocus.dispose();
    super.dispose();
  }

  Future<void> _addPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 2000,
        imageQuality: 85,
      );
      if (picked == null) return;
      final houseId = _houseId;
      if (houseId == null) {
        if (!mounted) return;
        setState(() {
          _pendingPhotoPaths.add(picked.path);
        });
        _showFeedback('照片已暂存，保存房源后自动归档。');
        return;
      }

      await _savePhotoForHouse(houseId, picked.path);
      if (!mounted) return;
      await _refreshSavedPhotos(houseId);
      if (!mounted) return;
      _showFeedback('照片已保存 ${_formatTime(DateTime.now())}');
    } catch (_) {
      if (!mounted) return;
      _showFeedback('照片保存失败，点击重试。', isError: true);
    }
  }

  /// 从仓库回填当前房源已归档的照片，驱动缩略图刷新。
  Future<void> _refreshSavedPhotos(String houseId) async {
    final repo = ref.read(houseRepositoryProvider);
    final photos = await repo.getPhotoAssets(houseId);
    if (!mounted) return;
    setState(() => _savedPhotos = photos);
  }

  Future<void> _savePhotoForHouse(String houseId, String sourcePath) async {
    final store = ref.read(photoStoreProvider);
    final saved = await store.savePhoto(houseId, sourcePath, PhotoTag.room);
    final repo = ref.read(houseRepositoryProvider);
    final photoId = await repo.addPhotoAsset(
      houseId,
      localPath: saved.localPath,
      tag: PhotoTag.room,
    );
    // 本地优先：落盘与元信息已就绪，云直传作为非阻塞增强，失败不影响记录。
    unawaited(
      repo.tryUploadPhotoAsset(
        photoId,
        ownerType: domain.PhotoOwnerType.house,
        ownerId: houseId,
        tag: PhotoTag.room,
        localPath: saved.localPath,
      ),
    );
  }

  Future<void> _flushPendingPhotos(String houseId) async {
    if (_pendingPhotoPaths.isEmpty) return;
    final paths = List<String>.of(_pendingPhotoPaths);
    _pendingPhotoPaths.clear();
    for (final path in paths) {
      try {
        await _savePhotoForHouse(houseId, path);
      } catch (_) {
        if (mounted) {
          _showFeedback('房源已保存，部分照片归档失败，可稍后重试。', isError: true);
        }
      }
    }
    await _refreshSavedPhotos(houseId);
  }

  void _setInlineFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _feedbackMessage = message;
      _feedbackIsError = isError;
    });
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    _setInlineFeedback(message, isError: isError);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  void _clearFeedback() {
    if (_feedbackMessage == null) return;
    setState(() {
      _feedbackMessage = null;
      _feedbackIsError = false;
    });
  }

  _QuickRecordDraft? _readValidDraft() {
    final rentText = _rentController.text.trim();
    final rent = int.tryParse(rentText);
    final roomNo = _roomNoController.text.trim();
    final layout = _layout?.trim();
    if (rent == null ||
        rent <= 0 ||
        roomNo.isEmpty ||
        layout == null ||
        layout.isEmpty) {
      _setInlineFeedback('请填写月租、门牌/房号、房型', isError: true);
      return null;
    }
    return _QuickRecordDraft(rent: rent, roomNo: roomNo, layout: layout);
  }

  Future<_ResolvedBuilding> _resolveBuilding() async {
    if (_hasBuildingContext) {
      return _ResolvedBuilding(
        id: widget.buildingId!.trim(),
        name: widget.buildingName?.trim().isNotEmpty == true
            ? widget.buildingName!.trim()
            : null,
      );
    }

    final raw = _buildingNameController.text.trim();
    if (raw.isEmpty) return const _ResolvedBuilding();

    final villageRepo = ref.read(villageRepositoryProvider);
    final buildings =
        await villageRepo.getBuildingsForVillage(widget.villageId);
    final normalized = raw.toLowerCase();
    for (final building in buildings) {
      if (building.name.trim().toLowerCase() == normalized) {
        return _ResolvedBuilding(id: building.id, name: building.name.trim());
      }
    }

    final id = await villageRepo.createBuilding(
      villageId: widget.villageId,
      name: raw,
    );
    return _ResolvedBuilding(id: id, name: raw, created: true);
  }

  Future<String?> _saveRecord({bool showSuccessFeedback = true}) async {
    if (!_hasVillageContext) return null;
    final draft = _readValidDraft();
    if (draft == null) return null;
    if (_saving) return _houseId;

    _ResolvedBuilding? rollbackBuilding;
    setState(() => _saving = true);
    try {
      final building = await _resolveBuilding();
      if (building.created && building.id != null) {
        rollbackBuilding = building;
      }
      final repo = ref.read(houseRepositoryProvider);
      final now = DateTime.now();
      final visitedAt = now.millisecondsSinceEpoch;
      final title = _buildTitle(
        rent: draft.rent,
        roomNo: draft.roomNo,
        buildingName: building.name,
      );
      final fee = domain.FeeInfo(rentMonthly: draft.rent);
      final room = domain.RoomInfo(layout: draft.layout);

      var id = _houseId;
      if (id == null) {
        id = await repo.create(
          title: title,
          villageId: widget.villageId,
          buildingId: building.id,
          buildingName: building.name,
          roomNo: draft.roomNo,
          fee: fee,
          room: room,
          visitedAt: visitedAt,
        );
        _houseId = id;
        rollbackBuilding = null;
      } else {
        await repo.updateMain(
          id,
          title: Value(title),
          villageId: Value(widget.villageId),
          buildingId: Value(building.id),
          buildingName: Value(building.name),
          roomNo: Value(draft.roomNo),
          visitedAt: Value(visitedAt),
        );
        await repo.updateFee(id, fee);
        await repo.updateRoom(id, room);
        rollbackBuilding = null;
      }

      await _flushPendingPhotos(id);
      if (!mounted) return id;
      if (showSuccessFeedback) {
        _showFeedback('已保存 ${_formatTime(DateTime.now())}');
      }
      return id;
    } catch (e) {
      final createdBuildingId = rollbackBuilding?.id;
      if (createdBuildingId != null) {
        await ref.read(villageRepositoryProvider).deleteBuildingIfEmpty(
              createdBuildingId,
            );
      }
      if (mounted) _showFeedback('保存失败：$e', isError: true);
      return null;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveAndLeave() async {
    unawaited(HapticFeedback.selectionClick());
    final id = await _saveRecord(showSuccessFeedback: false);
    if (id == null || !mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.go('/scan');
    } else {
      _showFeedback('房源已保存。');
    }
  }

  Future<void> _saveAndOpenDetail() async {
    unawaited(HapticFeedback.selectionClick());
    final id = await _saveRecord(showSuccessFeedback: false);
    if (id == null || !mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final router = GoRouter.maybeOf(context);
    final navigator = Navigator.of(context);
    if (router == null) {
      unawaited(
        navigator.pushReplacement<void, void>(
          MaterialPageRoute<void>(
            builder: (_) => HouseDetailPage(houseId: id),
          ),
        ),
      );
      return;
    }

    if (navigator.canPop()) {
      // QuickRecord is a transient data-entry page. Pop it out of the
      // Navigator tree before opening detail, otherwise it can remain offstage
      // under the root detail route.
      navigator.pop();
      await Future<void>.delayed(Duration.zero);
      unawaited(router.push('/houses/$id'));
    } else {
      router.go('/houses/$id');
    }
  }

  String _buildTitle({
    required int rent,
    required String roomNo,
    String? buildingName,
  }) {
    final parts = <String>[
      if (buildingName?.trim().isNotEmpty == true) buildingName!.trim(),
      roomNo,
      '$rent 元/月',
    ];
    return parts.join(' · ');
  }

  String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}';
  }

  void _backHomeFromMissingVillage() {
    // 缺失村是全局入口错误态：有 GoRouter 时回到首页根路径；
    // 单页/测试 fallback 没有路由树时，再尝试弹回上一页。
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.go('/scan');
      return;
    }

    final navigator = Navigator.maybeOf(context);
    if (navigator?.canPop() == true) {
      navigator!.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasVillageContext) {
      return _MissingVillagePage(onBackHome: _backHomeFromMissingVillage);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('快速记录'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveAndOpenDetail,
            child: const Text('去补全'),
          ),
        ],
      ),
      body: _buildForm(context),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '本地保存，弱网也可记录',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('quick-save-leave-button'),
              onPressed: _saving ? null : _saveAndLeave,
              child: Text(_saving ? '保存中…' : '保存并离开'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final buildingsAsync = _hasBuildingContext
        ? const AsyncValue<List<domain.Building>>.data(<domain.Building>[])
        : ref.watch(buildingsForVillageProvider(widget.villageId));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _hasBuildingContext
                ? '已选择楼栋，填写月租、门牌/房号和房型后保存房源记录。'
                : '可先选择已有楼栋或输入新楼栋，再填写月租、门牌/房号和房型。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _ContextCard(
            buildingId: widget.buildingId,
            buildingName: widget.buildingName,
          ),
          const SizedBox(height: 16),
          if (!_hasBuildingContext)
            _BuildingSelector(
              controller: _buildingNameController,
              buildingsAsync: buildingsAsync,
              onSelected: (building) {
                _buildingNameController.text = building.name;
                _buildingNameController.selection = TextSelection.collapsed(
                  offset: _buildingNameController.text.length,
                );
                _clearFeedback();
                setState(() {});
              },
              onChanged: (_) => _clearFeedback(),
            ),
          const FieldGroupLabel('① 月租 *'),
          LabeledField(
            fieldKey: const Key('quick-rent-field'),
            label: '月租 *',
            controller: _rentController,
            focusNode: _rentFocus,
            keyboardType: TextInputType.number,
            hintText: '如 1800',
            suffixText: '元/月',
            onChanged: (_) => _clearFeedback(),
          ),
          const FieldGroupLabel('② 门牌/房号 *'),
          LabeledField(
            fieldKey: const Key('quick-room-field'),
            label: '门牌/房号 *',
            controller: _roomNoController,
            hintText: '如 501、3楼右手边',
            onChanged: (_) => _clearFeedback(),
          ),
          const FieldGroupLabel('③ 房型 *'),
          ChoiceChipsField(
            label: '选一个最接近的 *',
            options: _layoutOptions,
            value: _layout,
            onChanged: (layout) {
              setState(() => _layout = layout);
              _clearFeedback();
            },
          ),
          const FieldGroupLabel('④ 拍照/相册（可选）'),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addPhoto(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('拍照'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addPhoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('相册'),
                ),
              ),
            ],
          ),
          if (_photoCount > 0) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '已记录 $_photoCount 张照片',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            PhotoGrid(photos: _photoThumbs),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '拍照后照片会显示在这里，保存后可在房源详情查看。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          if (_feedbackMessage != null) ...[
            const SizedBox(height: 8),
            AnimatedOpacity(
              opacity: 1,
              duration: AppMotionHelper.effectiveDuration(
                context,
                AppMotion.riskHint,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _feedbackIsError
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    size: 16,
                    color:
                        _feedbackIsError ? AppColors.risk : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _feedbackMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _feedbackIsError
                            ? AppColors.risk
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickRecordDraft {
  const _QuickRecordDraft({
    required this.rent,
    required this.roomNo,
    required this.layout,
  });

  final int rent;
  final String roomNo;
  final String layout;
}

class _ResolvedBuilding {
  const _ResolvedBuilding({
    this.id,
    this.name,
    this.created = false,
  });

  final String? id;
  final String? name;
  final bool created;
}

class _BuildingSelector extends StatelessWidget {
  const _BuildingSelector({
    required this.controller,
    required this.buildingsAsync,
    required this.onSelected,
    required this.onChanged,
  });

  final TextEditingController controller;
  final AsyncValue<List<domain.Building>> buildingsAsync;
  final ValueChanged<domain.Building> onSelected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final buildings = buildingsAsync.valueOrNull ?? const <domain.Building>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          fieldKey: const Key('quick-building-field'),
          label: '楼栋/入口（可选，可选择或新建）',
          controller: controller,
          hintText: '如 A栋、东门、巷口自建楼；留空则未分楼栋',
          onChanged: onChanged,
        ),
        if (buildingsAsync.isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: LinearProgressIndicator(minHeight: 2),
          )
        else if (buildings.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final building in buildings)
                  ActionChip(
                    label: Text(building.name),
                    avatar: const Icon(Icons.apartment_outlined, size: 16),
                    onPressed: () => onSelected(building),
                  ),
              ],
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Text(
              '还没有楼栋；输入楼栋名保存时会自动创建。',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({this.buildingId, this.buildingName});

  final String? buildingId;
  final String? buildingName;

  @override
  Widget build(BuildContext context) {
    final hasBuilding = buildingId != null && buildingId!.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.kawaiiPalette.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(
            hasBuilding
                ? Icons.apartment_outlined
                : Icons.meeting_room_outlined,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasBuilding
                  ? '已归属楼栋：${buildingName?.trim().isNotEmpty == true ? buildingName!.trim() : '已选择楼栋'}'
                  : '可选择已有楼栋或输入新楼栋；留空则保存为未分楼栋房源。',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingVillagePage extends StatelessWidget {
  const _MissingVillagePage({required this.onBackHome});

  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('快速记录')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.home_work_outlined,
                size: 44,
                color: AppColors.offline,
              ),
              const SizedBox(height: 12),
              Text(
                '请先在首页选择一个村再记录房源',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '新版流程要求房源必须归属村，楼栋可以后补。',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onBackHome,
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
