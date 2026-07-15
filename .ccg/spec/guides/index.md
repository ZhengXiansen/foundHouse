# 通用开发指南

## Drift 聚合流与子表变更

当页面流只 watch 主表（例如 `houseRecords`）但展示内容依赖子表聚合（例如 `riskFlags`、checklist、照片等）时，子表增删改必须显式触发主表可观察字段更新，或改为 watch 覆盖子表的查询。

推荐做法：

- 子表写入与主表 `_touch(parentId)` 放在同一个 transaction 内。
- 删除子表记录前先查询父级 id，删除后 `_touch(parentId)`。
- 为关键聚合流补回归测试：订阅 `watchAll()` / 对应 stream，执行子表变更后断言 stream 会推送新聚合。

背景：Android 真机主流程中曾发现 `riskFlags` 写入 blocker 后，对比页仍未显示「已淘汰(红线)」。根因是 `watchAll()` 只 watch 主表，子表变化没有刷新主表，导致聚合流未推送。

## Android release 与未配置 BFF

移动端通过 BFF 获取地图/POI/通勤能力时，正式构建不要把 `127.0.0.1` / localhost 作为默认 BFF 地址打进 release 包。

推荐做法：

- BFF 地址通过 `--dart-define=FOUND_HOUSE_BFF_BASE_URL=https://...` 注入。
- 如果暂时没有 BFF 地址，provider 默认返回离线/未配置客户端，抛出业务可读错误（例如 `MAP_BFF_NOT_CONFIGURED`），让本地记录、列表、对比等离线能力继续可用。
- 为“未配置 BFF 不访问 localhost、不阻断本地能力”的行为补 provider/客户端测试。
- 发布报告中明确：未配置 BFF 的 release 包只覆盖本地离线能力，地图刷新/通勤/POI 需要部署 BFF 后重新构建或配置。

## 外部服务下线的分阶段策略

当产品决策要求下线某个外部服务能力（例如第三方地图 / BFF API）时，优先做“业务下线”而不是一次性删除底层表结构和历史仓库：

- 路由、首页入口、用户可见文案、按钮和错误态不得再触发或暴露该服务。
- 旧数据字段、repository、集成测试可作为第二阶段清理，避免迁移和评分/导出链路一次性大爆炸。
- 若保留兼容类，必须转发到新流程，不能保留旧用户界面。
- 为主流程补“不出现旧服务文案/失败态”的 widget 回归测试。

## Flutter widget test 中 Riverpod + Drift stream 的卸载

Widget test 里如果 ProviderScope 持有 Drift 查询流，测试结束前主动 `pumpWidget(SizedBox.shrink())` 后还需要再 pump 一个非零帧（例如 `pump(Duration(milliseconds: 1))`），让 Drift stream close 的零时长 timer 被 fake async 刷掉，否则可能出现 `A Timer is still pending even after the widget tree was disposed`。

## Drift schema 升级与迁移回归测试

当 `schemaVersion` 升级并涉及新增表、重建表、给旧表增加非空字段、或把旧字段迁移到新归属模型时，必须补显式迁移回归测试，而不能只依赖 fresh DB 测试：

- 测试先构造旧版本 schema 与旧数据，再用当前 `AppDatabase` 打开触发 `onUpgrade`。
- 断言旧数据的业务归属、兼容字段、非空新字段、外键关系和聚合查询均可用。
- 对新增非空字段尤其要验证回填逻辑，例如从旧 `house_id` 回填新 `owner_id`。
- review 时若只看到 fresh DB 测试，应标记为迁移覆盖不足，而不是认为迁移风险已被测试覆盖。

## 主流程变更后的设备测试同步

当主流程从旧能力切换到新能力（例如从地图/定位扫楼切换到首页村列表手动扫楼）时，除了 widget/unit 测试和文档状态标注，还必须同步 `integration_test/` 里的设备主流程脚本：

- 启动页断言应覆盖新的一级入口和关键空状态，同时明确断言旧服务文案不再出现。
- 设备脚本应走真实用户路径（新增村 → 进入村 → 新增楼栋 → 在楼栋下快速记录 → 去补全 → 详情/列表/对比），避免继续依赖被下线的地图/定位入口。
- 如果 Android 设备处于 `unauthorized` 或无可用设备，必须记录 `adb devices` / `flutter devices` 证据，并至少补充 Android 构建验证，不能声称已完成真机测试。

## Flutter 对话框与真机集成测试稳定性

Android 真机 `flutter test -d <device>` 使用 LiveTest 帧调度时，`showDialog` 退出动画期间仍可能重建对话框内的 `TextField`。如果 `TextEditingController` 在 `await showDialog(...)` 返回后立即 `dispose()`，可能触发 `A TextEditingController was used after being disposed`。

推荐做法：

