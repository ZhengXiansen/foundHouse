# 需求说明

用户提供正式发布参数：

1. Android applicationId / namespace：`com.zheng.foundhouse`
2. App 显示名称：`扫楼侠`
3. BFF 地址：用户不知道，当前阶段按“无 BFF 地址”处理。

本阶段目标：

- 配置 Android 正式构建基础项：包名、应用名称、release 签名、release 权限、版本/构建方式。
- 在没有 BFF 地址的情况下，不硬编码假的生产地址；构建时使用离线/本机默认可构建策略，并明确地图/BFF联网功能在正式可用前需要后续配置。
- 生成 release APK/AAB（优先 APK 便于真机安装；如可行同时生成 AAB）。
- 运行分析/测试/构建验证，必要时做 release 真机安装启动烟测。

风险：Android 包名/签名/权限属于发布高风险配置；需要审查与验证证据。
