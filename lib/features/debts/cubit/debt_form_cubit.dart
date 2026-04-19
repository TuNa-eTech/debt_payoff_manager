import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/extensions/decimal_extensions.dart';
import '../../../domain/entities/debt.dart';
import '../../../domain/enums/debt_status.dart';
import '../../../domain/enums/debt_type.dart';
import '../../../domain/enums/interest_method.dart';
import '../../../domain/enums/min_payment_type.dart';
import '../../../domain/enums/payment_cadence.dart';
import '../../../domain/repositories/debt_repository.dart';
import '../../../engine/interest_calculator.dart';
import '../../../engine/validators.dart';

enum DebtFormMode { onboarding, create, edit }

class DebtFormState extends Equatable {
  static const Object _sentinel = Object();

  const DebtFormState({
    required this.mode,
    required this.selectedType,
    required this.interestMethod,
    required this.minimumPaymentType,
    required this.paymentCadence,
    required this.status,
    this.pausedUntil,
    this.excludeFromStrategy = false,
    this.showAdvanced = false,
    this.isSubmitting = false,
    this.nameError,
    this.originalPrincipalError,
    this.currentBalanceError,
    this.aprError,
    this.minimumPaymentError,
    this.dueDayError,
    this.minimumPaymentPercentError,
    this.minimumPaymentFloorError,
    this.pausedUntilError,
    this.inlineError,
    this.warnings = const [],
    this.interestMethodOverridden = false,
  });

  final DebtFormMode mode;
  final DebtType selectedType;
  final InterestMethod interestMethod;
  final MinPaymentType minimumPaymentType;
  final PaymentCadence paymentCadence;
  final DebtStatus status;
  final DateTime? pausedUntil;
  final bool excludeFromStrategy;
  final bool showAdvanced;
  final bool isSubmitting;
  final String? nameError;
  final String? originalPrincipalError;
  final String? currentBalanceError;
  final String? aprError;
  final String? minimumPaymentError;
  final String? dueDayError;
  final String? minimumPaymentPercentError;
  final String? minimumPaymentFloorError;
  final String? pausedUntilError;
  final String? inlineError;
  final List<String> warnings;
  final bool interestMethodOverridden;

  bool get isOnboarding => mode == DebtFormMode.onboarding;
  bool get showOriginalPrincipalByDefault {
    if (mode == DebtFormMode.edit) return true;

    if (mode == DebtFormMode.onboarding) {
      switch (selectedType) {
        case DebtType.studentLoan:
        case DebtType.carLoan:
        case DebtType.mortgage:
        case DebtType.personal:
          return true;
        case DebtType.creditCard:
        case DebtType.medical:
        case DebtType.other:
          return false;
      }
    }

    switch (selectedType) {
      case DebtType.studentLoan:
      case DebtType.carLoan:
      case DebtType.mortgage:
      case DebtType.personal:
        return true;
      case DebtType.creditCard:
      case DebtType.medical:
      case DebtType.other:
        return false;
    }
  }

  bool get showDueDayByDefault {
    if (mode == DebtFormMode.edit) return true;

    switch (selectedType) {
      case DebtType.creditCard:
      case DebtType.studentLoan:
      case DebtType.carLoan:
      case DebtType.mortgage:
      case DebtType.personal:
        return true;
      case DebtType.medical:
      case DebtType.other:
        return false;
    }
  }

  bool get requiresMinimumPaymentPercent =>
      minimumPaymentType == MinPaymentType.percentOfBalance ||
      minimumPaymentType == MinPaymentType.interestPlusPercent;
  bool get requiresMinimumPaymentFloor =>
      minimumPaymentType != MinPaymentType.fixed;
  bool get showPausedUntilField => status == DebtStatus.paused;
  bool get hasValidationErrors =>
      nameError != null ||
      originalPrincipalError != null ||
      currentBalanceError != null ||
      aprError != null ||
      minimumPaymentError != null ||
      dueDayError != null ||
      minimumPaymentPercentError != null ||
      minimumPaymentFloorError != null ||
      pausedUntilError != null;

