# 开发执行计划实现审查

审查日期：2026-07-03  
范围：对照 `开发执行计划.md` 与 `租房扫楼产品落地细节与技术实现方案.md`，检查 `found-house-app` 与 `found-house-bff` 的实现完成度。未修改业务代码。

## 结论

当前实现不是可发布完成态。W1-2 本地记录闭环、W4 评分/对比/脱敏导出主体已经落地；BFF 地图代理的路由、schema、测试和构建也基本可用。但 W3 客户端地图链路仍是占位，W5 字段级加密没有接入生产仓库链路，Flutter 质量门禁未通过，BFF lint 也未通过。

按发布清单看，核心未满足项是：

- 有定位房源获取主要通勤时间和周边 POI 摘要：端到端未满足，客户端地图页仍占位。
- 敏感字段 AES-256-GCM 加密写入：未满足，默认注入 `NoopFieldCipher`，落库仍可为明文。
- 质量门禁：未满足，`flutter analyze`、`flutter test`、`npm run lint` 均失败。

## 外部模型审查限制

CCG 要求 L+ 任务进行 antigravity + Claude 双模型审查。本次已尝试，但不能视为完成双模型审查：

- antigravity：`codeagent-wrapper` 启动失败，错误为 `agy command not found in PATH`。
- Claude：`codeagent-wrapper --backend claude` 124 秒超时，没有返回可用审查报告；超时遗留的本次 wrapper/claude 子进程已定点清理。

因此本报告以本地静态审查和命令验证为准。

## 验证结果

| 命令 | 结果 | 关键输出 |
| --- | --- | --- |
| `flutter analyze` (`found-house-app`) | 失败 | 6 issues：`path`/`sqlite3` 非显式依赖，2 个 unused import |
| `flutter test` (`found-house-app`) | 失败 | 110 passed, 1 failed；`test/app_smoke_test.dart` 中 `pumpAndSettle timed out` |
| `npm test` (`found-house-bff`) | 通过 | 2 files, 20 tests passed |
| `npm run build` (`found-house-bff`) | 通过 | `tsc -p tsconfig.json` exit 0 |
| `npm run lint` (`found-house-bff`) | 失败 | ESLint 9 找不到 `eslint.config.(js|mjs|cjs)` |

## Critical

### C1. F7/W5 字段级加密未接入生产数据链路

要求：`开发执行计划.md:21`、`开发执行计划.md:118` 要求字段级 AES-256-GCM + `flutter_secure_storage` 托管 DEK，并由仓库层接入；技术方案 `租房扫楼产品落地细节与技术实现方案.md:360-365` 明确读写敏感字段统一经 `CryptoService`，验收要求密文不等于明文（同文档 `:824`）。

实际：

- `found-house-app/lib/data/crypto/crypto_service.dart:53-122` 实现了异步 AES-GCM 服务。
- 但 `found-house-app/lib/data/crypto/field_cipher.dart:6-7` 注释说明当前仍提供透传实现，`field_cipher.dart:22-29` 的 `NoopFieldCipher` 直接返回原文。
- `found-house-app/lib/data/providers.dart:25-27` 默认 `fieldCipherProvider` 注入 `const NoopFieldCipher()`。
- `found-house-app/lib/data/repositories/house_repository.dart:75`、`:123`、`:151` 确实把 `roomNo/phone/wechat/note` 交给 `FieldCipher`，但由于 provider 是 Noop，生产默认链路仍是明文。
- `found-house-app/test/data/house_repository_test.dart:72-89` 明确断言 Noop 下数据库行 `phone` 等于明文。
- `found-house-app/lib/features/settings/privacy_page.dart:29-30` 却告知用户“电话、微信、门牌以密文存储（AES-256-GCM）”，与实际默认行为不一致。

影响：隐私红线未满足，W5/H1 和发布前敏感字段加密验收失败；UI 还会给用户错误的安全承诺。

### C2. W3 客户端扫楼地图仍是占位，地图/通勤/POI 端到端未完成

要求：`开发执行计划.md:86-98` 要求 W3 完成 BFF 地图代理、高德展示、POI 统计、通勤时间、本地快照，验收为“有定位房源展示至少一个主要通勤时间；POI 可按半径/类型展示”；技术方案 `租房扫楼产品落地细节与技术实现方案.md:178`、`:186`、`:766-776` 要求 `amap_flutter_map` + `amap_flutter_location`、底图、当前定位、房源标记和目标区域圈层。

实际：

