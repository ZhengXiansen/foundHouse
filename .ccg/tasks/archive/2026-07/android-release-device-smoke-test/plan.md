# Android release APK 真机烟测计划

1. 确认 release APK 存在。
2. 检测 ADB 设备授权状态和设备信息。
3. 安装 `com.zheng.foundhouse` release APK；如签名冲突，先卸载同包名后重装并记录。
4. 清空 logcat 后启动 App。
5. 检查前台焦点、导出截图、导出 UI XML。
6. 抓取 logcat 并扫描 FATAL/ANR/Dart Error/Fatal signal 等崩溃模式。
7. 写测试报告并归档任务。
