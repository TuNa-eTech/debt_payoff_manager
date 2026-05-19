import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/enums/debt_type.dart';
import '../../../../domain/repositories/debt_repository.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../cubit/debt_form_cubit.dart';
import '../debt_ui_utils.dart';
import '../widgets/debt_form_fields.dart';

class AddDebtPage extends StatelessWidget {
  const AddDebtPage({super.key})
    : _mode = DebtFormMode.create,
      _initialDebt = null;

  const AddDebtPage.edit({super.key, required Debt debt})
    : _mode = DebtFormMode.edit,
      _initialDebt = debt;

  final DebtFormMode _mode;
  final Debt? _initialDebt;

  @override
  Widget build(BuildContext context) {
    final debtRepository = getIt.get<DebtRepository>();
    final settingsRepository = getIt.get<SettingsRepository>();
    return BlocProvider(
      create: (_) => _initialDebt == null
          ? DebtFormCubit.create(
              debtRepository: debtRepository,
              settingsRepository: settingsRepository,
              mode: _mode,
            )
          : DebtFormCubit.edit(
              debtRepository: debtRepository,
              settingsRepository: settingsRepository,
              debt: _initialDebt,
            ),
      child: DebtFormScaffold(
        mode: _mode,
        title: _initialDebt == null
            ? context.l10n.addDebtTitle
            : context.l10n.editDebtTitle,
        primaryActionLabel: _initialDebt == null
            ? context.l10n.addDebtSave
            : context.l10n.addDebtSaveChanges,
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
    this.backButtonKey,
    this.progressLabel,
    this.progressValue,
  });

  final DebtFormMode mode;
  final String title;
  final String primaryActionLabel;
  final void Function(BuildContext context, Debt debt) onSaved;
  final VoidCallback onCancel;
  final Debt? initialDebt;
  final Key? backButtonKey;
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
  _OnboardingDebtEntryPhase _onboardingPhase =
      _OnboardingDebtEntryPhase.selectType;

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
      text: debt == null
          ? ''
          : (double.parse(debt.apr.toString()) * 100).toStringAsFixed(2),
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
    final scaffold = Scaffold(
      appBar: isOnboarding
          ? AppBar(
              leading: IconButton(
                key: widget.backButtonKey,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: _handleBack,
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
                          Semantics(
                            label: widget.progressLabel!,
                            value: context.l10n.debtFormProgressComplete(
                              (widget.progressValue! * 100).round(),
                            ),
                            child: LinearProgressIndicator(
                              value: widget.progressValue,
                              backgroundColor:
                                  AppColors.mdSurfaceContainerHighest,
                              color: AppColors.mdPrimary,
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 4,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (isOnboarding &&
                            _onboardingPhase ==
                                _OnboardingDebtEntryPhase.selectType)
                          _OnboardingDebtTypeChooser(
                            selectedType: state.selectedType,
                            onSelected: (type) {
                              final cubit = context.read<DebtFormCubit>();
                              cubit.setDebtType(type);
                              _refreshFormFeedback();
                            },
                          )
                        else
                          DebtFormFields(
                            mode: widget.mode,
                            nameController: _nameController,
                            currentBalanceController: _currentBalanceController,
                            aprController: _aprController,
                            minPaymentController: _minimumPaymentController,
                            originalPrincipalController:
                                _originalPrincipalController,
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
                            showOriginalPrincipalByDefault:
                                state.showOriginalPrincipalByDefault,
                            showDueDayByDefault: state.showDueDayByDefault,
                            pausedUntil: state.pausedUntil,
                            onDebtTypeChanged: (type) {
                              final cubit = context.read<DebtFormCubit>();
                              cubit.setDebtType(type);
                              _refreshFormFeedback();
                            },
                            onInterestMethodChanged: (method) {
                              final cubit = context.read<DebtFormCubit>();
                              cubit.setInterestMethod(method);
                              _refreshFormFeedback();
                            },
                            onMinimumPaymentTypeChanged: (type) {
                              final cubit = context.read<DebtFormCubit>();
                              cubit.setMinimumPaymentType(type);
                              _refreshFormFeedback();
                            },
                            onPaymentCadenceChanged: (cadence) {
                              final cubit = context.read<DebtFormCubit>();
                              cubit.setPaymentCadence(cadence);
                              _refreshFormFeedback();
                            },
                            onStatusChanged: (status) {
                              final cubit = context.read<DebtFormCubit>();
                              cubit.setStatus(status);
                              _refreshFormFeedback();
                            },
                            onExcludeFromStrategyChanged: context
                                .read<DebtFormCubit>()
                                .setExcludeFromStrategy,
                            onToggleAdvanced: context
                                .read<DebtFormCubit>()
                                .toggleAdvanced,
                            onCoreFieldChanged: _refreshFormFeedback,
                            onSelectPausedUntil: _selectPausedUntil,
                            onClearPausedUntil: () {
                              context.read<DebtFormCubit>().setPausedUntil(
                                null,
                              );
                              _refreshFormFeedback();
                            },
                            nameError: state.nameError,
                            originalPrincipalError:
                                state.originalPrincipalError,
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

    if (!isOnboarding) return scaffold;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: scaffold,
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
                  key: AppTestKeys.debtFormCancel,
                  onPressed: widget.onCancel,
                  child: Text(context.l10n.commonCancel),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: widget.mode == DebtFormMode.onboarding ? 1 : 2,
              child: BlocBuilder<DebtFormCubit, DebtFormState>(
                builder: (context, state) {
                  if (widget.mode == DebtFormMode.onboarding &&
                      _onboardingPhase ==
                          _OnboardingDebtEntryPhase.selectType) {
                    return FilledButton(
                      key: AppTestKeys.onboardingDebtTypeContinue,
                      onPressed: () {
                        setState(
                          () => _onboardingPhase =
                              _OnboardingDebtEntryPhase.enterDetails,
                        );
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppDimensions.buttonHeightLg,
                        ),
                        backgroundColor: AppColors.mdPrimary,
                        foregroundColor: AppColors.mdOnPrimary,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(context.l10n.onboardingDebtTypeContinue),
                    );
                  }

                  return FilledButton(
                    key: AppTestKeys.debtFormSave,
                    onPressed: state.isSubmitting
                        ? null
                        : () => _submit(context),
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

  void _handleBack() {
    if (widget.mode == DebtFormMode.onboarding &&
        _onboardingPhase == _OnboardingDebtEntryPhase.enterDetails) {
      setState(() => _onboardingPhase = _OnboardingDebtEntryPhase.selectType);
      return;
    }

    widget.onCancel();
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
      _refreshFormFeedback();
    }
  }

  void _refreshFormFeedback() {
    context.read<DebtFormCubit>().refreshFormFeedback(
      nameInput: _nameController.text,
      originalPrincipalInput: _originalPrincipalController.text,
      currentBalanceInput: _currentBalanceController.text,
      aprInput: _aprController.text,
      minimumPaymentInput: _minimumPaymentController.text,
      dueDayInput: _dueDayController.text,
      minimumPaymentPercentInput: _minimumPaymentPercentController.text,
      minimumPaymentFloorInput: _minimumPaymentFloorController.text,
    );
  }

  static final _currencyDisplayFormat = NumberFormat('#,##0.##', 'en_US');

  String _displayCurrency(int cents) {
    final value = cents / 100;
    // Always show at least 2 decimal places for whole-cent amounts.
    if (value == value.truncateToDouble()) {
      return NumberFormat('#,##0.00', 'en_US').format(value);
    }
    return _currencyDisplayFormat.format(value);
  }
}

enum _OnboardingDebtEntryPhase { selectType, enterDetails }

class _OnboardingDebtTypeChooser extends StatelessWidget {
  const _OnboardingDebtTypeChooser({
    required this.selectedType,
    required this.onSelected,
  });

  final DebtType selectedType;
  final ValueChanged<DebtType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.onboardingDebtTypeTitle,
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          context.l10n.onboardingDebtTypeSubtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.lg),
        ...DebtType.values.map((type) {
          final selected = type == selectedType;
          final color = debtTypeColor(type);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.md),
            child: AppCard(
              key: AppTestKeys.onboardingDebtTypeOption(type.name),
              onTap: () => onSelected(type),
              color: selected
                  ? AppColors.mdPrimaryContainer
                  : AppColors.mdSurface,
              borderColor: selected
                  ? AppColors.mdPrimary
                  : AppColors.mdOutlineVariant,
              borderWidth: selected ? 2 : 1,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(debtTypeIcon(type), color: color, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          debtTypeDisplayName(type, context.l10n),
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        Text(
                          _descriptionFor(context, type),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mdOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    selected ? LucideIcons.checkCircle2 : LucideIcons.circle,
                    color: selected ? AppColors.mdPrimary : AppColors.mdOutline,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _descriptionFor(BuildContext context, DebtType type) {
    switch (type) {
      case DebtType.creditCard:
        return context.l10n.onboardingDebtTypeCreditCardDescription;
      case DebtType.studentLoan:
        return context.l10n.onboardingDebtTypeStudentLoanDescription;
      case DebtType.carLoan:
        return context.l10n.onboardingDebtTypeCarLoanDescription;
      case DebtType.mortgage:
        return context.l10n.onboardingDebtTypeMortgageDescription;
      case DebtType.personal:
        return context.l10n.onboardingDebtTypePersonalDescription;
      case DebtType.medical:
        return context.l10n.onboardingDebtTypeMedicalDescription;
      case DebtType.paydayLoan:
        return context.l10n.onboardingDebtTypePaydayLoanDescription;
      case DebtType.buyNowPayLater:
        return context.l10n.onboardingDebtTypeBuyNowPayLaterDescription;
      case DebtType.storeFinancing:
        return context.l10n.onboardingDebtTypeStoreFinancingDescription;
      case DebtType.lineOfCredit:
        return context.l10n.onboardingDebtTypeLineOfCreditDescription;
      case DebtType.taxDebt:
        return context.l10n.onboardingDebtTypeTaxDebtDescription;
      case DebtType.collections:
        return context.l10n.onboardingDebtTypeCollectionsDescription;
      case DebtType.familyLoan:
        return context.l10n.onboardingDebtTypeFamilyLoanDescription;
      case DebtType.homeEquity:
        return context.l10n.onboardingDebtTypeHomeEquityDescription;
      case DebtType.other:
        return context.l10n.onboardingDebtTypeOtherDescription;
    }
  }
}