- `found-house-app/lib/features/scan/scan_map_page.dart:9-11` 明确说明当前文件仅占位并 TODO 接入高德地图。
- `scan_map_page.dart:17-19` 返回 `PlaceholderPage`。
- `found-house-app/lib/integrations/amap/amap_client.dart:1-11` 与 `amap_models.dart:1-8` 仍是占位。
- `found-house-app/pubspec.yaml` 未出现 `amap_flutter_map` / `amap_flutter_location` 依赖。
- BFF 侧 `found-house-bff/src/modules/map/map.routes.ts:45-57` 已提供 `/api/map/nearby-summary` 和 `/api/map/commute`，`map.service.ts:39-45`、`:94-149` 有 Redis 缓存与通勤结果逻辑，但客户端缺少承接页面和地图 SDK 集成。

影响：W3 的后端部分基本可用，但用户侧“扫楼地图页 + 房源标点 + 当前定位 + 主要通勤/POI 展示”未完成，发布清单中的地图能力不成立。

## Warning

### W1. 月总成本对水电费口径不完整，有单价时可能低估成本

要求：技术方案 `租房扫楼产品落地细节与技术实现方案.md:375-382` 定义 `estimated_total_monthly` 应包含 `estimated_water_fee` 与 `estimated_electricity_fee`；`开发执行计划.md:15-16` 要求预算硬筛唯一基准为月总成本，缺失水电费要保守补偿。

实际：

- `found-house-app/lib/features/scoring/cost_calculator.dart:30-42` 只在 `waterUnitPrice` / `electricityUnitPrice` 缺失时加入默认月费。
- `found-house-app/test/scoring/cost_calculator_test.dart:18-22` 断言存在水费/电费单价时，月总成本仍为 2200，即未把水电月度费用计入。
- `found-house-app/lib/features/scoring/filter_engine.dart:37` 确实用 `estimatedTotalMonthly` 做预算硬筛，但输入的总成本可能已经偏低。

影响：录入了水电单价的房源反而可能不计入水电月费，导致 F1 硬筛和 F2 成本评分偏乐观。

### W2. F5 主要通勤未按 `primary=true` 目的地过滤

要求：`开发执行计划.md:19` 和技术方案 `租房扫楼产品落地细节与技术实现方案.md:403` 要求主要通勤时间取 `primary=true` 目的地，未标记时取第一个目的地；模式默认 `transit`，用户指定优先，无结果回退 `driving`。

实际：

- `found-house-app/lib/features/settings/preference_page.dart:192-200` 保存了目的地 JSON，并设置 `id: primary`、`primary: true`。
- BFF `found-house-bff/src/modules/map/map.service.ts:109`、`:149` 返回 `destinationId`。
- 但 `found-house-app/lib/features/scoring/house_scoring_controller.dart:251-257` 只解析所有 `commuteJson` 后按模式选择；`:280` 构造 `CommuteOption` 时未保留 `destinationId` / `primary`。
- `found-house-app/lib/features/scoring/commute_selector.dart:17-44` 只按 mode 查找，未考虑目的地。

影响：多目的地或非主要目的地先出现在快照中时，硬筛可能用错通勤时间。

### W3. BFF 限流实现不完整，错误码与方案不一致

要求：`开发执行计划.md:92` 要求 Redis 缓存与按匿名设备 token 阈值限流；技术方案 `租房扫楼产品落地细节与技术实现方案.md:649-670`、`:679-684` 要求 429 返回业务码 `MAP_RATE_LIMITED`。

实际：

- `found-house-bff/src/infra/rate-limit.ts:19` 定义了 `GLOBAL_PER_MINUTE`，但未被注册逻辑使用。
- `rate-limit.ts:31-39` 只注册 per-device `max: PER_DEVICE_PER_MINUTE`，未配置 Redis/shared store。
- `rate-limit.ts:39` 返回 `RATE_LIMITED`；`found-house-bff/src/app.ts:57-58` 也映射为 `ErrorCode.RATE_LIMITED`，与计划的 `MAP_RATE_LIMITED` 不一致。

影响：多实例部署时限流状态不共享，且客户端无法按地图业务错误码做一致提示。

### W4. 质量门禁未通过

本次 Fresh 验证结果：

- `flutter analyze` 失败：`lib/data/db/app_database.dart:5`、`:7`，`lib/data/local_files/photo_store.dart:11`，`test/data/photo_store_test.dart:10` 引入了未显式声明的 `path`/`sqlite3`；`test/app_smoke_test.dart:1`、`test/features/house_scoring_controller_test.dart:18` 有 unused import。
- `flutter test` 失败：`test/app_smoke_test.dart:30` 在“切换到「房源」Tab 展示房源列表占位”用例 `pumpAndSettle timed out`，汇总为 110 passed / 1 failed。
- `npm run lint` 失败：ESLint 9 需要 `eslint.config.(js|mjs|cjs)`，当前仓库未提供。

影响：即使功能补齐，也不能报告“测试通过”或进入发布。

## Info

### I1. PDF 导出中文字体未配置，中文内容可能不可读