  DebtFormState copyWith({
    DebtFormMode? mode,
    DebtType? selectedType,
    InterestMethod? interestMethod,
    MinPaymentType? minimumPaymentType,
    PaymentCadence? paymentCadence,
    DebtStatus? status,
    Object? pausedUntil = _sentinel,
    bool clearPausedUntil = false,
    bool? excludeFromStrategy,
    bool? showAdvanced,
    bool? isSubmitting,
    Object? nameError = _sentinel,
    Object? originalPrincipalError = _sentinel,
    Object? currentBalanceError = _sentinel,
    Object? aprError = _sentinel,
    Object? minimumPaymentError = _sentinel,
    Object? dueDayError = _sentinel,
    Object? minimumPaymentPercentError = _sentinel,
    Object? minimumPaymentFloorError = _sentinel,
    Object? pausedUntilError = _sentinel,
    Object? inlineError = _sentinel,
    bool clearErrors = false,
    bool clearInlineError = false,
    List<String>? warnings,
    bool? interestMethodOverridden,
  }) {
    return DebtFormState(
      mode: mode ?? this.mode,
      selectedType: selectedType ?? this.selectedType,
      interestMethod: interestMethod ?? this.interestMethod,
      minimumPaymentType: minimumPaymentType ?? this.minimumPaymentType,
      paymentCadence: paymentCadence ?? this.paymentCadence,
      status: status ?? this.status,
      pausedUntil: clearPausedUntil
          ? null
          : (pausedUntil == _sentinel
                ? this.pausedUntil
                : pausedUntil as DateTime?),
      excludeFromStrategy: excludeFromStrategy ?? this.excludeFromStrategy,
      showAdvanced: showAdvanced ?? this.showAdvanced,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      nameError: clearErrors
          ? null
          : (nameError == _sentinel ? this.nameError : nameError as String?),
      originalPrincipalError: clearErrors
          ? null
          : (originalPrincipalError == _sentinel
                ? this.originalPrincipalError
                : originalPrincipalError as String?),
      currentBalanceError: clearErrors
          ? null
          : (currentBalanceError == _sentinel
                ? this.currentBalanceError
                : currentBalanceError as String?),
      aprError: clearErrors
          ? null
          : (aprError == _sentinel ? this.aprError : aprError as String?),
      minimumPaymentError: clearErrors
          ? null
          : (minimumPaymentError == _sentinel
                ? this.minimumPaymentError
                : minimumPaymentError as String?),
      dueDayError: clearErrors
          ? null
          : (dueDayError == _sentinel
                ? this.dueDayError
                : dueDayError as String?),
      minimumPaymentPercentError: clearErrors
          ? null
          : (minimumPaymentPercentError == _sentinel
                ? this.minimumPaymentPercentError
                : minimumPaymentPercentError as String?),
      minimumPaymentFloorError: clearErrors
          ? null
          : (minimumPaymentFloorError == _sentinel
                ? this.minimumPaymentFloorError
                : minimumPaymentFloorError as String?),
      pausedUntilError: clearErrors
          ? null
          : (pausedUntilError == _sentinel
                ? this.pausedUntilError
                : pausedUntilError as String?),
      inlineError: clearInlineError
          ? null
          : (inlineError == _sentinel
                ? this.inlineError
                : inlineError as String?),
      warnings: warnings ?? this.warnings,
      interestMethodOverridden:
          interestMethodOverridden ?? this.interestMethodOverridden,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    selectedType,
    interestMethod,
    minimumPaymentType,
    paymentCadence,
    status,
    pausedUntil,
    excludeFromStrategy,
    showAdvanced,
    isSubmitting,
    nameError,
    originalPrincipalError,
    currentBalanceError,
    aprError,
    minimumPaymentError,
    dueDayError,
    minimumPaymentPercentError,
    minimumPaymentFloorError,
    pausedUntilError,
    inlineError,
    warnings,
    interestMethodOverridden,
  ];
}

class DebtFormCubit extends Cubit<DebtFormState> {
  DebtFormCubit.create({
    required DebtRepository debtRepository,
    required DebtFormMode mode,
  }) : _debtRepository = debtRepository,
       _existingDebt = null,
       super(
         DebtFormState(
           mode: mode,
           selectedType: DebtType.creditCard,
           interestMethod: _defaultInterestMethodFor(DebtType.creditCard),
           minimumPaymentType: MinPaymentType.fixed,
           paymentCadence: PaymentCadence.monthly,
           status: DebtStatus.active,
         ),
       );

