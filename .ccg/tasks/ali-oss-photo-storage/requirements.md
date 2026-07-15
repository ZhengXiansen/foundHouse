# Requirements — Ali OSS photo upload/display

## User objective
将「拍照」和「相册」选项产生的照片改为阿里云 OSS 存储；上传成功后，照片可直接在按钮下方显示；先调研实现方式，制定方案与执行计划，并完成开发。

## Functional requirements
1. QuickRecord 页的拍照与相册入口都必须走同一套照片处理流程。
2. 当房源已经创建后，用户选择/拍摄照片时：
   - 先保存一份端侧本地缓存，保留离线/旧数据兼容能力；
   - 通过 BFF 获取 OSS 表单上传签名；
   - 直接从 App 上传图片文件到 OSS；
   - 上传成功后写入 `photo_asset` 元信息，包含本地缓存路径与 OSS 远程元信息；
   - 成功后立即在「拍照/相册」按钮下方显示缩略图。
3. 当 QuickRecord 尚未创建房源时，照片不能生成最终 OSS 对象归属；先本地暂存/显示本地预览，保存房源后再批量上传并写入 OSS 元信息。
4. 上传服务未配置或上传失败时必须给用户可读错误，不能静默丢失；未配置不能默认访问 localhost。
5. 既有本地照片必须继续可读；新增远程字段不能破坏旧行。
6. BFF 不能把阿里云长期 AccessKey Secret 传给 App；App 不能内置长期 OSS 凭据。
7. BFF 必须自己生成对象 key，限制 owner/tag/content-type/大小，不能接受客户端指定任意 OSS 路径。
8. 数据库 schemaVersion 升级必须有迁移回归测试，验证旧 `photo_asset` 行默认 `storage_provider='local'`，远程字段为空。
9. 文档/隐私文案必须不再承诺照片只存本机；README/字段字典需说明 OSS 配置和字段。

## Non-functional / security requirements
- 使用 `--dart-define=FOUND_HOUSE_OSS_SIGNER_URL=https://.../api/photos/upload-intent` 配置 App 签名接口。
- 若 `FOUND_HOUSE_OSS_SIGNER_URL` 为空，provider 返回 Offline uploader，抛出稳定 code：`OSS_PHOTO_UPLOAD_NOT_CONFIGURED`。
- 上传对象 key 使用服务端随机 UUID，路径限定为 `photos/<ownerType>/<ownerId>/...`。
- 表单 policy 设置过期时间、key 前缀、content-length-range、允许图片 MIME。
- BFF 响应不得包含 `ALI_OSS_ACCESS_KEY_SECRET`。
- 删除照片元信息不在本任务中删除远程 OSS 对象，避免误删；本地缓存删除保持原行为。

## Verification requirements
- Flutter：RED/GREEN 覆盖 uploader 未配置、OSS 上传成功、repository 远程元信息、v2→v3 迁移、QuickRecord 下方预览组件。
- BFF：RED/GREEN 覆盖 `/api/photos/upload-intent` 缺配置、校验失败、成功响应与不泄露 secret。
- 运行 `dart run build_runner build --delete-conflicting-outputs`，`flutter analyze`，相关/全量 Flutter tests。
- 运行 BFF `npm test`、`npm run build`、`npm run lint`。
- Android release build/install 属发布审计要求；若设备/环境可用，最后重新安装 release APK。

## CCG limitation
CCG 要求 L+ 任务进行 antigravity + Claude 双模型分析/审查；本机 `~/.claude/bin/codeagent-wrapper` 不存在，无法执行该外部双模型流程。该限制已记录在 `external-wrapper-check.txt`；本任务继续使用本地源码审查、测试与构建证据替代，但在 review 中必须明确说明。
