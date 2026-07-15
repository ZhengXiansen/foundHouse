# 上传 GitHub 需求

## 目标

将当前 `foundHouse` 工作区作为一个完整的单仓库项目上传到 `https://github.com/ZhengXiansen/foundHouse.git` 的 `main` 分支。

## 范围

- 保留远程仓库现有 `LICENSE` 与已有提交历史。
- 纳入 Flutter 应用、Node.js BFF、设计稿、文档、图片资产、项目级 AI/CCG 配置与任务记录。
- 将 `found-house-app` 当前空历史的嵌套 Git 元数据移出工作区，使其源码作为根仓库普通目录被跟踪。
- 排除依赖、构建产物、缓存、IDE 文件、环境变量文件、签名文件与常见密钥文件。

## 验收标准

- 根目录初始化为 Git 仓库，分支为 `main`，远程 `origin` 指向指定地址。
- `git status` 不包含 `node_modules`、`dist`、`build`、`.dart_tool`、Gradle 缓存或密钥文件。
- GitHub 远程保留原 `LICENSE`，并能看到项目源码。
- BFF 测试/构建与 Flutter 静态检查/测试按本机条件执行并记录结果。
- 当前 CCG 任务完成后归档并推送。
