import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class LogPaymentPage extends StatefulWidget {
  const LogPaymentPage({super.key, required this.id});
  final String id;

  @override
  State<LogPaymentPage> createState() => _LogPaymentPageState();
}

class _LogPaymentPageState extends State<LogPaymentPage> {
  final _amountController = TextEditingController(text: '285');
  final _noteController = TextEditingController();
  final _dateController = TextEditingController(text: 'Hôm nay, 16 tháng 4, 2026');
  String _selectedType = 'min';

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Payment'),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Debt Context (Select which debt to pay)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mdSurfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.mdPrimaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.creditCard, color: AppColors.mdOnPrimaryContainer, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chase Sapphire Reserve', style: AppTextStyles.titleSmall),
                        const SizedBox(height: 2),
                        Text('Dư nợ: \$5,200', style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant)),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronDown, size: 18, color: AppColors.mdOnSurfaceVariant),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Amount
            Text('Số tiền thanh toán', style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdOnSurfaceVariant)),
            const SizedBox(height: 8),
            IntrinsicWidth(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$', style: AppTextStyles.titleLarge.copyWith(color: AppColors.mdOnSurfaceVariant, fontFamily: 'Geist', fontSize: 28)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      style: const TextStyle(fontFamily: 'Geist', fontSize: 56, fontWeight: FontWeight.w700, letterSpacing: -1, color: AppColors.mdOnSurface),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: AppColors.mdPrimary),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildQuickAmount('Min: \$125', false),
                _buildQuickAmount('+\$50', true),
                _buildQuickAmount('Toàn bộ: \$5,200', false),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Payment Type
            Text('Loại payment', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTypeChip('min', 'Minimum')),
                const SizedBox(width: 8),
                Expanded(child: _buildTypeChip('extra', 'Trả thêm')),
                const SizedBox(width: 8),
                Expanded(child: _buildTypeChip('lump', 'Cục bộ')),
              ],
            ),
            
            const SizedBox(height: 32),
            
            AppTextField(
              controller: _dateController,
              label: 'Ngày thanh toán',
              readOnly: true,
              prefixIcon: LucideIcons.calendar, // In real app use trailing or inkwell
            ),
            
            const SizedBox(height: 16),
            
            AppTextField(
              controller: _noteController,
              label: 'Ghi chú (Tùy chọn)',
              hint: 'VD: Tax refund tháng 4...',
            ),
            
            const SizedBox(height: 32),
            
            // Balance Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mdSurfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mdOutlineVariant),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Số dư sau payment', style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text('\$4,915', style: AppTextStyles.titleLarge.copyWith(color: AppColors.mdPrimary, fontFamily: 'Roboto Mono', fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Giảm', style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.arrowDownRight, size: 16, color: AppColors.mdPrimary),
                          Text('\$285', style: AppTextStyles.titleSmall.copyWith(color: AppColors.mdPrimary)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.mdSurface,
          border: Border(top: BorderSide(color: AppColors.mdOutlineVariant)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              AppButton.outlined(
                onPressed: () => context.pop(),
                label: 'Hủy',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton.filled(
                  onPressed: () {
                    context.pop();
                  },
                  label: 'Xác nhận',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmount(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.mdSecondaryContainer : AppColors.mdSurfaceContainerLow,
        borderRadius: BorderRadius.circular(100),
        border: isSelected ? null : Border.all(color: AppColors.mdOutlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.mdOnSecondaryContainer : AppColors.mdOnSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTypeChip(String id, String label) {
    final isSelected = _selectedType == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mdSecondaryContainer : AppColors.mdSurfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: AppColors.mdOutlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.mdOnSecondaryContainer : AppColors.mdOnSurface,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
