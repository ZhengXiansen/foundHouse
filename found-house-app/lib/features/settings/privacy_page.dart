import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// 隐私设置页（W5 · H1/H2，UI §5.11，技术方案 §10.2）。
///
/// 职责边界：向用户说明本地优先与默认脱敏策略，展示导出脱敏默认项。
/// MVP 阶段这些默认项为固定策略（导出层强制执行，见 ExportSanitizer），
/// 此页以只读说明为主，避免给用户「可关闭脱敏」的误导入口；W5 接入
/// CryptoService 后再开放加密状态展示与可配置项。
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('隐私设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _sectionHeader(context, '数据存储'),
          const _InfoTile(
            icon: Icons.phone_iphone,
            title: '本地优先',
            subtitle: '房源、照片、联系人默认只存本机，不上传云端。',
          ),
          const _InfoTile(
            icon: Icons.lock_outline,
            title: '敏感字段加密',
            subtitle: '电话、微信、门牌以密文存储（AES-256-GCM）。',
          ),
          const Divider(height: 24),
          _sectionHeader(context, '导出脱敏（默认开启）'),
          const _InfoTile(
            icon: Icons.contact_phone_outlined,
            title: '隐藏联系人',
            subtitle: '导出时默认隐藏姓名、电话、微信。',
          ),
          const _InfoTile(
            icon: Icons.home_outlined,
            title: '隐藏门牌',
            subtitle: '导出时默认隐藏精确门牌号。',
          ),
          const _InfoTile(
            icon: Icons.visibility_off_outlined,
            title: '隐藏详细地址',
            subtitle: '导出时默认隐藏详细地址与照片元数据。',
          ),
          const _InfoTile(
            icon: Icons.description_outlined,
            title: '合同照片',
            subtitle: '导出默认不包含合同照片。',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '以上脱敏项在导出时强制执行，用于避免个人敏感信息随分享外泄。'
              '风险提示仅为建议，不构成法律结论。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// 只读说明条目。
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: Text(subtitle),
      dense: false,
    );
  }
}
