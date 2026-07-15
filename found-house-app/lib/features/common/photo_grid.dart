// 照片缩略图网格与全屏预览（W1-2 · UI §5.4/§5.5）。
//
// 职责边界：纯表现层组件，按本地文件路径展示缩略图，点击进入全屏预览。
// 不读写数据库、不知晓标签语义，仅负责渲染与交互。提供给快速记录页与
// 房源详情页复用，避免缩略图/预览逻辑 copy-paste（DRY）。
//
// 照片文件落盘由 PhotoStore 统一管理（applicationSupportDirectory），
// 此处用 Image.file 直读绝对路径；路径失效时展示占位图，不崩溃。

import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// 单张可展示照片的最小信息：本地路径 + 可选标签文案 + 可选拍摄时间。
class PhotoThumb {
  const PhotoThumb({required this.path, this.tagLabel, this.takenAt});

  /// 端侧绝对路径（PhotoStore 归档后的 localPath）。
  final String path;

  /// 标签文案（如「房间」「招租牌」），叠加在缩略图左下角；为空不展示。
  final String? tagLabel;

  /// 拍摄时间（毫秒时间戳），用于全屏预览顶栏；为空不展示。
  final int? takenAt;
}

/// 照片缩略图网格。空列表不渲染（返回 SizedBox.shrink），由调用方决定空态文案。
///
/// 网格自适应宽度，每行 3 列、固定正方形缩略图、行/列间距 8。点击任一格
/// 进入全屏 PageView 预览，支持左右滑动切换。
class PhotoGrid extends StatelessWidget {
  const PhotoGrid({
    super.key,
    required this.photos,
    this.onRemove,
  });

  /// 待展示照片列表（顺序即为展示顺序）。
  final List<PhotoThumb> photos;

  /// 缩略图右上角删除回调；为 null 时缩略图不显示删除按钮。
  /// 回调参数为被删照片在 [photos] 中的下标。
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final photo = photos[index];
        return _ThumbCell(
          photo: photo,
          onRemove: onRemove == null ? null : () => onRemove!(index),
          onTap: () => _openViewer(context, index),
        );
      },
    );
  }

  void _openViewer(BuildContext context, int initialIndex) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => _PhotoViewer(
          photos: photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _ThumbCell extends StatelessWidget {
  const _ThumbCell({required this.photo, required this.onTap, this.onRemove});

  final PhotoThumb photo;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Image.file(
              File(photo.path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        if (photo.tagLabel != null && photo.tagLabel!.isNotEmpty)
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x66000000)],
                ),
              ),
              child: Text(
                photo.tagLabel!,
                style: const TextStyle(color: Colors.white, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        if (onRemove != null)
          Positioned(
            right: 4,
            top: 4,
            child: _RemoveButton(onTap: onRemove!),
          ),
      ],
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(3),
          child: Icon(Icons.close, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}

/// 全屏照片预览：PageView 左右滑动切换，黑底，点击关闭。
class _PhotoViewer extends StatefulWidget {
  const _PhotoViewer({required this.photos, required this.initialIndex});

  final List<PhotoThumb> photos;
  final int initialIndex;

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final PageController _controller;
  late int _index = widget.initialIndex;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_index];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(_title(photo)),
      ),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.photos.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) {
            return Center(
              child: InteractiveViewer(
                child: Image.file(
                  File(widget.photos[i].path),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        size: 64,
                        color: Colors.white54,
                      ),
                      SizedBox(height: 12),
                      Text(
                        '图片不可用',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _title(PhotoThumb photo) {
    final pos = '${_index + 1}/${widget.photos.length}';
    return pos;
  }
}
