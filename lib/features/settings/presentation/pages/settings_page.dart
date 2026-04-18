import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notiEnabled = true;
  bool _darkTheme = false;
  bool _monthlyReport = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: 'CHIẾN LƯỢC TRẢ NỢ',
              children: [
                _buildListTile(
                  title: 'Chiến lược hiện tại',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Snowball', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant)),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.mdOnSurfaceVariant),
                    ],
                  ),
                  onTap: () {},
                ),
                _buildDivider(),
                _buildListTile(
                  title: 'Trả thêm hàng tháng',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\$250', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant, fontFamily: 'Roboto Mono')),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.mdOnSurfaceVariant),
                    ],
                  ),
                  onTap: () {},
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildSection(
              title: 'NHẮC NHỞ',
              children: [
                _buildSwitchTile(
                  title: 'Nhắc nhở thanh toán',
                  value: _notiEnabled,
                  onChanged: (v) => setState(() => _notiEnabled = v),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: 'Báo cáo hàng tháng',
                  value: _monthlyReport,
                  onChanged: (v) => setState(() => _monthlyReport = v),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildSection(
              title: 'TUỲ CHỌN',
              children: [
                _buildListTile(
                  title: 'Loại tiền tệ',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('USD (\$)', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant)),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.mdOnSurfaceVariant),
                    ],
                  ),
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: 'Giao diện tối (Dark Mode)',
                  value: _darkTheme,
                  onChanged: (v) => setState(() => _darkTheme = v),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildSection(
              title: 'DỮ LIỆU',
              children: [
                _buildListTile(
                  title: 'Đồng bộ & Sao lưu',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Chưa đồng bộ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdError)),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.mdOnSurfaceVariant),
                    ],
                  ),
                  onTap: () {},
                ),
                _buildDivider(),
                _buildListTile(
                  title: 'Xuất dữ liệu (CSV)',
                  trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.mdOnSurfaceVariant),
                  onTap: () {},
                ),
                _buildDivider(),
                _buildListTile(
                  title: 'Xóa toàn bộ dữ liệu',
                  titleColor: AppColors.mdError,
                  trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.mdError),
                  onTap: () {},
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // App info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Phiên bản 1.0.0 (MVP)', style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant)),
                  Text('© 2026 Debt Payoff', style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant)),
                ],
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: AppColors.mdPrimary,
            ),
          ),
        ),
        Container(
          color: AppColors.mdSurface,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required String title,
    required Widget trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.bodyLarge.copyWith(color: titleColor ?? AppColors.mdOnSurface)),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.bodyLarge),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.mdPrimary,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: AppColors.mdOutlineVariant);
  }
}
