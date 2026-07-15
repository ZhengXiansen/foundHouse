# Review — PRD v1.2 导航 fallback 与 offstage 残留收尾

## 变更范围

- `found-house-app/lib/features/scan/quick_record_page.dart`
  - 新增 `_backHomeFromMissingVillage()`：缺失村错误态优先使用 `GoRouter.maybeOf(context)?.go('/scan')` 回首页；无 GoRouter 时使用 `Navigator.maybeOf(context)`，可 pop 则返回上一页，不可 pop 则 no-op，避免 `No GoRouter found in context`。
  - MissingVillage 页 `返回首页` 改为调用上述安全 handler。
- `found-house-app/test/features/scan_map_page_test.dart`
  - 主流程保存离开后新增 `skipOffstage:false` 断言，防止 QuickRecord offstage 残留。
  - 新增缺失村 MissingVillage 三类导航用例：
    1. 无 GoRouter 根页点击返回首页不抛异常；
    2. 无 GoRouter 且可 pop 时返回上一页；
    3. GoRouter 环境下返回 `/scan` 首页。

## TDD / Red-Green 证据

RED：先补 `缺失村的快速记录 fallback 返回首页不依赖 GoRouter` 回归用例，执行：

```text
flutter test test/features/scan_map_page_test.dart --reporter expanded
```

失败符合预期：

```text
Expected: null
  Actual: FlutterError:<No GoRouter found in context>
The test description was: 缺失村的快速记录 fallback 返回首页不依赖 GoRouter
```

GREEN：实现 `GoRouter.maybeOf` + `Navigator.maybeOf` fallback 后，目标用例通过。后续根据审查补齐 GoRouter 分支与 Navigator pop 分支覆盖。

## 验证命令

```text
flutter analyze
```

结果：

```text
No issues found! (ran in 3.3s)
```

```text
flutter test test/features/scan_map_page_test.dart --reporter expanded
```

结果：

```text
14/14 passed, All tests passed!
```

```text
flutter test --reporter expanded
```

结果：

```text
158/158 passed, All tests passed!
```

## 外部审查

- antigravity：已按 CCG 尝试调用，但本机不可用：

```text
agy command not found in PATH
```

- Claude reviewer：最终只读复审通过，结论：

```text
Critical: 无
Warning: 无
Info: 仅建议可读性注释（不阻断）
Ready to merge? Yes.
Session-ID: 9fe61bd4-37dd-411c-bbe4-be8da266e301
```

## 结论

本次导航收尾满足验收：缺失村页不再因无 GoRouter 崩溃；GoRouter / Navigator / no-op 三个 fallback 分支均有 widget 测试；主流程保存离开与去补全均有 `skipOffstage:false` 断言防止快速记录页残留；全量 analyze 与测试通过。

## 备注

- 根目录 `D:\dev\code\foundHouse` 不是 git 仓库。
- `found-house-app` 虽有 `.git`，但当前工程文件整体处于 untracked 状态，`git diff` 不能反映本轮变更，因此本 review 以文件路径和命令输出记录为准。
