import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../sync/sync_auth_service.dart';
import '../../data/sharing_service.dart';

class InviteAcceptPage extends StatefulWidget {
  const InviteAcceptPage({super.key, required this.token});

  final String? token;

  @override
  State<InviteAcceptPage> createState() => _InviteAcceptPageState();
}

class _InviteAcceptPageState extends State<InviteAcceptPage> {
  late final SharingService _sharingService = getIt<SharingService>();
  late final SyncAuthService _authService = getIt<SyncAuthService>();

  bool _isBusy = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasToken = widget.token != null && widget.token!.isNotEmpty;
    return Scaffold(
      backgroundColor: AppColors.mdSurfaceContainerLow,
      appBar: AppBar(title: Text(l10n.inviteAcceptTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePaddingH,
            AppDimensions.md,
            AppDimensions.pagePaddingH,
            AppDimensions.xxl,
          ),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    LucideIcons.hand,
                    color: AppColors.mdPrimary,
                    size: 48,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    hasToken
                        ? l10n.inviteAcceptJoinTitle
                        : l10n.inviteAcceptMissingTitle,
                    style: AppTextStyles.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    hasToken
                        ? l10n.inviteAcceptJoinBody
                        : l10n.inviteAcceptMissingBody,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.mdOnSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      _errorMessage!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.mdError,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppDimensions.lg),
                  AppButton.filledLg(
                    label: l10n.inviteAcceptButton,
                    icon: LucideIcons.check,
                    loading: _isBusy,
                    fullWidth: true,
                    onPressed: hasToken && !_isBusy ? _acceptInvite : null,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  AppButton.outlined(
                    label: l10n.syncBackupSignInGoogle,
                    icon: LucideIcons.cloud,
                    loading: _isBusy,
                    fullWidth: true,
                    onPressed: hasToken && !_isBusy
                        ? () => _signInThenAccept(_authService.signInWithGoogle)
                        : null,
                  ),
                  if (_showsAppleSignIn) ...[
                    const SizedBox(height: AppDimensions.sm),
                    AppButton.outlined(
                      label: l10n.syncBackupSignInApple,
                      icon: LucideIcons.badgeCheck,
                      loading: _isBusy,
                      fullWidth: true,
                      onPressed: hasToken && !_isBusy
                          ? () =>
                                _signInThenAccept(_authService.signInWithApple)
                          : null,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInThenAccept(
    Future<SyncAuthAccount> Function() signIn,
  ) async {
    await _run(() async {
      await signIn();
      await _acceptInvite();
    });
  }

  Future<void> _acceptInvite() async {
    final signInRequiredMessage = context.l10n.inviteAcceptSignInRequired;
    await _run(() async {
      final account = await _authService.currentAccount();
      if (account == null) {
        throw StateError(signInRequiredMessage);
      }
      final result = await _sharingService.acceptInvite(widget.token!);
      if (!mounted) return;
      context.go(AppRoutes.sharedPlanPath(result.shareId));
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    try {
      await action();
    } on SyncAuthCancelledException {
      // Keep the invite screen ready for another attempt.
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = _message(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  bool get _showsAppleSignIn {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  String _message(Object error) {
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