- 简单输入弹窗优先不用外部 controller，用 `TextField.onChanged` / `onSubmitted` 写入外层局部变量，再在弹窗关闭后读取该变量。
- 如果必须使用 controller，应让 controller 生命周期归属于对话框内部的 `StatefulWidget` / `StatefulBuilder` 封装，而不是在调用方 `await showDialog` 后立刻销毁仍可能被退出动画引用的对象。
- 真机集成脚本输入文本后要显式收起测试输入法或发送 `TextInputAction.done`，再对小屏幕上的懒加载 `ListView` 目标执行滚动查找；对可能同时存在于旧 route/输入框/列表卡片中的文本，点击时优先使用 `hitTestable()` 限定可命中元素。

## Flutter 真机 route replacement 负向断言稳定性

Android 真机 `flutter test -d <device>` 中，`context.pushReplacement(...)` / route replacement 进入新页面后，旧 route 的退出动画结束前旧 `AppBar` 文案可能仍短暂存在于 widget tree。若脚本在 `pumpUntilFound(新页面标题)` 后立刻断言旧标题 `findsNothing`，会产生真机误报。

推荐做法：

- 对“旧页面文案不再存在”的负向断言，在确认新页面出现后额外 `pump` 若干帧，等待退出动画完成。
- 或优先断言新页面关键功能已可交互，把旧文案 `findsNothing` 作为动画稳定后检查。
- 对同一路由重入后的滚动位置，不要假设会自动回到顶部；需要用 `scrollUntilFound` 支持正/反向滚动查找。

## Flutter GoRouter 与命令式 Navigator 混用

当页面入口从 `Navigator.push(MaterialPageRoute(...))` 切换到 `go_router` 的命名路由时，后续跳转必须保持同一套导航语义，否则页面可能在 `StatefulShellRoute` / root navigator 下以 offstage 形式残留：

- App 主流程优先使用已有 `GoRoute` / `pushNamed` 打开临时表单页，避免绕过路由树。
- 如果临时页保存后要进入详情页，先显式移除临时页，再进入详情，并补 `skipOffstage: false` 的 widget 回归断言，确认旧页不只是在当前视图不可见。
- 若组件支持单页 `MaterialApp` 测试 fallback，所有使用 `context.go` / `GoRouter.of` 的出口都要用 `GoRouter.maybeOf(context)` 兜底，防止测试复用场景崩溃。

## Flutter 真机 integration 后必须重新安装 release 包

`flutter test -d <device> integration_test/...` 会构建并安装 debug APK；如果之前手机上安装的是正式包，integration 测试可能先因签名不一致而卸载旧包，再安装 debug 包。因此发布审计不能把 integration 测试后的设备状态直接当作“正式版已安装”。

推荐发布审计顺序：

- 先跑 `flutter analyze`、unit/widget/repository 测试和必要的真机 integration 脚本。
- 然后重新执行 `flutter build apk --release`，并在真机上用 `adb install -r build/app/outputs/flutter-apk/app-release.apk` 或等价命令安装正式包。
- 安装后用 `adb shell dumpsys package <applicationId>` 记录 `versionName`、`versionCode`、`lastUpdateTime`，再用 `monkey` + `dumpsys activity` + `uiautomator dump` 验证启动页和关键文案。
- 如果设备侧出现 `INSTALL_FAILED_USER_RESTRICTED`，不要把失败安装当作发布通过；解锁/确认设备安装权限后重试，并在审计报告中记录首次失败与最终通过证据。

## Flutter 移动端破坏性滑动手势

在手机真机上为列表卡片提供滑动删除等破坏性手势时，当前产品约定为“删除按钮显示在数据行/卡片右侧”：

- 本 App 的村/楼栋/房源卡片删除优先使用 `SwipeDeleteAction` 这类“部分露出操作区”的组件，而不是整行 `Dismissible` 滑到底移除；用户向左滑动卡片（物理右向左拖动）时，只应 snap 到右侧固定宽度删除按钮，向右滑动/左向右拖动必须保持收回态且不露出左侧删除操作。
- 删除确认仍应复用 `confirmDeleteRecord` / 等价显式确认，确认后通过 repository/Drift stream 刷新移除列表项；避免同时让滑动组件自行移除和 stream 重建造成双重移除风险。
- 若未来临时使用 `Dismissible`，必须显式限制为尾部/右侧删除方向并配置确认流程；不能因为 `horizontal` 默认值重新引入双向删除。
- Widget 测试至少覆盖右滑不触发、左滑后不立即弹确认、小幅左滑收回、仅在右侧露出固定宽度操作区、以及红色操作区和可见数据行/卡片高度对齐；真机 integration 测试用 `timedDrag`/足够时长模拟真实手势，避免只用桌面 widget drag 证明移动端体验。
- 如删除只能通过滑动触发，应评估 TalkBack/无障碍替代入口（例如菜单中的“删除”），并确保未露出的删除按钮不暴露在语义树中。
- 部分露出删除操作区在未滑动/收回状态必须视觉上完全隐藏破坏性背景；如果卡片有 margin、圆角或阴影，背景层不得在卡片边缘预绘制风险红色，只能在达到滑动露出态后绘制并响应点击。
- 红色删除操作区必须绘制在可见数据行/卡片的视觉边界内（例如通过 `SwipeDeleteAction.actionInsets` 对齐 `Card.margin`），不得填满外层列表间距而显得比数据行更高或与数据行分离。

