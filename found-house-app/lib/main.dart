import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

/// 应用入口。
///
/// 职责边界：仅负责启动前的最小初始化与 [ProviderScope] 包裹，
/// 具体主题、路由、页面结构下沉到 `app/` 目录，业务逻辑不在此处。
void main() {
  // TODO(W1-2): 如需在启动前做异步初始化（打开 Drift 数据库、读取偏好、
  //   生成 anon_device_token 等），在此改为 async 并 `WidgetsFlutterBinding.ensureInitialized()`。
  runApp(
    const ProviderScope(
      child: FoundHouseApp(),
    ),
  );
}
