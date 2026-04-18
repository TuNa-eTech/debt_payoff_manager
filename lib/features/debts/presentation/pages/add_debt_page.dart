import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/repositories/debt_repository.dart';
import '../../cubit/debt_form_cubit.dart';
import '../widgets/debt_form_fields.dart';

class AddDebtPage extends StatelessWidget {
  const AddDebtPage({super.key})
      : _mode = DebtFormMode.create,
        _initialDebt = null;

  const AddDebtPage.edit({
    super.key,
    required Debt debt,
  })  : _mode = DebtFormMode.edit,
        _initialDebt = debt;

  final DebtFormMode _mode;
  final Debt? _initialDebt;

  @override
  Widget build(BuildContext context) {
    final debtRepository = getIt.get<DebtRepository>();
    return BlocProvider(
      create: (_) => _initialDebt == null
          ? DebtFormCubit.create(
              debtRepository: debtRepository,
              mode: _mode,
            )
          : DebtFormCubit.edit(
              debtRepository: debtRepository,
              debt: _initialDebt,
            ),
      child: DebtFormScaffold(
        mode: _mode,
        title: _initialDebt == null ? 'Thêm khoản nợ' : 'Chỉnh sửa khoản nợ',
        primaryActionLabel: _initialDebt == null ? 'Lưu khoản nợ' : 'Lưu thay đổi',
        onSaved: (context, debt) {
          if (_mode == DebtFormMode.edit) {
            context.go(AppRoutes.debtDetailPath(debt.id));
            return;
          }
          context.go(AppRoutes.debts);
        },
        onCancel: () => context.pop(),
        initialDebt: _initialDebt,
      ),
    );
  }
}

class DebtFormScaffold extends StatefulWidget {
  const DebtFormScaffold({
    super.key,
    required this.mode,
    required this.title,
    required this.primaryActionLabel,
    required this.onSaved,
    required this.onCancel,
    this.initialDebt,
    this.progressLabel,
    this.progressValue,
  });

  final DebtFormMode mode;
  final String title;
  final String primaryActionLabel;
  final void Function(BuildContext context, Debt debt) onSaved;
  final VoidCallback onCancel;
  final Debt? initialDebt;
  final String? progressLabel;
  final double? progressValue;

  @override
  State<DebtFormScaffold> createState() => _DebtEditorScaffoldState();
}

class _DebtEditorScaffoldState extends State<DebtFormScaffold> {
  late final TextEditingController _nameController;
  late final TextEditingController _originalPrincipalController;
  late final TextEditingController _currentBalanceController;
  late final TextEditingController _aprController;
  late final TextEditingController _minimumPaymentController;
  late final TextEditingController _dueDayController;
  late final TextEditingController _minimumPaymentPercentController;
  late final TextEditingController _minimumPaymentFloorController;

