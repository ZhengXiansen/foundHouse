# 需求：完善 Git 忽略规则并排除非代码本地文件

## 目标

- 保留项目源代码、测试、构建/依赖清单、必要配置、许可证和产品设计资产。
- 忽略本机 AI/Agent 工具配置、编辑器/系统文件、缓存、日志、构建产物、密钥和其他可重新生成的文件。
- 对已经被 Git 跟踪且新规则命中的文件，仅从 Git 索引移除，保留本地文件。

## 保留范围

- `found-house-app/`：Flutter 源码、测试、平台工程、`pubspec.yaml`、`pubspec.lock`。
- `found-house-bff/`：TypeScript 源码、测试、`package.json`、`package-lock.json`、必要配置。
- `design-system/`、`prototypes/`：可执行 HTML/CSS/原型代码与项目设计实现。
- `DESIGN.md`：产品设计说明。
- `CLAUDE.md`、`skills-lock.json`：项目协作说明与本地工具安装的可复现清单。
- `LICENSE`、`.gitignore`。
- `.ccg/spec/`，以及任务的 `task.json`、`requirements.md`、`plan.md`、`review.md`、`context.jsonl` 等持久化治理元数据。

## 忽略范围

- 根目录本地 AI/Agent 状态与安装副本：`.ace-tool/`、`.aeroric/`、`.agents/`、`.claude/`、`.impeccable.md`。
- OS、IDE、日志、临时文件、环境变量、凭据、证书和签名材料。
- Node/TypeScript、Flutter/Dart、Android/native、Apple 平台、Python 的依赖缓存与生成产物。
- `img/` 与 `found-house-app/.screenshots/`：集成测试可重新生成的设备截图。
- `.ccg/tasks/` 中除持久化治理元数据以外的模型输出、研究抓取、日志、设备转储、截图、临时脚本和验证证据。

## 安全约束

- 不使用 `git rm -r --cached .`。
- 只对新增忽略规则明确命中的已跟踪路径执行索引移除。
- 不删除本地文件，不 force push。
- 完成前使用 `git check-ignore`、`git ls-files -ci --exclude-standard`、`git diff --cached --stat` 和 `git status` 验证。