`flutter test` 中 `found-house-app/test/features/export_service_test.dart` 的 PDF 生成用例虽然继续执行，但输出大量 `Helvetica has no Unicode support` 与 `Unable to find a font to draw` 警告。实现侧 `found-house-app/lib/features/compare/export_service.dart:176-208` 使用默认 `pw.TextStyle`，未提供中文字体 fallback。

影响：PDF 字节非空不等于中文可读；内测导出对比报告可能出现中文缺字。

### I2. 已完成或基本完成的范围

- 数据层：`found-house-app/lib/data/db/app_database.dart:18-34` 聚合 10 张表，`:44` schemaVersion 为 1，`:53` 开启外键；`tables.dart:18-321` 覆盖 House/Fee/Room/Contact/Checklist/Risk/Photo/Map/Score/Preference。
- 本地记录：`quick_record_page.dart:3-11` 描述了进入即建草稿、照片经 `PhotoStore` 落盘；Checklist 页面 `checklist_page.dart:73-135` 有四态写库与 RiskFlag 联动。
- 评分规则：`docs/rules/score-rule-v0.json:2-30` 有规则版本、权重、缺失水电默认值和公式；`score_engine.dart:49-175` 对分项做 clamp，缺失费用 cost cap 也有实现。
- 导出脱敏：`export_service.dart:3-10`、`:21-45`、`:77-165` 默认隐藏联系人、门牌和精确位置，并先经 `ExportSanitizer`。
- BFF 地图代理：`map.routes.ts:45-57` 提供 POI/commute 接口；`map.schema.ts:46-73` 使用 strict zod schema，`modes` 默认 `['transit']`；`map.service.ts:39-45`、`:132-149` 有缓存和 `destinationId` 输出；BFF 测试和构建通过。

## 完成度矩阵

| 项 | 状态 | 说明 |
| --- | --- | --- |
| F1 月总成本预算硬筛 | 部分满足 | FilterEngine 使用 `estimatedTotalMonthly`，但成本输入的水电月费口径不完整 |
| F2 缺失水电费补偿 + cost cap | 部分满足 | 缺失单价时有默认补偿和 cap；有单价但无月度用量/费用时仍可能低估 |
| F3 clamp 不为负 | 基本满足 | 评分引擎统一 clamp 到 0-100 |
| F4 五维评分 + 权重 | 基本满足 | 规则文件与引擎均有对应结构 |
| F5 主要通勤 | 部分满足 | mode 默认/回退逻辑存在；primary destination 未参与选择 |
| F6 高德 Flutter 集成 | 未满足 | 客户端地图与 AMap 封装仍占位，依赖未接入 |
| F7 本地字段加密 | 未满足 | CryptoService 存在，但 provider 默认 Noop，落库可为明文 |
| F8 评分规则版本 | 部分满足 | 本地默认规则版本存在；远程覆盖/历史冻结闭环未形成完整证据 |
| F9 字段字典单一事实源 | 基本满足 | `docs/field-dictionary.md` 存在，schema 覆盖主要表；需后续随 schema 持续校验 |
| F10 中文浅层 UI | 基本满足 | 主要页面中文文案已落地，仍需结合 smoke test 修复验证 |
| W0 规则与骨架 | 部分满足 | 规则/字典/模板/双仓存在；高德可跑通地图未满足 |
| W1-2 本地记录闭环 | 大部分满足 | schema、CRUD、草稿、照片、Checklist 具备；Flutter 门禁失败 |
| W3 地图与通勤 | 部分满足 | BFF 基本完成；客户端地图与端到端快照未完成 |
| W4 评分筛选与对比 | 大部分满足 | 引擎/UI/对比/脱敏导出已落地；成本和通勤口径有缺口 |
| W5 隐私稳定性与内测 | 未满足 | 加密未接入，质量门禁未通过，PDF 中文字体存在风险 |

## 建议修复顺序

1. 先修 F7：把 `CryptoService` 接到仓库默认链路，处理异步边界，新增“DB 密文不等于明文”的测试，并修正隐私页只在真实加密时声明 AES。
2. 再修 W3/F6：接入 `amap_flutter_map` / `amap_flutter_location`，完成扫楼地图、定位、房源 marker、BFF POI/commute 调用和本地 `MapSnapshot` 写入。
3. 修 F1/F2：补齐水电月费/用量口径，确保 `estimated_total_monthly` 始终包含真实或保守水电月费。
4. 修 F5：在 `CommuteOption` 中保留 `destinationId`，按偏好 `primary=true` 目的地过滤后再按 mode 选择。
5. 清质量门禁：补 `path`/`sqlite3` 依赖或调整导入，修 smoke test 的 settle 超时，补 ESLint 9 flat config，并配置 PDF 中文字体。
