# found_house_app

> **状态更新（2026-07）**：README 下方仍含早期脚手架和 map-first 说明，作为历史背景保留。当前产品方向以 `../租房扫楼产品PRDv1.1.md` 为准：默认进入「首页/扫楼」村列表，手动新增村和楼栋，在村/楼栋下记录房源；不再依赖定位或第三方地图 API 完成主流程。

个人扫楼助手 MVP 的 Flutter 移动端。本地优先、弱网/无网可用，承载「扫楼前设偏好 → 现场快速记录 → 地图/通勤/周边补全 → 硬筛选 + 加权评分 → 对比导出」核心闭环。

> 本目录为 **W0 · 轨道 B（客户端脚手架）** 产物：仅工程骨架 + 主题 / 路由 / 动画常量，**业务页面、Drift schema、评分/硬筛引擎尚未实现**（W1-2 / W3 / W4 落地）。所有占位文件均带 TODO 注释标明职责边界。

## 技术栈

| 能力 | 包 |
| --- | --- |
| 状态管理 | flutter_riverpod |
| 路由 | go_router（一级 4 Tab 用 `StatefulShellRoute.indexedStack`） |
| 本地数据库 | drift + sqlite3_flutter_libs |
| 文件路径 | path_provider |
| 拍照/选图 | image_picker（camera 后置） |
| 权限 | permission_handler |
| PDF / 打印 | pdf + printing |
| 安全存储 | flutter_secure_storage（托管字段级加密 DEK） |
| 主键 | uuid |

依赖版本查证说明见 `pubspec.yaml` 内逐条注释（2026-07，经 context7 检索 pub.dev / 官方文档确认）。

## 工程结构

```text
lib/
  main.dart                 # 入口：ProviderScope 包裹 FoundHouseApp
  app/
    app.dart                # 根组件：MaterialApp.router 装配主题 + 路由
    theme.dart              # Material 3 ThemeData + AppColors（色值单一事实源，UI §4.1）
    motion.dart             # 动效 duration/curve 常量 + 减少动态效果兜底（UI §7/§10）
    router.dart             # go_router：4 Tab Shell + 二级页面 + 转场
    placeholder_page.dart   # 占位页脚手架（各未实现页复用，避免样板重复）
  features/
    scan/                   # 扫楼地图、快速记录
    house/                  # 房源列表、详情、表单分区
    checklist/              # 看房检查清单与模板
    scoring/                # 评分/硬筛引擎（纯 Dart，不依赖 UI）+ 评分详情页
    compare/                # 对比表与导出服务
    settings/               # 设置首页、偏好、隐私
  data/
    db/                     # Drift 数据库入口、表定义、migrations/
    repositories/           # HouseRepository / MapRepository / PreferenceRepository（只读写）
    local_files/            # PhotoStore / ExportStore（端侧文件管理）
  integrations/
    amap/                   # 高德地图桥接与数据模型
    permissions/            # 用时申请权限封装
```

关键原则（技术方案 §8）：`ScoreEngine`/`FilterEngine` 不依赖 UI 便于单测；`HouseRepository` 只读写不含评分；地图结果先落本地快照；照片操作统一走 `PhotoStore`。

## 环境要求

- Flutter 稳定版（Dart SDK ≥ 3.6，见 `pubspec.yaml` 的 `environment` 约束；go_router 15.2.x 要求 Dart ≥ 3.6）。
- 本脚手架**手写生成**，未运行过 `flutter create`。首次拉取依赖前请确保已安装 Flutter SDK 并执行 `flutter doctor` 通过。

> 注意：本目录不含 `android/` `ios/` 等平台工程目录。如需在真机/模拟器运行，先在本目录执行
> `flutter create --project-name found_house_app --org <你的组织标识> .`
> 补齐平台脚手架（该命令不会覆盖已存在的 `lib/`、`pubspec.yaml`）。

## 常用命令

在本目录（`found-house-app/`）执行：

```bash
# 1. 拉取依赖
flutter pub get

# 2. Drift 代码生成（W1-2 定义 @DriftDatabase 后必需；生成 *.g.dart）
#    先跑一次性生成：
dart run build_runner build --delete-conflicting-outputs
#    开发期可用监听模式：
dart run build_runner watch --delete-conflicting-outputs

# 3. 静态分析（对齐 analysis_options.yaml 的严格 lint）
flutter analyze

# 4. 运行测试
flutter test

# 5. 运行应用（需先补齐平台工程，见上）
flutter run
```

> 当前脚手架阶段 `lib/data/db/app_database.dart` 尚未声明 `part 'app_database.g.dart';`，
> 因此 `build_runner` 暂无产物；待 W1-2 定义表与数据库后再启用代码生成。

## 里程碑对照

| 阶段 | 范围 | 状态 |
| --- | --- | --- |
| W0·B | 工程骨架 + 主题/路由/动画常量 | 本目录已完成 |
| W1-2 | Drift schema、房源 CRUD、快速新建、拍照、Checklist | 未开始 |
| W3 | 高德地图展示、BFF 代理、POI/通勤、本地快照 | 未开始 |
| W4 | FilterEngine / ScoreEngine、评分详情、对比、导出 | 未开始 |
| W5 | 字段加密、导出脱敏、埋点、内测 | 未开始 |
