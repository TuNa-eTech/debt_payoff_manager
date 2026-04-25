import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../domain/entities/user_settings.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../../../sync/cloud_backup_service.dart';
import '../../../../sync/sync_auth_service.dart';

enum _CloudBackupAction { google, apple, disable }

class SyncBackupPage extends StatefulWidget {
  const SyncBackupPage({super.key});

  @override
  State<SyncBackupPage> createState() => _SyncBackupPageState();
}

class _SyncBackupPageState extends State<SyncBackupPage> {
  late final SettingsRepository _settingsRepository =
      getIt<SettingsRepository>();
  late final CloudBackupService _cloudBackupService =
      getIt<CloudBackupService>();
  late final _settingsStream = _settingsRepository.watchSettings();
  late final _runtimeStream = _cloudBackupService.watchRuntimeState();

  _CloudBackupAction? _pendingAction;
  bool _refreshQueued = false;

  bool get _isBusy =>
      _pendingAction != null || _cloudBackupService.currentState.isBusy;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserSettings>(
      stream: _settingsStream,
      builder: (context, settingsSnapshot) {
        final settings = settingsSnapshot.data;
        if (settings == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (settings.trustLevel >= 1 && !_refreshQueued) {
          _refreshQueued = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              unawaited(_cloudBackupService.refresh());
            }
          });
        }

        return StreamBuilder<CloudBackupRuntimeState>(
          stream: _runtimeStream,
          initialData: _cloudBackupService.currentState,
          builder: (context, runtimeSnapshot) {
            final runtime =
                runtimeSnapshot.data ?? _cloudBackupService.currentState;
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
              body: SafeArea(
                top: false,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.pagePaddingH,
                    AppDimensions.md,
                    AppDimensions.pagePaddingH,
                    AppDimensions.xxl,
                  ),
                  children: [
                    _buildHeader(settings),
                    const SizedBox(height: AppDimensions.xl),
                    if (settings.trustLevel >= 1)
                      _buildEnabledState(settings, runtime)
                    else
                      _buildOptInState(runtime),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(UserSettings settings) {
    final l10n = context.l10n;
    final isEnabled = settings.trustLevel >= 1;

    return Column(
      children: [
        Align(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.mdPrimaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                LucideIcons.cloud,
                size: 48,
                color: AppColors.mdPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.xl),
        Text(
          isEnabled ? l10n.syncBackupEnabledHeadline : l10n.syncBackupHeadline,
          style: AppTextStyles.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          isEnabled ? l10n.syncBackupEnabledBody : l10n.syncBackupBody,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOptInState(CloudBackupRuntimeState runtime) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          color: AppColors.mdSurfaceContainerLow,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                LucideIcons.shieldCheck,
                color: AppColors.mdPrimary,
                size: AppDimensions.iconMd,
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  l10n.syncBackupTrustMessage,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (runtime.lastError != null) ...[
          const SizedBox(height: AppDimensions.lg),
          _buildErrorCard(runtime.lastError!),
        ],
        const SizedBox(height: AppDimensions.xl),
        AppButton.filledLg(
          key: AppTestKeys.syncBackupGoogle,
          label: l10n.syncBackupSignInGoogle,
          icon: LucideIcons.cloud,
          fullWidth: true,
          loading: _pendingAction == _CloudBackupAction.google,
          onPressed: _isBusy
              ? null
              : () => _runCloudAction(
                  _CloudBackupAction.google,
                  _cloudBackupService.enableWithGoogle,
                  successMessage: l10n.syncBackupEnableSuccess,
                ),
        ),
        if (_showsAppleSignIn) ...[
          const SizedBox(height: AppDimensions.md),
          AppButton.outlined(
            key: AppTestKeys.syncBackupApple,
            label: l10n.syncBackupSignInApple,
            icon: LucideIcons.apple,
            fullWidth: true,
            loading: _pendingAction == _CloudBackupAction.apple,
            onPressed: _isBusy
                ? null
                : () => _runCloudAction(
                    _CloudBackupAction.apple,
                    _cloudBackupService.enableWithApple,
                    successMessage: l10n.syncBackupEnableSuccess,
                  ),
          ),
        ],
        const SizedBox(height: AppDimensions.md),
        AppButton.text(
          label: l10n.syncBackupContinueLocal,
          onPressed: _isBusy ? null : () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildEnabledState(
    UserSettings settings,
    CloudBackupRuntimeState runtime,
  ) {
    final l10n = context.l10n;
    final account = runtime.account;
    final accountLabel =
        account?.email ?? account?.displayName ?? settings.firebaseUid ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          color: AppColors.mdSurfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusRow(
                icon: LucideIcons.badgeCheck,
                label: l10n.syncBackupStatus,
                value: runtime.isBusy
                    ? l10n.syncBackupSyncing
                    : l10n.syncBackupStatusEnabled,
              ),
              const SizedBox(height: AppDimensions.md),
              _StatusRow(
                icon: LucideIcons.user,
                label: l10n.syncBackupSignedInAs,
                value: accountLabel,
              ),
              const SizedBox(height: AppDimensions.md),
              _StatusRow(
                icon: LucideIcons.clock3,
                label: l10n.syncBackupLastSynced,
                value: runtime.lastSyncedAt == null
                    ? l10n.syncBackupLastSyncedPending
                    : AppFormatters.formatDateTime(
                        runtime.lastSyncedAt!.toLocal(),
                        localeCode: settings.localeCode,
                      ),
              ),
            ],
          ),
        ),
        if (runtime.lastError != null) ...[
          const SizedBox(height: AppDimensions.lg),
          _buildErrorCard(runtime.lastError!),
        ],
        const SizedBox(height: AppDimensions.xl),
        AppButton.error(
          key: AppTestKeys.syncBackupDisable,
          label: l10n.syncBackupDisable,
          icon: LucideIcons.cloudOff,
          fullWidth: true,
          loading: _pendingAction == _CloudBackupAction.disable,
          onPressed: _isBusy ? null : _confirmDisable,
        ),
      ],
    );
  }

  Widget _buildErrorCard(Object error) {
    return AppCard(
      color: AppColors.mdErrorContainer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.alertCircle,
            color: AppColors.mdError,
            size: AppDimensions.iconMd,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              _errorMessageFor(error),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mdOnErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDisable() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.syncBackupDisableDialogTitle),
          content: Text(l10n.syncBackupDisableDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.settingsCancel),
            ),
            FilledButton(
              key: AppTestKeys.syncBackupDisableConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.mdError,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.syncBackupDisableConfirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await _runCloudAction(
      _CloudBackupAction.disable,
      _cloudBackupService.disableAndDeleteCloudBackup,
      successMessage: l10n.syncBackupDisableSuccess,
    );
  }

  Future<void> _runCloudAction(
    _CloudBackupAction action,
    Future<void> Function() operation, {
    required String successMessage,
  }) async {
    if (_pendingAction != null) return;

    setState(() => _pendingAction = action);
    try {
      await operation();
      if (mounted) {
        context.showSnackBar(successMessage);
      }
    } on SyncAuthCancelledException {
      // User closed the provider sheet; keep the screen unchanged.
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

  bool get _showsAppleSignIn {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
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
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.mdPrimary, size: AppDimensions.iconMd),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.mdOnSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
