# Requirements

用户要求：分析项目代码，说明下一步如何编译、打包、测试，以及还需要用户手动配置的地方。

## Scope

- 根目录项目结构与模块状态。
- Flutter 移动端 `found-house-app` 的依赖、代码生成、静态检查、单测、打包前置条件。
- Node/Fastify BFF `found-house-bff` 的依赖、构建、测试、运行环境变量。
- 本机实际执行验证并记录阻塞项。

## Non-goals

- 不修改业务代码。
- 不生成 Flutter 平台工程，需用户先确认 `--org` / 包名。
- 不写入真实高德 Key、数据库连接串或 Redis 地址。
