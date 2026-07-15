# CCG 审查记录

任务：`android-full-device-test-report`  
状态：审查后 Warning 已处理，最终 Android 真机重跑已通过；自动化范围内无剩余阻塞。

## 外部模型调用

### antigravity

- 证据：`review-antigravity-final.txt`
- 结果：未能运行，`agy command not found in PATH`，ExitCode 127。

### Claude

- 证据：`review-claude-final.txt`
- 结果：完成审查，明确“无 Critical”。

## Claude 主要发现与处理

### Critical

无 Critical。

### Warning 1：Checklist/Photo 子表与 riskFlags 同源，未刷新 `watchAll()` 聚合流

处理：已修复。

- RED：新增 Checklist 新增/更新/删除、Photo 新增/删除后 `watchAll()` 推送测试，修复前预期超时失败。
  - 证据：`house-repository-child-watch-red.txt`，ExitCode 1。
- GREEN：`addChecklistItem()`、`updateChecklistItem()`、`deleteChecklistItem()`、`addPhotoAsset()`、`deletePhotoAsset()` 事务内写子表并 `_touch(houseId)`。
  - 证据：`house-repository-child-watch-green.txt`，ExitCode 0，`+19: All tests passed!`。

### Warning 2：报告 Pass 统计 off-by-one / 表述过强

处理：已修正。

- `test-report.md` 已改为最终完成版，并使用最新重跑证据。
- 用例统计修正为：Pass 15 项（FD-001 ~ FD-014、FD-021）；Partial Pass / Manual 2 项（FD-016、FD-019）；Blocked / Conditional 1 项（FD-015）；Manual-only 3 项（FD-017、FD-018、FD-020）；Fail 0 项。
- 保留覆盖边界：`NativeDatabase.memory()`、`NoopFieldCipher()`、临时 `PhotoStore` 不覆盖真实 DB/字段加密/照片权限链路。

### Warning 3：`deleteRiskFlag()` 缺少对应回归测试

处理：已补充。

- 新增 `watchAll 在 risk flag 删除后推送新聚合`。
- 仓库层 GREEN 证据：`house-repository-child-watch-green.txt`。

### Info

- integration_test 文案 finder 脆弱、FD 注释与报告编号可进一步清理；非当前阻塞项。
- 已将 Drift 聚合流与子表变更的经验沉淀到 `.ccg/spec/guides/index.md`。

## 最终验证

| 验证项 | 结果 | 证据 |
|---|---:|---|
| Android 真机 `flutter drive` | Pass，ExitCode 0，`All tests passed.` | `integration-drive-output-final.txt`, `integration-drive-output-final.exitcode.txt` |
| `flutter analyze` | Pass，ExitCode 0，`No issues found!` | `flutter-analyze-final.txt`, `flutter-analyze-final.exitcode.txt` |
| `flutter test --reporter compact` | Pass，ExitCode 0，`+130: All tests passed!` | `flutter-test-final.txt`, `flutter-test-final.exitcode.txt` |
| 成功测试后 logcat fatal/ANR/Dart error 扫描 | Pass，ExitCode 0，无匹配 | `crash-scan-final-strict.txt`, `crash-scan-final-strict.exitcode.txt` |

## 剩余边界

无自动化范围内阻塞。以下仍属于手工/专项范围：真实 SQLite 持久化与迁移、真实 `FieldCipher` 加密链路、相机/相册权限、PDF/系统分享面板、真实 BFF/地图联调、弱网专项。
