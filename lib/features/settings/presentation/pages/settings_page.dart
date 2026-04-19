import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/models/backup_bundle_preview.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/backup_file_picker.dart';
import '../../../../core/services/data_management_service.dart';
import '../../../../core/services/share_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/user_settings.dart';
import '../../../../domain/repositories/plan_repository.dart';
import '../../../../domain/repositories/settings_repository.dart';

enum _SettingsDataAction { csvExport, localBackup, restoreBackup, clearAll }

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsRepository _settingsRepository =
      getIt<SettingsRepository>();
  late final PlanRepository _planRepository = getIt<PlanRepository>();
  late final BackupFilePicker _backupFilePicker = getIt<BackupFilePicker>();
  late final DataManagementService _dataManagementService =
      getIt<DataManagementService>();
  late final ShareLauncher _shareLauncher = getIt<ShareLauncher>();

  _SettingsDataAction? _pendingAction;

  bool get _isDataActionPending => _pendingAction != null;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserSettings>(
      stream: _settingsRepository.watchSettings(),
      builder: (context, settingsSnapshot) {
        final settings = settingsSnapshot.data;
        if (settings == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return StreamBuilder(
          stream: _planRepository.watchCurrentPlan(),
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
                        _buildDataStatusBanner(settings),
                        _buildDivider(),
                        _buildListTile(
                          key: AppTestKeys.settingsCloudBackup,
                          title: 'Sao lưu đám mây',
                          subtitle: _trustLevelCopy(settings.trustLevel),
                          trailingText: settings.trustLevel == 0
                              ? 'Local only'
                              : 'Trust ${settings.trustLevel}',
                          enabled: !_isDataActionPending,
                          onTap: () => context.push(AppRoutes.syncBackup),
                        ),
                        _buildDivider(),
                        _buildListTile(
                          key: AppTestKeys.settingsDataExportCsv,
                          title: 'Xuất dữ liệu (CSV)',
                          subtitle:
                              'ZIP gồm nhiều file CSV + manifest để bạn tự kiểm tra từng bảng.',
                          trailingText: 'ZIP',
                          enabled: !_isDataActionPending,
                          isLoading:
                              _pendingAction == _SettingsDataAction.csvExport,
                          onTap: _isDataActionPending ? null : _exportCsv,
                        ),
                        _buildDivider(),
                        _buildListTile(
                          key: AppTestKeys.settingsDataLocalBackup,
                          title: 'Sao lưu cục bộ',
                          subtitle:
                              'Tạo JSON backup ZIP đầy đủ để lưu sang Files, Drive hoặc ổ đĩa ngoài.',
                          trailingText: 'ZIP',
                          enabled: !_isDataActionPending,
                          isLoading:
                              _pendingAction == _SettingsDataAction.localBackup,
                          onTap: _isDataActionPending
                              ? null
                              : _createLocalBackup,
                        ),
                        _buildDivider(),
                        _buildListTile(
                          key: AppTestKeys.settingsDataRestoreBackup,
                          title: 'Khôi phục từ bản sao lưu',
                          subtitle:
                              'Đọc preview manifest và số bản ghi trước khi thay thế dữ liệu local.',
                          trailingText: 'Restore',
                          enabled: !_isDataActionPending,
                          isLoading:
                              _pendingAction ==
                              _SettingsDataAction.restoreBackup,
                          onTap: _isDataActionPending
                              ? null
                              : _restoreFromBackup,
                        ),
                        _buildDivider(),
                        _buildListTile(
                          key: AppTestKeys.settingsDataClearAll,
                          title: 'Xóa toàn bộ dữ liệu',
                          subtitle:
                              'Chỉ reset dữ liệu trên thiết bị này. Cloud chưa bật ở Level 0.',
                          trailingText: 'Reset',
                          titleColor: AppColors.mdError,
                          trailingColor: AppColors.mdError,
                          enabled: !_isDataActionPending,
                          isLoading:
                              _pendingAction == _SettingsDataAction.clearAll,
                          onTap: _isDataActionPending ? null : _confirmClearAll,
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

  Future<void> _updateSettings(UserSettings settings) {
    return _settingsRepository.updateSettings(settings);
  }

  Future<void> _exportCsv() async {
    await _runDataAction(_SettingsDataAction.csvExport, () async {
      final artifact = await _dataManagementService.generateCsvExportBundle();
      await _shareLauncher.shareArtifact(artifact);
    });
  }

  Future<void> _createLocalBackup() async {
    await _runDataAction(_SettingsDataAction.localBackup, () async {
      final artifact = await _dataManagementService.generateLocalBackupBundle();
      await _shareLauncher.shareArtifact(artifact);
    });
  }

  Future<void> _restoreFromBackup() async {
    await _runDataAction(_SettingsDataAction.restoreBackup, () async {
      final picked = await _backupFilePicker.pickBackupBundle();
      if (picked == null) {
        return;
      }

      final preview = await _dataManagementService.inspectLocalBackupBundle(
        filePath: picked.path,
        fileName: picked.fileName,
      );
      if (!mounted) {
        return;
      }

      final confirmed = await _confirmRestore(preview);
      if (confirmed != true || !mounted) {
        return;
      }

      await _dataManagementService.restoreFromLocalBackup(
        filePath: preview.path,
        fileName: preview.fileName,
      );
      if (mounted) {
        context.showSnackBar(
          'Đã khôi phục dữ liệu local từ bản sao lưu đã chọn.',
        );
      }
    });
  }

  Future<bool?> _confirmRestore(BackupBundlePreview preview) {
    final rowCounts = preview.tableRowCounts.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Khôi phục từ bản sao lưu?'),
          content: SingleChildScrollView(
            child: Text(
              'File: ${preview.fileName}\n'
              'Xuất lúc: ${_formatPreviewTimestamp(preview.exportedAtUtc)}\n'
              'Tổng bản ghi: ${preview.totalRows}\n\n'
              'Dữ liệu trong backup:\n'
              '$rowCounts\n\n'
              'Toàn bộ dữ liệu local hiện tại sẽ bị thay thế.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              key: AppTestKeys.settingsDataRestoreConfirm,
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Khôi phục'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmClearAll() async {
    final confirmedStepOne = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa toàn bộ dữ liệu?'),
          content: const Text(
            'Thao tác này sẽ xóa toàn bộ dữ liệu local và đưa app về trạng thái lần đầu mở.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              key: AppTestKeys.settingsDataClearAllConfirmOne,
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Tiếp tục'),
            ),
          ],
        );
      },
    );

    if (confirmedStepOne != true || !mounted) {
      return;
    }

    final confirmedStepTwo = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận lần cuối'),
          content: const Text(
            'Bạn sẽ mất toàn bộ debts, payments, milestones và backup local hiện tại trong app này.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Quay lại'),
            ),
            FilledButton(
              key: AppTestKeys.settingsDataClearAllConfirmTwo,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.mdError,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Xóa sạch'),
            ),
          ],
        );
      },
    );

    if (confirmedStepTwo != true) {
      return;
    }

    await _runDataAction(_SettingsDataAction.clearAll, () async {
      await _dataManagementService.clearAllData();
    });
  }

  Future<void> _runDataAction(
    _SettingsDataAction action,
    Future<void> Function() operation,
  ) async {
    if (_pendingAction != null) {
      return;
    }

    setState(() => _pendingAction = action);
    try {
      await operation();
    } catch (error) {
      if (mounted) {
        context.showSnackBar(_errorMessageFor(error), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _pendingAction = null);
      }
    }
  }

  String _errorMessageFor(Object error) {
    const prefixes = ['Exception: ', 'Bad state: ', 'Invalid argument(s): '];
    var message = error.toString();
    for (final prefix in prefixes) {
      if (message.startsWith(prefix)) {
        message = message.substring(prefix.length);
      }
    }
    return message;
  }

  String _trustLevelCopy(int trustLevel) {
    switch (trustLevel) {
      case 1:
        return 'Cloud backup cơ bản đã bật. Local export vẫn luôn khả dụng.';
      case 2:
        return 'Đang dùng trust mode cao hơn. Hãy kiểm tra quyền chia sẻ trước khi reset local.';
      case 0:
      default:
        return 'Hiện tại bạn đang ở local-only. Cloud backup là roadmap tiếp theo, không phải yêu cầu để dùng app.';
    }
  }

  String _formatPreviewTimestamp(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString().padLeft(4, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
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

  Widget _buildDataStatusBanner(UserSettings settings) {
    final isLocalOnly = settings.trustLevel == 0;
    final icon = isLocalOnly ? LucideIcons.shieldCheck : LucideIcons.cloud;
    final title = isLocalOnly
        ? 'Local-first đang bật'
        : 'Trust mode nâng cao đang bật';
    final body = isLocalOnly
        ? 'Dữ liệu hiện nằm trên thiết bị này. Bạn luôn có CSV export, local backup/restore và clear all mà không cần tài khoản hoặc bank linking.'
        : 'Bạn đang ở trust level > 0. Local export vẫn còn, nhưng các thao tác reset cần cẩn thận hơn vì có thể liên quan tới cloud semantics.';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical: AppDimensions.lg,
      ),
      color: AppColors.mdPrimaryContainer.withValues(alpha: 0.55),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.mdPrimary, size: AppDimensions.iconMd),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.mdOnPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  body,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mdOnPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    Key? key,
    required String title,
    String? subtitle,
    String? trailingText,
    Color? titleColor,
    Color? trailingColor,
    bool enabled = true,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    final canTap = enabled && onTap != null && !isLoading;
    final effectiveTitleColor =
        titleColor ??
        (enabled ? AppColors.mdOnSurface : AppColors.mdOnSurfaceVariant);
    final effectiveTrailingColor =
        trailingColor ??
        (enabled ? AppColors.mdOnSurfaceVariant : AppColors.mdOutlineVariant);

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
                    color: effectiveTitleColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: enabled
                          ? AppColors.mdOnSurfaceVariant
                          : AppColors.mdOutlineVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: AppDimensions.md),
            child: isLoading
                ? const SizedBox(
                    width: AppDimensions.iconMd,
                    height: AppDimensions.iconMd,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (trailingText != null)
                        Text(
                          trailingText,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: effectiveTrailingColor,
                            fontFamily: 'Roboto Mono',
                          ),
                        ),
                      if (canTap) ...[
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

    if (!canTap) {
      return KeyedSubtree(key: key, child: content);
    }

    return InkWell(key: key, onTap: onTap, child: content);
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
