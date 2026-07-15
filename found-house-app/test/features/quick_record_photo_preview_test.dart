// 快速记录 / 房源详情照片缩略图展示回归测试。
//
// 目标（用户需求）：拍照/相册上传的照片在快速记录下方与房源详情均可见。
// 直接验证可复用的 [PhotoGrid]：传入照片路径后按行渲染缩略图（GridView）。
// PhotoGrid 同时被 quick_record_page 与 house_detail_page 使用，覆盖两类入口。
//
// 注意：测试刻意指向不存在的路径，触发 Image.file 的 errorBuilder 渲染占位，
// 避免真图解码在 desktop test runner 下挂起（pumpAndSettle 会无限等待解码帧）。
// 因此用 `pump()` 而非 `pumpAndSettle()`，并断言布局结构与占位图标，不强依赖解码。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/features/common/photo_grid.dart';

void main() {
  testWidgets('PhotoGrid renders a thumbnail cell per photo below the entry', (tester) async {
    const thumbs = [
      PhotoThumb(path: '/nonexistent/room.jpg', tagLabel: '房间'),
      PhotoThumb(path: '/nonexistent/sign.jpg', tagLabel: '招租牌'),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('拍照/相册入口'),
              PhotoGrid(photos: thumbs),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    // 每张照片渲染一格：GridView 存在，内部对应 2 个 Image（缩略图来自 File）。
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(2));
    // 标签文案叠加可见。
    expect(find.text('房间'), findsOneWidget);
    expect(find.text('招租牌'), findsOneWidget);
  });

  testWidgets('PhotoGrid renders nothing when there are no photos', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PhotoGrid(photos: [])),
      ),
    );
    await tester.pump();
    expect(find.byType(GridView), findsNothing);
  });

  testWidgets('PhotoGrid remove button calls onRemove with the right index', (tester) async {
    var removed = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PhotoGrid(
            photos: const [
              PhotoThumb(path: '/nonexistent/a.jpg', tagLabel: '房间'),
              PhotoThumb(path: '/nonexistent/b.jpg', tagLabel: '招租牌'),
            ],
            onRemove: (i) => removed = i,
          ),
        ),
      ),
    );
    await tester.pump();

    // 点击第一个删除按钮（close 图标）。
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump();
    expect(removed, 0);
  });
}
