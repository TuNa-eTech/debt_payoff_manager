import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../cubit/sharing_cubit.dart';
import '../../domain/sharing_models.dart';

class PartnerSharingPage extends StatefulWidget {
  const PartnerSharingPage({super.key});

  @override
  State<PartnerSharingPage> createState() => _PartnerSharingPageState();
}

class _PartnerSharingPageState extends State<PartnerSharingPage> {
  @override
  void initState() {
    super.initState();
    context.read<SharingCubit>().start();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<SharingCubit, SharingState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage ||
            previous.lastInviteResult != current.lastInviteResult;
      },
      listener: (context, state) {
        if (state.errorMessage != null) {
          context.showSnackBar(state.errorMessage!, isError: true);
        }
        final invite = state.lastInviteResult;
        if (invite != null) {
          _showInviteCreatedSheet(invite);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.mdSurfaceContainerLow,
          appBar: AppBar(title: Text(l10n.partnerSharingPageTitle)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePaddingH,
                AppDimensions.md,
                AppDimensions.pagePaddingH,
                AppDimensions.xxl,
              ),
              children: [
                _buildHeader(l10n),
                const SizedBox(height: AppDimensions.sectionGap),
                if (state.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (!state.isSignedIn)
                  _buildSignInCard(state, l10n)
                else ...[
                  _buildOwnerShareCard(state, l10n),
                  const SizedBox(height: AppDimensions.sectionGap),
                  _buildPartnerPlansCard(state, l10n),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return AppCard(
      color: AppColors.mdSurface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.users,
            color: AppColors.mdPrimary,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.partnerSharingHeaderTitle,
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  l10n.partnerSharingHeaderBody,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInCard(SharingState state, AppLocalizations l10n) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.partnerSharingCloudRequiredTitle,
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            l10n.partnerSharingCloudRequiredBody,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          AppButton.filled(
            key: AppTestKeys.partnerSharingGoogle,
            label: l10n.syncBackupSignInGoogle,
            icon: LucideIcons.cloud,
            loading: state.isBusy,
            fullWidth: true,
            onPressed: state.isBusy
                ? null
                : () => context.read<SharingCubit>().signInWithGoogle(),
          ),
          if (_showsAppleSignIn) ...[
            const SizedBox(height: AppDimensions.md),
            AppButton.outlined(
              key: AppTestKeys.partnerSharingApple,
              label: l10n.syncBackupSignInApple,
              icon: LucideIcons.badgeCheck,
              loading: state.isBusy,
              fullWidth: true,
              onPressed: state.isBusy
                  ? null
                  : () => context.read<SharingCubit>().signInWithApple(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOwnerShareCard(SharingState state, AppLocalizations l10n) {
    final plan = state.ownerPlan;
    final isActive = plan != null && plan.isActive;
    final hasPartners = isActive && plan.hasPartners;
    final hasPending = isActive && plan.hasPendingInvites;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.partnerSharingYourSharedPlan,
                  style: AppTextStyles.titleMedium,
                ),
              ),
              AppChip.status(
                label: hasPartners
                    ? l10n.partnerSharingStatusActive
                    : hasPending
                    ? l10n.partnerSharingStatusInvitePending
                    : l10n.partnerSharingStatusOff,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            hasPartners
                ? l10n.partnerSharingOwnerHasPartner
                : hasPending
                ? l10n.partnerSharingOwnerHasPending
                : l10n.partnerSharingOwnerNoAccess,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: AppDimensions.md),
            _PlanStatusRow(
              icon: LucideIcons.keyRound,
              label: l10n.partnerSharingPermission,
              value: _modeLabel(plan.mode, l10n),
            ),
            if (hasPending) ...[
              const SizedBox(height: AppDimensions.sm),
              for (final invite in plan.pendingInvites)
                _PlanStatusRow(
                  icon: LucideIcons.mail,
                  label: l10n.partnerSharingPending,
                  value: invite.email,
                ),
            ],
            if (hasPartners) ...[
              const SizedBox(height: AppDimensions.sm),
              for (final partnerUid in plan.partnerUids)
                _PartnerRow(
                  partnerUid: partnerUid,
                  busy: state.isBusy,
                  l10n: l10n,
                  onRevoke: () =>
                      context.read<SharingCubit>().revokePartner(partnerUid),
                ),
            ],
          ],
          const SizedBox(height: AppDimensions.lg),
          AppButton.filled(
            key: AppTestKeys.partnerSharingInvite,
            label: isActive
                ? l10n.partnerSharingCreateAnotherInvite
                : l10n.partnerSharingInvitePartner,
            icon: LucideIcons.userPlus,
            loading: state.isBusy,
            fullWidth: true,
            onPressed: state.isBusy ? null : _showInviteForm,
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerPlansCard(SharingState state, AppLocalizations l10n) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.partnerSharingPlansSharedWithYou,
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppDimensions.sm),
          if (state.partnerPlans.isEmpty)
            Text(
              l10n.partnerSharingPlansEmpty,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mdOnSurfaceVariant,
              ),
            )
          else
            for (final plan in state.partnerPlans)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.sm),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.hand,
                      color: AppColors.mdPrimary,
                      size: AppDimensions.iconMd,
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Text(
                        l10n.partnerSharingSharedBy(plan.ownerUid),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    AppChip.status(label: _modeLabel(plan.mode, l10n)),
                    const SizedBox(width: AppDimensions.sm),
                    AppButton.text(
                      label: l10n.partnerSharingOpenSharedPlan,
                      onPressed: () =>
                          context.push(AppRoutes.sharedPlanPath(plan.id)),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _showInviteForm() async {
    final l10n = context.l10n;
    final emailController = TextEditingController();
    var mode = SharingPermissionMode.readonly;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.pagePaddingH,
                right: AppDimensions.pagePaddingH,
                top: AppDimensions.lg,
                bottom:
                    MediaQuery.of(sheetContext).viewInsets.bottom +
                    AppDimensions.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.partnerSharingInvitePartner,
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  AppTextField(
                    key: AppTestKeys.partnerSharingEmail,
                    label: l10n.partnerSharingEmailLabel,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    prefixIcon: LucideIcons.mail,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Wrap(
                    spacing: AppDimensions.sm,
                    runSpacing: AppDimensions.sm,
                    children: [
                      AppChip.filter(
                        key: AppTestKeys.partnerSharingModeReadonly,
                        label: l10n.partnerSharingModeReadOnly,
                        selected: mode == SharingPermissionMode.readonly,
                        onTap: () => setSheetState(
                          () => mode = SharingPermissionMode.readonly,
                        ),
                      ),
                      AppChip.filter(
                        key: AppTestKeys.partnerSharingModeCollaborative,
                        label: l10n.partnerSharingModeCollaborative,
                        selected: mode == SharingPermissionMode.collaborative,
                        onTap: () => setSheetState(
                          () => mode = SharingPermissionMode.collaborative,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  AppButton.filledLg(
                    label: l10n.partnerSharingCreateInviteLink,
                    fullWidth: true,
                    onPressed: () {
                      final email = emailController.text.trim();
                      if (email.isEmpty) {
                        context.showSnackBar(
                          l10n.partnerSharingEnterPartnerEmail,
                          isError: true,
                        );
                        return;
                      }
                      Navigator.pop(sheetContext);
                      context.read<SharingCubit>().createInvite(
                        partnerEmail: email,
                        mode: mode,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    emailController.dispose();
  }

  Future<void> _showInviteCreatedSheet(SharingInviteResult invite) async {
    final l10n = context.l10n;
    context.read<SharingCubit>().clearInviteResult();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final inviteText = l10n.partnerSharingInviteText(
          invite.inviteUrl.toString(),
        );
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePaddingH,
            AppDimensions.lg,
            AppDimensions.pagePaddingH,
            AppDimensions.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.partnerSharingInviteReady,
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppDimensions.md),
              Center(
                child: QrImageView(
                  data: invite.inviteUrl.toString(),
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: AppColors.mdSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              SelectableText(
                invite.inviteUrl.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mdOnSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              AppButton.filled(
                label: l10n.partnerSharingShareInvite,
                icon: LucideIcons.share2,
                fullWidth: true,
                onPressed: () => Share.share(inviteText),
              ),
              const SizedBox(height: AppDimensions.sm),
              AppButton.outlined(
                label: l10n.partnerSharingCopyLink,
                icon: LucideIcons.copy,
                fullWidth: true,
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: invite.inviteUrl.toString()),
                  );
                  if (mounted) {
                    context.showSnackBar(l10n.partnerSharingInviteCopied);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool get _showsAppleSignIn {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  String _modeLabel(SharingPermissionMode mode, AppLocalizations l10n) {
    return switch (mode) {
      SharingPermissionMode.readonly => l10n.partnerSharingModeReadOnly,
      SharingPermissionMode.collaborative =>
        l10n.partnerSharingModeCollaborative,
    };
  }
}

class _PlanStatusRow extends StatelessWidget {
  const _PlanStatusRow({
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
      children: [
        Icon(icon, color: AppColors.mdPrimary, size: AppDimensions.iconMd),
        const SizedBox(width: AppDimensions.sm),
        Text(
          '$label: ',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
        ),
        Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
      ],
    );
  }
}

class _PartnerRow extends StatelessWidget {
  const _PartnerRow({
    required this.partnerUid,
    required this.busy,
    required this.l10n,
    required this.onRevoke,
  });

  final String partnerUid;
  final bool busy;
  final AppLocalizations l10n;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          LucideIcons.user,
          color: AppColors.mdPrimary,
          size: AppDimensions.iconMd,
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(child: Text(partnerUid, style: AppTextStyles.bodyMedium)),
        AppButton.error(
          label: l10n.partnerSharingRevoke,
          onPressed: busy ? null : onRevoke,
        ),
      ],
    );
  }
}
