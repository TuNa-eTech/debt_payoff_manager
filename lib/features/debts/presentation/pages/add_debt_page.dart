import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_text_field.dart';

class AddDebtPage extends StatefulWidget {
  const AddDebtPage({super.key});

  @override
  State<AddDebtPage> createState() => _AddDebtPageState();
}

class _AddDebtPageState extends State<AddDebtPage> {
  String _selectedType = 'credit_card';
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _aprController = TextEditingController();
  final _minPayController = TextEditingController();
  final _dueDateController = TextEditingController(text: '15');
  bool _isOptionalExpanded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _aprController.dispose();
    _minPayController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm khoản nợ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Debt Type Section
            Text('Loại nợ', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTypeChip('credit_card', 'Credit Card', LucideIcons.creditCard),
                _buildTypeChip('student_loan', 'Student Loan', LucideIcons.graduationCap),
                _buildTypeChip('car_loan', 'Car Loan', LucideIcons.car),
                _buildTypeChip('mortgage', 'Mortgage', LucideIcons.home),
                _buildTypeChip('medical', 'Medical', LucideIcons.heartPulse),
                _buildTypeChip('other', 'Khác', LucideIcons.moreHorizontal),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Required Fields Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Thông tin bắt buộc', style: AppTextStyles.titleSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.mdErrorContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text('4 trường', style: TextStyle(color: AppColors.mdOnErrorContainer, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            AppTextField(
              controller: _nameController,
              label: 'Tên khoản nợ',
              hint: 'VD: Chase Sapphire Reserve',
            ),
            const SizedBox(height: 16),
            
            AppTextField.currency(
              controller: _balanceController,
              label: 'Số dư hiện tại',
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: AppTextField.percentage(
                    controller: _aprController,
                    label: 'Lãi suất (APR)',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField.currency(
                    controller: _minPayController,
                    label: 'Trả tối thiểu',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            // APR Tooltip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mdSurfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mdOutlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.info, size: 16, color: AppColors.mdOnSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'APR là gì? Tìm trên statement hoặc app ngân hàng của bạn, thường ghi là "Annual Percentage Rate".',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Note: In a real app we'd use a date picker instead of textfield
            AppTextField(
              controller: _dueDateController,
              label: 'Ngày đến hạn hàng tháng',
              hint: 'Ngày 15 mỗi tháng',
            ),
            
            const SizedBox(height: 32),
            
            // Optional Section
             GestureDetector(
              onTap: () {
                setState(() {
                  _isOptionalExpanded = !_isOptionalExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mdSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.mdOutlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.slidersHorizontal, size: 18, color: AppColors.mdOnSurfaceVariant),
                        const SizedBox(width: 10),
                        Text('Thông tin bổ sung', style: AppTextStyles.titleSmall),
                      ],
                    ),
                    Icon(
                      _isOptionalExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                      size: 20,
                      color: AppColors.mdOnSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
             if (_isOptionalExpanded) ...[
                const SizedBox(height: 16),
                // Expanded optional fields would go here
             ],
            
            const SizedBox(height: 120), // Bottom padding for CTA
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
                  label: 'Thêm',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String id, String label, IconData icon) {
    return AppChip.filter(
      label: label,
      selected: _selectedType == id,
      icon: icon,
      onTap: () {
        setState(() {
          _selectedType = id;
        });
      },
    );
  }
}
