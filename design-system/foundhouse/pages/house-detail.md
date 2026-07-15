# House Detail / Score Page Overrides（房源详情与评分）

> **PROJECT:** foundHouse  
> **Route 概念:** 房源详情、评分解释（`HouseDetailPage` / `ScoreDetailPage`）  
> **覆盖:** 仅本页差异。

---

## 目标

支持决策：这套房是否值得跟进？  
一眼看到：总成本、通勤/约束、清单风险、综合分与未通过硬筛原因。

---

## Layout

- 顶：标题 + 状态 chip（draft/active/shortlisted/rejected/chosen）  
- 中：关键指标条（月总成本 / 评分 / 风险数）→ 分段内容（费用、房屋、清单摘要、评分拆解）  
- 底：主操作（加入对比 / 编辑 / 标记状态）按场景一个 Primary  

## Score presentation

- 总分强调；分项 cost / commute / living / nearby / risk 用条或列表  
- **硬筛失败**优先于分数展示：清晰列表原因  
- 缺失字段：标明「缺失导致该维上限」类提示（与评分规则一致），不用假 0 分掩盖  

## Risk

- warning vs blocker 层级分明  
- 颜色 + 图标 + 文案；风险提示保持「建议」语气，非法务结论  

## Visual

- 评分与金额用高对比；通勤用 `AppColors.commute`  
- 卡片分区，避免一页无层级长滚动墙  

## Avoid

- 只有圆环分数无解释  
- 仅用红绿表示风险无文字  
- 地图大图抢主流程（若有快照，折叠为次级）  