  DebtFormCubit.edit({
    required DebtRepository debtRepository,
    required Debt debt,
  }) : _debtRepository = debtRepository,
       _existingDebt = debt,
       super(
         DebtFormState(
           mode: DebtFormMode.edit,
           selectedType: debt.type,
           interestMethod: debt.interestMethod,
           minimumPaymentType: debt.minimumPaymentType,
           paymentCadence: debt.paymentCadence,
           status: debt.status,
           pausedUntil: debt.pausedUntil,
           excludeFromStrategy: debt.excludeFromStrategy,
           showAdvanced: true,
           interestMethodOverridden: true,
         ),
       );

  final DebtRepository _debtRepository;
  final Debt? _existingDebt;
  final Uuid _uuid = const Uuid();

  void setDebtType(DebtType type) {
    emit(
      state.copyWith(
        selectedType: type,
        interestMethod: state.interestMethodOverridden
            ? state.interestMethod
            : _defaultInterestMethodFor(type),
      ),
    );
  }

  void setInterestMethod(InterestMethod method) {
    emit(
      state.copyWith(interestMethod: method, interestMethodOverridden: true),
    );
  }

  void setMinimumPaymentType(MinPaymentType type) {
    emit(state.copyWith(minimumPaymentType: type));
  }

  void setPaymentCadence(PaymentCadence cadence) {
    emit(state.copyWith(paymentCadence: cadence));
  }

  void setStatus(DebtStatus status) {
    emit(
      state.copyWith(
        status: status,
        clearPausedUntil: status != DebtStatus.paused,
        pausedUntilError: status == DebtStatus.paused ? null : null,
      ),
    );
  }

  void setPausedUntil(DateTime? value) {
    emit(state.copyWith(pausedUntil: value, pausedUntilError: null));
  }

  void setExcludeFromStrategy(bool value) {
    emit(state.copyWith(excludeFromStrategy: value));
  }

  void toggleAdvanced() {
    emit(state.copyWith(showAdvanced: !state.showAdvanced));
  }

  void clearInlineError() {
    if (state.inlineError == null) return;
    emit(state.copyWith(clearInlineError: true));
  }

  void refreshWarnings({
    required String originalPrincipalInput,
    required String currentBalanceInput,
    required String aprInput,
    required String minimumPaymentInput,
  }) {
    emit(
      state.copyWith(
        warnings: _buildWarnings(
          originalPrincipalInput: originalPrincipalInput,
          currentBalanceInput: currentBalanceInput,
          aprInput: aprInput,
          minimumPaymentInput: minimumPaymentInput,
        ),
      ),
    );
  }

