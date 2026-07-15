[根目录](../CLAUDE.md) > **found-house-app**

> **状态更新（2026-07）**：本文大量内容是早期 Flutter 空骨架 / map-first 规划，作为历史背景保留。当前实现以 `../租房扫楼产品PRDv1.1.md` 为准：扫楼 Tab 为首页村列表，按村/楼栋手动扫楼记录；地图、定位、第三方地图 API 已从主流程下线。

# found-house-app（Flutter 移动端）

## 模块职责

扫楼找房助手的移动端主应用。承载全部核心闭环：偏好设置、现场快速记录、拍照归档、Checklist、地图与通勤、硬筛选 + 加权评分、对比导出。本地优先，弱网/无网可用。

## 当前状态

空仓库骨架。目录仅含 `.git`（已 `git init`，默认分支 `main`，无任何提交与源码）。以下内容为依据规划文档整理的目标结构，尚未落地。

## 入口与启动（规划）

- 应用入口：`lib/app/app.dart`
- 路由：`lib/app/router.dart`（go_router，一级 Tab 用 ShellRoute / StatefulShellRoute）
- 启动默认进入「扫楼」地图页

## 规划目录结构

```text
lib/
  app/
    app.dart          # 应用入口、主题（Material 3）
    router.dart       # go_router 路由与 Tab Shell
  features/
    scan/             # 扫楼地图、快速记录
      scan_map_page.dart
      quick_record_page.dart
    house/            # 房源列表、详情、表单分区
      house_list_page.dart
      house_detail_page.dart
      house_form_sections.dart
    checklist/        # 看房检查清单与模板
      checklist_page.dart
      checklist_templates.dart
    scoring/          # 评分与筛选（不依赖 UI）
      score_detail_page.dart
      score_engine.dart
      filter_engine.dart
    compare/          # 对比表与导出
      compare_page.dart
      export_service.dart
    settings/         # 偏好、隐私设置
      preference_page.dart
      privacy_page.dart
  data/
    db/               # Drift + sqlite3 schema 与迁移
      app_database.dart
      tables.dart
      migrations/
    repositories/     # 只读写，不含业务逻辑
      house_repository.dart
      map_repository.dart
      preference_repository.dart
    local_files/      # 照片/导出文件管理
      photo_store.dart
      export_store.dart
  integrations/
    amap/             # 高德地图桥接
      amap_client.dart
      amap_models.dart
    permissions/      # 用时申请权限
      permission_service.dart
```

## 对外接口（规划）

移动端通过后端 BFF 获取地图能力，不直连高德 WebService（保护 Key）：

- `POST /api/map/nearby-summary`：按经纬度 + 半径（300/800/1500m）+ POI 类型返回周边统计摘要。
- `POST /api/map/commute`：按起点 + 目的地 + 出行方式（walking/bicycling/transit/driving）返回通勤时长、步行距离、换乘次数。

地图结果先落本地 `MapSnapshot`，列表与评分从本地快照读取。

## 关键依赖与配置（规划）

| 能力 | 包 |
| --- | --- |
| 状态管理 | riverpod |
| 路由 | go_router |
| 本地数据库 | drift + sqlite3 |
| 文件路径 | path_provider |
| 拍照 | camera / image_picker |
| 权限 | permission_handler |
| PDF 导出 | pdf + printing |
| 地图 | 高德地图 Flutter 插件或自建原生桥接 |

## 数据模型（规划本地表）

核心表见根方案文档第 5 节。主要实体：

