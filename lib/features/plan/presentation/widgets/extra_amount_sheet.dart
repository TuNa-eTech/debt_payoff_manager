import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/extensions/context_extensions.dart';

class ExtraAmountSheet extends StatelessWidget {
  const ExtraAmountSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.mdSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mdOutlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(context.l10n.planExtraAmountSheetTitle, style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          Text(
            context.l10n.planExtraAmountSheetSubtitle,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mdOnSurfaceVariant),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.mdPrimaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('\$', style: TextStyle(color: AppColors.mdOnPrimaryContainer, fontSize: 32, fontWeight: FontWeight.w700, fontFamily: 'Roboto Mono')),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: '250'),
                    style: const TextStyle(color: AppColors.mdOnPrimaryContainer, fontSize: 48, fontWeight: FontWeight.w700, fontFamily: 'Roboto Mono', letterSpacing: -1),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          AppButton.filled(
            onPressed: () => Navigator.pop(context),
            label: context.l10n.planExtraAmountSheetSave,
          ),
          const SizedBox(height: 12),
          AppButton.outlined(
            onPressed: () => Navigator.pop(context),
            label: context.l10n.planExtraAmountSheetReset,
          ),
        ],
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
