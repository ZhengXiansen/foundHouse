# 发布前人工检查清单需求

基于 `租房扫楼产品PRDv1.1.md`、`found-house-app/docs/qa/v1.1-test-cases.md` 与 `found-house-app/docs/qa/v1.1-android-device-test-report.md`，新增 v1.1 发布前人工检查清单。

范围：
- Android 真机发布前人工验收。
- 覆盖自动化无法稳定控制的系统 UI：相机、相册、系统分享面板。
- 覆盖 v1.1 主路径：首页村列表、村详情楼栋工作台、快速记录、房源复盘、Checklist/风险、评分对比、隐私脱敏。
- 明确阻断发布的 gate：地图/定位主流程回归、核心本地记录失败、隐私脱敏失败、系统 UI 崩溃等。
