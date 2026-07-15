# 需求

继续收尾 PRD v1.2 最终审查里的非阻断导航问题：

1. `_MissingVillagePage` 无 GoRouter 场景点击“返回首页”不应崩溃。
2. App 主流程“保存并离开”后快速记录页不应 offstage 残留。
3. 尽量降低 `Navigator.pop()` + `go_router` push 的混用风险，保持当前 PRD 行为不变。

# 验收

- 先补失败测试，再修实现。
- `flutter analyze` 通过。
- `flutter test test/features/scan_map_page_test.dart --reporter expanded` 通过。
- `flutter test --reporter expanded` 通过。
- 视变更范围补审查记录并归档任务。
