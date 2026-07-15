# Drift 迁移目录

职责边界（W1-2 · D1，技术方案 §5.1）：存放 Drift schema 版本迁移逻辑与
`drift_dev` 导出的 schema 快照（`schema.dart` / 版本化 JSON），支撑
`schemaVersion` 升级时的表结构演进与迁移测试。

MVP 首版 `schemaVersion = 1`，暂无迁移；新增/变更表结构时在此按 Drift
迁移规范补充 `MigrationStrategy`。此文件为占位说明，实现见 W1-2 · D1。