- `HouseRecord`：房源主记录（id/title/status/经纬度/地址/楼栋/门牌脱敏/时间戳）。status 取值 draft/active/shortlisted/rejected/chosen。
- `FeeInfo`：费用（月租、押金、付款周期、管理费、网费、水电单价、燃气、预估月总成本）。
- `RoomInfo`：房屋（房型、面积、楼层、电梯、朝向、独卫、厨房、能否做饭/养宠）。
- `ContactInfo`：联系人（称呼、角色、电话、微信、身份核验）。电话/微信本地加密。
- `ChecklistItem`：检查项（module: room/kitchen/building/contract/risk；value: good/ok/bad/not_seen）。
- `RiskFlag`：风险（severity: warning/blocker；source: user/system）。
- `PhotoAsset`：照片（tag: sign/building/room/window/bathroom/meter/contract/damage；exif_removed）。
- `MapSnapshot`：地图快照（commute_json、poi_summary_json、user_correction_json）。
- `ScoreSnapshot`：评分快照（rule_version、hard_filter_result、score_total、score_breakdown_json、explanation_json）。
- `PreferenceProfile`：偏好（月总成本上限、最大通勤、目的地、硬性条件、权重 30/20/25/15/10）。

## 核心算法（规划）

月总成本：

```text
estimated_total_monthly = rent_monthly + management_fee + internet_fee
  + gas_fee + other_fee + estimated_water_fee + estimated_electricity_fee
```

缺失水电单价时不填 0，标记缺失，总成本维度最高只能拿 70%。

硬筛选（优先于评分，命中进入 rejected/flagged）：超预算、超通勤、缺必选条件、命中 blocker 风险（非居住空间、拒绝证明身份、押金规则完全不清、消防/楼栋安全异常、费用口径矛盾）。

加权评分（100 分制）：

```text
total_score = cost_score*0.30 + commute_score*0.20 + living_score*0.25
  + nearby_score*0.15 + risk_score*0.10
```

评分规则必须版本化，变更保留旧快照。

## 关键流程

- 快速新建：点 `+` 立即创建草稿（记录时间/位置）→ 半屏抽屉聚焦价格 → 输入价格/拍照/选房型或直接保存。不超过 3 步。
- 拍照归档：拍完不跳系统相册，缩略图飞入当前房源照片轨。
- 弱网：无网可新建、拍照、编辑 checklist；地图/通勤后补。
- 权限：定位/相机/相册/麦克风用时申请，拒绝后仍可继续（手动地址、文字记录、本地保存）。

## 测试与质量（规划）

- 单元测试重点：`score_engine.dart`、`filter_engine.dart`、月总成本、缺失扣分、导出脱敏。
- 集成测试：本地记录闭环持久化、地图失败降级、权重变更重算 + 快照保留。

## 常见问题 (FAQ)

- Q：为什么地图能力要走后端而非直连高德？A：保护服务端 Key，并对 POI/路线做缓存降低成本，同时按经纬度网格缓存以降低精确住址暴露。
- Q：敏感数据如何处理？A：默认本地保存、默认不上传、导出默认脱敏；电话/微信/门牌本地加密；删除房源时清理关联照片与本地敏感数据。

## 相关文件清单

- 实现入口：`lib/app/app.dart`、`lib/app/router.dart`、`lib/app/theme.dart`、`lib/app/kawaii_widgets.dart`
- **UI 设计系统（改界面必读）**：`../design-system/foundhouse/MASTER.md`；页面覆盖见 `../design-system/foundhouse/pages/`（`scan-list` / `quick-record` / `house-detail` / `compare`）。页面文件优先于 Master；色板与组件实现以本模块 `theme.dart` / `kawaii_widgets.dart` 为准。
- 字段与集成说明：`docs/field-dictionary.md`、`docs/INTEGRATION-NOTES.md`
- 规划来源（历史）：根目录 PRD / 技术方案 / 早期 UI 设计文档；主流程以 PRD v1.1 村列表扫楼为准。

## 变更记录 (Changelog)

- 2026-07-11：相关文件清单加入 `design-system/foundhouse/` 索引与 UI 改动阅读顺序。
- 2026-07-02：首次生成。模块为空 Flutter 仓库骨架，本文档依据规划文档整理目标结构、数据模型、算法与流程。
