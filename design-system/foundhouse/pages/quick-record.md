# Quick Record Page Overrides（快速记录）

> **PROJECT:** foundHouse  
> **Route 概念:** 现场快速记房源（`QuickRecordPage` 等）  
> **覆盖:** 仅本页差异。

---

## 目标

弱网/站路边时，**≤3 步**留下可用草稿：价格/房型/照片/备注。  
可稍后补全 checklist、联系人、评分。

**主 CTA：**保存（或保存并继续）  
**次操作：**拍照、跳过非必填

---

## Layout

- 单列表单；首屏优先：**租金 / 房型 / 拍照入口**  
- 分区折叠或步进：基础 → 费用 → 房屋 → 联系人（敏感）  
- 长表单：考虑顶部迷你进度或分区锚点；底栏固定保存  
- 键盘弹起时，主 CTA 不被遮挡（`resizeToAvoidBottomInset` / 滚动保证）  

## Form UX

- 每个字段可见 label；错误在字段下  
- 租金等用数字键盘；电话用 telephone keyboard  
- 提交：loading → success（SnackBar/返回列表）/ error（可重试）  
- 未保存离开：确认（sheet dismiss confirm）  
- 离线：明确可保存本地；不假装已云同步  

## Photos

- 拍完回到本流程，不强制跳系统相册浏览  
- 缩略图轨 + 标签（room/building/…）  
- 权限拒绝：仍可纯文字保存  

## Visual / Density

- Density 偏高（8）：字段紧凑但触控高度 ≥48  
- Primary 仅保存与关键「完成」；拍照用 secondary/tonal  

## Accessibility

- 表单 `Semantics` / 系统 `TextFormField` label  
- 危险删除照片需确认  

## Avoid

- 首屏塞满全部 PRD 字段  
- Placeholder 代替 label  
- 保存无反馈  
- 依赖定位才能保存  