  @override
  void initState() {
    super.initState();
    final debt = widget.initialDebt;
    _nameController = TextEditingController(text: debt?.name ?? '');
    _originalPrincipalController = TextEditingController(
      text: debt == null ? '' : _displayCurrency(debt.originalPrincipal),
    );
    _currentBalanceController = TextEditingController(
      text: debt == null ? '' : _displayCurrency(debt.currentBalance),
    );
    _aprController = TextEditingController(
      text: debt == null ? '' : (double.parse(debt.apr.toString()) * 100).toStringAsFixed(2),
    );
    _minimumPaymentController = TextEditingController(
      text: debt == null ? '' : _displayCurrency(debt.minimumPayment),
    );
    _dueDayController = TextEditingController(
      text: debt == null ? '' : debt.dueDayOfMonth.toString(),
    );
    _minimumPaymentPercentController = TextEditingController(
      text: debt?.minimumPaymentPercent == null
          ? ''
          : (double.parse(debt!.minimumPaymentPercent.toString()) * 100)
              .toStringAsFixed(2),
    );
    _minimumPaymentFloorController = TextEditingController(
      text: debt?.minimumPaymentFloor == null
          ? ''
          : _displayCurrency(debt!.minimumPaymentFloor!),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originalPrincipalController.dispose();
    _currentBalanceController.dispose();
    _aprController.dispose();
    _minimumPaymentController.dispose();
    _dueDayController.dispose();
    _minimumPaymentPercentController.dispose();
    _minimumPaymentFloorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnboarding = widget.mode == DebtFormMode.onboarding;
    return Scaffold(
      appBar: isOnboarding
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: widget.onCancel,
              ),
              title: Text(widget.title),
            )
          : AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<DebtFormCubit, DebtFormState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.pagePaddingH,
                      vertical: AppDimensions.pagePaddingV,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.progressLabel != null &&
                            widget.progressValue != null) ...[
                          Text(
                            widget.progressLabel!,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.mdOnSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: widget.progressValue,
                            backgroundColor: AppColors.mdSurfaceContainerHighest,
                            color: AppColors.mdPrimary,
                            borderRadius: BorderRadius.circular(4),
                            minHeight: 4,
                          ),
                          const SizedBox(height: 24),
                        ],
                        DebtFormFields(
                          mode: widget.mode,
                          nameController: _nameController,
                          currentBalanceController: _currentBalanceController,
                          aprController: _aprController,
                          minPaymentController: _minimumPaymentController,
                          originalPrincipalController: _originalPrincipalController,
                          dueDateController: _dueDayController,
                          minimumPaymentPercentController:
                              _minimumPaymentPercentController,
                          minimumPaymentFloorController:
                              _minimumPaymentFloorController,
                          selectedDebtType: state.selectedType,
                          interestMethod: state.interestMethod,
                          minimumPaymentType: state.minimumPaymentType,
                          paymentCadence: state.paymentCadence,
                          status: state.status,
                          excludeFromStrategy: state.excludeFromStrategy,
                          showAdvanced: state.showAdvanced,
                          pausedUntil: state.pausedUntil,
                          onDebtTypeChanged:
                              context.read<DebtFormCubit>().setDebtType,
                          onInterestMethodChanged:
                              context.read<DebtFormCubit>().setInterestMethod,
                          onMinimumPaymentTypeChanged: context
                              .read<DebtFormCubit>()
                              .setMinimumPaymentType,
                          onPaymentCadenceChanged: context
                              .read<DebtFormCubit>()
                              .setPaymentCadence,
                          onStatusChanged:
                              context.read<DebtFormCubit>().setStatus,
                          onExcludeFromStrategyChanged: context
                              .read<DebtFormCubit>()
                              .setExcludeFromStrategy,
                          onToggleAdvanced:
                              context.read<DebtFormCubit>().toggleAdvanced,
                          onCoreFieldChanged: _refreshWarnings,
                          onSelectPausedUntil: _selectPausedUntil,
                          onClearPausedUntil: () => context
                              .read<DebtFormCubit>()
                              .setPausedUntil(null),
                          nameError: state.nameError,
                          originalPrincipalError: state.originalPrincipalError,
                          currentBalanceError: state.currentBalanceError,
                          aprError: state.aprError,
                          minPaymentError: state.minimumPaymentError,
                          dueDayError: state.dueDayError,
                          minimumPaymentPercentError:
                              state.minimumPaymentPercentError,
                          minimumPaymentFloorError:
                              state.minimumPaymentFloorError,
                          pausedUntilError: state.pausedUntilError,
                          inlineError: state.inlineError,
                          warnings: state.warnings,
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.mdSurface,
        border: Border(top: BorderSide(color: AppColors.mdOutlineVariant)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (widget.mode != DebtFormMode.onboarding) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: widget.mode == DebtFormMode.onboarding ? 1 : 2,
              child: BlocBuilder<DebtFormCubit, DebtFormState>(
                builder: (context, state) {
                  return FilledButton(
                    onPressed: state.isSubmitting ? null : () => _submit(context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        AppDimensions.buttonHeightLg,
                      ),
                      backgroundColor: AppColors.mdPrimary,
                      foregroundColor: AppColors.mdOnPrimary,
                      shape: const StadiumBorder(),
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.mdOnPrimary,
                            ),
                          )
                        : Text(widget.primaryActionLabel),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final cubit = context.read<DebtFormCubit>();
    final debt = await cubit.save(
      nameInput: _nameController.text,
      originalPrincipalInput: _originalPrincipalController.text,
      currentBalanceInput: _currentBalanceController.text,
      aprInput: _aprController.text,
      minimumPaymentInput: _minimumPaymentController.text,
      dueDayInput: _dueDayController.text,
      minimumPaymentPercentInput: _minimumPaymentPercentController.text,
      minimumPaymentFloorInput: _minimumPaymentFloorController.text,
    );
    if (!mounted || debt == null) return;
    widget.onSaved(this.context, debt);
  }

  Future<void> _selectPausedUntil() async {
    final cubit = context.read<DebtFormCubit>();
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      initialDate: cubit.state.pausedUntil ?? now,
      lastDate: DateTime(now.year + 10),
    );
    if (selected != null) {
      cubit.setPausedUntil(selected);
    }
  }

  void _refreshWarnings() {
    context.read<DebtFormCubit>().refreshWarnings(
          originalPrincipalInput: _originalPrincipalController.text,
          currentBalanceInput: _currentBalanceController.text,
          aprInput: _aprController.text,
          minimumPaymentInput: _minimumPaymentController.text,
        );
  }

  String _displayCurrency(int cents) => (cents / 100).toStringAsFixed(2);
}
