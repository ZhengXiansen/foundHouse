# 本地自配置 OSS + 启用开关

## 目标
在 app 内本地自行配置阿里云 OSS(端侧直配密钥,无后端),提供启用开关。
启用且配置完整 → 照片直传 OSS;否则纯本地存储(现有回退语义不变)。

## 架构决策(已与用户确认)
- 模式:端侧直配密钥 + 阿里云 OSS PostObject 直传(本地生成 policy + HMAC-SHA1 签名)。
- 凭据存储:`AccessKeySecret` 等配置整体存 `flutter_secure_storage`(复用 `KeyStore` 抽象),不入 Drift,免迁移。
- 开关即时生效:上传器每次上传时惰性读配置,未启用/不完整则抛
  `OSS_PHOTO_UPLOAD_NOT_CONFIGURED`。`tryUploadPhotoAsset` 已吞该异常回退本地,
  故 `photoUploaderProvider` 保持同步单例,无需重建 provider 链。

## 变更清单
1. `pubspec.yaml`:`crypto` 由传递依赖提升为直接依赖(HMAC-SHA1)。
2. 新增 `lib/integrations/oss/oss_config.dart`:`OssConfig` 模型 + `OssConfigStore`
   (基于 `KeyStore`,JSON 序列化,含 `isComplete`/`isActive` 判定)。
3. 新增 `lib/integrations/oss/aliyun_oss_uploader.dart`:`AliyunOssDirectUploader
   implements PhotoUploader`,惰性读配置、本地签名、PostObject 直传。
4. `lib/integrations/oss/oss_photo_uploader.dart`:抽出 `buildOssMultipartBody`
   顶层函数供两个上传器复用(DRY);旧 `OssPhotoUploader` 行为不变。
5. `lib/data/providers.dart`:新增 `ossConfigStoreProvider`;重写
   `photoUploaderProvider` 返回 `AliyunOssDirectUploader`(自检配置)。
6. 新增 `lib/features/settings/oss_settings_page.dart`:表单 + 启用开关 + 保存。
7. `lib/app/router.dart`:注册 `oss` 二级路由与 name。
8. `lib/features/settings/settings_page.dart`:「隐私与数据」组下加入口。

## 测试
- `test/integrations/oss/oss_config_store_test.dart`:存取往返、isActive 判定。
- `test/integrations/oss/aliyun_oss_uploader_test.dart`:未启用抛 not-configured;
  启用时对本地 mock OSS 发出含 key/policy/Signature/file 的 PostObject。

## 不做范围
- 不改后端 signer 方案(`OssPhotoUploader` 保留,不再被 provider 装配)。
- 不做批量补传历史照片、不做云端删除同步(超出本次开关范围)。
