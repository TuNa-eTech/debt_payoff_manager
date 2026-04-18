import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_text_field.dart';

class DebtEntryPage extends StatefulWidget {
  const DebtEntryPage({super.key});

  @override
  State<DebtEntryPage> createState() => _DebtEntryPageState();
}

class _DebtEntryPageState extends State<DebtEntryPage> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _aprController = TextEditingController();
  final _minPaymentController = TextEditingController();

  String _selectedType = 'Thẻ tín dụng';
  final _debtTypes = ['Thẻ tín dụng', 'Vay mua xe', 'Vay y tế', 'Khác'];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _aprController.dispose();
    _minPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Thêm khoản nợ'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bước 1/3',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.mdOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.33,
                          backgroundColor: AppColors.mdSurfaceContainerHighest,
                          color: AppColors.mdPrimary,
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 4,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Debt Type
                    Text(
                      'Loại khoản nợ',
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _debtTypes.map((type) {
                        return AppChip.filter(
                          label: type,
                          selected: _selectedType == type,
                          onTap: () {
                            setState(() {
                              _selectedType = type;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Fields
                    AppTextField(
                      label: 'Tên khoản nợ',
                      controller: _nameController,
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    AppTextField.currency(
                      label: 'Dư nợ hiện tại',
                      controller: _balanceController,
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Lãi suất (%/năm)',
                      controller: _aprController,
                      required: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      suffixIcon: LucideIcons.percent,
                    ),
                    const SizedBox(height: 16),
                    AppTextField.currency(
                      label: 'Số tiền trả tối thiểu/tháng',
                      controller: _minPaymentController,
                      required: true,
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom CTA
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.mdSurface,
                border: Border(
                  top: BorderSide(color: AppColors.mdOutlineVariant, width: 1),
                ),
              ),
              child: AppButton.filledLg(
                label: 'Tiếp tục',
                icon: null,
                trailingIcon: LucideIcons.arrowRight,
                fullWidth: true,
                onPressed: () {
                  context.go(AppRoutes.addAnotherDebt);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

