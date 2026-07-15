// 截图 driver：把 integration_test 里 binding.takeScreenshot(name) 产生的
// PNG 字节写到仓库根的 img/ 目录，文件名即截图名。
//
// 运行：flutter drive \
//   --driver=test_driver/screenshot_driver.dart \
//   --target=integration_test/screenshot_all_pages_test.dart -d <deviceId>

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      // test_driver 的工作目录是 found-house-app，img/ 在其上一级仓库根。
      final dir = Directory('../img');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File('${dir.path}/$name.png');
      await file.writeAsBytes(bytes);
      // 返回 true 表示截图已成功处理。
      return true;
    },
  );
}
