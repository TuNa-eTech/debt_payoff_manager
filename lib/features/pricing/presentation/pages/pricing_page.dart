import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../cubit/pricing_cubit.dart';
import '../../cubit/pricing_state.dart';
import '../../domain/premium_models.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PricingCubit>()..load(),
      child: const _PricingView(),
    );
  }
}

class _PricingView extends StatelessWidget {
  const _PricingView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.mdSurfaceContainerLow,
      appBar: AppBar(title: Text(l10n.pricingPageTitle)),
      body: SafeArea(
        child: BlocConsumer<PricingCubit, PricingState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage ||
              previous.message != current.message,
          listener: (context, state) {
            if (state.errorMessage != null) {
              context.showSnackBar(state.errorMessage!, isError: true);
            } else if (state.message == pricingPremiumActivatedMessage) {
              unawaited(
                _showPremiumActivatedDialog(context, state.premiumExpiresAt),
              );
            } else if (state.message == pricingDebugPremiumClearedMessage) {
              context.showSnackBar(
                context.l10n.pricingDebugClearPremiumMessage,
              );
            } else if (state.message != null) {
              context.showSnackBar(state.message!);
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<PricingCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.pagePaddingH,
                  AppDimensions.lg,
                  AppDimensions.pagePaddingH,
                  AppDimensions.xxl,
                ),
                children: [
                  Text(
                    l10n.pricingHeadline,
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    l10n.pricingBody,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.mdOnSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  if (state.isPremiumActive) ...[
                    _PremiumActiveCard(expiresAt: state.premiumExpiresAt),
                    const SizedBox(height: AppDimensions.lg),
                  ],
                  _TierCard(
                    title: l10n.pricingFreeTitle,
                    subtitle: l10n.pricingFreeSubtitle,
                    accentColor: AppColors.mdPrimary,
                    backgroundColor: AppColors.mdPrimaryContainer,
                    icon: LucideIcons.shield,
                    bullets: <String>[
                      l10n.pricingFreeBulletUnlimitedDebts,
                      l10n.pricingFreeBulletStrategies,
                      l10n.pricingFreeBulletPayments,
                      l10n.pricingFreeBulletExport,
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  _TierCard(
                    title: l10n.pricingPremiumTitle,
                    subtitle: state.products.isEmpty
                        ? l10n.pricingPremiumSubtitle
                        : l10n.pricingPremiumLoadedSubtitle,
                    accentColor: AppColors.mdSecondary,
                    backgroundColor: AppColors.mdSecondaryContainer,
                    icon: LucideIcons.sparkles,
                    bullets: <String>[
                      l10n.pricingPremiumBulletScenarios,
                      l10n.pricingPremiumBulletSharing,
                      l10n.pricingPremiumBulletPdf,
                      l10n.pricingPremiumBulletPricing,
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  _ProductSelector(state: state),
                  const SizedBox(height: AppDimensions.lg),
                  _TrustCard(message: l10n.pricingTrustMessage),
                  const SizedBox(height: AppDimensions.xl),
                  AppButton.filledLg(
                    key: AppTestKeys.pricingPurchasePremium,
                    label: _purchaseLabel(context, state),
                    fullWidth: true,
                    loading: state.isPurchasing,
                    icon: LucideIcons.lock,
                    onPressed: _canPurchase(state)
                        ? context.read<PricingCubit>().buySelected
                        : null,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  AppButton.outlined(
                    key: AppTestKeys.pricingRestorePurchases,
                    label: l10n.pricingRestorePurchases,
                    fullWidth: true,
                    loading: state.isPurchasing,
                    icon: LucideIcons.rotateCcw,
                    onPressed: state.isStoreAvailable && !state.isPurchasing
                        ? context.read<PricingCubit>().restorePurchases
                        : null,
                  ),
                  if (_showDebugSubscriptionActions()) ...[
                    const SizedBox(height: AppDimensions.md),
                    AppButton.outlined(
                      key: AppTestKeys.pricingDebugManageSubscription,
                      label: l10n.pricingDebugManageSubscription,
                      fullWidth: true,
                      icon: LucideIcons.externalLink,
                      onPressed: state.isPurchasing
                          ? null
                          : context
                                .read<PricingCubit>()
                                .openSubscriptionManagement,
                    ),
                  ],
                  if (kDebugMode && state.isPremiumActive) ...[
                    const SizedBox(height: AppDimensions.md),
                    AppButton.error(
                      key: AppTestKeys.pricingDebugClearPremium,
                      label: l10n.pricingDebugClearPremium,
                      fullWidth: true,
                      icon: LucideIcons.bug,
                      onPressed: state.isPurchasing
                          ? null
                          : context.read<PricingCubit>().debugClearPremiumCache,
                    ),
                  ],
                  const SizedBox(height: AppDimensions.md),
                  SizedBox(
                    key: AppTestKeys.pricingContinueFree,
                    child: AppButton.text(
                      label: l10n.pricingContinueFree,
                      onPressed: context.pop,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  const _LegalLinksRow(),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    _footerMessage(context, state),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mdOnSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  bool _canPurchase(PricingState state) {
    return state.isStoreAvailable &&
        state.selectedProduct != null &&
        !state.isPurchasing &&
        !state.isPremiumActive;
  }

  bool _showDebugSubscriptionActions() {
    return kDebugMode && defaultTargetPlatform == TargetPlatform.iOS;
  }

  String _purchaseLabel(BuildContext context, PricingState state) {
    final l10n = context.l10n;
    if (state.isPremiumActive) return l10n.pricingPremiumActiveCta;
    if (state.isLoading) return l10n.pricingLoadingProducts;
    if (!state.isStoreAvailable) return l10n.pricingStoreUnavailableCta;
    final product = state.selectedProduct;
    if (product == null) return l10n.pricingProductsMissingCta;
    return l10n.pricingPurchaseCta(product.price);
  }

  String _footerMessage(BuildContext context, PricingState state) {
    final l10n = context.l10n;
    if (state.isLoading) return l10n.pricingLoadingProducts;
    if (!state.isStoreAvailable) return l10n.pricingStoreUnavailableMessage;
    if (state.products.isEmpty) return l10n.pricingProductsMissingMessage;
    return l10n.pricingNoTrialNotice;
  }

  Future<void> _showPremiumActivatedDialog(
    BuildContext context,
    DateTime? expiresAt,
  ) {
    final l10n = context.l10n;
    final body = expiresAt == null
        ? l10n.pricingPurchaseSuccessBody
        : l10n.pricingPurchaseSuccessBodyUntil(
            expiresAt.toLocal().toString().split(' ').first,
          );

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.mdSurface,
        icon: const Icon(
          LucideIcons.badgeCheck,
          color: AppColors.mdPrimary,
          size: AppDimensions.iconLg,
        ),
        title: Text(l10n.pricingPurchaseSuccessTitle),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.pricingPurchaseSuccessAction),
          ),
        ],
      ),
    );
  }
}

class _ProductSelector extends StatelessWidget {
  const _ProductSelector({required this.state});

  final PricingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.isStoreAvailable || state.products.isEmpty) {
      return AppCard(
        color: AppColors.mdSurface,
        child: Text(
          !state.isStoreAvailable
              ? l10n.pricingStoreUnavailableMessage
              : l10n.pricingProductsMissingMessage,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final product in state.products) ...[
          _ProductOption(
            product: product,
            selected: product.id == state.selectedProductId,
            onTap: () => context.read<PricingCubit>().selectProduct(product.id),
          ),
          if (product != state.products.last)
            const SizedBox(height: AppDimensions.sm),
        ],
      ],
    );
  }
}

class _ProductOption extends StatelessWidget {
  const _ProductOption({
    required this.product,
    required this.selected,
    required this.onTap,
  });

  final PremiumProduct product;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = product.id == PremiumProductId.yearly
        ? l10n.pricingYearlyPlan
        : l10n.pricingMonthlyPlan;
    final subtitle = product.id == PremiumProductId.yearly
        ? l10n.pricingYearlyPlanSubtitle
        : l10n.pricingMonthlyPlanSubtitle;

    return AppCard(
      key: product.id == PremiumProductId.yearly
          ? AppTestKeys.pricingYearlyProduct
          : AppTestKeys.pricingMonthlyProduct,
      onTap: onTap,
      color: selected
          ? AppColors.mdPrimaryContainer.withValues(alpha: 0.4)
          : AppColors.mdSurface,
      borderColor: selected ? AppColors.mdPrimary : AppColors.whisperBorder,
      child: Row(
        children: [
          Icon(
            selected ? LucideIcons.checkCircle2 : LucideIcons.circle,
            color: selected
                ? AppColors.mdPrimary
                : AppColors.mdOnSurfaceVariant,
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(product.price, style: AppTextStyles.moneyXSmall),
        ],
      ),
    );
  }
}

class _PremiumActiveCard extends StatelessWidget {
  const _PremiumActiveCard({this.expiresAt});

  final DateTime? expiresAt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      color: AppColors.mdPrimaryContainer.withValues(alpha: 0.55),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.badgeCheck,
            color: AppColors.mdPrimary,
            size: AppDimensions.iconMd,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.pricingPremiumActiveTitle,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  expiresAt == null
                      ? l10n.pricingPremiumActiveBody
                      : l10n.pricingPremiumActiveUntil(
                          expiresAt!.toLocal().toString().split(' ').first,
                        ),
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
}

class _TrustCard extends StatelessWidget {
  const _TrustCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.mdSurface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.badgeCheck,
            color: AppColors.mdPrimary,
            size: AppDimensions.iconMd,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mdOnSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays tappable Privacy Policy and Terms of Service links.
///
/// Required by Apple Guideline 3.1.2(c) — must be present in any
/// screen that offers auto-renewable subscription purchases.
class _LegalLinksRow extends StatelessWidget {
  const _LegalLinksRow();

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => _launch(AppUrls.privacyPolicy),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.mdOnSurfaceVariant,
            textStyle: AppTextStyles.bodySmall,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.sm,
              vertical: AppDimensions.xs,
            ),
          ),
          child: Text(l10n.pricingPrivacyPolicy),
        ),
        Text(
          '·',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () => _launch(AppUrls.termsOfService),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.mdOnSurfaceVariant,
            textStyle: AppTextStyles.bodySmall,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.sm,
              vertical: AppDimensions.xs,
            ),
          ),
          child: Text(l10n.pricingTermsOfService),
        ),
      ],
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.backgroundColor,
    required this.icon,
    required this.bullets,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final Color backgroundColor;
  final IconData icon;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: backgroundColor.withValues(alpha: 0.55),
      borderRadius: AppDimensions.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          for (final bullet in bullets) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.check, size: 16, color: accentColor),
                const SizedBox(width: AppDimensions.sm),
                Expanded(child: Text(bullet, style: AppTextStyles.bodyMedium)),
              ],
            ),
            if (bullet != bullets.last)
              const SizedBox(height: AppDimensions.sm),
          ],
        ],
      ),
    );
  }
}
