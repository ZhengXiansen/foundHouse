# Scan List Page Overrides（扫楼首页 · 村列表）

> **PROJECT:** foundHouse  
> **Route 概念:** 首页 Tab / 村列表（`VillageHomePage`）  
> **覆盖:** 仅本页相对 `MASTER.md` 的差异；其余遵循 Master。

---

## 目标

让用户在 3 秒内回答：  
1）我扫过哪些村？  
2）哪村还能继续扫？  
3）如何新增一个村？

**主 CTA：**「新增村」  
**次 CTA：**进入某村 / 继续扫楼

---

## Layout

- 结构：AppBar（标题 + 新增）→ 可选顶部摘要条 → 村列表 / 空状态  
- **非** Newsletter / Hero 订阅表单（忽略引擎对该 page 的 landing 模板）  
- 信息密度：中高；每行展示村名 + 关键统计（楼栋数/房源数/最近更新）  
- 列表项使用稳定 `ValueKey(villageId)`  
- 底部若有 Tab，列表 `padding` 预留 Tab + SafeArea  

## Visual

- 沿用 `KawaiiBackdrop` + `KawaiiIconBubble` 页头点缀  
- 卡片白底 / soft surface；主色仅用于 CTA 与关键数字强调  
- 统计数字对齐，避免「0 栋 0 套」与有数据行高度剧烈跳动  

## Empty state

- 文案方向：「还没有村，先添加你正在扫的城中村/小区」  
- 单一主按钮：新增村  
- 禁止空白屏无行动  

## Loading / Error

- Loading：居中 progress 或 2–3 条 skeleton 卡片  
- Error：原因 + 重试；不静默失败  

## Interactions

- 整卡可点进入村详情  
- 新增村：对话框或半屏 sheet；字段尽量少（村名必填，备注可选）  
- 删除村：二次确认（`delete_confirmation`）；说明关联楼栋/房源后果  

## Accessibility

- 「新增村」按钮有明确 label  
- 列表项语义包含村名与统计摘要  

## Avoid

- 地图/定位入口作为本页主路径  
- 桌面端 12 列复杂网格（移动单列卡片流）  
- 把本页做成营销 landing  
