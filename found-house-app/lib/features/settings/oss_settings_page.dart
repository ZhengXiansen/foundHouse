import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/providers.dart';
import '../../integrations/oss/oss_config.dart';

/// OSS 云存储设置页（端侧直配密钥模式）。
///
/// 职责边界：读写用户本地保存的 [OssConfig]——启用开关、endpoint/bucket/
/// accessKeyId/accessKeySecret 及可选自定义域名、路径前缀。保存后经
/// [ossConfigStoreProvider] 落平台安全存储。上传逻辑不在此页，见
/// AliyunOssDirectUploader；本页仅负责配置录入与持久化。
///
/// 安全提示：AccessKeySecret 驻留本机安全存储，建议使用最小权限 RAM 子账号。
class OssSettingsPage extends ConsumerStatefulWidget {
  const OssSettingsPage({super.key});

  @override
  ConsumerState<OssSettingsPage> createState() => _OssSettingsPageState();
}

class _OssSettingsPageState extends ConsumerState<OssSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _endpointCtrl = TextEditingController();
  final _bucketCtrl = TextEditingController();
  final _accessKeyIdCtrl = TextEditingController();
  final _accessKeySecretCtrl = TextEditingController();
  final _customDomainCtrl = TextEditingController();
  final _pathPrefixCtrl = TextEditingController();

  bool _enabled = false;
  bool _obscureSecret = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _endpointCtrl.dispose();
    _bucketCtrl.dispose();
    _accessKeyIdCtrl.dispose();
    _accessKeySecretCtrl.dispose();
    _customDomainCtrl.dispose();
    _pathPrefixCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final config = await ref.read(ossConfigStoreProvider).load();
    if (!mounted) return;
    setState(() {
      _enabled = config.enabled;
      _endpointCtrl.text = config.endpoint;
      _bucketCtrl.text = config.bucket;
      _accessKeyIdCtrl.text = config.accessKeyId;
      _accessKeySecretCtrl.text = config.accessKeySecret;
      _customDomainCtrl.text = config.customDomain;
      _pathPrefixCtrl.text = config.pathPrefix;
      _loading = false;
    });
  }

  OssConfig _currentConfig() => OssConfig(
        enabled: _enabled,
        endpoint: _endpointCtrl.text.trim(),
        bucket: _bucketCtrl.text.trim(),
        accessKeyId: _accessKeyIdCtrl.text.trim(),
        accessKeySecret: _accessKeySecretCtrl.text.trim(),
        customDomain: _customDomainCtrl.text.trim(),
        pathPrefix: _pathPrefixCtrl.text.trim(),
      );

  Future<void> _save() async {
    final config = _currentConfig();
    // 仅在“启用”时强制必填校验；关闭时允许保存半成品配置草稿。
    if (config.enabled && !config.isComplete) {
      _showSnack(
        '启用 OSS 需填全 Endpoint、Bucket、AccessKeyId、AccessKeySecret。',
        isError: true,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(ossConfigStoreProvider).save(config);
      if (!mounted) return;
      _showSnack(config.isActive ? 'OSS 已启用，新照片将上传云端。' : '配置已保存。');
    } catch (_) {
      if (!mounted) return;
      _showSnack('保存失败，请重试。', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OSS 云存储')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.cloud_upload_outlined),
                    title: const Text('启用 OSS 上传'),
                    subtitle: const Text('开启后，新拍照片在本地留存的同时直传到你的 OSS。'),
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                  const Divider(height: 1),
                  _sectionHeader(context, '连接配置'),
                  _field(
                    controller: _endpointCtrl,
                    label: 'Endpoint',
                    hint: 'oss-cn-shenzhen.aliyuncs.com',
                    keyboardType: TextInputType.url,
                  ),
                  _field(
                    controller: _bucketCtrl,
                    label: 'Bucket',
                    hint: 'my-found-house',
                  ),
                  _field(
                    controller: _accessKeyIdCtrl,
                    label: 'AccessKeyId',
                    hint: 'LTAI...',
                  ),
                  _field(
                    controller: _accessKeySecretCtrl,
                    label: 'AccessKeySecret',
                    hint: '仅存本机安全存储',
                    obscureText: _obscureSecret,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureSecret
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureSecret = !_obscureSecret),
                    ),
                  ),
                  _sectionHeader(context, '可选'),
                  _field(
                    controller: _customDomainCtrl,
                    label: '自定义域名（CDN）',
                    hint: 'cdn.example.com',
                    keyboardType: TextInputType.url,
                  ),
                  _field(
                    controller: _pathPrefixCtrl,
                    label: '路径前缀',
                    hint: 'photos/',
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'AccessKeySecret 仅保存在本机安全存储（Keychain / Keystore），'
                      '不随导出或云同步外发。建议使用仅具备该 Bucket 写权限的 RAM 子账号。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(_saving ? '保存中…' : '保存'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
