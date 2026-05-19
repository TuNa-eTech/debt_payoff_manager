import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../domain/enums/debt_status.dart';
import '../../../../domain/enums/debt_type.dart';
import '../../../../domain/enums/interest_method.dart';
import '../../../../domain/enums/min_payment_type.dart';
import '../../../../domain/enums/payment_cadence.dart';
import '../../../../l10n/app_localizations.dart';
import '../../cubit/debt_form_cubit.dart';
import '../debt_ui_utils.dart';

/// Reusable debt form fields widget for both add and edit flows.
///
/// Encapsulates all input fields needed to define a debt:
/// name, type, balances, APR, minimum payment, due date, and advanced options.
///
/// Used by: [AddDebtPage], [DebtEntryPage] (onboarding).
class DebtFormFields extends StatelessWidget {
  const DebtFormFields({
    super.key,
    required this.mode,
    required this.nameController,
    required this.currentBalanceController,
    required this.aprController,
    required this.minPaymentController,
    required this.originalPrincipalController,
    required this.dueDateController,
    required this.minimumPaymentPercentController,
    required this.minimumPaymentFloorController,
    required this.selectedDebtType,
    required this.interestMethod,
    required this.minimumPaymentType,
    required this.paymentCadence,
    required this.status,
    required this.excludeFromStrategy,
    required this.showAdvanced,
    required this.showOriginalPrincipalByDefault,
    required this.showDueDayByDefault,
    required this.onDebtTypeChanged,
    required this.onInterestMethodChanged,
    required this.onMinimumPaymentTypeChanged,
    required this.onPaymentCadenceChanged,
    required this.onStatusChanged,
    required this.onExcludeFromStrategyChanged,
    required this.onToggleAdvanced,
    required this.onCoreFieldChanged,
    required this.onSelectPausedUntil,
    required this.onClearPausedUntil,
    this.pausedUntil,
    this.nameError,
    this.originalPrincipalError,
    this.currentBalanceError,
    this.aprError,
    this.minPaymentError,
    this.dueDayError,
    this.minimumPaymentPercentError,
    this.minimumPaymentFloorError,
    this.pausedUntilError,
    this.inlineError,
    this.warnings = const [],
  });

  final DebtFormMode mode;
  final TextEditingController nameController;
  final TextEditingController currentBalanceController;
  final TextEditingController aprController;
  final TextEditingController minPaymentController;
  final TextEditingController originalPrincipalController;
  final TextEditingController dueDateController;
  final TextEditingController minimumPaymentPercentController;
  final TextEditingController minimumPaymentFloorController;
  final DebtType selectedDebtType;
  final InterestMethod interestMethod;
  final MinPaymentType minimumPaymentType;
  final PaymentCadence paymentCadence;
  final DebtStatus status;
  final bool excludeFromStrategy;
  final bool showAdvanced;
  final bool showOriginalPrincipalByDefault;
  final bool showDueDayByDefault;
  final ValueChanged<DebtType> onDebtTypeChanged;
  final ValueChanged<InterestMethod> onInterestMethodChanged;
  final ValueChanged<MinPaymentType> onMinimumPaymentTypeChanged;
  final ValueChanged<PaymentCadence> onPaymentCadenceChanged;
  final ValueChanged<DebtStatus> onStatusChanged;
  final ValueChanged<bool> onExcludeFromStrategyChanged;
  final VoidCallback onToggleAdvanced;
  final VoidCallback onCoreFieldChanged;
  final VoidCallback onSelectPausedUntil;
  final VoidCallback onClearPausedUntil;
  final DateTime? pausedUntil;
  final String? nameError;
  final String? originalPrincipalError;
  final String? currentBalanceError;
  final String? aprError;
  final String? minPaymentError;
  final String? dueDayError;
  final String? minimumPaymentPercentError;
  final String? minimumPaymentFloorError;
  final String? pausedUntilError;
  final String? inlineError;
  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final content = _contentFor(selectedDebtType, l10n);
    final recommendedInterest = DebtFormCubit.recommendedInterestMethodFor(
      selectedDebtType,
    );

