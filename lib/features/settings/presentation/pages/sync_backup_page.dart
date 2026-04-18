import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SyncBackupPage extends StatelessWidget {
  const SyncBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mdSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: AppColors.mdOnSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.mdPrimaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.cloud, size: 48, color: AppColors.mdPrimary),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Mở khoá Sao lưu', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 12),
                Text(
                  'Bảo vệ dữ liệu và đồng bộ tức thì trên thiết bị của bạn. Nâng cấp an toàn lên Trust Level 1.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Benefits
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                _buildBenefitItem(
                  LucideIcons.shieldCheck,
                  'Mã hoá an toàn',
                  'Chỉ bạn mới có quyền xem kế hoạch.',
                ),
                const SizedBox(height: 20),
                _buildBenefitItem(
                  LucideIcons.smartphone,
                  'Đồng bộ đa thiết bị',
                  'Chuyển điện thoại không sợ mất data.',
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Auth CTA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAuthBtn(
                  icon: LucideIcons.apple,
                  label: 'Tiếp tục với Apple',
                  bgColor: Colors.black,
                  textColor: Colors.white,
                  borderColor: Colors.black,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildAuthBtn(
                  icon: LucideIcons.mail,
                  label: 'Tiếp tục với Google',
                  bgColor: Colors.white,
                  textColor: Colors.black,
                  borderColor: AppColors.mdOutlineVariant,
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Text(
                      'Bỏ qua & Dùng thiết bị',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.mdOnSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: AppColors.mdPrimary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleSmall),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthBtn({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