  void refreshFormFeedback({
    required String nameInput,
    required String originalPrincipalInput,
    required String currentBalanceInput,
    required String aprInput,
    required String minimumPaymentInput,
    required String dueDayInput,
    required String minimumPaymentPercentInput,
    required String minimumPaymentFloorInput,
  }) {
    final warnings = _buildWarnings(
      originalPrincipalInput: originalPrincipalInput,
      currentBalanceInput: currentBalanceInput,
      aprInput: aprInput,
      minimumPaymentInput: minimumPaymentInput,
    );

    if (!state.hasValidationErrors && state.inlineError == null) {
      emit(state.copyWith(warnings: warnings));
      return;
    }

    final errors = _buildValidationErrors(
      nameInput: nameInput,
      originalPrincipalInput: originalPrincipalInput,
      currentBalanceInput: currentBalanceInput,
      aprInput: aprInput,
      minimumPaymentInput: minimumPaymentInput,
      dueDayInput: dueDayInput,
      minimumPaymentPercentInput: minimumPaymentPercentInput,
      minimumPaymentFloorInput: minimumPaymentFloorInput,
    );

    emit(
      state.copyWith(
        nameError: errors.nameError,
        originalPrincipalError: errors.originalPrincipalError,
        currentBalanceError: errors.currentBalanceError,
        aprError: errors.aprError,
        minimumPaymentError: errors.minimumPaymentError,
        dueDayError: errors.dueDayError,
        minimumPaymentPercentError: errors.minimumPaymentPercentError,
        minimumPaymentFloorError: errors.minimumPaymentFloorError,
        pausedUntilError: errors.pausedUntilError,
        inlineError: null,
        warnings: warnings,
      ),
    );
  }

