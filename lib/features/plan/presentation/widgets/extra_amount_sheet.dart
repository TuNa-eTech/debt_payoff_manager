import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/extensions/context_extensions.dart';

class ExtraAmountSheet extends StatelessWidget {
  const ExtraAmountSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    final availableHeight = MediaQuery.sizeOf(context).height - keyboardBottom;
    final maxSheetHeight = availableHeight * 0.86;

    return AnimatedPadding(
      duration: const Duration(milliseconds: AppDimensions.animFast),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardBottom),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.mdSurface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radius2xl),
              topRight: Radius.circular(AppDimensions.radius2xl),
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.lg,
                AppDimensions.md,
                AppDimensions.lg,
                AppDimensions.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.mdOutlineVariant,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXs,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  Text(
                    context.l10n.planExtraAmountSheetTitle,
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    context.l10n.planExtraAmountSheetSubtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.mdOnSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg,
                      vertical: AppDimensions.lg,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mdPrimaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\$',
                          style: AppTextStyles.moneyMedium.copyWith(
                            color: AppColors.mdOnPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: '250'),
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.mdOnPrimaryContainer,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[\d.,]'),
                              ),
                              CurrencyInputFormatter(),
                            ],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  AppButton.filled(
                    onPressed: () => Navigator.pop(context),
                    label: context.l10n.planExtraAmountSheetSave,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  AppButton.outlined(
                    onPressed: () => Navigator.pop(context),
                    label: context.l10n.planExtraAmountSheetReset,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ExtraAmountSheet(),
    );
  }
}