    if (mode == DebtFormMode.onboarding) {
      return _buildOnboardingMinimalFields(
        context: context,
        content: content,
        l10n: l10n,
        recommendedInterest: recommendedInterest,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.debtFormDebtTypeLabel,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Wrap(
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.sm,
          children: DebtType.values
              .map(
                (type) => Semantics(
                  button: true,
                  selected: selectedDebtType == type,
                  label: l10n.debtFormDebtTypeSemantic(
                    debtTypeDisplayName(type, l10n),
                  ),
                  hint: selectedDebtType == type
                      ? l10n.debtFormSelectedHint
                      : l10n.debtFormSwitchTypeHint(
                          debtTypeDisplayName(type, l10n),
                        ),
                  child: AppChip.filter(
                    label: debtTypeDisplayName(type, l10n),
                    selected: selectedDebtType == type,
                    onTap: () => onDebtTypeChanged(type),
                    icon: debtTypeIcon(type),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppDimensions.md),
        _buildTypeOverview(content),
        const SizedBox(height: 28),
        AppTextField(
          key: AppTestKeys.debtFormName,
          label: l10n.debtFormNameLabel,
          controller: nameController,
          hint: content.nameHint,
          helperText: content.nameHelper,
          prefixIcon: debtTypeIcon(selectedDebtType),
          errorText: nameError,
          required: true,
          onChanged: (_) => onCoreFieldChanged(),
        ),
        const SizedBox(height: 20),
        ..._buildBalanceFields(content, l10n),
        const SizedBox(height: 20),
        ..._buildPricingFields(content, l10n),
        if (showDueDayByDefault) ...[
          const SizedBox(height: 20),
          _buildDueDayField(content),
        ],
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: 20),
          ...warnings.map((warning) => _buildWarningCard(warning, l10n)),
        ],
        if (inlineError != null) ...[
          const SizedBox(height: 16),
          Semantics(
            container: true,
            liveRegion: true,
            label: l10n.debtFormInlineErrorSemantic(inlineError!),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.mdErrorContainer,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Text(
                inlineError!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mdOnErrorContainer,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        Semantics(
          button: true,
          toggled: showAdvanced,
          label: l10n.debtFormAdvancedSettings,
          hint: showAdvanced
              ? l10n.debtFormCollapseAdvanced
              : l10n.debtFormOpenAdvanced,
          child: InkWell(
            key: AppTestKeys.debtFormAdvancedToggle,
            onTap: onToggleAdvanced,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.mdSurfaceContainerLow,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: AppColors.mdOutlineVariant),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.slidersHorizontal,
                        size: 18,
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.debtFormAdvancedSettings,
                        style: AppTextStyles.titleSmall,
                      ),
                    ],
                  ),
                  Icon(
                    showAdvanced
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 18,
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showAdvanced) ...[
          const SizedBox(height: 16),
          _buildDefaultsCard(
            content: content,
            recommendedInterest: recommendedInterest,
            l10n: l10n,
          ),
          if (!showOriginalPrincipalByDefault) ...[
            const SizedBox(height: 16),
            AppTextField.currency(
              key: AppTestKeys.debtFormOriginalPrincipal,
              label: content.originalPrincipalLabel,
              controller: originalPrincipalController,
              helperText: content.originalPrincipalHelper,
              errorText: originalPrincipalError,
              onChanged: (_) => onCoreFieldChanged(),
            ),
          ],
          if (!showDueDayByDefault) ...[
            const SizedBox(height: 16),
            _buildDueDayField(content),
          ],
          const SizedBox(height: 20),
          _buildEnumSection<InterestMethod>(
            title: l10n.debtFormInterestMethodSection,
            values: InterestMethod.values,
            selected: interestMethod,
            labelBuilder: (method) => _interestMethodLabel(method, l10n),
            onSelected: onInterestMethodChanged,
          ),
          const SizedBox(height: 20),
          _buildEnumSection<MinPaymentType>(
            title: l10n.debtFormMinimumPaymentMethodSection,
            values: MinPaymentType.values,
            selected: minimumPaymentType,
            labelBuilder: (type) => _minimumPaymentTypeLabel(type, l10n),
            onSelected: onMinimumPaymentTypeChanged,
          ),
          if (minimumPaymentType != MinPaymentType.fixed) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField.percentage(
                    label: l10n.debtFormMinimumPercentLabel,
                    controller: minimumPaymentPercentController,
                    errorText: minimumPaymentPercentError,
                    onChanged: (_) => onCoreFieldChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField.currency(
                    label: l10n.debtFormMinimumFloorLabel,
                    controller: minimumPaymentFloorController,
                    errorText: minimumPaymentFloorError,
                    onChanged: (_) => onCoreFieldChanged(),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          _buildEnumSection<PaymentCadence>(
            title: l10n.debtFormPaymentCadenceSection,
            values: PaymentCadence.values,
            selected: paymentCadence,
            labelBuilder: (cadence) => _paymentCadenceLabel(cadence, l10n),
            onSelected: onPaymentCadenceChanged,
          ),
          const SizedBox(height: 20),
          _buildEnumSection<DebtStatus>(
            title: l10n.debtFormStatusSection,
            values: _statusValues,
            selected: status,
            labelBuilder: (status) => _statusLabel(status, l10n),
            onSelected: onStatusChanged,
          ),
          if (status == DebtStatus.paused) ...[
            const SizedBox(height: 16),
            Semantics(
              container: true,
              label: pausedUntil == null
                  ? l10n.debtFormPausedNoDateSemantic
                  : l10n.debtFormPausedUntilSemantic(
                      AppFormatters.formatDate(pausedUntil!),
                    ),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.mdSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.mdOutlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.debtFormPausedUntilLabel,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pausedUntil == null
                                ? l10n.debtFormNoDateSelected
                                : AppFormatters.formatDate(pausedUntil!),
                            style: AppTextStyles.titleSmall,
                          ),
                        ),
                        AppChip.assist(
                          label: l10n.debtFormChooseDate,
                          icon: LucideIcons.calendar,
                          onTap: onSelectPausedUntil,
                        ),
                        if (pausedUntil != null) ...[
                          const SizedBox(width: 8),
                          AppChip.assist(
                            label: l10n.commonDelete,
                            icon: LucideIcons.x,
                            onTap: onClearPausedUntil,
                          ),
                        ],
                      ],
                    ),
                    if (pausedUntilError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        pausedUntilError!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mdError,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SwitchListTile(
            value: excludeFromStrategy,
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.debtFormExcludeFromStrategyTitle,
              style: AppTextStyles.bodyLarge,
            ),
            subtitle: Text(
              l10n.debtFormExcludeFromStrategySubtitle,
              style: AppTextStyles.bodySmall,
            ),
            onChanged: onExcludeFromStrategyChanged,
            activeThumbColor: AppColors.mdPrimary,
            activeTrackColor: AppColors.mdPrimary.withValues(alpha: 0.24),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildBalanceFields(
    _DebtTypeFormContent content,
    AppLocalizations l10n,
  ) {
    final currentBalanceField = AppTextField.currency(
      key: AppTestKeys.debtFormCurrentBalance,
      label: l10n.debtFormCurrentBalanceLabel,
      controller: currentBalanceController,
      helperText: '${content.balanceLabel}: ${content.balanceHelper}',
      errorText: currentBalanceError,
      required: true,
      onChanged: (_) => onCoreFieldChanged(),
    );

    final originalPrincipalField = AppTextField.currency(
      key: AppTestKeys.debtFormOriginalPrincipal,
      label: content.originalPrincipalLabel,
      controller: originalPrincipalController,
      helperText: content.originalPrincipalHelper,
      errorText: originalPrincipalError,
      required: mode != DebtFormMode.onboarding,
      onChanged: (_) => onCoreFieldChanged(),
    );

    if (!showOriginalPrincipalByDefault) {
      return [
        currentBalanceField,
        if (content.deferredPrincipalHint != null) ...[
          const SizedBox(height: 8),
          Text(
            content.deferredPrincipalHint!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
        ],
      ];
    }

    if (mode == DebtFormMode.onboarding) {
      return [
        currentBalanceField,
        const SizedBox(height: 16),
        originalPrincipalField,
      ];
    }

    return [
      Row(
        children: [
          Expanded(child: currentBalanceField),
          const SizedBox(width: 12),
          Expanded(child: originalPrincipalField),
        ],
      ),
    ];
  }

  List<Widget> _buildPricingFields(
    _DebtTypeFormContent content,
    AppLocalizations l10n,
  ) {
    return [
      Row(
        children: [
          Expanded(
            child: AppTextField.percentage(
              key: AppTestKeys.debtFormApr,
              label: l10n.debtFormAprLabel,
              controller: aprController,
              helperText: content.aprHelper,
              errorText: aprError,
              required: true,
              onChanged: (_) => onCoreFieldChanged(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppTextField.currency(
              key: AppTestKeys.debtFormMinimumPayment,
              label: content.minimumPaymentLabel,
              controller: minPaymentController,
              helperText: content.minimumPaymentHelper,
              errorText: minPaymentError,
              required: true,
              onChanged: (_) => onCoreFieldChanged(),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildOnboardingMinimalFields({
    required BuildContext context,
    required _DebtTypeFormContent content,
    required AppLocalizations l10n,
    required InterestMethod recommendedInterest,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.onboardingDebtDetailsTitle(
            debtTypeDisplayName(selectedDebtType, l10n),
          ),
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          l10n.onboardingDebtDetailsSubtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.lg),
        AppTextField(
          key: AppTestKeys.debtFormName,
          label: l10n.debtFormNameLabel,
          controller: nameController,
          hint: content.nameHint,
          helperText: content.nameHelper,
          prefixIcon: debtTypeIcon(selectedDebtType),
          errorText: nameError,
          required: true,
          onChanged: (_) => onCoreFieldChanged(),
        ),
        const SizedBox(height: AppDimensions.md),
        AppTextField.currency(
          key: AppTestKeys.debtFormCurrentBalance,
          label: l10n.debtFormCurrentBalanceLabel,
          controller: currentBalanceController,
          helperText: l10n.onboardingDebtBalanceHelper,
          errorText: currentBalanceError,
          required: true,
          onChanged: (_) => onCoreFieldChanged(),
        ),
        const SizedBox(height: AppDimensions.md),
        AppTextField.percentage(
          key: AppTestKeys.debtFormApr,
          label: l10n.debtFormAprLabel,
          controller: aprController,
          helperText: l10n.onboardingDebtAprHelper,
          errorText: aprError,
          required: true,
          onChanged: (_) => onCoreFieldChanged(),
        ),
        const SizedBox(height: AppDimensions.md),
        AppTextField.currency(
          key: AppTestKeys.debtFormMinimumPayment,
          label: content.minimumPaymentLabel,
          controller: minPaymentController,
          helperText: l10n.onboardingDebtMinimumPaymentHelper,
          errorText: minPaymentError,
          required: true,
          onChanged: (_) => onCoreFieldChanged(),
        ),
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.md),
          ...warnings.map((warning) => _buildWarningCard(warning, l10n)),
        ],
        if (inlineError != null) ...[
          const SizedBox(height: AppDimensions.md),
          Semantics(
            container: true,
            liveRegion: true,
            label: l10n.debtFormInlineErrorSemantic(inlineError!),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.mdErrorContainer,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Text(
                inlineError!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mdOnErrorContainer,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.lg),
        Semantics(
          button: true,
          toggled: showAdvanced,
          label: l10n.onboardingDebtOptionalDetails,
          child: InkWell(
            key: AppTestKeys.onboardingDebtOptionalDetails,
            onTap: onToggleAdvanced,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.mdSurfaceContainerLow,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: AppColors.mdOutlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.slidersHorizontal,
                    size: AppDimensions.iconSm,
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.onboardingDebtOptionalDetails,
                          style: AppTextStyles.titleSmall,
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        Text(
                          l10n.onboardingDebtOptionalDetailsSubtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mdOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    showAdvanced
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: AppDimensions.iconSm,
                    color: AppColors.mdOnSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showAdvanced) ...[
          const SizedBox(height: AppDimensions.md),
          AppTextField.currency(
            key: AppTestKeys.debtFormOriginalPrincipal,
            label: content.originalPrincipalLabel,
            controller: originalPrincipalController,
            helperText: content.originalPrincipalHelper,
            errorText: originalPrincipalError,
            onChanged: (_) => onCoreFieldChanged(),
          ),
          const SizedBox(height: AppDimensions.md),
          _buildDueDayField(content),
          const SizedBox(height: AppDimensions.md),
          _buildDefaultsCard(
            content: content,
            recommendedInterest: recommendedInterest,
            l10n: l10n,
          ),
          const SizedBox(height: AppDimensions.md),
          _buildEnumSection<InterestMethod>(
            title: l10n.debtFormInterestMethodSection,
            values: InterestMethod.values,
            selected: interestMethod,
            labelBuilder: (method) => _interestMethodLabel(method, l10n),
            onSelected: onInterestMethodChanged,
          ),
          const SizedBox(height: AppDimensions.md),
          _buildEnumSection<MinPaymentType>(
            title: l10n.debtFormMinimumPaymentMethodSection,
            values: MinPaymentType.values,
            selected: minimumPaymentType,
            labelBuilder: (type) => _minimumPaymentTypeLabel(type, l10n),
            onSelected: onMinimumPaymentTypeChanged,
          ),
          if (minimumPaymentType != MinPaymentType.fixed) ...[
            const SizedBox(height: AppDimensions.md),
            AppTextField.percentage(
              label: l10n.debtFormMinimumPercentLabel,
              controller: minimumPaymentPercentController,
              errorText: minimumPaymentPercentError,
              onChanged: (_) => onCoreFieldChanged(),
            ),
            const SizedBox(height: AppDimensions.md),
            AppTextField.currency(
              label: l10n.debtFormMinimumFloorLabel,
              controller: minimumPaymentFloorController,
              errorText: minimumPaymentFloorError,
              onChanged: (_) => onCoreFieldChanged(),
            ),
          ],
          const SizedBox(height: AppDimensions.md),
          _buildEnumSection<PaymentCadence>(
            title: l10n.debtFormPaymentCadenceSection,
            values: PaymentCadence.values,
            selected: paymentCadence,
            labelBuilder: (cadence) => _paymentCadenceLabel(cadence, l10n),
            onSelected: onPaymentCadenceChanged,
          ),
          const SizedBox(height: AppDimensions.md),
          _buildEnumSection<DebtStatus>(
            title: l10n.debtFormStatusSection,
            values: _statusValues,
            selected: status,
            labelBuilder: (status) => _statusLabel(status, l10n),
            onSelected: onStatusChanged,
          ),
          if (status == DebtStatus.paused) ...[
            const SizedBox(height: AppDimensions.md),
            Semantics(
              container: true,
              label: pausedUntil == null
                  ? l10n.debtFormPausedNoDateSemantic
                  : l10n.debtFormPausedUntilSemantic(
                      AppFormatters.formatDate(pausedUntil!),
                    ),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.mdSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.mdOutlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.debtFormPausedUntilLabel,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pausedUntil == null
                                ? l10n.debtFormNoDateSelected
                                : AppFormatters.formatDate(pausedUntil!),
                            style: AppTextStyles.titleSmall,
                          ),
                        ),
                        AppChip.assist(
                          label: l10n.debtFormChooseDate,
                          icon: LucideIcons.calendar,
                          onTap: onSelectPausedUntil,
                        ),
                        if (pausedUntil != null) ...[
                          const SizedBox(width: AppDimensions.sm),
                          AppChip.assist(
                            label: l10n.commonDelete,
                            icon: LucideIcons.x,
                            onTap: onClearPausedUntil,
                          ),
                        ],
                      ],
                    ),
                    if (pausedUntilError != null) ...[
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        pausedUntilError!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mdError,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.md),
          SwitchListTile(
            value: excludeFromStrategy,
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.debtFormExcludeFromStrategyTitle,
              style: AppTextStyles.bodyLarge,
            ),
            subtitle: Text(
              l10n.debtFormExcludeFromStrategySubtitle,
              style: AppTextStyles.bodySmall,
            ),
            onChanged: onExcludeFromStrategyChanged,
            activeThumbColor: AppColors.mdPrimary,
            activeTrackColor: AppColors.mdPrimary.withValues(alpha: 0.24),
          ),
        ],
      ],
    );
  }

  Widget _buildDueDayField(_DebtTypeFormContent content) {
    return AppTextField(
      key: AppTestKeys.debtFormDueDay,
      label: content.dueDayLabel,
      controller: dueDateController,
      hint: content.dueDayHint,
      helperText: content.dueDayHelper,
      prefixIcon: LucideIcons.calendar,
      keyboardType: TextInputType.number,
      errorText: dueDayError,
      onChanged: (_) => onCoreFieldChanged(),
    );
  }

  Widget _buildTypeOverview(_DebtTypeFormContent content) {
    final accent = debtTypeColor(selectedDebtType);
    return Semantics(
      container: true,
      label: '${content.displayName}. ${content.headline}. ${content.summary}',
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.mdSurfaceContainerLow,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.mdOutlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    debtTypeIcon(selectedDebtType),
                    color: accent,
                    size: AppDimensions.iconMd,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.displayName,
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        content.headline,
                        style: AppTextStyles.bodySmall.copyWith(color: accent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(content.summary, style: AppTextStyles.bodySmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: AppDimensions.sm,
              runSpacing: AppDimensions.sm,
              children: content.quickTips
                  .map(
                    (tip) =>
                        AppChip.status(label: tip, icon: LucideIcons.sparkles),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultsCard({
    required _DebtTypeFormContent content,
    required InterestMethod recommendedInterest,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.mdSurfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.mdOutlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.debtFormSuggestionTitle(content.displayName),
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            content.advancedGuidance,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            children: [
              AppChip.status(
                label: l10n.debtFormDefaultInterest(
                  _interestMethodLabel(recommendedInterest, l10n),
                ),
                icon: LucideIcons.percent,
              ),
              AppChip.status(
                label: content.minimumPaymentChip,
                icon: LucideIcons.walletCards,
              ),
              AppChip.status(
                label: content.cadenceChip,
                icon: LucideIcons.calendar,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(String warning, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Semantics(
        container: true,
        liveRegion: true,
        label: l10n.debtFormWarningSemantic(warning),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: AppColors.mdPrimaryContainer,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                LucideIcons.alertTriangle,
                size: 16,
                color: AppColors.mdPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  warning,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mdOnPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnumSection<T>({
    required String title,
    required List<T> values,
    required T selected,
    required String Function(T value) labelBuilder,
    required ValueChanged<T> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.sm,
          children: values
              .map(
                (value) => Semantics(
                  button: true,
                  selected: selected == value,
                  label: labelBuilder(value),
                  child: AppChip.filter(
                    label: labelBuilder(value),
                    selected: selected == value,
                    onTap: () => onSelected(value),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  String _statusLabel(DebtStatus value, AppLocalizations l10n) {
    switch (value) {
      case DebtStatus.active:
        return l10n.debtStatusActive;
      case DebtStatus.paidOff:
        return l10n.debtStatusPaidOff;
      case DebtStatus.paused:
        return l10n.debtStatusPaused;
      case DebtStatus.archived:
        return l10n.debtStatusArchived;
    }
  }

  String _interestMethodLabel(InterestMethod value, AppLocalizations l10n) {
    switch (value) {
      case InterestMethod.simpleMonthly:
        return l10n.interestMethodSimpleMonthly;
      case InterestMethod.compoundDaily:
        return l10n.interestMethodCompoundDaily;
      case InterestMethod.compoundMonthly:
        return l10n.interestMethodCompoundMonthly;
    }
  }

  String _minimumPaymentTypeLabel(MinPaymentType value, AppLocalizations l10n) {
    switch (value) {
      case MinPaymentType.fixed:
        return l10n.minimumPaymentTypeFixed;
      case MinPaymentType.percentOfBalance:
        return l10n.minimumPaymentTypePercentOfBalance;
      case MinPaymentType.interestPlusPercent:
        return l10n.minimumPaymentTypeInterestPlusPercent;
    }
  }

  String _paymentCadenceLabel(PaymentCadence value, AppLocalizations l10n) {
    switch (value) {
      case PaymentCadence.monthly:
        return l10n.paymentCadenceMonthly;
      case PaymentCadence.biweekly:
        return l10n.paymentCadenceBiweekly;
      case PaymentCadence.weekly:
        return l10n.paymentCadenceWeekly;
      case PaymentCadence.semimonthly:
        return l10n.paymentCadenceSemimonthly;
    }
  }

  _DebtTypeFormContent _contentFor(DebtType type, AppLocalizations l10n) {
    switch (type) {
      case DebtType.creditCard:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypeCreditCard,
          headline: l10n.debtFormCreditCardHeadline,
          summary: l10n.debtFormCreditCardSummary,
          nameHint: l10n.debtFormCreditCardNameHint,
          nameHelper: l10n.debtFormCreditCardNameHelper,
          balanceLabel: l10n.debtFormCreditCardBalanceLabel,
          balanceHelper: l10n.debtFormCreditCardBalanceHelper,
          originalPrincipalLabel: l10n.debtFormCreditCardOriginalPrincipalLabel,
          originalPrincipalHelper:
              l10n.debtFormCreditCardOriginalPrincipalHelper,
          deferredPrincipalHint: l10n.debtFormCreditCardDeferredPrincipalHint,
          aprHelper: l10n.debtFormCreditCardAprHelper,
          minimumPaymentLabel: l10n.debtFormMinimumPaymentLabel,
          minimumPaymentHelper: l10n.debtFormCreditCardMinimumPaymentHelper,
          dueDayLabel: l10n.debtFormCreditCardDueDayLabel,
          dueDayHint: l10n.debtFormCreditCardDueDayHint,
          dueDayHelper: l10n.debtFormCreditCardDueDayHelper,
          advancedGuidance: l10n.debtFormCreditCardAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormStatementPriorityChip,
          cadenceChip: l10n.debtFormMonthlyCadenceChip,
          quickTips: [
            l10n.debtFormTipLatestStatement,
            l10n.debtFormTipAccurateApr,
            l10n.debtFormTipDueDate,
          ],
        );
      case DebtType.studentLoan:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypeStudentLoan,
          headline: l10n.debtFormStudentLoanHeadline,
          summary: l10n.debtFormStudentLoanSummary,
          nameHint: l10n.debtFormStudentLoanNameHint,
          nameHelper: l10n.debtFormStudentLoanNameHelper,
          balanceLabel: l10n.debtFormRemainingBalanceLabel,
          balanceHelper: l10n.debtFormStudentLoanBalanceHelper,
          originalPrincipalLabel: l10n.debtFormOriginalLoanAmountLabel,
          originalPrincipalHelper:
              l10n.debtFormStudentLoanOriginalPrincipalHelper,
          deferredPrincipalHint: null,
          aprHelper: l10n.debtFormStudentLoanAprHelper,
          minimumPaymentLabel: l10n.debtFormMinimumPaymentLabel,
          minimumPaymentHelper: l10n.debtFormStudentLoanMinimumPaymentHelper,
          dueDayLabel: l10n.debtFormAutoDebitDayLabel,
          dueDayHint: l10n.debtFormStudentLoanDueDayHint,
          dueDayHelper: l10n.debtFormStudentLoanDueDayHelper,
          advancedGuidance: l10n.debtFormStudentLoanAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormFixedPaymentChip,
          cadenceChip: l10n.debtFormMonthlyCadenceChip,
          quickTips: [
            l10n.debtFormTipRemainingPrincipal,
            l10n.debtFormTipAutoDebit,
            l10n.debtFormTipDefermentPause,
          ],
        );
      case DebtType.carLoan:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypeCarLoan,
          headline: l10n.debtFormCarLoanHeadline,
          summary: l10n.debtFormCarLoanSummary,
          nameHint: l10n.debtFormCarLoanNameHint,
          nameHelper: l10n.debtFormCarLoanNameHelper,
          balanceLabel: l10n.debtFormRemainingPrincipalLabel,
          balanceHelper: l10n.debtFormCarLoanBalanceHelper,
          originalPrincipalLabel: l10n.debtFormOriginalLoanValueLabel,
          originalPrincipalHelper: l10n.debtFormCarLoanOriginalPrincipalHelper,
          deferredPrincipalHint: null,
          aprHelper: l10n.debtFormCarLoanAprHelper,
          minimumPaymentLabel: l10n.debtFormMonthlyPaymentLabel,
          minimumPaymentHelper: l10n.debtFormMinimumObligationHelper,
          dueDayLabel: l10n.debtFormDueDayLabel,
          dueDayHint: l10n.debtFormCarLoanDueDayHint,
          dueDayHelper: l10n.debtFormCarLoanDueDayHelper,
          advancedGuidance: l10n.debtFormCarLoanAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormFixedPaymentChip,
          cadenceChip: l10n.debtFormMonthlyCadenceChip,
          quickTips: [
            l10n.debtFormTipFixedApr,
            l10n.debtFormTipRemainingPrincipal,
            l10n.debtFormTipDueDate,
          ],
        );
      case DebtType.mortgage:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypeMortgage,
          headline: l10n.debtFormMortgageHeadline,
          summary: l10n.debtFormMortgageSummary,
          nameHint: l10n.debtFormMortgageNameHint,
          nameHelper: l10n.debtFormMortgageNameHelper,
          balanceLabel: l10n.debtFormRemainingPrincipalLabel,
          balanceHelper: l10n.debtFormMortgageBalanceHelper,
          originalPrincipalLabel: l10n.debtFormOriginalLoanAmountLabel,
          originalPrincipalHelper: l10n.debtFormMortgageOriginalPrincipalHelper,
          deferredPrincipalHint: null,
          aprHelper: l10n.debtFormMortgageAprHelper,
          minimumPaymentLabel: l10n.debtFormMinimumPaymentLabel,
          minimumPaymentHelper: l10n.debtFormMortgageMinimumPaymentHelper,
          dueDayLabel: l10n.debtFormMortgageDueDayLabel,
          dueDayHint: l10n.debtFormMortgageDueDayHint,
          dueDayHelper: l10n.debtFormMortgageDueDayHelper,
          advancedGuidance: l10n.debtFormMortgageAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormFixedPaymentChip,
          cadenceChip: l10n.debtFormMonthlyCadenceChip,
          quickTips: [
            l10n.debtFormTipPrincipalOnly,
            l10n.debtFormTipFirstDayCommon,
            l10n.debtFormTipExtraLater,
          ],
        );
      case DebtType.personal:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypePersonal,
          headline: l10n.debtFormPersonalLoanHeadline,
          summary: l10n.debtFormPersonalLoanSummary,
          nameHint: l10n.debtFormPersonalLoanNameHint,
          nameHelper: l10n.debtFormPersonalLoanNameHelper,
          balanceLabel: l10n.debtFormRemainingBalanceLabel,
          balanceHelper: l10n.debtFormPersonalLoanBalanceHelper,
          originalPrincipalLabel: l10n.debtFormOriginalLoanAmountLabel,
          originalPrincipalHelper:
              l10n.debtFormPersonalLoanOriginalPrincipalHelper,
          deferredPrincipalHint: null,
          aprHelper: l10n.debtFormPersonalLoanAprHelper,
          minimumPaymentLabel: l10n.debtFormMinimumPaymentLabel,
          minimumPaymentHelper: l10n.debtFormPersonalLoanMinimumPaymentHelper,
          dueDayLabel: l10n.debtFormDueDayLabel,
          dueDayHint: l10n.debtFormPersonalLoanDueDayHint,
          dueDayHelper: l10n.debtFormPersonalLoanDueDayHelper,
          advancedGuidance: l10n.debtFormPersonalLoanAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormFixedPaymentChip,
          cadenceChip: l10n.debtFormFlexibleCadenceChip,
          quickTips: [
            l10n.debtFormTipFixedPayment,
            l10n.debtFormTipDueDate,
            l10n.debtFormTipLenderApr,
          ],
        );
      case DebtType.medical:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypeMedical,
          headline: l10n.debtFormMedicalHeadline,
          summary: l10n.debtFormMedicalSummary,
          nameHint: l10n.debtFormMedicalNameHint,
          nameHelper: l10n.debtFormMedicalNameHelper,
          balanceLabel: l10n.debtFormMedicalBalanceLabel,
          balanceHelper: l10n.debtFormMedicalBalanceHelper,
          originalPrincipalLabel: l10n.debtFormMedicalOriginalPrincipalLabel,
          originalPrincipalHelper: l10n.debtFormMedicalOriginalPrincipalHelper,
          deferredPrincipalHint: l10n.debtFormMedicalDeferredPrincipalHint,
          aprHelper: l10n.debtFormMedicalAprHelper,
          minimumPaymentLabel: l10n.debtFormMedicalMinimumPaymentLabel,
          minimumPaymentHelper: l10n.debtFormMedicalMinimumPaymentHelper,
          dueDayLabel: l10n.debtFormMedicalDueDayLabel,
          dueDayHint: l10n.debtFormMedicalDueDayHint,
          dueDayHelper: l10n.debtFormMedicalDueDayHelper,
          advancedGuidance: l10n.debtFormMedicalAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormAgreementPaymentChip,
          cadenceChip: l10n.debtFormMonthlyCadenceChip,
          quickTips: [
            l10n.debtFormTipAprCanBeZero,
            l10n.debtFormTipPaymentPlan,
            l10n.debtFormTipNoFixedDate,
          ],
        );
      case DebtType.paydayLoan:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypePaydayLoan,
          headline: l10n.debtFormOtherHeadline,
          summary: l10n.debtFormOtherSummary,
          nameHint: l10n.debtFormOtherNameHint,
          nameHelper: l10n.debtFormOtherNameHelper,
          balanceLabel: l10n.debtFormRemainingBalanceLabel,
          balanceHelper: l10n.debtFormOtherBalanceHelper,
          originalPrincipalLabel: l10n.debtFormOriginalPrincipalLabel,
          originalPrincipalHelper: l10n.debtFormOtherOriginalPrincipalHelper,
          deferredPrincipalHint: l10n.debtFormOtherDeferredPrincipalHint,
          aprHelper: l10n.debtFormOtherAprHelper,
          minimumPaymentLabel: l10n.debtFormMinimumPaymentLabel,
          minimumPaymentHelper: l10n.debtFormOtherMinimumPaymentHelper,
          dueDayLabel: l10n.debtFormDueDayLabel,
          dueDayHint: l10n.debtFormOtherDueDayHint,
          dueDayHelper: l10n.debtFormOtherDueDayHelper,
          advancedGuidance: l10n.debtFormOtherAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormFlexiblePaymentChip,
          cadenceChip: l10n.debtFormVariableCadenceChip,
          quickTips: [
            l10n.debtFormTipAccurateApr,
            l10n.debtFormTipDueDate,
            l10n.debtFormTipAdjustLater,
          ],
        );
      case DebtType.buyNowPayLater:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypeBuyNowPayLater,
          headline: l10n.debtFormPersonalLoanHeadline,
          summary: l10n.debtFormPersonalLoanSummary,
          nameHint: l10n.debtFormOtherNameHint,
          nameHelper: l10n.debtFormOtherNameHelper,
          balanceLabel: l10n.debtFormRemainingBalanceLabel,
          balanceHelper: l10n.debtFormPersonalLoanBalanceHelper,
          originalPrincipalLabel: l10n.debtFormOriginalPrincipalLabel,
          originalPrincipalHelper:
              l10n.debtFormPersonalLoanOriginalPrincipalHelper,
          deferredPrincipalHint: null,
          aprHelper: l10n.debtFormOtherAprHelper,
          minimumPaymentLabel: l10n.debtFormMinimumPaymentLabel,
          minimumPaymentHelper: l10n.debtFormPersonalLoanMinimumPaymentHelper,
          dueDayLabel: l10n.debtFormDueDayLabel,
          dueDayHint: l10n.debtFormOtherDueDayHint,
          dueDayHelper: l10n.debtFormOtherDueDayHelper,
          advancedGuidance: l10n.debtFormPersonalLoanAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormFixedPaymentChip,
          cadenceChip: l10n.debtFormFlexibleCadenceChip,
          quickTips: [
            l10n.debtFormTipFixedPayment,
            l10n.debtFormTipAprCanBeZero,
            l10n.debtFormTipDueDate,
          ],
        );
      case DebtType.storeFinancing:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypeStoreFinancing,
          headline: l10n.debtFormPersonalLoanHeadline,
          summary: l10n.debtFormPersonalLoanSummary,
          nameHint: l10n.debtFormOtherNameHint,
          nameHelper: l10n.debtFormOtherNameHelper,
          balanceLabel: l10n.debtFormRemainingBalanceLabel,
          balanceHelper: l10n.debtFormPersonalLoanBalanceHelper,
          originalPrincipalLabel: l10n.debtFormOriginalLoanAmountLabel,
          originalPrincipalHelper:
              l10n.debtFormPersonalLoanOriginalPrincipalHelper,
          deferredPrincipalHint: null,
          aprHelper: l10n.debtFormPersonalLoanAprHelper,
          minimumPaymentLabel: l10n.debtFormMinimumPaymentLabel,
          minimumPaymentHelper: l10n.debtFormPersonalLoanMinimumPaymentHelper,
          dueDayLabel: l10n.debtFormDueDayLabel,
          dueDayHint: l10n.debtFormOtherDueDayHint,
          dueDayHelper: l10n.debtFormOtherDueDayHelper,
          advancedGuidance: l10n.debtFormPersonalLoanAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormFixedPaymentChip,
          cadenceChip: l10n.debtFormMonthlyCadenceChip,
          quickTips: [
            l10n.debtFormTipFixedPayment,
            l10n.debtFormTipLenderApr,
            l10n.debtFormTipDueDate,
          ],
        );
      case DebtType.lineOfCredit:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypeLineOfCredit,
          headline: l10n.debtFormCreditCardHeadline,
          summary: l10n.debtFormCreditCardSummary,
          nameHint: l10n.debtFormOtherNameHint,
          nameHelper: l10n.debtFormOtherNameHelper,
          balanceLabel: l10n.debtFormRemainingBalanceLabel,
          balanceHelper: l10n.debtFormCreditCardBalanceHelper,
          originalPrincipalLabel: l10n.debtFormCreditCardOriginalPrincipalLabel,
          originalPrincipalHelper:
              l10n.debtFormCreditCardOriginalPrincipalHelper,
          deferredPrincipalHint: l10n.debtFormCreditCardDeferredPrincipalHint,
          aprHelper: l10n.debtFormCreditCardAprHelper,
          minimumPaymentLabel: l10n.debtFormMinimumPaymentLabel,
          minimumPaymentHelper: l10n.debtFormCreditCardMinimumPaymentHelper,
          dueDayLabel: l10n.debtFormDueDayLabel,
          dueDayHint: l10n.debtFormOtherDueDayHint,
          dueDayHelper: l10n.debtFormOtherDueDayHelper,
          advancedGuidance: l10n.debtFormCreditCardAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormStatementPriorityChip,
          cadenceChip: l10n.debtFormMonthlyCadenceChip,
          quickTips: [
            l10n.debtFormTipAccurateApr,
            l10n.debtFormTipDueDate,
            l10n.debtFormTipAdjustLater,
          ],
        );
      case DebtType.taxDebt:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypeTaxDebt,
          headline: l10n.debtFormPersonalLoanHeadline,
          summary: l10n.debtFormPersonalLoanSummary,
          nameHint: l10n.debtFormOtherNameHint,
          nameHelper: l10n.debtFormOtherNameHelper,
          balanceLabel: l10n.debtFormRemainingBalanceLabel,
          balanceHelper: l10n.debtFormPersonalLoanBalanceHelper,
          originalPrincipalLabel: l10n.debtFormOriginalPrincipalLabel,
          originalPrincipalHelper:
              l10n.debtFormPersonalLoanOriginalPrincipalHelper,
          deferredPrincipalHint: null,
          aprHelper: l10n.debtFormOtherAprHelper,
          minimumPaymentLabel: l10n.debtFormMinimumPaymentLabel,
          minimumPaymentHelper: l10n.debtFormPersonalLoanMinimumPaymentHelper,
          dueDayLabel: l10n.debtFormDueDayLabel,
          dueDayHint: l10n.debtFormOtherDueDayHint,
          dueDayHelper: l10n.debtFormOtherDueDayHelper,
          advancedGuidance: l10n.debtFormPersonalLoanAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormAgreementPaymentChip,
          cadenceChip: l10n.debtFormMonthlyCadenceChip,
          quickTips: [
            l10n.debtFormTipPaymentPlan,
            l10n.debtFormTipAccurateApr,
            l10n.debtFormTipDueDate,
          ],
        );
      case DebtType.collections:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypeCollections,
          headline: l10n.debtFormMedicalHeadline,
          summary: l10n.debtFormMedicalSummary,
          nameHint: l10n.debtFormOtherNameHint,
          nameHelper: l10n.debtFormMedicalNameHelper,
          balanceLabel: l10n.debtFormMedicalBalanceLabel,
          balanceHelper: l10n.debtFormMedicalBalanceHelper,
          originalPrincipalLabel: l10n.debtFormOriginalPrincipalLabel,
          originalPrincipalHelper: l10n.debtFormMedicalOriginalPrincipalHelper,
          deferredPrincipalHint: l10n.debtFormMedicalDeferredPrincipalHint,
          aprHelper: l10n.debtFormMedicalAprHelper,
          minimumPaymentLabel: l10n.debtFormMedicalMinimumPaymentLabel,
          minimumPaymentHelper: l10n.debtFormMedicalMinimumPaymentHelper,
          dueDayLabel: l10n.debtFormDueDayLabel,
          dueDayHint: l10n.debtFormOtherDueDayHint,
          dueDayHelper: l10n.debtFormOtherDueDayHelper,
          advancedGuidance: l10n.debtFormMedicalAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormAgreementPaymentChip,
          cadenceChip: l10n.debtFormMonthlyCadenceChip,
          quickTips: [
            l10n.debtFormTipPaymentPlan,
            l10n.debtFormTipAprCanBeZero,
            l10n.debtFormTipAdjustLater,
          ],
        );
      case DebtType.familyLoan:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypeFamilyLoan,
          headline: l10n.debtFormOtherHeadline,
          summary: l10n.debtFormOtherSummary,
          nameHint: l10n.debtFormOtherNameHint,
          nameHelper: l10n.debtFormOtherNameHelper,
          balanceLabel: l10n.debtFormRemainingBalanceLabel,
          balanceHelper: l10n.debtFormOtherBalanceHelper,
          originalPrincipalLabel: l10n.debtFormOriginalPrincipalLabel,
          originalPrincipalHelper: l10n.debtFormOtherOriginalPrincipalHelper,
          deferredPrincipalHint: l10n.debtFormOtherDeferredPrincipalHint,
          aprHelper: l10n.debtFormOtherAprHelper,
          minimumPaymentLabel: l10n.debtFormMinimumPaymentLabel,
          minimumPaymentHelper: l10n.debtFormOtherMinimumPaymentHelper,
          dueDayLabel: l10n.debtFormDueDayLabel,
          dueDayHint: l10n.debtFormOtherDueDayHint,
          dueDayHelper: l10n.debtFormOtherDueDayHelper,
          advancedGuidance: l10n.debtFormOtherAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormFlexiblePaymentChip,
          cadenceChip: l10n.debtFormVariableCadenceChip,
          quickTips: [
            l10n.debtFormTipAprCanBeZero,
            l10n.debtFormTipFlexible,
            l10n.debtFormTipAdjustLater,
          ],
        );
      case DebtType.homeEquity:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypeHomeEquity,
          headline: l10n.debtFormMortgageHeadline,
          summary: l10n.debtFormMortgageSummary,
          nameHint: l10n.debtFormMortgageNameHint,
          nameHelper: l10n.debtFormMortgageNameHelper,
          balanceLabel: l10n.debtFormRemainingPrincipalLabel,
          balanceHelper: l10n.debtFormMortgageBalanceHelper,
          originalPrincipalLabel: l10n.debtFormOriginalLoanAmountLabel,
          originalPrincipalHelper: l10n.debtFormMortgageOriginalPrincipalHelper,
          deferredPrincipalHint: null,
          aprHelper: l10n.debtFormMortgageAprHelper,
          minimumPaymentLabel: l10n.debtFormMinimumPaymentLabel,
          minimumPaymentHelper: l10n.debtFormMortgageMinimumPaymentHelper,
          dueDayLabel: l10n.debtFormMortgageDueDayLabel,
          dueDayHint: l10n.debtFormMortgageDueDayHint,
          dueDayHelper: l10n.debtFormMortgageDueDayHelper,
          advancedGuidance: l10n.debtFormMortgageAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormFixedPaymentChip,
          cadenceChip: l10n.debtFormMonthlyCadenceChip,
          quickTips: [
            l10n.debtFormTipPrincipalOnly,
            l10n.debtFormTipLenderApr,
            l10n.debtFormTipExtraLater,
          ],
        );
      case DebtType.other:
        return _DebtTypeFormContent(
          displayName: l10n.debtTypeOther,
          headline: l10n.debtFormOtherHeadline,
          summary: l10n.debtFormOtherSummary,
          nameHint: l10n.debtFormOtherNameHint,
          nameHelper: l10n.debtFormOtherNameHelper,
          balanceLabel: l10n.debtFormRemainingBalanceLabel,
          balanceHelper: l10n.debtFormOtherBalanceHelper,
          originalPrincipalLabel: l10n.debtFormOriginalPrincipalLabel,
          originalPrincipalHelper: l10n.debtFormOtherOriginalPrincipalHelper,
          deferredPrincipalHint: l10n.debtFormOtherDeferredPrincipalHint,
          aprHelper: l10n.debtFormOtherAprHelper,
          minimumPaymentLabel: l10n.debtFormMinimumPaymentLabel,
          minimumPaymentHelper: l10n.debtFormOtherMinimumPaymentHelper,
          dueDayLabel: l10n.debtFormDueDayLabel,
          dueDayHint: l10n.debtFormOtherDueDayHint,
          dueDayHelper: l10n.debtFormOtherDueDayHelper,
          advancedGuidance: l10n.debtFormOtherAdvancedGuidance,
          minimumPaymentChip: l10n.debtFormFlexiblePaymentChip,
          cadenceChip: l10n.debtFormVariableCadenceChip,
          quickTips: [
            l10n.debtFormTipFlexible,
            l10n.debtFormTipStartAtZero,
            l10n.debtFormTipAdjustLater,
          ],
        );
    }
  }

  static const List<DebtStatus> _statusValues = [
    DebtStatus.active,
    DebtStatus.paidOff,
    DebtStatus.paused,
  ];
}

@immutable
class _DebtTypeFormContent {
  const _DebtTypeFormContent({
    required this.displayName,
    required this.headline,
    required this.summary,
    required this.nameHint,
    required this.nameHelper,
    required this.balanceLabel,
    required this.balanceHelper,
    required this.originalPrincipalLabel,
    required this.originalPrincipalHelper,
    required this.deferredPrincipalHint,
    required this.aprHelper,
    required this.minimumPaymentLabel,
    required this.minimumPaymentHelper,
    required this.dueDayLabel,
    required this.dueDayHint,
    required this.dueDayHelper,
    required this.advancedGuidance,
    required this.minimumPaymentChip,
    required this.cadenceChip,
    required this.quickTips,
  });

  final String displayName;
  final String headline;
  final String summary;
  final String nameHint;
  final String nameHelper;
  final String balanceLabel;
  final String balanceHelper;
  final String originalPrincipalLabel;
  final String originalPrincipalHelper;
  final String? deferredPrincipalHint;
  final String aprHelper;
  final String minimumPaymentLabel;
  final String minimumPaymentHelper;
  final String dueDayLabel;
  final String dueDayHint;
  final String dueDayHelper;
  final String advancedGuidance;
  final String minimumPaymentChip;
  final String cadenceChip;
  final List<String> quickTips;
}
