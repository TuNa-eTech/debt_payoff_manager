import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../sync/sync_auth_service.dart';
import '../../data/sharing_service.dart';
import '../../domain/sharing_models.dart';

class SharedPlanPage extends StatefulWidget {
  const SharedPlanPage({super.key, required this.shareId});

  final String shareId;

  @override
  State<SharedPlanPage> createState() => _SharedPlanPageState();
}

class _SharedPlanPageState extends State<SharedPlanPage> {
  late final SharingService _sharingService = getIt<SharingService>();
  late final SyncAuthService _authService = getIt<SyncAuthService>();
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<SyncAuthAccount?>(
      future: _authService.currentAccount(),
      builder: (context, accountSnapshot) {
        final account = accountSnapshot.data;
        if (accountSnapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (account == null) {
          return _buildMessageScaffold(
            title: l10n.sharedPlanSignInRequiredTitle,
            body: l10n.sharedPlanSignInRequiredBody,
          );
        }

        return StreamBuilder<List<SharedPlan>>(
          stream: _sharingService.watchPartnerPlans(partnerUid: account.uid),
          builder: (context, plansSnapshot) {
            final plans = plansSnapshot.data ?? const <SharedPlan>[];
            final plan = plans
                .where((candidate) => candidate.id == widget.shareId)
                .firstOrNull;
            if (plansSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (plan == null) {
              return _buildMessageScaffold(
                title: l10n.sharedPlanAccessUnavailableTitle,
                body: l10n.sharedPlanAccessUnavailableBody,
              );
            }
            return _buildSharedPlan(plan);
          },
        );
      },
    );
  }

  Widget _buildSharedPlan(SharedPlan plan) {
    return StreamBuilder<SharedPlanSnapshot>(
      stream: _sharingService.watchSharedPlanSnapshot(plan),
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Scaffold(
          backgroundColor: AppColors.mdSurfaceContainerLow,
          appBar: AppBar(title: Text(context.l10n.sharedPlanTitle)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePaddingH,
                AppDimensions.md,
                AppDimensions.pagePaddingH,
                AppDimensions.xxl,
              ),
              children: [
                _buildSharedBanner(plan),
                const SizedBox(height: AppDimensions.sectionGap),
                if (data == null)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  _buildSummaryCard(data),
                  const SizedBox(height: AppDimensions.sectionGap),
                  for (final debt in data.debts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.md),
                      child: _buildDebtCard(plan, debt),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSharedBanner(SharedPlan plan) {
    return AppCard(
      color: AppColors.mdPrimaryContainer,
      borderColor: AppColors.mdPrimaryContainer,
      child: Row(
        children: [
          const Icon(
            LucideIcons.hand,
            color: AppColors.mdPrimary,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.partnerSharingSharedBy(plan.ownerUid),
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  plan.mode == SharingPermissionMode.collaborative
                      ? context.l10n.sharedPlanCollaborativeBody
                      : context.l10n.sharedPlanReadOnlyBody,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppChip.status(label: _modeLabel(plan.mode)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(SharedPlanSnapshot snapshot) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.sharedPlanBalanceTitle,
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            context.formatCents(snapshot.totalBalanceCents),
            style: AppTextStyles.moneyMedium,
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            context.l10n.sharedPlanDebtCount(snapshot.debts.length),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(SharedPlan plan, SharedDebtSnapshot debt) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(debt.name, style: AppTextStyles.titleMedium),
              ),
              AppChip.status(label: debt.status),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            context.formatCents(debt.currentBalanceCents),
            style: AppTextStyles.moneySmall,
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            context.l10n.sharedPlanApr(debt.apr.toString()),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
          if (plan.mode == SharingPermissionMode.collaborative) ...[
            const SizedBox(height: AppDimensions.md),
            AppButton.tonal(
              label: context.l10n.sharedPlanLogPayment,
              icon: LucideIcons.receipt,
              loading: _isBusy,
              onPressed: _isBusy
                  ? null
                  : () => _showLogPaymentSheet(plan, debt),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showLogPaymentSheet(
    SharedPlan plan,
    SharedDebtSnapshot debt,
  ) async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
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
                context.l10n.sharedPlanLogPaymentTitle,
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppDimensions.md),
              AppTextField.currency(
                label: context.l10n.sharedPlanPaymentAmount,
                controller: amountController,
                required: true,
              ),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                label: context.l10n.sharedPlanNote,
                controller: noteController,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppDimensions.lg),
              AppButton.filledLg(
                label: context.l10n.sharedPlanSavePayment,
                fullWidth: true,
                onPressed: () {
                  final amount = _parseCents(amountController.text);
                  if (amount <= 0) {
                    context.showSnackBar(
                      context.l10n.sharedPlanPositiveAmountRequired,
                      isError: true,
                    );
                    return;
                  }
                  Navigator.pop(sheetContext);
                  _logPayment(
                    plan: plan,
                    debt: debt,
                    amountCents: amount,
                    note: noteController.text.trim(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
    amountController.dispose();
    noteController.dispose();
  }

  Future<void> _logPayment({
    required SharedPlan plan,
    required SharedDebtSnapshot debt,
    required int amountCents,
    required String note,
  }) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await _sharingService.logSharedPayment(
        shareId: plan.id,
        debtId: debt.id,
        amountCents: amountCents,
        date: DateTime.now(),
        note: note.isEmpty ? null : note,
      );
      if (mounted) {
        context.showSnackBar(context.l10n.sharedPlanPaymentLogged);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar(error.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Widget _buildMessageScaffold({required String title, required String body}) {
    return Scaffold(
      backgroundColor: AppColors.mdSurfaceContainerLow,
      appBar: AppBar(title: Text(context.l10n.sharedPlanTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.lock,
                  color: AppColors.mdPrimary,
                  size: 48,
                ),
                const SizedBox(height: AppDimensions.md),
                Text(title, style: AppTextStyles.titleLarge),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  body,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _parseCents(String input) {
    final normalized = input.replaceAll(RegExp(r'[^0-9.]'), '');
    if (normalized.isEmpty) return 0;
    final amount = double.tryParse(normalized) ?? 0;
    return (amount * 100).round();
  }

  String _modeLabel(SharingPermissionMode mode) {
    return switch (mode) {
      SharingPermissionMode.readonly => context.l10n.partnerSharingModeReadOnly,
      SharingPermissionMode.collaborative =>
        context.l10n.partnerSharingModeCollaborative,
    };
  }
}
