# Design System Master File — foundHouse

> **LOGIC:** 构建具体页面时，先查 `design-system/foundhouse/pages/[page-name].md`。  
> 页面文件存在则其规则 **覆盖** 本 Master；否则严格遵循本文件。

---

**Project:** foundHouse（扫楼找房助手）  
**Generated:** 2026-07-11  
**Source:** `ui-ux-pro-max` CLI + 产品 PRD v1.1 + 现有 Flutter 实现（`found-house-app/lib/app/theme.dart`）  
**Category:** Personal productivity / field tool（线下扫楼记录，非房源交易平台）  
**Platform:** Flutter mobile-first（Riverpod 2.x + go_router）  
**Design Dials (engine):** Variance 3–4/10 · Motion 2–3/10 · Density 7–8/10

---

## 0. Product framing（设计前提）

| 维度 | 决策 |
|------|------|
| 用户场景 | 城中村/老小区现场扫楼：单手操作、弱网、强日光、快速记价格/房型/照片/清单 |
| 主流程 | 首页村列表 → 进入村 → 楼栋/房源 → 快速记录 / Checklist / 评分对比 |
| 明确不做 | 地图首页、定位依赖、交易/合同、实时多人协作、AI 紫粉渐变堆砌 |
| 品牌气质 | **Kawaii Minimal**：柔软圆角、浅色画布、糖果强调色；信息层级清晰，不幼稚到影响「可信/决策」 |
| 与引擎默认的差异 | 引擎常推「房产奢侈 / 手写字体 / Newsletter」——**不采用**。本系统以现有 Kawaii 主题为 Source of Truth，引擎仅作结构、UX 规则与 Flutter 栈约束 |

### 必须避免（Anti-patterns）

- 把 emoji 当导航/系统图标（用 Material Symbols / 统一圆角图标）
- 仅靠 hover 表达可点（移动端以 tap + pressed 态为准）
- 触控目标 &lt; 44×44pt，或相邻目标间距 &lt; 8px
- Placeholder-only 表单标签；提交无 loading / 成功 / 失败反馈
- 破坏系统返回栈；返回后丢失滚动位置/草稿
- 深色模式半吊子（当前 App 为 `ThemeMode.light`；若未来开 dark 必须整套 token 反转并单独测对比度）
- AI 紫粉渐变装饰、过大展示字体（Exaggerated Minimalism 不适合现场工具）
- 安全区（刘海 / 手势条）下被固定底栏遮挡内容

---

## 1. Style direction

| 项 | 选择 | 理由 |
|----|------|------|
| Primary style | **Kawaii Minimal** + Soft UI Evolution（高对比改良） | 已落地 4 套可切换色板；圆角卡片 + 轻阴影 + 清晰层级 |
| Secondary reference | Minimalism / Swiss（信息架构） | 列表密度、表单分区、对比表以功能优先 |
| 不采用 | Neumorphism 全屏粘土、Brutalism、Luxury Real-estate editorial | 户外可读性差或与现网视觉冲突 |
| 图标 | Material Symbols Rounded / `*_rounded` | 与 `KawaiiIconBubble` 一致；禁止 emoji 图标 |
| 动效 | 150–300ms；pressed scale ≈ 0.97；尊重 `reduce motion` | 现场工具：反馈要快，动画不挡操作 |

---

## 2. Color system

### 2.1 Semantic tokens（跨主题稳定）

这些角色在业务 UI 中应优先使用语义名，而不是硬编码业务含义色：

| Role | 用途 | 默认 Hex（草莓奶油基准） | 代码锚点 |
|------|------|--------------------------|----------|
| Background | 画布 | `#FFFAF7` | `AppColors.background` / `KawaiiPalette.background` |
| Background blush | 渐变次色 | `#FFF1F6` | `backgroundBlush` |
| Surface | 卡片/底栏 | `#FFFFFF` | `AppColors.surface` |
| Surface soft | 次级卡片 | `#FFF7FA` | `surfaceSoft` |
| Text primary | 标题/正文 | `#33263B` | `textPrimary` |
| Text secondary | 辅助说明 | `#756A7D` | `textSecondary` |
| Divider / border | 分割线 | `#F0DFE8` | `divider` |
| Primary / CTA | 主操作 | `#FF5C92` | `primary` |
| Primary dark | 按下/强调 | `#E9477D` | `primaryDark` |
| Secondary | 次强调/气泡 | `#8B6CFF` | `secondary` |
| Success / mint | 通过、良好 checklist | `#51C9A6` | `mint` |
| Warning | 费用待补、弱提示 | `#D98937` | `warning` |
| Risk / destructive | blocker、删除 | `#DC5A75` / 删除确认用更高对比红 | `risk` |
| Commute | 通勤相关 | `#4C7DFF` | `commute` |
| Offline | 离线/降级状态 | `#756D7C` | `offline` |
| Sunshine | 标签/高亮点缀 | `#F5C556` | `sunshine` |

