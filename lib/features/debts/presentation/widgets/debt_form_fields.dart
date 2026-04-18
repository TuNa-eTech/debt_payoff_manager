import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Reusable debt form fields widget for both add and edit flows.
///
/// Encapsulates all input fields needed to define a debt:
/// name, type, balance, APR, minimum payment, due date.
///
/// Used by: [AddDebtPage], [DebtEntryPage] (onboarding).
class DebtFormFields extends StatelessWidget {
  const DebtFormFields({
    super.key,
    required this.nameController,
    required this.balanceController,
    required this.aprController,
    required this.minPaymentController,
    this.dueDateController,
    this.selectedDebtType = 0,
    this.onDebtTypeChanged,
    this.nameError,
    this.balanceError,
    this.aprError,
    this.minPaymentError,
    this.showUsuryWarning = false,
  });

  final TextEditingController nameController;
  final TextEditingController balanceController;
  final TextEditingController aprController;
  final TextEditingController minPaymentController;
  final TextEditingController? dueDateController;
  final int selectedDebtType;
  final ValueChanged<int>? onDebtTypeChanged;
  final String? nameError;
  final String? balanceError;
  final String? aprError;
  final String? minPaymentError;
  final bool showUsuryWarning;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Debt Type Selector ──
        Text(
          'Loại khoản nợ',
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdOnSurfaceVariant),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _DebtTypeChip(
                icon: LucideIcons.creditCard,
                label: 'Thẻ tín dụng',
                isSelected: selectedDebtType == 0,
                onTap: () => onDebtTypeChanged?.call(0),
              ),
              const SizedBox(width: 8),
              _DebtTypeChip(
                icon: LucideIcons.car,
                label: 'Vay mua xe',
                isSelected: selectedDebtType == 1,
                onTap: () => onDebtTypeChanged?.call(1),
              ),
              const SizedBox(width: 8),
              _DebtTypeChip(
                icon: LucideIcons.graduationCap,
                label: 'Vay sinh viên',
                isSelected: selectedDebtType == 2,
                onTap: () => onDebtTypeChanged?.call(2),
              ),
              const SizedBox(width: 8),
              _DebtTypeChip(
                icon: LucideIcons.home,
                label: 'Thế chấp',
                isSelected: selectedDebtType == 3,
                onTap: () => onDebtTypeChanged?.call(3),
              ),
              const SizedBox(width: 8),
              _DebtTypeChip(
                icon: LucideIcons.heartPulse,
                label: 'Nợ y tế',
                isSelected: selectedDebtType == 4,
                onTap: () => onDebtTypeChanged?.call(4),
              ),
              const SizedBox(width: 8),
              _DebtTypeChip(
                icon: LucideIcons.banknote,
                label: 'Vay cá nhân',
                isSelected: selectedDebtType == 5,
                onTap: () => onDebtTypeChanged?.call(5),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ── Debt Name ──
        AppTextField(
          label: 'Tên khoản nợ',
          controller: nameController,
          hint: 'VD: Chase Sapphire, Vay mua xe...',
          prefixIcon: LucideIcons.tag,
          errorText: nameError,
          required: true,
        ),

        const SizedBox(height: 20),

        // ── Balance + APR Row ──
        Row(
          children: [
            Expanded(
              child: AppTextField.currency(
                label: 'Số dư còn lại',
                controller: balanceController,
                errorText: balanceError,
                required: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField.percentage(
                    label: 'Lãi suất (APR)',
                    controller: aprController,
                    errorText: aprError,
                    required: true,
                  ),
                  if (showUsuryWarning) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.alertTriangle, size: 12, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'APR > 36% — lãi suất cao',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Minimum Payment ──
        AppTextField.currency(
          label: 'Thanh toán tối thiểu/tháng',
          controller: minPaymentController,
          helperText: 'Số tiền tối thiểu bạn phải trả hàng tháng',
          errorText: minPaymentError,
          required: true,
        ),

        const SizedBox(height: 20),

        // ── Due Date (Optional) ──
        if (dueDateController != null)
          AppTextField(
            label: 'Ngày đến hạn hàng tháng',
            controller: dueDateController!,
            hint: 'VD: 15',
            prefixIcon: LucideIcons.calendar,
            keyboardType: TextInputType.number,
          ),
      ],
    );
  }
}

/// Individual debt type chip for the type selector.
class _DebtTypeChip extends StatelessWidget {
  const _DebtTypeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mdSecondaryContainer : AppColors.mdSurfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: AppColors.mdOutlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.mdOnSecondaryContainer : AppColors.mdOnSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.mdOnSecondaryContainer : AppColors.mdOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