  Future<Debt?> save({
    required String nameInput,
    required String originalPrincipalInput,
    required String currentBalanceInput,
    required String aprInput,
    required String minimumPaymentInput,
    required String dueDayInput,
    required String minimumPaymentPercentInput,
    required String minimumPaymentFloorInput,
  }) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        clearErrors: true,
        clearInlineError: true,
        warnings: _buildWarnings(
          originalPrincipalInput: originalPrincipalInput,
          currentBalanceInput: currentBalanceInput,
          aprInput: aprInput,
          minimumPaymentInput: minimumPaymentInput,
        ),
      ),
    );

    final validation = _validateAndBuildDebt(
      nameInput: nameInput,
      originalPrincipalInput: originalPrincipalInput,
      currentBalanceInput: currentBalanceInput,
      aprInput: aprInput,
      minimumPaymentInput: minimumPaymentInput,
      dueDayInput: dueDayInput,
      minimumPaymentPercentInput: minimumPaymentPercentInput,
      minimumPaymentFloorInput: minimumPaymentFloorInput,
    );

    if (validation.errors != null) {
      emit(
        state.copyWith(
          isSubmitting: false,
          nameError: validation.errors!.nameError,
          originalPrincipalError: validation.errors!.originalPrincipalError,
          currentBalanceError: validation.errors!.currentBalanceError,
          aprError: validation.errors!.aprError,
          minimumPaymentError: validation.errors!.minimumPaymentError,
          dueDayError: validation.errors!.dueDayError,
          minimumPaymentPercentError:
              validation.errors!.minimumPaymentPercentError,
          minimumPaymentFloorError: validation.errors!.minimumPaymentFloorError,
          pausedUntilError: validation.errors!.pausedUntilError,
        ),
      );
      return null;
    }

    try {
      final debt = validation.debt!;
      if (_existingDebt == null) {
        await _debtRepository.addDebt(debt);
      } else {
        await _debtRepository.updateDebt(debt);
      }
      emit(state.copyWith(isSubmitting: false));
      return debt;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          inlineError: error is ArgumentError && error.message is String
              ? error.message as String
              : error.toString(),
        ),
      );
      return null;
    }
  }

  _ValidationResult _validateAndBuildDebt({
    required String nameInput,
    required String originalPrincipalInput,
    required String currentBalanceInput,
    required String aprInput,
    required String minimumPaymentInput,
    required String dueDayInput,
    required String minimumPaymentPercentInput,
    required String minimumPaymentFloorInput,
  }) {
    final errors = _buildValidationErrors(
      nameInput: nameInput,
      originalPrincipalInput: originalPrincipalInput,
      currentBalanceInput: currentBalanceInput,
      aprInput: aprInput,
      minimumPaymentInput: minimumPaymentInput,
      dueDayInput: dueDayInput,
      minimumPaymentPercentInput: minimumPaymentPercentInput,
      minimumPaymentFloorInput: minimumPaymentFloorInput,
    );

    if (errors.hasErrors) {
      return _ValidationResult(errors: errors);
    }

    final name = nameInput.trim();
    final originalPrincipal = _parseCurrency(
      originalPrincipalInput.trim().isEmpty
          ? currentBalanceInput
          : originalPrincipalInput,
    );
    final currentBalance = _parseCurrency(currentBalanceInput);
    final minimumPayment = _parseCurrency(minimumPaymentInput);
    final apr = _parseApr(aprInput);
    final dueDay = _parseWholeNumber(
      dueDayInput.trim().isEmpty ? '15' : dueDayInput,
    );
    final minimumPaymentPercent = _parseOptionalPercent(
      minimumPaymentPercentInput,
    );
    final minimumPaymentFloor = _parseOptionalCurrency(
      minimumPaymentFloorInput,
    );
    final now = DateTime.now().toUtc();
    final existingDebt = _existingDebt;

    return _ValidationResult(
      debt: Debt(
        id: existingDebt?.id ?? _uuid.v4(),
        scenarioId: existingDebt?.scenarioId ?? 'main',
        name: name,
        type: state.selectedType,
        originalPrincipal: originalPrincipal!,
        currentBalance: currentBalance!,
        apr: apr!,
        interestMethod: state.interestMethod,
        minimumPayment: minimumPayment!,
        minimumPaymentType: state.minimumPaymentType,
        minimumPaymentPercent: minimumPaymentPercent,
        minimumPaymentFloor: minimumPaymentFloor,
        paymentCadence: state.paymentCadence,
        dueDayOfMonth: dueDay!,
        firstDueDate: _computeFirstDueDate(dueDay),
        status: state.status,
        pausedUntil: state.pausedUntil,
        priority: existingDebt?.priority,
        excludeFromStrategy: state.excludeFromStrategy,
        createdAt: existingDebt?.createdAt ?? now,
        updatedAt: now,
        paidOffAt: state.status == DebtStatus.paidOff
            ? (existingDebt?.paidOffAt ?? now)
            : null,
        deletedAt: existingDebt?.deletedAt,
      ),
    );
  }

  _ValidationErrors _buildValidationErrors({
    required String nameInput,
    required String originalPrincipalInput,
    required String currentBalanceInput,
    required String aprInput,
    required String minimumPaymentInput,
    required String dueDayInput,
    required String minimumPaymentPercentInput,
    required String minimumPaymentFloorInput,
  }) {
    final name = nameInput.trim();
    final originalPrincipal = _parseCurrency(
      originalPrincipalInput.trim().isEmpty
          ? currentBalanceInput
          : originalPrincipalInput,
    );
    final currentBalance = _parseCurrency(currentBalanceInput);
    final minimumPayment = _parseCurrency(minimumPaymentInput);
    final apr = _parseApr(aprInput);
    final dueDay = _parseWholeNumber(
      dueDayInput.trim().isEmpty ? '15' : dueDayInput,
    );
    final minimumPaymentPercent = _parseOptionalPercent(
      minimumPaymentPercentInput,
    );
    final minimumPaymentFloor = _parseOptionalCurrency(
      minimumPaymentFloorInput,
    );

    final errors = _ValidationErrors(
      nameError: name.isEmpty ? 'Nhập tên khoản nợ.' : null,
      originalPrincipalError: originalPrincipal == null
          ? 'Nhập số gốc hợp lệ.'
          : originalPrincipal <= 0
          ? 'Số gốc phải lớn hơn 0.'
          : null,
      currentBalanceError: currentBalance == null
          ? 'Nhập số dư hợp lệ.'
          : currentBalance < 0
          ? 'Số dư không được âm.'
          : null,
      aprError: apr == null
          ? 'Nhập APR hợp lệ.'
          : apr < Decimal.zero || apr > Decimal.one
          ? 'APR phải nằm trong khoảng 0% đến 100%.'
          : null,
      minimumPaymentError: minimumPayment == null
          ? 'Nhập minimum payment hợp lệ.'
          : minimumPayment < 0
          ? 'Minimum payment không được âm.'
          : null,
      dueDayError: dueDay == null
          ? 'Nhập ngày đến hạn hợp lệ.'
          : dueDay < 1 || dueDay > 31
          ? 'Ngày đến hạn phải từ 1 đến 31.'
          : null,
      minimumPaymentPercentError:
          state.requiresMinimumPaymentPercent && minimumPaymentPercent == null
          ? 'Nhập phần trăm tối thiểu.'
          : null,
      minimumPaymentFloorError:
          state.requiresMinimumPaymentFloor && minimumPaymentFloor == null
          ? 'Nhập mức sàn tối thiểu.'
          : null,
      pausedUntilError:
          state.status == DebtStatus.paused && state.pausedUntil == null
          ? 'Chọn ngày kết thúc tạm dừng.'
          : null,
    );

    if (state.status == DebtStatus.active && currentBalance == 0) {
      return errors.copyWith(
        currentBalanceError: 'Khoản nợ đang hoạt động phải có số dư lớn hơn 0.',
      );
    }

    if (state.status == DebtStatus.paidOff && currentBalance != 0) {
      return errors.copyWith(
        currentBalanceError: 'Khoản nợ đã trả xong phải có số dư bằng 0.',
      );
    }

    return errors;
  }

  List<String> _buildWarnings({
    required String originalPrincipalInput,
    required String currentBalanceInput,
    required String aprInput,
    required String minimumPaymentInput,
  }) {
    final currentBalance = _parseOptionalCurrency(currentBalanceInput);
    final originalPrincipal = _parseOptionalCurrency(
      originalPrincipalInput.trim().isEmpty
          ? currentBalanceInput
          : originalPrincipalInput,
    );
    final apr = _parseOptionalApr(aprInput);
    final minimumPayment = _parseOptionalCurrency(minimumPaymentInput);

    if (currentBalance == null ||
        originalPrincipal == null ||
        apr == null ||
        minimumPayment == null) {
      return const [];
    }

    final warnings = <String>[];
    if (FinancialValidators.isUsuryWarning(apr)) {
      warnings.add('APR cao bất thường. Hãy kiểm tra lại lãi suất của bạn.');
    }

    if (FinancialValidators.isBalanceOverGrown(
      currentBalanceCents: currentBalance,
      originalPrincipalCents: originalPrincipal,
    )) {
      warnings.add(
        'Số dư hiện tại vượt xa số gốc ban đầu. Kiểm tra lại để tránh sai dữ liệu.',
      );
    }

    final monthlyInterest = InterestCalculator.computeMonthlyInterest(
      balanceCents: currentBalance,
      apr: apr,
      method: state.interestMethod,
    );
    if (FinancialValidators.isNegativeAmortization(
      minimumPaymentCents: minimumPayment,
      monthlyInterestCents: monthlyInterest,
    )) {
      warnings.add(
        'Minimum payment hiện tại chưa đủ bù lãi. Khoản nợ có thể tiếp tục tăng.',
      );
    }

    return warnings;
  }

  int? _parseCurrency(String raw) {
    if (raw.trim().isEmpty) return null;
    final decimal = Decimal.tryParse(raw.trim());
    if (decimal == null) return null;
    return decimal.toCents();
  }

  int? _parseOptionalCurrency(String raw) {
    if (raw.trim().isEmpty) return null;
    return _parseCurrency(raw);
  }

  Decimal? _parseApr(String raw) {
    final parsed = _parseOptionalApr(raw);
    return parsed;
  }

  Decimal? _parseOptionalApr(String raw) {
    if (raw.trim().isEmpty) return null;
    final decimal = Decimal.tryParse(raw.trim());
    if (decimal == null) return null;
    return (decimal / Decimal.fromInt(100))
        .toDecimal(scaleOnInfinitePrecision: 10)
        .roundRate();
  }

  Decimal? _parseOptionalPercent(String raw) {
    if (raw.trim().isEmpty) return null;
    final decimal = Decimal.tryParse(raw.trim());
    if (decimal == null) return null;
    return (decimal / Decimal.fromInt(100))
        .toDecimal(scaleOnInfinitePrecision: 10)
        .roundRate();
  }

  int? _parseWholeNumber(String raw) {
    return int.tryParse(raw.trim());
  }

  DateTime _computeFirstDueDate(int dueDay) {
    final today = DateTime.now();
    final todayLocal = DateTime(today.year, today.month, today.day);
    final currentMonthDay = _clampDay(today.year, today.month, dueDay);
    final currentMonthDue = DateTime(today.year, today.month, currentMonthDay);
    if (!currentMonthDue.isBefore(todayLocal)) {
      return currentMonthDue;
    }
    final nextMonth = DateTime(today.year, today.month + 1);
    final nextMonthDay = _clampDay(nextMonth.year, nextMonth.month, dueDay);
    return DateTime(nextMonth.year, nextMonth.month, nextMonthDay);
  }

  int _clampDay(int year, int month, int desiredDay) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return desiredDay.clamp(1, lastDay);
  }

  static InterestMethod recommendedInterestMethodFor(DebtType type) {
    return _defaultInterestMethodFor(type);
  }

  static InterestMethod _defaultInterestMethodFor(DebtType type) {
    switch (type) {
      case DebtType.creditCard:
        return InterestMethod.compoundDaily;
      case DebtType.studentLoan:
      case DebtType.mortgage:
      case DebtType.medical:
      case DebtType.other:
        return InterestMethod.simpleMonthly;
      case DebtType.carLoan:
      case DebtType.personal:
        return InterestMethod.compoundMonthly;
    }
  }
}

