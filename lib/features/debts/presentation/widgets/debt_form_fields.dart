import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
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
    final content = _contentFor(selectedDebtType);
    final recommendedInterest = DebtFormCubit.recommendedInterestMethodFor(
      selectedDebtType,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Loại khoản nợ',
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
                  label: 'Loại khoản nợ ${debtTypeDisplayName(type)}',
                  hint: selectedDebtType == type
                      ? 'Đang được chọn'
                      : 'Chạm để chuyển biểu mẫu sang ${debtTypeDisplayName(type)}',
                  child: AppChip.filter(
                    label: type.label,
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
          label: 'Tên khoản nợ',
          controller: nameController,
          hint: content.nameHint,
          helperText: content.nameHelper,
          prefixIcon: debtTypeIcon(selectedDebtType),
          errorText: nameError,
          required: true,
          onChanged: (_) => onCoreFieldChanged(),
        ),
        const SizedBox(height: 20),
        ..._buildBalanceFields(content),
        const SizedBox(height: 20),
        ..._buildPricingFields(content),
        if (showDueDayByDefault) ...[
          const SizedBox(height: 20),
          _buildDueDayField(content),
        ],
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: 20),
          ...warnings.map(_buildWarningCard),
        ],
        if (inlineError != null) ...[
          const SizedBox(height: 16),
          Semantics(
            container: true,
            liveRegion: true,
            label: 'Lỗi biểu mẫu. $inlineError',
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
          label: 'Thiết lập nâng cao',
          hint: showAdvanced
              ? 'Thu gọn các tuỳ chọn nâng cao'
              : 'Mở các tuỳ chọn nâng cao',
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
                        'Thiết lập nâng cao',
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
                    onChanged: (_) => onCoreFieldChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField.currency(
                    label: 'Mức sàn tối thiểu',
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
            Semantics(
              container: true,
              label: pausedUntil == null
                  ? 'Khoản nợ đang tạm dừng, chưa chọn ngày kết thúc'
                  : 'Khoản nợ đang tạm dừng đến ${AppFormatters.formatDate(pausedUntil!)}',
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

  List<Widget> _buildBalanceFields(_DebtTypeFormContent content) {
    final currentBalanceField = AppTextField.currency(
      key: AppTestKeys.debtFormCurrentBalance,
      label: 'Số dư còn lại',
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

  List<Widget> _buildPricingFields(_DebtTypeFormContent content) {
    return [
      Row(
        children: [
          Expanded(
            child: AppTextField.percentage(
              key: AppTestKeys.debtFormApr,
              label: 'Lãi suất (APR)',
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
            'Gợi ý cho ${content.displayName}',
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
                label:
                    'Lãi mặc định: ${_interestMethodLabel(recommendedInterest)}',
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

  Widget _buildWarningCard(String warning) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Semantics(
        container: true,
        liveRegion: true,
        label: 'Cảnh báo. $warning',
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

  String _interestMethodLabel(InterestMethod value) {
    switch (value) {
      case InterestMethod.simpleMonthly:
        return 'Lãi đơn theo tháng';
      case InterestMethod.compoundDaily:
        return 'Lãi kép theo ngày';
      case InterestMethod.compoundMonthly:
        return 'Lãi kép theo tháng';
    }
  }

  _DebtTypeFormContent _contentFor(DebtType type) {
    switch (type) {
      case DebtType.creditCard:
        return const _DebtTypeFormContent(
          displayName: 'Thẻ tín dụng',
          headline: 'Bám theo sao kê gần nhất',
          summary:
              'Ưu tiên số dư statement hiện tại, APR trên sao kê, và minimum payment của kỳ gần nhất.',
          nameHint: 'VD: Chase Sapphire, Citi Double Cash',
          nameHelper: 'Dùng tên nhà phát hành hoặc tên thẻ để dễ nhận diện.',
          balanceLabel: 'Số dư statement',
          balanceHelper: 'Nhập số dư bạn cần payoff lúc này.',
          originalPrincipalLabel: 'Số dư khi bắt đầu theo dõi',
          originalPrincipalHelper:
              'Tùy chọn. Hữu ích nếu bạn muốn app hiển thị tiến độ kể từ hôm nay.',
          deferredPrincipalHint:
              'Nếu bạn biết số dư khi bắt đầu theo dõi, mở Nâng cao để theo dõi tiến độ chính xác hơn.',
          aprHelper: 'Dùng APR hiện trên sao kê hoặc ứng dụng ngân hàng.',
          minimumPaymentLabel: 'Minimum payment',
          minimumPaymentHelper: 'Lấy trực tiếp từ sao kê gần nhất.',
          dueDayLabel: 'Ngày đến hạn sao kê',
          dueDayHint: 'VD: 15',
          dueDayHelper: 'Ngày bạn cần trả minimum để tránh fee và báo quá hạn.',
          advancedGuidance:
              'Thẻ tín dụng thường dùng lãi kép theo ngày. App đang gợi ý cấu hình đó làm mặc định.',
          minimumPaymentChip: 'Ưu tiên theo sao kê',
          cadenceChip: 'Thường trả hàng tháng',
          quickTips: ['Sao kê mới nhất', 'APR chính xác', 'Ngày đến hạn'],
        );
      case DebtType.studentLoan:
        return const _DebtTypeFormContent(
          displayName: 'Vay học tập',
          headline: 'Khoản vay trả góp dài hạn',
          summary:
              'Tập trung vào dư nợ còn lại, khoản trả tối thiểu cố định, và ngày auto-debit hàng tháng.',
          nameHint: 'VD: Federal Loan, Sallie Mae',
          nameHelper:
              'Dùng tên servicer hoặc khoản vay để không nhầm giữa các loan.',
          balanceLabel: 'Dư nợ còn lại',
          balanceHelper: 'Lấy số principal còn nợ từ portal của khoản vay.',
          originalPrincipalLabel: 'Số tiền vay ban đầu',
          originalPrincipalHelper:
              'Giúp app hiển thị tiến độ payoff từ lúc giải ngân.',
          deferredPrincipalHint: null,
          aprHelper: 'Nhiều khoản vay học tập dùng APR cố định theo tháng.',
          minimumPaymentLabel: 'Khoản trả tối thiểu',
          minimumPaymentHelper: 'Lấy từ lịch trả hàng tháng hiện tại.',
          dueDayLabel: 'Ngày auto-debit',
          dueDayHint: 'VD: 5',
          dueDayHelper: 'Ngày hệ thống thường rút tiền hoặc đến hạn trả.',
          advancedGuidance:
              'Vay học tập thường có kỳ hạn ổn định; simple monthly là cấu hình mặc định phù hợp.',
          minimumPaymentChip: 'Khoản trả cố định',
          cadenceChip: 'Thường trả hàng tháng',
          quickTips: [
            'Principal còn lại',
            'Auto-debit',
            'Có thể tạm dừng nếu deferment',
          ],
        );
      case DebtType.carLoan:
        return const _DebtTypeFormContent(
          displayName: 'Vay mua xe',
          headline: 'Khoản vay trả góp tài sản',
          summary:
              'Ưu tiên principal còn lại, khoản trả cố định, và ngày đến hạn chuẩn để tránh trễ kỳ.',
          nameHint: 'VD: Toyota Financial, Wells Fargo Auto',
          nameHelper: 'Gắn với lender hoặc chiếc xe để dễ đối chiếu.',
          balanceLabel: 'Principal còn lại',
          balanceHelper: 'Lấy dư nợ gốc còn lại từ lender nếu có.',
          originalPrincipalLabel: 'Giá trị khoản vay ban đầu',
          originalPrincipalHelper:
              'Giúp bạn nhìn rõ tiến độ đã trả được bao nhiêu phần khoản vay.',
          deferredPrincipalHint: null,
          aprHelper:
              'Vay mua xe thường dùng APR cố định và lãi kép theo tháng.',
          minimumPaymentLabel: 'Khoản trả hàng tháng',
          minimumPaymentHelper: 'Nhập đúng nghĩa vụ tối thiểu mỗi kỳ.',
          dueDayLabel: 'Ngày đến hạn',
          dueDayHint: 'VD: 12',
          dueDayHelper: 'Ngày lender chốt bạn đã trả kỳ hiện tại hay chưa.',
          advancedGuidance:
              'Khoản vay mua xe thường khớp với compound monthly và minimum payment cố định.',
          minimumPaymentChip: 'Khoản trả cố định',
          cadenceChip: 'Thường trả hàng tháng',
          quickTips: ['APR cố định', 'Principal còn lại', 'Ngày đến hạn'],
        );
      case DebtType.mortgage:
        return const _DebtTypeFormContent(
          displayName: 'Thế chấp',
          headline: 'Theo dõi principal, không phải giá nhà',
          summary:
              'Hãy nhập phần gốc còn nợ, khoản trả tối thiểu hàng tháng, và ngày đến hạn mortgage.',
          nameHint: 'VD: Primary Home Mortgage',
          nameHelper: 'Dùng tên khoản vay hoặc địa chỉ rút gọn.',
          balanceLabel: 'Principal còn lại',
          balanceHelper: 'Chỉ nhập phần dư nợ gốc, không nhập giá trị căn nhà.',
          originalPrincipalLabel: 'Số tiền vay ban đầu',
          originalPrincipalHelper:
              'Dùng số tiền mortgage ban đầu để app tính phần trăm đã trả.',
          deferredPrincipalHint: null,
          aprHelper: 'Mortgage tiêu chuẩn thường đi theo lãi đơn theo tháng.',
          minimumPaymentLabel: 'Khoản trả tối thiểu',
          minimumPaymentHelper:
              'Chỉ nhập nghĩa vụ tối thiểu mỗi tháng, chưa gồm extra principal.',
          dueDayLabel: 'Ngày đến hạn mortgage',
          dueDayHint: 'VD: 1',
          dueDayHelper: 'Nhiều mortgage đến hạn vào đầu tháng.',
          advancedGuidance:
              'Với mortgage, simple monthly và minimum cố định thường là cấu hình gần thực tế nhất.',
          minimumPaymentChip: 'Khoản trả cố định',
          cadenceChip: 'Thường trả hàng tháng',
          quickTips: [
            'Chỉ principal',
            'Ngày mùng 1 phổ biến',
            'Extra trả thêm nhập sau',
          ],
        );
      case DebtType.personal:
        return const _DebtTypeFormContent(
          displayName: 'Vay cá nhân',
          headline: 'Khoản vay trả góp không tài sản',
          summary:
              'Tập trung vào dư nợ gốc, khoản trả tối thiểu hiện tại, và ngày lender thu tiền mỗi kỳ.',
          nameHint: 'VD: SoFi Personal Loan, LendingClub',
          nameHelper: 'Dùng tên lender hoặc mục đích khoản vay.',
          balanceLabel: 'Dư nợ còn lại',
          balanceHelper: 'Lấy từ ứng dụng lender hoặc statement gần nhất.',
          originalPrincipalLabel: 'Số tiền vay ban đầu',
          originalPrincipalHelper:
              'Giúp app thể hiện tiến độ trả nợ của khoản vay cá nhân.',
          deferredPrincipalHint: null,
          aprHelper: 'Vay cá nhân thường là lãi kép theo tháng.',
          minimumPaymentLabel: 'Khoản trả tối thiểu',
          minimumPaymentHelper: 'Nhập nghĩa vụ thanh toán hiện tại mỗi kỳ.',
          dueDayLabel: 'Ngày đến hạn',
          dueDayHint: 'VD: 18',
          dueDayHelper: 'Ngày lender đánh dấu bạn bị trễ hạn nếu chưa trả.',
          advancedGuidance:
              'Vay cá nhân thường mang cấu hình amortization chuẩn: compound monthly và khoản trả cố định.',
          minimumPaymentChip: 'Khoản trả cố định',
          cadenceChip: 'Có thể bi-weekly hoặc monthly',
          quickTips: ['Khoản trả cố định', 'Ngày đến hạn', 'APR của lender'],
        );
      case DebtType.medical:
        return const _DebtTypeFormContent(
          displayName: 'Nợ y tế',
          headline: 'Thường là kế hoạch trả mềm',
          summary:
              'Nếu khoản nợ không bị tính lãi, hãy nhập APR là 0 và dùng khoản thanh toán đã thoả thuận.',
          nameHint: 'VD: City Hospital Billing',
          nameHelper: 'Dùng tên bệnh viện, phòng khám, hoặc đơn vị thu hộ.',
          balanceLabel: 'Số tiền còn phải thanh toán',
          balanceHelper: 'Nhập số dư còn lại trên kế hoạch trả góp hiện tại.',
          originalPrincipalLabel: 'Tổng bill ban đầu',
          originalPrincipalHelper:
              'Tùy chọn. Dùng khi bạn muốn xem mình đã trả được bao nhiêu phần hoá đơn.',
          deferredPrincipalHint:
              'Nếu bạn muốn tracking tổng bill ban đầu, mở Nâng cao để nhập số tiền gốc.',
          aprHelper:
              'Nhiều kế hoạch trả nợ y tế là 0%, nên nhập 0 nếu đúng thực tế.',
          minimumPaymentLabel: 'Khoản thanh toán kỳ này',
          minimumPaymentHelper:
              'Nhập đúng số đã được bệnh viện hoặc agency yêu cầu.',
          dueDayLabel: 'Ngày hẹn thanh toán',
          dueDayHint: 'VD: 20',
          dueDayHelper:
              'Có thể để trống và mặc định 15 nếu chưa có lịch rõ ràng.',
          advancedGuidance:
              'Nợ y tế thường đơn giản hơn: minimum cố định, APR có thể bằng 0, và không cần quá nhiều cấu hình.',
          minimumPaymentChip: 'Thường theo thoả thuận',
          cadenceChip: 'Thường trả hàng tháng',
          quickTips: [
            'APR có thể bằng 0',
            'Theo kế hoạch trả góp',
            'Có thể không có ngày cố định',
          ],
        );
      case DebtType.other:
        return const _DebtTypeFormContent(
          displayName: 'Khoản nợ khác',
          headline: 'Thiết lập linh hoạt theo thực tế',
          summary:
              'Dùng mục này cho các khoản không khớp loại chuẩn. Hãy nhập số dư, APR, minimum, rồi tinh chỉnh ở Nâng cao.',
          nameHint: 'VD: Store Financing, Family Loan',
          nameHelper: 'Đặt tên đủ rõ để sau này bạn còn nhớ đây là khoản nào.',
          balanceLabel: 'Số dư còn lại',
          balanceHelper: 'Nhập số bạn đang còn nợ ở thời điểm hiện tại.',
          originalPrincipalLabel: 'Số tiền gốc ban đầu',
          originalPrincipalHelper:
              'Tùy chọn. Hữu ích nếu bạn muốn app hiển thị tiến độ tốt hơn.',
          deferredPrincipalHint:
              'Bạn có thể thêm số tiền gốc ban đầu trong Nâng cao nếu muốn theo dõi tiến độ.',
          aprHelper: 'Không chắc APR? Hãy bắt đầu với 0 và cập nhật sau.',
          minimumPaymentLabel: 'Khoản thanh toán tối thiểu',
          minimumPaymentHelper: 'Nhập mức tối thiểu bạn phải trả mỗi kỳ.',
          dueDayLabel: 'Ngày đến hạn',
          dueDayHint: 'VD: 15',
          dueDayHelper: 'Nếu chưa rõ, cứ để mặc định rồi chỉnh lại sau.',
          advancedGuidance:
              'Mục này linh hoạt nhất. Bạn có thể giữ cấu hình mặc định trước rồi tinh chỉnh khi đã rõ thông tin.',
          minimumPaymentChip: 'Linh hoạt theo thực tế',
          cadenceChip: 'Cadence có thể thay đổi',
          quickTips: ['Linh hoạt', 'Có thể bắt đầu với 0%', 'Tinh chỉnh sau'],
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
