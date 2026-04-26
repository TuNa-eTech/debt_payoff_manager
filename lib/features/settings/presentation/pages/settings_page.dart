import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/app_locale_picker_sheet.dart';
import '../../../../core/models/backup_bundle_preview.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/backup_file_picker.dart';
import '../../../../core/services/data_management_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/reminder_scheduler_service.dart';
import '../../../../core/services/share_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../domain/entities/user_settings.dart';
import '../../../../domain/enums/strategy.dart';
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
  late final _planStream = _planRepository.watchCurrentPlan();

  _SettingsDataAction? _pendingAction;

  bool get _isDataActionPending => _pendingAction != null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.userSettings;
    if (settings == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder(
      stream: _planStream,
      builder: (context, planSnapshot) {
        final plan = planSnapshot.data;

            return Scaffold(
              backgroundColor: AppColors.mdSurfaceContainerLow,
              appBar: AppBar(title: Text(l10n.settingsPageTitle)),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSection(
                      title: l10n.settingsSectionPlan,
                      children: [
                        _buildListTile(
                          title: l10n.settingsCurrentStrategyTitle,
                          subtitle: l10n.settingsCurrentStrategySubtitle,
                          trailingText: _strategyLabel(
                            plan?.strategy ?? Strategy.snowball,
                          ),
                          onTap: () => context.go(AppRoutes.plan),
                        ),
                        _buildDivider(),
                        _buildListTile(
                          title: l10n.settingsExtraMonthlyTitle,
                          subtitle: l10n.settingsExtraMonthlySubtitle,
                          trailingText: AppFormatters.formatCents(
                            plan?.extraMonthlyAmount ?? 0,
                            currencyCode: settings.currencyCode,
                            localeCode: settings.localeCode,
                          ),
                          onTap: () => context.go(AppRoutes.plan),
                        ),
                        _buildDivider(),
                        _buildListTile(
                          title: l10n.scenariosTitle,
                          subtitle: l10n.scenariosEmptySubtitle,
                          trailingText: '',
                          onTap: () => context.push(AppRoutes.scenarios),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _buildSection(
                      title: l10n.settingsSectionReminders,
                      children: [
                        _buildListTile(
                          key: AppTestKeys.settingsPaymentReminders,
                          title: l10n.settingsPaymentReminderTitle,
                          subtitle: l10n.settingsPaymentReminderSubtitle,
                          trailingWidget: Switch(
                            value: settings.notifPaymentReminder,
                            onChanged: (value) =>
                                _togglePaymentReminder(settings, value),
                          ),
                          onTap: () => _togglePaymentReminder(
                            settings,
                            !settings.notifPaymentReminder,
                          ),
                        ),
                        _buildDivider(),
                        if (settings.notifPaymentReminder) ...[
                          _buildReminderDayPicker(settings),
                          _buildDivider(),
                        ],
                        _buildListTile(
                          key: AppTestKeys.settingsMonthlyReminder,
                          title: l10n.settingsMonthlyReminderTitle,
                          subtitle: l10n.settingsMonthlyReminderSubtitle,
                          trailingWidget: Switch(
                            value: settings.notifMonthlyLog,
                            onChanged: (value) =>
                                _toggleMonthlyReminder(settings, value),
                          ),
                          onTap: () => _toggleMonthlyReminder(
                            settings,
                            !settings.notifMonthlyLog,
                          ),
                        ),
                        _buildDivider(),
                        _buildListTile(
                          key: AppTestKeys.settingsMilestoneReminder,
                          title: l10n.settingsMilestoneReminderTitle,
                          subtitle: l10n.settingsMilestoneReminderSubtitle,
                          trailingWidget: Switch(
                            value: settings.notifMilestone,
                            onChanged: (value) =>
                                _toggleMilestoneReminder(settings, value),
                          ),
                          onTap: () => _toggleMilestoneReminder(
                            settings,
                            !settings.notifMilestone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _buildSection(
                      title: l10n.settingsSectionReports,
                      children: [
                        _buildListTile(
                          key: AppTestKeys.settingsReportsPreview,
                          title: l10n.settingsReportsPreviewTitle,
                          subtitle: l10n.settingsReportsPreviewSubtitle,
                          onTap: () => context.push(AppRoutes.reportsPreview),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _buildSection(
                      title: l10n.settingsSectionOptions,
                      children: [
                        _buildListTile(
                          title: l10n.settingsCurrencyTitle,
                          subtitle: l10n.settingsCurrencySubtitle,
                          trailingText: settings.currencyCode,
                        ),
                        _buildDivider(),
                        _buildListTile(
                          key: AppTestKeys.settingsLocale,
                          title: l10n.settingsLocaleTitle,
                          subtitle: l10n.settingsLocaleSubtitle,
                          trailingText: AppLocale.displayNameForLocaleCode(
                            settings.localeCode,
                          ),
                          onTap: () => _showLocalePicker(settings),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _buildSection(
                      title: l10n.settingsSectionData,
                      children: [
                        _buildDataStatusBanner(settings),
                        _buildDivider(),
                        _buildListTile(
                          key: AppTestKeys.settingsCloudBackup,
                          title: l10n.settingsCloudBackupTitle,
                          subtitle: _trustLevelCopy(settings.trustLevel),
                          trailingText: _trustLevelLabel(settings.trustLevel),
                          enabled: !_isDataActionPending,
                          onTap: _isDataActionPending
                              ? null
                              : () => context.push(AppRoutes.syncBackup),
                        ),
                        _buildDivider(),
                        _buildListTile(
                          key: AppTestKeys.settingsDataExportCsv,
                          title: l10n.settingsExportCsvTitle,
                          subtitle: l10n.settingsExportCsvSubtitle,
                          trailingText: l10n.settingsZipLabel,
                          enabled: !_isDataActionPending,
                          isLoading:
                              _pendingAction == _SettingsDataAction.csvExport,
                          onTap: _isDataActionPending ? null : _exportCsv,
                        ),
                        _buildDivider(),
                        _buildListTile(
                          key: AppTestKeys.settingsDataLocalBackup,
                          title: l10n.settingsLocalBackupTitle,
                          subtitle: l10n.settingsLocalBackupSubtitle,
                          trailingText: l10n.settingsZipLabel,
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
                          title: l10n.settingsRestoreTitle,
                          subtitle: l10n.settingsRestoreSubtitle,
                          trailingText: l10n.settingsRestoreAction,
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
                          title: l10n.settingsClearAllTitle,
                          subtitle: l10n.settingsClearAllSubtitle,
                          trailingText: l10n.settingsResetAction,
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
                            l10n.settingsVersionFooter,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mdOnSurfaceVariant,
                            ),
                          ),
                          Text(
                            l10n.settingsCopyrightFooter,
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
      final settings = await _settingsRepository.getSettings();
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

      final confirmed = await _confirmRestore(
        preview,
        localeCode: settings.localeCode,
      );
      if (confirmed != true || !mounted) {
        return;
      }

      await _dataManagementService.restoreFromLocalBackup(
        filePath: preview.path,
        fileName: preview.fileName,
      );
      if (mounted) {
        context.showSnackBar(context.l10n.settingsRestoreSuccess);
      }
    });
  }

  Future<bool?> _confirmRestore(
    BackupBundlePreview preview, {
    required String localeCode,
  }) {
    final l10n = context.l10n;
    final rowCounts = preview.tableRowCounts.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsRestoreDialogTitle),
          content: SingleChildScrollView(
            child: Text(
              '${l10n.settingsRestoreDialogFileLabel}: ${preview.fileName}\n'
              '${l10n.settingsRestoreDialogExportedAtLabel}: '
              '${_formatPreviewTimestamp(preview.exportedAtUtc, localeCode: localeCode)}\n'
              '${l10n.settingsRestoreDialogTotalRecordsLabel}: ${preview.totalRows}\n\n'
              '${l10n.settingsRestoreDialogDataHeader}\n'
              '$rowCounts\n\n'
              '${l10n.settingsRestoreDialogWarning}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.settingsCancel),
            ),
            FilledButton(
              key: AppTestKeys.settingsDataRestoreConfirm,
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.settingsRestoreConfirm),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmClearAll() async {
    final l10n = context.l10n;
    final confirmedStepOne = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsClearAllDialogTitle),
          content: Text(l10n.settingsClearAllDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.settingsCancel),
            ),
            FilledButton(
              key: AppTestKeys.settingsDataClearAllConfirmOne,
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.settingsContinue),
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
          title: Text(l10n.settingsFinalConfirmTitle),
          content: Text(l10n.settingsFinalConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.settingsGoBack),
            ),
            FilledButton(
              key: AppTestKeys.settingsDataClearAllConfirmTwo,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.mdError,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.settingsDeleteAllConfirm),
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

  Future<void> _showLocalePicker(UserSettings settings) async {
    await showAppLocalePickerSheet(
      context,
      selectedLocaleCode: settings.localeCode,
      onSelected: (localeCode) {
        return _updateSettings(settings.copyWith(localeCode: localeCode));
      },
    );
  }

  Future<void> _togglePaymentReminder(UserSettings settings, bool value) async {
    if (value && !await _ensureNotificationPermission()) {
      return;
    }

    await _updateSettings(settings.copyWith(notifPaymentReminder: value));
    await getIt<ReminderSchedulerService>().rescheduleAllReminders();
  }

  Future<void> _toggleMonthlyReminder(UserSettings settings, bool value) async {
    if (value && !await _ensureNotificationPermission()) {
      return;
    }

    await _updateSettings(settings.copyWith(notifMonthlyLog: value));
    await getIt<ReminderSchedulerService>().rescheduleAllReminders();
  }

  Future<void> _toggleMilestoneReminder(
    UserSettings settings,
    bool value,
  ) async {
    if (value && !await _ensureNotificationPermission()) {
      return;
    }

    await _updateSettings(settings.copyWith(notifMilestone: value));
  }

  Future<void> _updateReminderDays(
    UserSettings settings,
    int daysBefore,
  ) async {
    if (settings.notifPaymentReminderDaysBefore == daysBefore) {
      return;
    }

    await _updateSettings(
      settings.copyWith(notifPaymentReminderDaysBefore: daysBefore),
    );
    await getIt<ReminderSchedulerService>().rescheduleAllReminders();
  }

  Future<bool> _ensureNotificationPermission() async {
    final notificationService = getIt<NotificationService>();
    final granted = await notificationService.requestPermissions();
    if (!granted && mounted) {
      context.showSnackBar(
        context.l10n.settingsNotificationPermissionRequired,
        isError: true,
      );
    }
    return granted;
  }


  String _strategyLabel(Strategy strategy) {
    final l10n = context.l10n;
    switch (strategy) {
      case Strategy.avalanche:
        return l10n.settingsStrategyAvalanche;
      case Strategy.custom:
        return l10n.settingsStrategyCustom;
      case Strategy.snowball:
        return l10n.settingsStrategySnowball;
    }
  }

  String _trustLevelCopy(int trustLevel) {
    final l10n = context.l10n;
    switch (trustLevel) {
      case 1:
        return l10n.settingsTrustLevelOneBody;
      case 2:
        return l10n.settingsTrustLevelTwoBody;
      case 0:
      default:
        return l10n.settingsTrustLevelLocalOnlyBody;
    }
  }

  String _trustLevelLabel(int trustLevel) {
    final l10n = context.l10n;
    switch (trustLevel) {
      case 1:
        return l10n.settingsTrustLevelOneLabel;
      case 2:
        return l10n.settingsTrustLevelTwoLabel;
      case 0:
      default:
        return l10n.settingsTrustLevelLocalOnlyLabel;
    }
  }

  String _formatPreviewTimestamp(DateTime value, {required String localeCode}) {
    return AppFormatters.formatDateTime(
      value.toLocal(),
      localeCode: localeCode,
    );
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDataStatusBanner(UserSettings settings) {
    final l10n = context.l10n;
    final isLocalOnly = settings.trustLevel == 0;
    final icon = isLocalOnly ? LucideIcons.shieldCheck : LucideIcons.cloud;
    final title = isLocalOnly
        ? l10n.settingsDataBannerLocalTitle
        : l10n.settingsDataBannerTrustTitle;
    final body = isLocalOnly
        ? l10n.settingsDataBannerLocalBody
        : l10n.settingsDataBannerTrustBody;

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

  Widget _buildReminderDayPicker(UserSettings settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical: AppDimensions.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.settingsReminderDaysTitle,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            context.l10n.settingsReminderDaysSubtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            children: [1, 3, 7].map((days) {
              return AppChip.filter(
                key: AppTestKeys.settingsReminderDayOption(days),
                label: '$days',
                selected: settings.notifPaymentReminderDaysBefore == days,
                onTap: () => _updateReminderDays(settings, days),
              );
            }).toList(),
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
    Widget? trailingWidget,
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
                      if (trailingWidget != null)
                        trailingWidget
                      else if (trailingText != null)
                        Text(
                          trailingText,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: effectiveTrailingColor,
                            fontFamily: 'Roboto Mono',
                          ),
                        ),
                      if (canTap &&
                          trailingWidget == null &&
                          trailingText == null) ...[
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