### 2.2 Theme presets（用户可选）

与 `AppThemePreset` 对齐，只换画布与主强调色，**不改信息架构**：

| Preset | 标签 | Primary 方向 |
|--------|------|----------------|
| `strawberryCream` | 草莓奶油 | 莓果粉（默认） |
| `grapeSoda` | 葡萄苏打 | 葡萄紫 |
| `mintCloud` | 薄荷云朵 | 薄荷绿 |
| `lemonCream` | 奶油柠檬 | 奶油黄 |

### 2.3 对比度与状态色规则

- 正文 vs 背景 ≥ **4.5:1**；大号标题 ≥ 3:1  
- 功能色（成功/警告/风险）**不得只靠颜色**表达：配图标或文案（如「风险 · 押金不明」）  
- Primary CTA 上的文字用高对比浅色（白或近白）  
- 禁用态：透明度约 0.38–0.5 + 不可点语义，不伪装成可点  
- 户外场景：优先保证字重与对比，避免过浅灰字

### 2.4 ui-ux-pro-max 色板备选（未采用，供对照）

引擎曾推荐 Real Estate Teal `#0F766E`、B2B Navy、CRM Blue 等。若未来做「专业冷静」皮肤，可新增 preset，**不要覆盖**现有 Kawaii 默认体验，除非产品明确改品牌。

---

## 3. Typography

### 3.1 实际方案（Flutter）

| 角色 | 字体 | 说明 |
|------|------|------|
| UI 默认 | **系统字体栈**（Material 3 `textTheme`） | 中文现场工具优先可读与性能；不强制 Google Fonts 下载 |
| 可选增强 | `Plus Jakarta Sans`（拉丁）/ 系统中文 | 若后续引入 `google_fonts`，仅作标题拉丁装饰；正文仍系统优先 |
| 明确不用 | Caveat、Cinzel、手写体、超大展示字 | 引擎误匹配「个人博客 / 奢侈地产」 |

### 3.2 类型阶梯（建议）

| Token | 约等于 | 用途 |
|-------|--------|------|
| display | 28–32 / w700 | 极少用；空状态大标题可 |
| title-lg | 22–24 / w700 | AppBar / 页标题 |
| title-md | 18–20 / w600 | 卡片标题、村名 |
| body | 15–16 / w400 | 正文；行高 1.45–1.6 |
| label | 13–14 / w500 | 表单标签、Tab、chip |
| caption | 12 / w400 | 辅助、时间戳；**正文勿长期用 &lt;12** |

数字（租金、评分、通勤分钟）：优先 **tabular figures** 感（等宽数字或固定列宽），避免列表跳动。

---

## 4. Spacing, radius, elevation, density

**Density dial ≈ 7–8（偏列表/表单信息密度）**，但触控区仍宽松。

| Token | Value | 用途 |
|-------|-------|------|
| `--space-xs` | 4 | 图标与文字微间距 |
| `--space-sm` | 8 | 芯片间距、列表次级 gap |
| `--space-md` | 16 | 卡片内边距、页面水平 gutter |
| `--space-lg` | 24 | 区块间距 |
| `--space-xl` | 32 | 大区块 |
| `--space-2xl` | 48 | 空状态上下留白 |
| 触控最小 | **44×44** | 按钮、列表尾部 icon、checkbox |
| 触控间距 | **≥8** | 相邻可点区域 |
| 圆角 card | 16–20 | 主卡片（Kawaii 软圆） |
| 圆角 button | 12–999 | 主按钮可偏 pill；次按钮 12 |
| 圆角 input | 12 | 与表单控件一致 |
| 圆角 bubble | ~36% of size | `KawaiiIconBubble` |
| elevation card | 轻阴影 / 细边框二选一为主 | 避免厚重多层阴影 |
| z-index 建议 | content &lt; sticky bar &lt; modal &lt; toast | 固定底 CTA 必须给列表 `padding-bottom` |

---

## 5. Motion

| 场景 | 时长 | 说明 |
|------|------|------|
| Pressed | 80–150ms 内出反馈 | scale ~0.97 或 ink；可配轻 haptic |
| 页面切换 | 200–300ms | 不阻塞路由；`go_router` 优先 |
| Skeleton | 脉冲柔和 | 列表加载优先 skeleton，长于 1s 勿只转圈 |
| 禁用 | 尊重系统「减少动态效果」 | 关闭非必要装饰动画 |

**Do：** 动效表达因果（打开 sheet、保存成功）。  
**Don't：** 装饰性无限循环动画、动画期间吞掉点击。

---

## 6. Layout & navigation

### 信息架构（当前产品）

```text
Tab / 根：扫楼（村列表首页） | …其它 Tab（对比 / 设置等以 router 为准）
扫楼 → 村详情 → 楼栋/房源列表 → 快速记录 / 详情 / Checklist / 评分
设置 → 偏好 / 隐私 / 主题色板
```

### 导航规则

