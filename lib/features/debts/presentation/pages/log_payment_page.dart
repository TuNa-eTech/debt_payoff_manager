import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/payment_logging_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/enums/payment_type.dart';
import '../../../../domain/repositories/debt_repository.dart';

class LogPaymentPage extends StatefulWidget {
  const LogPaymentPage({super.key, required this.id});

  final String id;

  @override
  State<LogPaymentPage> createState() => _LogPaymentPageState();
}

class _LogPaymentPageState extends State<LogPaymentPage> {
  final DebtRepository _debtRepository = getIt.get<DebtRepository>();
  final PaymentLoggingService _paymentLoggingService = getIt
      .get<PaymentLoggingService>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  PaymentType _selectedType = PaymentType.minimum;
  DateTime _selectedDate = DateTime.now();
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
    return StreamBuilder<Debt?>(
      stream: _debtRepository.watchDebtById(widget.id),
      builder: (context, snapshot) {
        final debt = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting &&
            debt == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Log payment')),
          body: debt == null
              ? const Center(
                  child: Text('Khoản nợ này không còn tồn tại hoặc đã bị xóa.'),
                )
              : SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.pagePaddingH,
                            AppDimensions.pagePaddingV,
                            AppDimensions.pagePaddingH,
                            AppDimensions.sectionGap,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppCard(
                                color: AppColors.mdSurfaceContainerLow,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      debt.name,
                                      style: AppTextStyles.titleMedium,
                                    ),
                                    const SizedBox(height: AppDimensions.xs),
                                    Text(
                                      'Current balance ${AppFormatters.formatCents(debt.currentBalance)}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.mdOnSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppDimensions.sectionGap),
                              AppTextField.currency(
                                key: AppTestKeys.paymentLogAmount,
                                label: 'Số tiền đã trả',
                                controller: _amountController,
                                helperText:
                                    'Phase 4 dùng model balance-first: amount giảm trực tiếp current balance.',
                                errorText: _inlineError,
                                onChanged: (_) {
                                  if (_inlineError != null) {
                                    setState(() => _inlineError = null);
                                  }
                                },
                              ),
                              const SizedBox(height: AppDimensions.lg),
                              Text(
                                'Loại payment',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.mdOnSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.sm),
                              Wrap(
                                spacing: AppDimensions.sm,
                                runSpacing: AppDimensions.sm,
                                children: [
                                  AppChip.filter(
                                    key: AppTestKeys.paymentTypeMinimum,
                                    label: 'Minimum',
                                    selected:
                                        _selectedType == PaymentType.minimum,
                                    onTap: () => setState(
                                      () => _selectedType = PaymentType.minimum,
                                    ),
                                    icon: LucideIcons.wallet,
                                  ),
                                  AppChip.filter(
                                    key: AppTestKeys.paymentTypeExtra,
                                    label: 'Extra',
                                    selected:
                                        _selectedType == PaymentType.extra,
                                    onTap: () => setState(
                                      () => _selectedType = PaymentType.extra,
                                    ),
                                    icon: LucideIcons.zap,
                                  ),
                                  AppChip.filter(
                                    key: AppTestKeys.paymentTypeLumpSum,
                                    label: 'Lump sum',
                                    selected:
                                        _selectedType == PaymentType.lumpSum,
                                    onTap: () => setState(
                                      () => _selectedType = PaymentType.lumpSum,
                                    ),
                                    icon: LucideIcons.badgeDollarSign,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.lg),
                              AppCard(
                                color: AppColors.mdSurface,
                                onTap: _pickDate,
                                child: Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.calendarDays,
                                      color: AppColors.mdPrimary,
                                    ),
                                    const SizedBox(width: AppDimensions.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Ngày áp dụng',
                                            style: AppTextStyles.titleSmall,
                                          ),
                                          const SizedBox(
                                            height: AppDimensions.xs,
                                          ),
                                          Text(
                                            AppFormatters.formatDate(
                                              _selectedDate,
                                            ),
                                            key: AppTestKeys.paymentLogDate,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: AppColors
                                                      .mdOnSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      LucideIcons.chevronRight,
                                      color: AppColors.mdOnSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppDimensions.lg),
                              AppTextField(
                                label: 'Ghi chú',
                                controller: _noteController,
                                hint: 'Ví dụ: autopay, bonus, paycheck sweep',
                                maxLines: 3,
                                textInputAction: TextInputAction.newline,
                              ),
                              const SizedBox(height: AppDimensions.sectionGap),
                              AppCard(
                                color: AppColors.mdSurfaceContainerLow,
                                child: Text(
                                  'Payment này sẽ tạo audit trail với số dư trước/sau và recast timeline ngay sau khi lưu.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.mdOnSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.mdSurface,
                          border: Border(
                            top: BorderSide(color: AppColors.mdOutlineVariant),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: AnimatedPadding(
                            duration: const Duration(
                              milliseconds: AppDimensions.animFast,
                            ),
                            curve: Curves.easeOut,
                            padding: EdgeInsets.fromLTRB(
                              AppDimensions.pagePaddingH,
                              AppDimensions.md,
                              AppDimensions.pagePaddingH,
                              AppDimensions.md +
                                  MediaQuery.viewInsetsOf(context).bottom,
                            ),
                            child: SizedBox(
                              key: AppTestKeys.paymentLogSubmit,
                              child: AppButton.filledLg(
                                label: 'Lưu payment',
                                trailingIcon: LucideIcons.arrowRight,
                                fullWidth: true,
                                loading: _isSubmitting,
                                onPressed: () => _submit(debt),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit(Debt debt) async {
    final amountText = _amountController.text.trim();
    final amount = _parseCurrency(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _inlineError = 'Nhập số tiền hợp lệ lớn hơn 0.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _inlineError = null;
    });

    try {
      await _paymentLoggingService.logPayment(
        debtId: debt.id,
        amountCents: amount,
        type: _selectedType,
        source: PaymentSource.manual,
        date: _selectedDate,
        note: _noteController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã log payment và recast timeline.')),
      );
      context.pop();
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
    if (value.isEmpty) return null;
    final normalized = value.replaceAll(',', '');
    final parsed = double.tryParse(normalized);
    if (parsed == null) return null;
    return (parsed * 100).round();
  }
}
