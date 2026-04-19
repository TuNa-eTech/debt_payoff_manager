import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/user_settings.dart';
import '../../../../domain/repositories/plan_repository.dart';
import '../../../../domain/repositories/settings_repository.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsRepository = getIt.get<SettingsRepository>();
    final planRepository = getIt.get<PlanRepository>();

    return StreamBuilder<UserSettings>(
      stream: settingsRepository.watchSettings(),
      builder: (context, settingsSnapshot) {
        final settings = settingsSnapshot.data;
        if (settings == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return StreamBuilder(
          stream: planRepository.watchCurrentPlan(),
          builder: (context, planSnapshot) {
            final plan = planSnapshot.data;

            return Scaffold(
              appBar: AppBar(title: const Text('Cài đặt')),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSection(
                      title: 'KẾ HOẠCH TRẢ NỢ',
                      children: [
                        _buildListTile(
                          title: 'Chiến lược hiện tại',
                          subtitle:
                              'Mở tab Kế hoạch để xem thứ tự ưu tiên chi tiết.',
                          trailingText: plan?.strategy.label ?? 'Snowball',
                          onTap: () => context.go(AppRoutes.plan),
                        ),
                        _buildDivider(),
                        _buildListTile(
                          title: 'Trả thêm hàng tháng',
                          subtitle: 'Đang lưu trong kế hoạch chính của bạn.',
                          trailingText:
                              '\$${((plan?.extraMonthlyAmount ?? 0) / 100).toStringAsFixed(2)}',
                          onTap: () => context.go(AppRoutes.plan),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _buildSection(
                      title: 'NHẮC NHỞ',
                      children: [
                        _buildSwitchTile(
                          title: 'Nhắc nhở thanh toán',
                          subtitle:
                              'App sẽ dùng cài đặt này khi payment reminders được bật.',
                          value: settings.notifPaymentReminder,
                          onChanged: (value) => _updateSettings(
                            settingsRepository,
                            settings.copyWith(notifPaymentReminder: value),
                          ),
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          title: 'Nhật ký hàng tháng',
                          subtitle:
                              'Dùng cho monthly log summary khi flow này được mở.',
                          value: settings.notifMonthlyLog,
                          onChanged: (value) => _updateSettings(
                            settingsRepository,
                            settings.copyWith(notifMonthlyLog: value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _buildSection(
                      title: 'TUỲ CHỌN',
                      children: [
                        _buildListTile(
                          title: 'Loại tiền tệ',
                          subtitle: 'Hiện tại chỉ dùng cho format hiển thị.',
                          trailingText: settings.currencyCode,
                        ),
                        _buildDivider(),
                        _buildListTile(
                          title: 'Locale',
                          subtitle:
                              'Ảnh hưởng tới format ngày và ngôn ngữ hiển thị.',
                          trailingText: settings.localeCode,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _buildSection(
                      title: 'DỮ LIỆU',
                      children: [
                        _buildListTile(
                          title: 'Đồng bộ & Sao lưu',
                          subtitle: _trustLevelCopy(settings.trustLevel),
                          trailingText: settings.trustLevel == 0
                              ? 'Local only'
                              : 'Trust ${settings.trustLevel}',
                          onTap: () => context.push(AppRoutes.syncBackup),
                        ),
                        _buildDivider(),
                        _buildListTile(
                          title: 'Xuất dữ liệu (CSV)',
                          subtitle: 'Chưa mở ở bản hiện tại.',
                          trailingText: 'Sắp có',
                        ),
                        _buildDivider(),
                        _buildListTile(
                          title: 'Xóa toàn bộ dữ liệu',
                          subtitle: 'Chưa mở ở bản hiện tại.',
                          trailingText: 'Sắp có',
                          titleColor: AppColors.mdError,
                          trailingColor: AppColors.mdError,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.pagePaddingH,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Phiên bản 1.0.0 (MVP)',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mdOnSurfaceVariant,
                            ),
                          ),
                          Text(
                            '© 2026 Debt Payoff',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mdOnSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateSettings(
    SettingsRepository repository,
    UserSettings settings,
  ) {
    return repository.updateSettings(settings);
  }

  String _trustLevelCopy(int trustLevel) {
    switch (trustLevel) {
      case 1:
        return 'Đã nâng lên cloud backup cơ bản.';
      case 2:
        return 'Đang dùng mức trust cao hơn cho chia sẻ hoặc sync nâng cao.';
      case 0:
      default:
        return 'Dữ liệu hiện đang lưu local trên thiết bị.';
    }
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.sm,
          ),
          child: Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.mdPrimary,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          color: AppColors.mdSurface,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    String? trailingText,
    Color? titleColor,
    Color? trailingColor,
    VoidCallback? onTap,
  }) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical: AppDimensions.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: titleColor ?? AppColors.mdOnSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mdOnSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(left: AppDimensions.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trailingText,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: trailingColor ?? AppColors.mdOnSurfaceVariant,
                      fontFamily: 'Roboto Mono',
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: AppDimensions.sm),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: AppDimensions.iconMd,
                      color: AppColors.mdOnSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(onTap: onTap, child: content);
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.mdPrimary,
      activeTrackColor: AppColors.mdPrimaryContainer,
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.mdOnSurfaceVariant,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
      ),
      color: AppColors.mdOutlineVariant,
    );
  }
}
