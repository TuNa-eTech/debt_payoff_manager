import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../cubit/debt_form_cubit.dart';
import '../../../../domain/enums/debt_status.dart';
import '../../../../domain/enums/debt_type.dart';
import '../../../../domain/enums/interest_method.dart';
import '../../../../domain/enums/min_payment_type.dart';
import '../../../../domain/enums/payment_cadence.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Loại khoản nợ',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.sm,
          children: DebtType.values
              .map(
                (type) => AppChip.filter(
                  label: type.label,
                  selected: selectedDebtType == type,
                  onTap: () => onDebtTypeChanged(type),
                  icon: _iconForType(type),
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 28),

        AppTextField(
          key: AppTestKeys.debtFormName,
          label: 'Tên khoản nợ',
          controller: nameController,
          hint: 'VD: Chase Sapphire, Vay mua xe...',
          prefixIcon: LucideIcons.tag,
          errorText: nameError,
          required: true,
          onChanged: (_) => onCoreFieldChanged(),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: AppTextField.currency(
                key: AppTestKeys.debtFormCurrentBalance,
                label: 'Số dư còn lại',
                controller: currentBalanceController,
                errorText: currentBalanceError,
                required: true,
                onChanged: (_) => onCoreFieldChanged(),
              ),
            ),
            if (mode != DebtFormMode.onboarding) ...[
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField.currency(
                  key: AppTestKeys.debtFormOriginalPrincipal,
                  label: 'Số gốc ban đầu',
                  controller: originalPrincipalController,
                  errorText: originalPrincipalError,
                  required: true,
                  onChanged: (_) => onCoreFieldChanged(),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: AppTextField.percentage(
                key: AppTestKeys.debtFormApr,
                label: 'Lãi suất (APR)',
                controller: aprController,
                errorText: aprError,
                required: true,
                onChanged: (_) => onCoreFieldChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField.currency(
                key: AppTestKeys.debtFormMinimumPayment,
                label: 'Minimum payment',
                controller: minPaymentController,
                helperText: 'Theo statement hiện tại',
                errorText: minPaymentError,
                required: true,
                onChanged: (_) => onCoreFieldChanged(),
              ),
            ),
          ],
        ),

        if (mode != DebtFormMode.onboarding) ...[
          const SizedBox(height: 20),
          AppTextField(
            key: AppTestKeys.debtFormDueDay,
            label: 'Ngày đến hạn hàng tháng',
            controller: dueDateController,
            hint: 'VD: 15',
            prefixIcon: LucideIcons.calendar,
            keyboardType: TextInputType.number,
            errorText: dueDayError,
          ),
        ],

        if (warnings.isNotEmpty) ...[
          const SizedBox(height: 20),
          ...warnings.map(_buildWarningCard),
        ],

        if (inlineError != null) ...[
          const SizedBox(height: 16),
          Container(
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
        ],

        const SizedBox(height: 28),

        InkWell(
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
                    Text('Thiết lập nâng cao', style: AppTextStyles.titleSmall),
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

        if (showAdvanced) ...[
          const SizedBox(height: 16),
          if (mode == DebtFormMode.onboarding) ...[
            AppTextField.currency(
              key: AppTestKeys.debtFormOriginalPrincipal,
              label: 'Số gốc ban đầu',
              controller: originalPrincipalController,
              helperText: 'Nếu bỏ trống, app sẽ dùng số dư hiện tại.',
              errorText: originalPrincipalError,
              onChanged: (_) => onCoreFieldChanged(),
            ),
            const SizedBox(height: 16),
            AppTextField(
              key: AppTestKeys.debtFormDueDay,
              label: 'Ngày đến hạn hàng tháng',
              controller: dueDateController,
              hint: 'VD: 15',
              prefixIcon: LucideIcons.calendar,
              keyboardType: TextInputType.number,
              errorText: dueDayError,
            ),
            const SizedBox(height: 20),
          ],
          _buildEnumSection<InterestMethod>(
            title: 'Cách tính lãi',
            values: InterestMethod.values,
            selected: interestMethod,
            labelBuilder: (method) => method.label,
            onSelected: onInterestMethodChanged,
          ),
          const SizedBox(height: 20),
          _buildEnumSection<MinPaymentType>(
            title: 'Cách tính minimum payment',
            values: MinPaymentType.values,
            selected: minimumPaymentType,
            labelBuilder: (type) => type.label,
            onSelected: onMinimumPaymentTypeChanged,
          ),
          if (minimumPaymentType != MinPaymentType.fixed) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField.percentage(
                    label: 'Phần trăm tối thiểu',
                    controller: minimumPaymentPercentController,
                    errorText: minimumPaymentPercentError,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField.currency(
                    label: 'Mức sàn tối thiểu',
                    controller: minimumPaymentFloorController,
                    errorText: minimumPaymentFloorError,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          _buildEnumSection<PaymentCadence>(
            title: 'Chu kỳ thanh toán',
            values: PaymentCadence.values,
            selected: paymentCadence,
            labelBuilder: (cadence) => cadence.label,
            onSelected: onPaymentCadenceChanged,
          ),
          const SizedBox(height: 20),
          _buildEnumSection<DebtStatus>(
            title: 'Trạng thái',
            values: _statusValues,
            selected: status,
            labelBuilder: _statusLabel,
            onSelected: onStatusChanged,
          ),
          if (status == DebtStatus.paused) ...[
            const SizedBox(height: 16),
            Container(
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
                    'Tạm dừng đến',
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
                              ? 'Chưa chọn ngày'
                              : AppFormatters.formatDate(pausedUntil!),
                          style: AppTextStyles.titleSmall,
                        ),
                      ),
                      AppChip.assist(
                        label: 'Chọn ngày',
                        icon: LucideIcons.calendar,
                        onTap: onSelectPausedUntil,
                      ),
                      if (pausedUntil != null) ...[
                        const SizedBox(width: 8),
                        AppChip.assist(
                          label: 'Xóa',
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
          ],
          const SizedBox(height: 20),
          SwitchListTile(
            value: excludeFromStrategy,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Loại khỏi chiến lược payoff',
              style: AppTextStyles.bodyLarge,
            ),
            subtitle: Text(
              'Khoản nợ này vẫn được lưu nhưng không được ưu tiên trong plan.',
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

  Widget _buildWarningCard(String warning) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
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
                (value) => AppChip.filter(
                  label: labelBuilder(value),
                  selected: selected == value,
                  onTap: () => onSelected(value),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  IconData _iconForType(DebtType type) {
    switch (type) {
      case DebtType.creditCard:
        return LucideIcons.creditCard;
      case DebtType.studentLoan:
        return LucideIcons.graduationCap;
      case DebtType.carLoan:
        return LucideIcons.car;
      case DebtType.mortgage:
        return LucideIcons.home;
      case DebtType.personal:
        return LucideIcons.wallet;
      case DebtType.medical:
        return LucideIcons.heartPulse;
      case DebtType.other:
        return LucideIcons.circleEllipsis;
    }
  }

  static const List<DebtStatus> _statusValues = [
    DebtStatus.active,
    DebtStatus.paidOff,
    DebtStatus.paused,
  ];

  String _statusLabel(DebtStatus value) {
    switch (value) {
      case DebtStatus.active:
        return 'Đang hoạt động';
      case DebtStatus.paidOff:
        return 'Đã trả xong';
      case DebtStatus.paused:
        return 'Tạm dừng';
      case DebtStatus.archived:
        return 'Đã lưu trữ';
    }
  }
}
