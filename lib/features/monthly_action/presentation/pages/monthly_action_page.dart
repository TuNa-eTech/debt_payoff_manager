import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

/// Monthly action page — "Tháng này bạn cần trả"
///
/// Feature 1.5: Monthly Action View
/// Primary checklist showing all debts due this month with suggested
/// extra payment allocation based on the user's active strategy.
class MonthlyActionPage extends StatefulWidget {
  const MonthlyActionPage({super.key});

  @override
  State<MonthlyActionPage> createState() => _MonthlyActionPageState();
}

class _MonthlyActionPageState extends State<MonthlyActionPage> {
  // Demo state — in production this comes from Cubit
  final Map<String, bool> _checkedItems = {
    'chase': false,
    'student': false,
    'car': false,
    'extra': false,
  };

  @override
  Widget build(BuildContext context) {
    final allChecked = _checkedItems.values.every((v) => v);
    final checkedCount = _checkedItems.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tháng này'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.mdSurfaceContainerLow,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              'Tháng 4/2026',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.mdOnSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Progress Banner ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: allChecked
                    ? AppColors.mdPrimary
                    : AppColors.mdSurfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(
                    allChecked ? LucideIcons.partyPopper : LucideIcons.target,
                    size: 32,
                    color: allChecked ? Colors.white : AppColors.mdPrimary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    allChecked ? 'Tuyệt vời! 🎉' : 'Tiến độ tháng này',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: allChecked ? Colors.white : AppColors.mdOnSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    allChecked
                        ? 'Bạn đã hoàn thành tất cả thanh toán!'
                        : '$checkedCount / ${_checkedItems.length} thanh toán đã hoàn thành',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: allChecked
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.mdOnSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: allChecked
                              ? Colors.white.withValues(alpha: 0.25)
                              : AppColors.mdSurfaceContainerHigh,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: checkedCount / _checkedItems.length,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: allChecked
                                ? AppColors.mdPrimaryContainer
                                : AppColors.mdPrimary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Minimum Payments Section ──
            Row(
              children: [
                const Icon(
                  LucideIcons.wallet,
                  size: 16,
                  color: AppColors.mdOnSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Thanh toán tối thiểu',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.mdOnSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildChecklistItem(
              id: 'chase',
              title: 'Chase Sapphire',
              subtitle: 'Minimum · Hạn 15/4',
              amount: '\$125',
              icon: LucideIcons.creditCard,
              iconColor: AppColors.mdPrimary,
            ),
            const SizedBox(height: 8),
            _buildChecklistItem(
              id: 'student',
              title: 'Student Loan',
              subtitle: 'Minimum · Hạn 20/4',
              amount: '\$80',
              icon: LucideIcons.graduationCap,
              iconColor: AppColors.mdSecondary,
              isWarning: true,
              warningText: 'Quá hạn 3 ngày',
            ),
            const SizedBox(height: 8),
            _buildChecklistItem(
              id: 'car',
              title: 'Toyota Car Loan',
              subtitle: 'Minimum · Hạn 25/4',
              amount: '\$320',
              icon: LucideIcons.car,
              iconColor: AppColors.mdTertiary,
            ),

            const SizedBox(height: 28),

            // ── Extra Payment Section ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.snowflake,
                      size: 16,
                      color: AppColors.mdPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Snowball – Trả thêm',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.mdOnSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mdPrimaryContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Ưu tiên #1',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.mdOnPrimaryContainer,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildChecklistItem(
              id: 'extra',
              title: 'Chase Sapphire',
              subtitle: 'Extra theo Snowball · Dư nợ thấp nhất',
              amount: '\$250',
              icon: LucideIcons.zap,
              iconColor: AppColors.mdPrimary,
              isExtra: true,
            ),

            const SizedBox(height: 28),

            // ── Summary ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mdSurfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mdOutlineVariant),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Tổng minimum', '\$525'),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Trả thêm (Snowball)',
                    '\$250',
                    valueColor: AppColors.mdPrimary,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      height: 1,
                      color: AppColors.mdOutlineVariant,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tổng tháng này', style: AppTextStyles.titleSmall),
                      Text(
                        '\$775',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.mdPrimary,
                          fontFamily: 'Roboto Mono',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Insight Card ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mdTertiaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.lightbulb,
                    color: AppColors.mdTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nếu trả thêm \$250/tháng',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.mdOnTertiaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bạn sẽ hết nợ sớm hơn 3 tháng và tiết kiệm \$850 tiền lãi!',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mdOnTertiaryContainer.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
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
          child: AppButton.filledLg(
            onPressed: allChecked ? () {} : null,
            label: allChecked
                ? 'Hoàn thành tháng này! ✓'
                : 'Đánh dấu đã trả tất cả',
            fullWidth: true,
            icon: allChecked ? LucideIcons.check : LucideIcons.checkSquare,
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required String id,
    required String title,
    required String subtitle,
    required String amount,
    required IconData icon,
    required Color iconColor,
    bool isWarning = false,
    String? warningText,
    bool isExtra = false,
  }) {
    final isChecked = _checkedItems[id] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          _checkedItems[id] = !isChecked;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isChecked
              ? AppColors.mdPrimaryContainer.withValues(alpha: 0.3)
              : isWarning
              ? AppColors.mdErrorContainer
              : isExtra
              ? AppColors.mdSurfaceContainerLow
              : AppColors.mdSurfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isChecked
                ? AppColors.mdPrimary.withValues(alpha: 0.4)
                : isWarning
                ? AppColors.mdError.withValues(alpha: 0.3)
                : isExtra
                ? AppColors.mdPrimary.withValues(alpha: 0.2)
                : AppColors.mdOutlineVariant,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.mdPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked ? AppColors.mdPrimary : AppColors.mdOutline,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),

            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isExtra
                    ? iconColor.withValues(alpha: 0.1)
                    : isWarning
                    ? AppColors.mdError.withValues(alpha: 0.1)
                    : AppColors.mdSurfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: isWarning ? AppColors.mdError : iconColor,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked
                          ? AppColors.mdOnSurfaceVariant
                          : isWarning
                          ? AppColors.mdOnErrorContainer
                          : AppColors.mdOnSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (isWarning && warningText != null)
                    Text(
                      warningText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mdError,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    )
                  else
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mdOnSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),

            // Amount
            Text(
              amount,
              style: AppTextStyles.titleMedium.copyWith(
                fontFamily: 'Roboto Mono',
                fontWeight: FontWeight.w600,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                color: isChecked
                    ? AppColors.mdOnSurfaceVariant
                    : isExtra
                    ? AppColors.mdPrimary
                    : AppColors.mdOnSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            fontFamily: 'Roboto Mono',
            color: valueColor ?? AppColors.mdOnSurface,
          ),
        ),
      ],
    );
  }
}
