# 集成待办与衔接点（跨里程碑）

> 记录多轨并行开发中发现的、需在后续里程碑收口的集成缺口。避免上下文丢失。

## 1. CryptoService 异步接口 vs FieldCipher 同步接口（W5 · H1 收口）

**现状**：
- `lib/data/crypto/field_cipher.dart` 的 `FieldCipher` 接口是**同步**的：`String? encrypt(String?)` / `String? decrypt(String?)`。
- `HouseRepository` 与 `mappers.dart` 通过同步方式内联调用 `_cipher.encrypt/decrypt`（在 Companion 构造与行→领域对象映射时）。
- `lib/data/crypto/crypto_service.dart` 的 `CryptoService`（W5·H1，AES-256-GCM）是**异步**的：`Future<String> encryptField(String)` / `Future<String> decryptField(String)`——AES-GCM 加解密本质异步，无法直接实现同步 `FieldCipher`。

**当前可用状态**：
- Provider 层（`lib/data/providers.dart`）默认注入 `NoopFieldCipher`（透传，不加密）。
- W1-2 / W4 全部功能在透传下完整可用，敏感字段以明文落库（MVP 本地库，可接受但**发布前必须收口**）。

**W5 收口方案（二选一，推荐 A）**：
- **方案 A（改造为异步管线）**：将 `FieldCipher.encrypt/decrypt` 改为返回 `Future`，`mappers.dart` 的行↔领域转换改为异步，`HouseRepository` 的写路径用 `await`、读路径（`watchAll`/`watchById` 的 Stream）用 `asyncMap`。影响面：mappers + house_repository + 相关测试。属真正的加密接入工作。
- **方案 B（同步包装，不推荐）**：在应用启动时预解密 DEK 并用同步对称算法（如 pointycastle 的同步 AES）实现同步 `FieldCipher`。牺牲 `cryptography` 包的现代实现，不推荐。

**验收**：接入后 `encrypt→decrypt` 往返一致；导出与数据库均不含明文 phone/wechat/roomNo；仓库层单测新增加密往返用例（技术方案测试计划 W5）。

## 2. 评分规则远程覆盖加载（W3 BFF 配置下发）

`ScoreRule.defaultRule()` 当前硬编码内置默认 `mvp-2026-07-02`，`fromJson` 入口已留。远程覆盖的加载 provider 与 BFF 配置下发端点尚未打通（F8），属 W3+ 工作。历史 `ScoreSnapshot` 冻结 `ruleVersion` 不自动重算的逻辑已在引擎实现。

## 3. MapRepository 客户端（W3 · E6）

`lib/data/repositories/map_repository.dart` 仍为占位。需实现：调用 BFF `/api/map/nearby-summary` 与 `/api/map/commute` → 落 `MapSnapshot` 本地快照 → 列表/评分从快照读。BFF 端（`found-house-bff`）E1-E4 已就绪。

`lib/features/scan/scan_map_page.dart` 亦为占位，属 W3 客户端地图展示（E5），依赖高德 Flutter 集成方案（F6）定稿后落地。

## 4. 导出（W4 已落地，两处后续项）

`export_service.dart` 与对比导出已实现（脱敏器 + PDF 生成 + 分享），经单测验证脱敏正确（联系人/门牌/经纬度默认隐藏，合同照片默认关）。W4 实测发现两处待后续里程碑接入：

- **PDF 中文字体**：`pdf` 包内置 Helvetica 无 CJK 字形，导出 PDF 中文会缺字（测试日志有 "Unable to find a font" 告警，不影响逻辑与测试）。需在 `pubspec.yaml` 注册中文字体 asset 并用 `pw.Font.ttf` 加载。
- **导出嵌图**：当前导出对比表文本，照片嵌入与 EXIF 移除（H2）后置；`ExportOptions` 的合同照片开关语义已落地，未实际嵌图。

## 5. CryptoService 装配（未接线）

`crypto_service.dart` 已实现并单测通过（8 例），但 `providers.dart` 的 `fieldCipherProvider` 仍注入透传 `NoopFieldCipher`。接线属上文第 1 节的 W5 异步化工作，未在本轮接入——当前敏感字段以明文落本地库，符合 MVP 本地优先但**尚未满足 F7 加密要求**，公网同步（V1.1）前必须完成。