- 使用 **go_router** + 类型化路由参数（Flutter stack：typed args，避免 `Map` 动态参数）
- 返回必须可预期；保留滚动位置与未保存草稿策略（长表单考虑草稿自动保存）
- 主 CTA：每屏 **一个** 主操作（如「新增村」「保存房源」）；危险操作视觉分离
- 底部固定操作条：遵守 SafeArea；列表末尾预留 inset
- 空状态：说明 + 主行动（见各 page 文件）

---

## 7. Components（实现约定）

### 7.1 已有组件优先复用

| 组件 | 路径/类 | 用途 |
|------|---------|------|
| 画布渐变 | `KawaiiBackdrop` | 全路由底 |
| 图标气泡 | `KawaiiIconBubble` | 页头/列表点缀 |
| 页头 | `KawaiiPageHeading` | 功能页介绍 |
| 主题 | `buildAppTheme` / `KawaiiPalette` | Material 3 + extension |
| 表单积木 | `features/common/form_widgets.dart` | 字段一致性 |
| 删除确认 | `delete_confirmation.dart` | 破坏性操作 |

### 7.2 通用控件规格

**Primary button**

- 填充 primary；字重 600；最小高度 48；圆角 12–pill  
- 异步：disabled + progress；结束 success/error 文案  

**Secondary button**

- 描边或浅底；不与 Primary 抢对比  

**List row（村 / 房源）**

- 左：标题 + 1 行 meta；右：统计或 chevron  
- `Key: ValueKey(id)` 保状态  
- 整行可点区域 ≥ 44 高  

**Form**

- 可见 label；错误在字段下方  
- 数字/电话用对应 keyboard  
- `Form` + `GlobalKey` 统一校验（Flutter stack）  

**Checklist**

- good / ok / bad / not_seen 四态，色 + 文案/图标  
- 模块分区：room / kitchen / building / contract / risk  

**Score / risk**

- 分数大数字 + 维度条；硬筛未过明确「未通过原因」  
- blocker 用 risk 色 + 不可忽略文案  

**Feedback**

- Toast 3–5s，不抢焦点；`SnackBar` / 等价  
- 删除等破坏操作二次确认  

---

## 8. Flutter stack guidelines（摘自 ui-ux-pro-max + 项目锁定）

| 规则 | Do | Don't |
|------|----|-------|
| 状态 | Riverpod 2.x（`ref.watch` 等经典 API） | Riverpod 3 codegen 风格混入 |
| 路由 | go_router，声明式 | 复杂流里到处 `Navigator.push` 匿名路由 |
| 列表 | `ValueKey` / 稳定 id | 无 key 的动态列表 |
| 无障碍 | `Semantics` / 系统控件语义 | 裸 `GestureDetector` 无 label |
| 表单 | `Form` + 统一校验 | 散落无关联校验 |
| 性能 | 长列表考虑懒加载；先 DevTools 再优化 | 无测量瞎优化 |
| 主题 | 经 `ThemeExtension`/`AppColors` 取色 | 业务页硬编码随机 hex |

---

## 9. UX priority checklist（交付前）

**CRITICAL**

- [ ] 对比度 AA；焦点/语义可读  
- [ ] 触控 ≥44pt，间距 ≥8  
- [ ] 主交互不依赖 hover  
- [ ] 表单有 label；提交有状态反馈  
- [ ] SafeArea；底栏不挡列表  

**HIGH**

- [ ] 空状态有说明 + CTA  
- [ ] 返回栈与草稿策略正确  
- [ ] 离线可完成记录闭环；网络能力失败有降级文案  
- [ ] 图标统一，无 emoji 图标  
- [ ] 加载用 skeleton/明确 progress  

**MEDIUM**

- [ ] 动效 150–300ms；可打断  
- [ ] 数字列对齐；租金/评分不跳动  
- [ ] 错误文案 = 原因 + 如何修  

---

## 10. File map & usage

```text
design-system/foundhouse/
  MASTER.md                 ← 本文件（全局 Source of Truth）
  pages/
    scan-list.md            ← 扫楼首页（村列表）
    quick-record.md         ← 快速记录
    house-detail.md         ← 房源详情 / 评分
    compare.md              ← 对比与导出
```

**给实现 Agent 的检索提示：**

```text
我在实现 [页面名]。请先读 design-system/foundhouse/pages/[page].md（若存在），
再读 design-system/foundhouse/MASTER.md。页面规则优先。
视觉与色板以 found-house-app/lib/app/theme.dart 与 kawaii_widgets.dart 为准。
主流程以 PRD v1.1：村列表扫楼，非地图首页。
```

---

## 11. Changelog

| 日期 | 说明 |
|------|------|
| 2026-07-11 | 用 ui-ux-pro-max 生成初稿；因引擎误匹配落地页/奢侈地产/手写字体，按 PRD + 现有 Kawaii 实现重写为产品向 Master，并补充 Flutter/现场扫楼约束 |