class _ValidationResult {
  const _ValidationResult({this.debt, this.errors});

  final Debt? debt;
  final _ValidationErrors? errors;
}

class _ValidationErrors {
  const _ValidationErrors({
    this.nameError,
    this.originalPrincipalError,
    this.currentBalanceError,
    this.aprError,
    this.minimumPaymentError,
    this.dueDayError,
    this.minimumPaymentPercentError,
    this.minimumPaymentFloorError,
    this.pausedUntilError,
  });

  final String? nameError;
  final String? originalPrincipalError;
  final String? currentBalanceError;
  final String? aprError;
  final String? minimumPaymentError;
  final String? dueDayError;
  final String? minimumPaymentPercentError;
  final String? minimumPaymentFloorError;
  final String? pausedUntilError;

  bool get hasErrors =>
      nameError != null ||
      originalPrincipalError != null ||
      currentBalanceError != null ||
      aprError != null ||
      minimumPaymentError != null ||
      dueDayError != null ||
      minimumPaymentPercentError != null ||
      minimumPaymentFloorError != null ||
      pausedUntilError != null;

  _ValidationErrors copyWith({
    String? nameError,
    String? originalPrincipalError,
    String? currentBalanceError,
    String? aprError,
    String? minimumPaymentError,
    String? dueDayError,
    String? minimumPaymentPercentError,
    String? minimumPaymentFloorError,
    String? pausedUntilError,
  }) {
    return _ValidationErrors(
      nameError: nameError ?? this.nameError,
      originalPrincipalError:
          originalPrincipalError ?? this.originalPrincipalError,
      currentBalanceError: currentBalanceError ?? this.currentBalanceError,
      aprError: aprError ?? this.aprError,
      minimumPaymentError: minimumPaymentError ?? this.minimumPaymentError,
      dueDayError: dueDayError ?? this.dueDayError,
      minimumPaymentPercentError:
          minimumPaymentPercentError ?? this.minimumPaymentPercentError,
      minimumPaymentFloorError:
          minimumPaymentFloorError ?? this.minimumPaymentFloorError,
      pausedUntilError: pausedUntilError ?? this.pausedUntilError,
    );
  }
}
