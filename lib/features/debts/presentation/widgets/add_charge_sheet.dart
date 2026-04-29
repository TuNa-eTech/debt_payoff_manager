import 'package:flutter/material.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/payment_logging_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../domain/entities/debt.dart';

class AddChargeSheet extends StatefulWidget {
  const AddChargeSheet({super.key, required this.debt});

  final Debt debt;

  static Future<void> show(BuildContext context, {required Debt debt}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddChargeSheet(debt: debt),
    );
  }

  @override
  State<AddChargeSheet> createState() => _AddChargeSheetState();
}

class _AddChargeSheetState extends State<AddChargeSheet> {
  final PaymentLoggingService _paymentLoggingService =
      getIt.get<PaymentLoggingService>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isSubmitting = false;
  String? _inlineError;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.mdSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppDimensions.md,
        right: AppDimensions.md,
        top: AppDimensions.md,
        bottom: bottomInset > 0 ? bottomInset + AppDimensions.md : 40,
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.newChargeDialogTitle,
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: AppDimensions.lg),
          AppTextField.currency(
            key: AppTestKeys.addChargeAmount,
            label: context.l10n.newChargeAmountLabel,
            controller: _amountController,
            errorText: _inlineError,
            onChanged: (_) {
              if (_inlineError != null) {
                setState(() => _inlineError = null);
              }
            },
          ),
          const SizedBox(height: AppDimensions.md),
          AppTextField(
            key: AppTestKeys.addChargeNote,
            label: context.l10n.newChargeNoteLabel,
            controller: _noteController,
            maxLines: 2,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppDimensions.xl),
          AppButton.filledLg(
            key: AppTestKeys.addChargeSubmit,
            label: context.l10n.newChargeSave,
            loading: _isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final amountText = _amountController.text.trim();
    final amount = _parseCurrency(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _inlineError = context.l10n.newChargeErrorInvalid);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _inlineError = null;
    });

    try {
      await _paymentLoggingService.logNewCharge(
        debt: widget.debt,
        amountCents: amount,
        note: _noteController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.newChargeSuccess)),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _inlineError = error.toString().replaceFirst(
          'Invalid argument(s): ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  int? _parseCurrency(String value) {
    final stripped = CurrencyInputFormatter.strip(value);
    if (stripped.isEmpty) return null;
    final parsed = double.tryParse(stripped);
    if (parsed == null) return null;
    return (parsed * 100).round();
  }
}
