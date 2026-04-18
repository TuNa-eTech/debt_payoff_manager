// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DebtsTableTable extends DebtsTable
    with TableInfo<$DebtsTableTable, DebtRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scenarioIdMeta = const VerificationMeta(
    'scenarioId',
  );
  @override
  late final GeneratedColumn<String> scenarioId = GeneratedColumn<String>(
    'scenario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('main'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DebtType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DebtType>($DebtsTableTable.$convertertype);
  static const VerificationMeta _originalPrincipalCentsMeta =
      const VerificationMeta('originalPrincipalCents');
  @override
  late final GeneratedColumn<int> originalPrincipalCents = GeneratedColumn<int>(
    'original_principal_cents',
    aliasedName,
    false,
    check: () => ComparableExpr(originalPrincipalCents).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentBalanceCentsMeta =
      const VerificationMeta('currentBalanceCents');
  @override
  late final GeneratedColumn<int> currentBalanceCents = GeneratedColumn<int>(
    'current_balance_cents',
    aliasedName,
    false,
    check: () => ComparableExpr(currentBalanceCents).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> apr =
      GeneratedColumn<String>(
        'apr',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($DebtsTableTable.$converterapr);
  @override
  late final GeneratedColumnWithTypeConverter<InterestMethod, String>
  interestMethod = GeneratedColumn<String>(
    'interest_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<InterestMethod>($DebtsTableTable.$converterinterestMethod);
  static const VerificationMeta _minimumPaymentCentsMeta =
      const VerificationMeta('minimumPaymentCents');
  @override
  late final GeneratedColumn<int> minimumPaymentCents = GeneratedColumn<int>(
    'minimum_payment_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MinPaymentType, String>
  minimumPaymentType =
      GeneratedColumn<String>(
        'minimum_payment_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MinPaymentType>(
        $DebtsTableTable.$converterminimumPaymentType,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String>
  minimumPaymentPercent = GeneratedColumn<String>(
    'minimum_payment_percent',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Decimal?>($DebtsTableTable.$converterminimumPaymentPercentn);
  static const VerificationMeta _minimumPaymentFloorCentsMeta =
      const VerificationMeta('minimumPaymentFloorCents');
  @override
  late final GeneratedColumn<int> minimumPaymentFloorCents =
      GeneratedColumn<int>(
        'minimum_payment_floor_cents',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentCadence, String>
  paymentCadence = GeneratedColumn<String>(
    'payment_cadence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PaymentCadence>($DebtsTableTable.$converterpaymentCadence);
  static const VerificationMeta _dueDayOfMonthMeta = const VerificationMeta(
    'dueDayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dueDayOfMonth = GeneratedColumn<int>(
    'due_day_of_month',
    aliasedName,
    true,
    check: () => ComparableExpr(dueDayOfMonth).isBetweenValues(1, 31),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> firstDueDate =
      GeneratedColumn<String>(
        'first_due_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($DebtsTableTable.$converterfirstDueDate);
  @override
  late final GeneratedColumnWithTypeConverter<DebtStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DebtStatus>($DebtsTableTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> pausedUntil =
      GeneratedColumn<String>(
        'paused_until',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($DebtsTableTable.$converterpausedUntiln);
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _excludeFromStrategyMeta =
      const VerificationMeta('excludeFromStrategy');
  @override
  late final GeneratedColumn<bool> excludeFromStrategy = GeneratedColumn<bool>(
    'exclude_from_strategy',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("exclude_from_strategy" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($DebtsTableTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($DebtsTableTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> paidOffAt =
      GeneratedColumn<String>(
        'paid_off_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($DebtsTableTable.$converterpaidOffAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($DebtsTableTable.$converterdeletedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scenarioId,
    name,
    type,
    originalPrincipalCents,
    currentBalanceCents,
    apr,
    interestMethod,
    minimumPaymentCents,
    minimumPaymentType,
    minimumPaymentPercent,
    minimumPaymentFloorCents,
    paymentCadence,
    dueDayOfMonth,
    firstDueDate,
    status,
    pausedUntil,
    priority,
    excludeFromStrategy,
    createdAt,
    updatedAt,
    paidOffAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebtRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scenario_id')) {
      context.handle(
        _scenarioIdMeta,
        scenarioId.isAcceptableOrUnknown(data['scenario_id']!, _scenarioIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('original_principal_cents')) {
      context.handle(
        _originalPrincipalCentsMeta,
        originalPrincipalCents.isAcceptableOrUnknown(
          data['original_principal_cents']!,
          _originalPrincipalCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalPrincipalCentsMeta);
    }
    if (data.containsKey('current_balance_cents')) {
      context.handle(
        _currentBalanceCentsMeta,
        currentBalanceCents.isAcceptableOrUnknown(
          data['current_balance_cents']!,
          _currentBalanceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentBalanceCentsMeta);
    }
    if (data.containsKey('minimum_payment_cents')) {
      context.handle(
        _minimumPaymentCentsMeta,
        minimumPaymentCents.isAcceptableOrUnknown(
          data['minimum_payment_cents']!,
          _minimumPaymentCentsMeta,
        ),
      );
    }
    if (data.containsKey('minimum_payment_floor_cents')) {
      context.handle(
        _minimumPaymentFloorCentsMeta,
        minimumPaymentFloorCents.isAcceptableOrUnknown(
          data['minimum_payment_floor_cents']!,
          _minimumPaymentFloorCentsMeta,
        ),
      );
    }
    if (data.containsKey('due_day_of_month')) {
      context.handle(
        _dueDayOfMonthMeta,
        dueDayOfMonth.isAcceptableOrUnknown(
          data['due_day_of_month']!,
          _dueDayOfMonthMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('exclude_from_strategy')) {
      context.handle(
        _excludeFromStrategyMeta,
        excludeFromStrategy.isAcceptableOrUnknown(
          data['exclude_from_strategy']!,
          _excludeFromStrategyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scenarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scenario_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $DebtsTableTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      originalPrincipalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_principal_cents'],
      )!,
      currentBalanceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_balance_cents'],
      )!,
      apr: $DebtsTableTable.$converterapr.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}apr'],
        )!,
      ),
      interestMethod: $DebtsTableTable.$converterinterestMethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}interest_method'],
        )!,
      ),
      minimumPaymentCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_payment_cents'],
      )!,
      minimumPaymentType: $DebtsTableTable.$converterminimumPaymentType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}minimum_payment_type'],
        )!,
      ),
      minimumPaymentPercent: $DebtsTableTable.$converterminimumPaymentPercentn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}minimum_payment_percent'],
            ),
          ),
      minimumPaymentFloorCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_payment_floor_cents'],
      ),
      paymentCadence: $DebtsTableTable.$converterpaymentCadence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_cadence'],
        )!,
      ),
      dueDayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_day_of_month'],
      ),
      firstDueDate: $DebtsTableTable.$converterfirstDueDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}first_due_date'],
        )!,
      ),
      status: $DebtsTableTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      pausedUntil: $DebtsTableTable.$converterpausedUntiln.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}paused_until'],
        ),
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      ),
      excludeFromStrategy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}exclude_from_strategy'],
      )!,
      createdAt: $DebtsTableTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $DebtsTableTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      paidOffAt: $DebtsTableTable.$converterpaidOffAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}paid_off_at'],
        ),
      ),
      deletedAt: $DebtsTableTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
    );
  }

  @override
  $DebtsTableTable createAlias(String alias) {
    return $DebtsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DebtType, String> $convertertype =
      const DebtTypeConverter();
  static TypeConverter<Decimal, String> $converterapr =
      const DecimalConverter();
  static TypeConverter<InterestMethod, String> $converterinterestMethod =
      const InterestMethodConverter();
  static TypeConverter<MinPaymentType, String> $converterminimumPaymentType =
      const MinPaymentTypeConverter();
  static TypeConverter<Decimal, String> $converterminimumPaymentPercent =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $converterminimumPaymentPercentn =
      NullAwareTypeConverter.wrap($converterminimumPaymentPercent);
  static TypeConverter<PaymentCadence, String> $converterpaymentCadence =
      const CadenceConverter();
  static TypeConverter<DateTime, String> $converterfirstDueDate =
      const LocalDateConverter();
  static TypeConverter<DebtStatus, String> $converterstatus =
      const DebtStatusConverter();
  static TypeConverter<DateTime, String> $converterpausedUntil =
      const LocalDateConverter();
  static TypeConverter<DateTime?, String?> $converterpausedUntiln =
      NullAwareTypeConverter.wrap($converterpausedUntil);
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterpaidOffAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterpaidOffAtn =
      NullAwareTypeConverter.wrap($converterpaidOffAt);
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class DebtRow extends DataClass implements Insertable<DebtRow> {
  final String id;
  final String scenarioId;
  final String name;
  final DebtType type;
  final int originalPrincipalCents;
  final int currentBalanceCents;
  final Decimal apr;
  final InterestMethod interestMethod;
  final int minimumPaymentCents;
  final MinPaymentType minimumPaymentType;
  final Decimal? minimumPaymentPercent;
  final int? minimumPaymentFloorCents;
  final PaymentCadence paymentCadence;
  final int? dueDayOfMonth;
  final DateTime firstDueDate;
  final DebtStatus status;
  final DateTime? pausedUntil;
  final int? priority;
  final bool excludeFromStrategy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidOffAt;
  final DateTime? deletedAt;
  const DebtRow({
    required this.id,
    required this.scenarioId,
    required this.name,
    required this.type,
    required this.originalPrincipalCents,
    required this.currentBalanceCents,
    required this.apr,
    required this.interestMethod,
    required this.minimumPaymentCents,
    required this.minimumPaymentType,
    this.minimumPaymentPercent,
    this.minimumPaymentFloorCents,
    required this.paymentCadence,
    this.dueDayOfMonth,
    required this.firstDueDate,
    required this.status,
    this.pausedUntil,
    this.priority,
    required this.excludeFromStrategy,
    required this.createdAt,
    required this.updatedAt,
    this.paidOffAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scenario_id'] = Variable<String>(scenarioId);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>(
        $DebtsTableTable.$convertertype.toSql(type),
      );
    }
    map['original_principal_cents'] = Variable<int>(originalPrincipalCents);
    map['current_balance_cents'] = Variable<int>(currentBalanceCents);
    {
      map['apr'] = Variable<String>($DebtsTableTable.$converterapr.toSql(apr));
    }
    {
      map['interest_method'] = Variable<String>(
        $DebtsTableTable.$converterinterestMethod.toSql(interestMethod),
      );
    }
    map['minimum_payment_cents'] = Variable<int>(minimumPaymentCents);
    {
      map['minimum_payment_type'] = Variable<String>(
        $DebtsTableTable.$converterminimumPaymentType.toSql(minimumPaymentType),
      );
    }
    if (!nullToAbsent || minimumPaymentPercent != null) {
      map['minimum_payment_percent'] = Variable<String>(
        $DebtsTableTable.$converterminimumPaymentPercentn.toSql(
          minimumPaymentPercent,
        ),
      );
    }
    if (!nullToAbsent || minimumPaymentFloorCents != null) {
      map['minimum_payment_floor_cents'] = Variable<int>(
        minimumPaymentFloorCents,
      );
    }
    {
      map['payment_cadence'] = Variable<String>(
        $DebtsTableTable.$converterpaymentCadence.toSql(paymentCadence),
      );
    }
    if (!nullToAbsent || dueDayOfMonth != null) {
      map['due_day_of_month'] = Variable<int>(dueDayOfMonth);
    }
    {
      map['first_due_date'] = Variable<String>(
        $DebtsTableTable.$converterfirstDueDate.toSql(firstDueDate),
      );
    }
    {
      map['status'] = Variable<String>(
        $DebtsTableTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || pausedUntil != null) {
      map['paused_until'] = Variable<String>(
        $DebtsTableTable.$converterpausedUntiln.toSql(pausedUntil),
      );
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<int>(priority);
    }
    map['exclude_from_strategy'] = Variable<bool>(excludeFromStrategy);
    {
      map['created_at'] = Variable<String>(
        $DebtsTableTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $DebtsTableTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || paidOffAt != null) {
      map['paid_off_at'] = Variable<String>(
        $DebtsTableTable.$converterpaidOffAtn.toSql(paidOffAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $DebtsTableTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    return map;
  }

  DebtsTableCompanion toCompanion(bool nullToAbsent) {
    return DebtsTableCompanion(
      id: Value(id),
      scenarioId: Value(scenarioId),
      name: Value(name),
      type: Value(type),
      originalPrincipalCents: Value(originalPrincipalCents),
      currentBalanceCents: Value(currentBalanceCents),
      apr: Value(apr),
      interestMethod: Value(interestMethod),
      minimumPaymentCents: Value(minimumPaymentCents),
      minimumPaymentType: Value(minimumPaymentType),
      minimumPaymentPercent: minimumPaymentPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumPaymentPercent),
      minimumPaymentFloorCents: minimumPaymentFloorCents == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumPaymentFloorCents),
      paymentCadence: Value(paymentCadence),
      dueDayOfMonth: dueDayOfMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDayOfMonth),
      firstDueDate: Value(firstDueDate),
      status: Value(status),
      pausedUntil: pausedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedUntil),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      excludeFromStrategy: Value(excludeFromStrategy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      paidOffAt: paidOffAt == null && nullToAbsent
          ? const Value.absent()
          : Value(paidOffAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory DebtRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtRow(
      id: serializer.fromJson<String>(json['id']),
      scenarioId: serializer.fromJson<String>(json['scenarioId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<DebtType>(json['type']),
      originalPrincipalCents: serializer.fromJson<int>(
        json['originalPrincipalCents'],
      ),
      currentBalanceCents: serializer.fromJson<int>(
        json['currentBalanceCents'],
      ),
      apr: serializer.fromJson<Decimal>(json['apr']),
      interestMethod: serializer.fromJson<InterestMethod>(
        json['interestMethod'],
      ),
      minimumPaymentCents: serializer.fromJson<int>(
        json['minimumPaymentCents'],
      ),
      minimumPaymentType: serializer.fromJson<MinPaymentType>(
        json['minimumPaymentType'],
      ),
      minimumPaymentPercent: serializer.fromJson<Decimal?>(
        json['minimumPaymentPercent'],
      ),
      minimumPaymentFloorCents: serializer.fromJson<int?>(
        json['minimumPaymentFloorCents'],
      ),
      paymentCadence: serializer.fromJson<PaymentCadence>(
        json['paymentCadence'],
      ),
      dueDayOfMonth: serializer.fromJson<int?>(json['dueDayOfMonth']),
      firstDueDate: serializer.fromJson<DateTime>(json['firstDueDate']),
      status: serializer.fromJson<DebtStatus>(json['status']),
      pausedUntil: serializer.fromJson<DateTime?>(json['pausedUntil']),
      priority: serializer.fromJson<int?>(json['priority']),
      excludeFromStrategy: serializer.fromJson<bool>(
        json['excludeFromStrategy'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      paidOffAt: serializer.fromJson<DateTime?>(json['paidOffAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scenarioId': serializer.toJson<String>(scenarioId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<DebtType>(type),
      'originalPrincipalCents': serializer.toJson<int>(originalPrincipalCents),
      'currentBalanceCents': serializer.toJson<int>(currentBalanceCents),
      'apr': serializer.toJson<Decimal>(apr),
      'interestMethod': serializer.toJson<InterestMethod>(interestMethod),
      'minimumPaymentCents': serializer.toJson<int>(minimumPaymentCents),
      'minimumPaymentType': serializer.toJson<MinPaymentType>(
        minimumPaymentType,
      ),
      'minimumPaymentPercent': serializer.toJson<Decimal?>(
        minimumPaymentPercent,
      ),
      'minimumPaymentFloorCents': serializer.toJson<int?>(
        minimumPaymentFloorCents,
      ),
      'paymentCadence': serializer.toJson<PaymentCadence>(paymentCadence),
      'dueDayOfMonth': serializer.toJson<int?>(dueDayOfMonth),
      'firstDueDate': serializer.toJson<DateTime>(firstDueDate),
      'status': serializer.toJson<DebtStatus>(status),
      'pausedUntil': serializer.toJson<DateTime?>(pausedUntil),
      'priority': serializer.toJson<int?>(priority),
      'excludeFromStrategy': serializer.toJson<bool>(excludeFromStrategy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'paidOffAt': serializer.toJson<DateTime?>(paidOffAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  DebtRow copyWith({
    String? id,
    String? scenarioId,
    String? name,
    DebtType? type,
    int? originalPrincipalCents,
    int? currentBalanceCents,
    Decimal? apr,
    InterestMethod? interestMethod,
    int? minimumPaymentCents,
    MinPaymentType? minimumPaymentType,
    Value<Decimal?> minimumPaymentPercent = const Value.absent(),
    Value<int?> minimumPaymentFloorCents = const Value.absent(),
    PaymentCadence? paymentCadence,
    Value<int?> dueDayOfMonth = const Value.absent(),
    DateTime? firstDueDate,
    DebtStatus? status,
    Value<DateTime?> pausedUntil = const Value.absent(),
    Value<int?> priority = const Value.absent(),
    bool? excludeFromStrategy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> paidOffAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => DebtRow(
    id: id ?? this.id,
    scenarioId: scenarioId ?? this.scenarioId,
    name: name ?? this.name,
    type: type ?? this.type,
    originalPrincipalCents:
        originalPrincipalCents ?? this.originalPrincipalCents,
    currentBalanceCents: currentBalanceCents ?? this.currentBalanceCents,
    apr: apr ?? this.apr,
    interestMethod: interestMethod ?? this.interestMethod,
    minimumPaymentCents: minimumPaymentCents ?? this.minimumPaymentCents,
    minimumPaymentType: minimumPaymentType ?? this.minimumPaymentType,
    minimumPaymentPercent: minimumPaymentPercent.present
        ? minimumPaymentPercent.value
        : this.minimumPaymentPercent,
    minimumPaymentFloorCents: minimumPaymentFloorCents.present
        ? minimumPaymentFloorCents.value
        : this.minimumPaymentFloorCents,
    paymentCadence: paymentCadence ?? this.paymentCadence,
    dueDayOfMonth: dueDayOfMonth.present
        ? dueDayOfMonth.value
        : this.dueDayOfMonth,
    firstDueDate: firstDueDate ?? this.firstDueDate,
    status: status ?? this.status,
    pausedUntil: pausedUntil.present ? pausedUntil.value : this.pausedUntil,
    priority: priority.present ? priority.value : this.priority,
    excludeFromStrategy: excludeFromStrategy ?? this.excludeFromStrategy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    paidOffAt: paidOffAt.present ? paidOffAt.value : this.paidOffAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  DebtRow copyWithCompanion(DebtsTableCompanion data) {
    return DebtRow(
      id: data.id.present ? data.id.value : this.id,
      scenarioId: data.scenarioId.present
          ? data.scenarioId.value
          : this.scenarioId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      originalPrincipalCents: data.originalPrincipalCents.present
          ? data.originalPrincipalCents.value
          : this.originalPrincipalCents,
      currentBalanceCents: data.currentBalanceCents.present
          ? data.currentBalanceCents.value
          : this.currentBalanceCents,
      apr: data.apr.present ? data.apr.value : this.apr,
      interestMethod: data.interestMethod.present
          ? data.interestMethod.value
          : this.interestMethod,
      minimumPaymentCents: data.minimumPaymentCents.present
          ? data.minimumPaymentCents.value
          : this.minimumPaymentCents,
      minimumPaymentType: data.minimumPaymentType.present
          ? data.minimumPaymentType.value
          : this.minimumPaymentType,
      minimumPaymentPercent: data.minimumPaymentPercent.present
          ? data.minimumPaymentPercent.value
          : this.minimumPaymentPercent,
      minimumPaymentFloorCents: data.minimumPaymentFloorCents.present
          ? data.minimumPaymentFloorCents.value
          : this.minimumPaymentFloorCents,
      paymentCadence: data.paymentCadence.present
          ? data.paymentCadence.value
          : this.paymentCadence,
      dueDayOfMonth: data.dueDayOfMonth.present
          ? data.dueDayOfMonth.value
          : this.dueDayOfMonth,
      firstDueDate: data.firstDueDate.present
          ? data.firstDueDate.value
          : this.firstDueDate,
      status: data.status.present ? data.status.value : this.status,
      pausedUntil: data.pausedUntil.present
          ? data.pausedUntil.value
          : this.pausedUntil,
      priority: data.priority.present ? data.priority.value : this.priority,
      excludeFromStrategy: data.excludeFromStrategy.present
          ? data.excludeFromStrategy.value
          : this.excludeFromStrategy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      paidOffAt: data.paidOffAt.present ? data.paidOffAt.value : this.paidOffAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtRow(')
          ..write('id: $id, ')
          ..write('scenarioId: $scenarioId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('originalPrincipalCents: $originalPrincipalCents, ')
          ..write('currentBalanceCents: $currentBalanceCents, ')
          ..write('apr: $apr, ')
          ..write('interestMethod: $interestMethod, ')
          ..write('minimumPaymentCents: $minimumPaymentCents, ')
          ..write('minimumPaymentType: $minimumPaymentType, ')
          ..write('minimumPaymentPercent: $minimumPaymentPercent, ')
          ..write('minimumPaymentFloorCents: $minimumPaymentFloorCents, ')
          ..write('paymentCadence: $paymentCadence, ')
          ..write('dueDayOfMonth: $dueDayOfMonth, ')
          ..write('firstDueDate: $firstDueDate, ')
          ..write('status: $status, ')
          ..write('pausedUntil: $pausedUntil, ')
          ..write('priority: $priority, ')
          ..write('excludeFromStrategy: $excludeFromStrategy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('paidOffAt: $paidOffAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    scenarioId,
    name,
    type,
    originalPrincipalCents,
    currentBalanceCents,
    apr,
    interestMethod,
    minimumPaymentCents,
    minimumPaymentType,
    minimumPaymentPercent,
    minimumPaymentFloorCents,
    paymentCadence,
    dueDayOfMonth,
    firstDueDate,
    status,
    pausedUntil,
    priority,
    excludeFromStrategy,
    createdAt,
    updatedAt,
    paidOffAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtRow &&
          other.id == this.id &&
          other.scenarioId == this.scenarioId &&
          other.name == this.name &&
          other.type == this.type &&
          other.originalPrincipalCents == this.originalPrincipalCents &&
          other.currentBalanceCents == this.currentBalanceCents &&
          other.apr == this.apr &&
          other.interestMethod == this.interestMethod &&
          other.minimumPaymentCents == this.minimumPaymentCents &&
          other.minimumPaymentType == this.minimumPaymentType &&
          other.minimumPaymentPercent == this.minimumPaymentPercent &&
          other.minimumPaymentFloorCents == this.minimumPaymentFloorCents &&
          other.paymentCadence == this.paymentCadence &&
          other.dueDayOfMonth == this.dueDayOfMonth &&
          other.firstDueDate == this.firstDueDate &&
          other.status == this.status &&
          other.pausedUntil == this.pausedUntil &&
          other.priority == this.priority &&
          other.excludeFromStrategy == this.excludeFromStrategy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.paidOffAt == this.paidOffAt &&
          other.deletedAt == this.deletedAt);
}

class DebtsTableCompanion extends UpdateCompanion<DebtRow> {
  final Value<String> id;
  final Value<String> scenarioId;
  final Value<String> name;
  final Value<DebtType> type;
  final Value<int> originalPrincipalCents;
  final Value<int> currentBalanceCents;
  final Value<Decimal> apr;
  final Value<InterestMethod> interestMethod;
  final Value<int> minimumPaymentCents;
  final Value<MinPaymentType> minimumPaymentType;
  final Value<Decimal?> minimumPaymentPercent;
  final Value<int?> minimumPaymentFloorCents;
  final Value<PaymentCadence> paymentCadence;
  final Value<int?> dueDayOfMonth;
  final Value<DateTime> firstDueDate;
  final Value<DebtStatus> status;
  final Value<DateTime?> pausedUntil;
  final Value<int?> priority;
  final Value<bool> excludeFromStrategy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> paidOffAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const DebtsTableCompanion({
    this.id = const Value.absent(),
    this.scenarioId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.originalPrincipalCents = const Value.absent(),
    this.currentBalanceCents = const Value.absent(),
    this.apr = const Value.absent(),
    this.interestMethod = const Value.absent(),
    this.minimumPaymentCents = const Value.absent(),
    this.minimumPaymentType = const Value.absent(),
    this.minimumPaymentPercent = const Value.absent(),
    this.minimumPaymentFloorCents = const Value.absent(),
    this.paymentCadence = const Value.absent(),
    this.dueDayOfMonth = const Value.absent(),
    this.firstDueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.pausedUntil = const Value.absent(),
    this.priority = const Value.absent(),
    this.excludeFromStrategy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.paidOffAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtsTableCompanion.insert({
    required String id,
    this.scenarioId = const Value.absent(),
    required String name,
    required DebtType type,
    required int originalPrincipalCents,
    required int currentBalanceCents,
    required Decimal apr,
    required InterestMethod interestMethod,
    this.minimumPaymentCents = const Value.absent(),
    required MinPaymentType minimumPaymentType,
    this.minimumPaymentPercent = const Value.absent(),
    this.minimumPaymentFloorCents = const Value.absent(),
    required PaymentCadence paymentCadence,
    this.dueDayOfMonth = const Value.absent(),
    required DateTime firstDueDate,
    required DebtStatus status,
    this.pausedUntil = const Value.absent(),
    this.priority = const Value.absent(),
    this.excludeFromStrategy = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.paidOffAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       originalPrincipalCents = Value(originalPrincipalCents),
       currentBalanceCents = Value(currentBalanceCents),
       apr = Value(apr),
       interestMethod = Value(interestMethod),
       minimumPaymentType = Value(minimumPaymentType),
       paymentCadence = Value(paymentCadence),
       firstDueDate = Value(firstDueDate),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DebtRow> custom({
    Expression<String>? id,
    Expression<String>? scenarioId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? originalPrincipalCents,
    Expression<int>? currentBalanceCents,
    Expression<String>? apr,
    Expression<String>? interestMethod,
    Expression<int>? minimumPaymentCents,
    Expression<String>? minimumPaymentType,
    Expression<String>? minimumPaymentPercent,
    Expression<int>? minimumPaymentFloorCents,
    Expression<String>? paymentCadence,
    Expression<int>? dueDayOfMonth,
    Expression<String>? firstDueDate,
    Expression<String>? status,
    Expression<String>? pausedUntil,
    Expression<int>? priority,
    Expression<bool>? excludeFromStrategy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? paidOffAt,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scenarioId != null) 'scenario_id': scenarioId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (originalPrincipalCents != null)
        'original_principal_cents': originalPrincipalCents,
      if (currentBalanceCents != null)
        'current_balance_cents': currentBalanceCents,
      if (apr != null) 'apr': apr,
      if (interestMethod != null) 'interest_method': interestMethod,
      if (minimumPaymentCents != null)
        'minimum_payment_cents': minimumPaymentCents,
      if (minimumPaymentType != null)
        'minimum_payment_type': minimumPaymentType,
      if (minimumPaymentPercent != null)
        'minimum_payment_percent': minimumPaymentPercent,
      if (minimumPaymentFloorCents != null)
        'minimum_payment_floor_cents': minimumPaymentFloorCents,
      if (paymentCadence != null) 'payment_cadence': paymentCadence,
      if (dueDayOfMonth != null) 'due_day_of_month': dueDayOfMonth,
      if (firstDueDate != null) 'first_due_date': firstDueDate,
      if (status != null) 'status': status,
      if (pausedUntil != null) 'paused_until': pausedUntil,
      if (priority != null) 'priority': priority,
      if (excludeFromStrategy != null)
        'exclude_from_strategy': excludeFromStrategy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (paidOffAt != null) 'paid_off_at': paidOffAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? scenarioId,
    Value<String>? name,
    Value<DebtType>? type,
    Value<int>? originalPrincipalCents,
    Value<int>? currentBalanceCents,
    Value<Decimal>? apr,
    Value<InterestMethod>? interestMethod,
    Value<int>? minimumPaymentCents,
    Value<MinPaymentType>? minimumPaymentType,
    Value<Decimal?>? minimumPaymentPercent,
    Value<int?>? minimumPaymentFloorCents,
    Value<PaymentCadence>? paymentCadence,
    Value<int?>? dueDayOfMonth,
    Value<DateTime>? firstDueDate,
    Value<DebtStatus>? status,
    Value<DateTime?>? pausedUntil,
    Value<int?>? priority,
    Value<bool>? excludeFromStrategy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? paidOffAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return DebtsTableCompanion(
      id: id ?? this.id,
      scenarioId: scenarioId ?? this.scenarioId,
      name: name ?? this.name,
      type: type ?? this.type,
      originalPrincipalCents:
          originalPrincipalCents ?? this.originalPrincipalCents,
      currentBalanceCents: currentBalanceCents ?? this.currentBalanceCents,
      apr: apr ?? this.apr,
      interestMethod: interestMethod ?? this.interestMethod,
      minimumPaymentCents: minimumPaymentCents ?? this.minimumPaymentCents,
      minimumPaymentType: minimumPaymentType ?? this.minimumPaymentType,
      minimumPaymentPercent:
          minimumPaymentPercent ?? this.minimumPaymentPercent,
      minimumPaymentFloorCents:
          minimumPaymentFloorCents ?? this.minimumPaymentFloorCents,
      paymentCadence: paymentCadence ?? this.paymentCadence,
      dueDayOfMonth: dueDayOfMonth ?? this.dueDayOfMonth,
      firstDueDate: firstDueDate ?? this.firstDueDate,
      status: status ?? this.status,
      pausedUntil: pausedUntil ?? this.pausedUntil,
      priority: priority ?? this.priority,
      excludeFromStrategy: excludeFromStrategy ?? this.excludeFromStrategy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidOffAt: paidOffAt ?? this.paidOffAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scenarioId.present) {
      map['scenario_id'] = Variable<String>(scenarioId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $DebtsTableTable.$convertertype.toSql(type.value),
      );
    }
    if (originalPrincipalCents.present) {
      map['original_principal_cents'] = Variable<int>(
        originalPrincipalCents.value,
      );
    }
    if (currentBalanceCents.present) {
      map['current_balance_cents'] = Variable<int>(currentBalanceCents.value);
    }
    if (apr.present) {
      map['apr'] = Variable<String>(
        $DebtsTableTable.$converterapr.toSql(apr.value),
      );
    }
    if (interestMethod.present) {
      map['interest_method'] = Variable<String>(
        $DebtsTableTable.$converterinterestMethod.toSql(interestMethod.value),
      );
    }
    if (minimumPaymentCents.present) {
      map['minimum_payment_cents'] = Variable<int>(minimumPaymentCents.value);
    }
    if (minimumPaymentType.present) {
      map['minimum_payment_type'] = Variable<String>(
        $DebtsTableTable.$converterminimumPaymentType.toSql(
          minimumPaymentType.value,
        ),
      );
    }
    if (minimumPaymentPercent.present) {
      map['minimum_payment_percent'] = Variable<String>(
        $DebtsTableTable.$converterminimumPaymentPercentn.toSql(
          minimumPaymentPercent.value,
        ),
      );
    }
    if (minimumPaymentFloorCents.present) {
      map['minimum_payment_floor_cents'] = Variable<int>(
        minimumPaymentFloorCents.value,
      );
    }
    if (paymentCadence.present) {
      map['payment_cadence'] = Variable<String>(
        $DebtsTableTable.$converterpaymentCadence.toSql(paymentCadence.value),
      );
    }
    if (dueDayOfMonth.present) {
      map['due_day_of_month'] = Variable<int>(dueDayOfMonth.value);
    }
    if (firstDueDate.present) {
      map['first_due_date'] = Variable<String>(
        $DebtsTableTable.$converterfirstDueDate.toSql(firstDueDate.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $DebtsTableTable.$converterstatus.toSql(status.value),
      );
    }
    if (pausedUntil.present) {
      map['paused_until'] = Variable<String>(
        $DebtsTableTable.$converterpausedUntiln.toSql(pausedUntil.value),
      );
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (excludeFromStrategy.present) {
      map['exclude_from_strategy'] = Variable<bool>(excludeFromStrategy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $DebtsTableTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $DebtsTableTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (paidOffAt.present) {
      map['paid_off_at'] = Variable<String>(
        $DebtsTableTable.$converterpaidOffAtn.toSql(paidOffAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $DebtsTableTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsTableCompanion(')
          ..write('id: $id, ')
          ..write('scenarioId: $scenarioId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('originalPrincipalCents: $originalPrincipalCents, ')
          ..write('currentBalanceCents: $currentBalanceCents, ')
          ..write('apr: $apr, ')
          ..write('interestMethod: $interestMethod, ')
          ..write('minimumPaymentCents: $minimumPaymentCents, ')
          ..write('minimumPaymentType: $minimumPaymentType, ')
          ..write('minimumPaymentPercent: $minimumPaymentPercent, ')
          ..write('minimumPaymentFloorCents: $minimumPaymentFloorCents, ')
          ..write('paymentCadence: $paymentCadence, ')
          ..write('dueDayOfMonth: $dueDayOfMonth, ')
          ..write('firstDueDate: $firstDueDate, ')
          ..write('status: $status, ')
          ..write('pausedUntil: $pausedUntil, ')
          ..write('priority: $priority, ')
          ..write('excludeFromStrategy: $excludeFromStrategy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('paidOffAt: $paidOffAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTableTable extends PaymentsTable
    with TableInfo<$PaymentsTableTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scenarioIdMeta = const VerificationMeta(
    'scenarioId',
  );
  @override
  late final GeneratedColumn<String> scenarioId = GeneratedColumn<String>(
    'scenario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('main'),
  );
  static const VerificationMeta _debtIdMeta = const VerificationMeta('debtId');
  @override
  late final GeneratedColumn<String> debtId = GeneratedColumn<String>(
    'debt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES debts (id)',
    ),
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    check: () => ComparableExpr(amountCents).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _principalPortionCentsMeta =
      const VerificationMeta('principalPortionCents');
  @override
  late final GeneratedColumn<int> principalPortionCents = GeneratedColumn<int>(
    'principal_portion_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _interestPortionCentsMeta =
      const VerificationMeta('interestPortionCents');
  @override
  late final GeneratedColumn<int> interestPortionCents = GeneratedColumn<int>(
    'interest_portion_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feePortionCentsMeta = const VerificationMeta(
    'feePortionCents',
  );
  @override
  late final GeneratedColumn<int> feePortionCents = GeneratedColumn<int>(
    'fee_portion_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PaymentsTableTable.$converterdate);
  @override
  late final GeneratedColumnWithTypeConverter<PaymentType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PaymentType>($PaymentsTableTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<PaymentSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PaymentSource>($PaymentsTableTable.$convertersource);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PaymentStatus>($PaymentsTableTable.$converterstatus);
  static const VerificationMeta _appliedBalanceBeforeCentsMeta =
      const VerificationMeta('appliedBalanceBeforeCents');
  @override
  late final GeneratedColumn<int> appliedBalanceBeforeCents =
      GeneratedColumn<int>(
        'applied_balance_before_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _appliedBalanceAfterCentsMeta =
      const VerificationMeta('appliedBalanceAfterCents');
  @override
  late final GeneratedColumn<int> appliedBalanceAfterCents =
      GeneratedColumn<int>(
        'applied_balance_after_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PaymentsTableTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PaymentsTableTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($PaymentsTableTable.$converterdeletedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scenarioId,
    debtId,
    amountCents,
    principalPortionCents,
    interestPortionCents,
    feePortionCents,
    date,
    type,
    source,
    note,
    status,
    appliedBalanceBeforeCents,
    appliedBalanceAfterCents,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scenario_id')) {
      context.handle(
        _scenarioIdMeta,
        scenarioId.isAcceptableOrUnknown(data['scenario_id']!, _scenarioIdMeta),
      );
    }
    if (data.containsKey('debt_id')) {
      context.handle(
        _debtIdMeta,
        debtId.isAcceptableOrUnknown(data['debt_id']!, _debtIdMeta),
      );
    } else if (isInserting) {
      context.missing(_debtIdMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('principal_portion_cents')) {
      context.handle(
        _principalPortionCentsMeta,
        principalPortionCents.isAcceptableOrUnknown(
          data['principal_portion_cents']!,
          _principalPortionCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_principalPortionCentsMeta);
    }
    if (data.containsKey('interest_portion_cents')) {
      context.handle(
        _interestPortionCentsMeta,
        interestPortionCents.isAcceptableOrUnknown(
          data['interest_portion_cents']!,
          _interestPortionCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interestPortionCentsMeta);
    }
    if (data.containsKey('fee_portion_cents')) {
      context.handle(
        _feePortionCentsMeta,
        feePortionCents.isAcceptableOrUnknown(
          data['fee_portion_cents']!,
          _feePortionCentsMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('applied_balance_before_cents')) {
      context.handle(
        _appliedBalanceBeforeCentsMeta,
        appliedBalanceBeforeCents.isAcceptableOrUnknown(
          data['applied_balance_before_cents']!,
          _appliedBalanceBeforeCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appliedBalanceBeforeCentsMeta);
    }
    if (data.containsKey('applied_balance_after_cents')) {
      context.handle(
        _appliedBalanceAfterCentsMeta,
        appliedBalanceAfterCents.isAcceptableOrUnknown(
          data['applied_balance_after_cents']!,
          _appliedBalanceAfterCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appliedBalanceAfterCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scenarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scenario_id'],
      )!,
      debtId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}debt_id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      principalPortionCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}principal_portion_cents'],
      )!,
      interestPortionCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interest_portion_cents'],
      )!,
      feePortionCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fee_portion_cents'],
      )!,
      date: $PaymentsTableTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      type: $PaymentsTableTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      source: $PaymentsTableTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      status: $PaymentsTableTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      appliedBalanceBeforeCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}applied_balance_before_cents'],
      )!,
      appliedBalanceAfterCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}applied_balance_after_cents'],
      )!,
      createdAt: $PaymentsTableTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $PaymentsTableTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $PaymentsTableTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
    );
  }

  @override
  $PaymentsTableTable createAlias(String alias) {
    return $PaymentsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdate =
      const LocalDateConverter();
  static TypeConverter<PaymentType, String> $convertertype =
      const PaymentTypeConverter();
  static TypeConverter<PaymentSource, String> $convertersource =
      const PaymentSourceConverter();
  static TypeConverter<PaymentStatus, String> $converterstatus =
      const PaymentStatusConverter();
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final String id;
  final String scenarioId;
  final String debtId;
  final int amountCents;
  final int principalPortionCents;
  final int interestPortionCents;
  final int feePortionCents;
  final DateTime date;
  final PaymentType type;
  final PaymentSource source;
  final String? note;
  final PaymentStatus status;
  final int appliedBalanceBeforeCents;
  final int appliedBalanceAfterCents;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const PaymentRow({
    required this.id,
    required this.scenarioId,
    required this.debtId,
    required this.amountCents,
    required this.principalPortionCents,
    required this.interestPortionCents,
    required this.feePortionCents,
    required this.date,
    required this.type,
    required this.source,
    this.note,
    required this.status,
    required this.appliedBalanceBeforeCents,
    required this.appliedBalanceAfterCents,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scenario_id'] = Variable<String>(scenarioId);
    map['debt_id'] = Variable<String>(debtId);
    map['amount_cents'] = Variable<int>(amountCents);
    map['principal_portion_cents'] = Variable<int>(principalPortionCents);
    map['interest_portion_cents'] = Variable<int>(interestPortionCents);
    map['fee_portion_cents'] = Variable<int>(feePortionCents);
    {
      map['date'] = Variable<String>(
        $PaymentsTableTable.$converterdate.toSql(date),
      );
    }
    {
      map['type'] = Variable<String>(
        $PaymentsTableTable.$convertertype.toSql(type),
      );
    }
    {
      map['source'] = Variable<String>(
        $PaymentsTableTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['status'] = Variable<String>(
        $PaymentsTableTable.$converterstatus.toSql(status),
      );
    }
    map['applied_balance_before_cents'] = Variable<int>(
      appliedBalanceBeforeCents,
    );
    map['applied_balance_after_cents'] = Variable<int>(
      appliedBalanceAfterCents,
    );
    {
      map['created_at'] = Variable<String>(
        $PaymentsTableTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $PaymentsTableTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $PaymentsTableTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    return map;
  }

  PaymentsTableCompanion toCompanion(bool nullToAbsent) {
    return PaymentsTableCompanion(
      id: Value(id),
      scenarioId: Value(scenarioId),
      debtId: Value(debtId),
      amountCents: Value(amountCents),
      principalPortionCents: Value(principalPortionCents),
      interestPortionCents: Value(interestPortionCents),
      feePortionCents: Value(feePortionCents),
      date: Value(date),
      type: Value(type),
      source: Value(source),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      status: Value(status),
      appliedBalanceBeforeCents: Value(appliedBalanceBeforeCents),
      appliedBalanceAfterCents: Value(appliedBalanceAfterCents),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      id: serializer.fromJson<String>(json['id']),
      scenarioId: serializer.fromJson<String>(json['scenarioId']),
      debtId: serializer.fromJson<String>(json['debtId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      principalPortionCents: serializer.fromJson<int>(
        json['principalPortionCents'],
      ),
      interestPortionCents: serializer.fromJson<int>(
        json['interestPortionCents'],
      ),
      feePortionCents: serializer.fromJson<int>(json['feePortionCents']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<PaymentType>(json['type']),
      source: serializer.fromJson<PaymentSource>(json['source']),
      note: serializer.fromJson<String?>(json['note']),
      status: serializer.fromJson<PaymentStatus>(json['status']),
      appliedBalanceBeforeCents: serializer.fromJson<int>(
        json['appliedBalanceBeforeCents'],
      ),
      appliedBalanceAfterCents: serializer.fromJson<int>(
        json['appliedBalanceAfterCents'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scenarioId': serializer.toJson<String>(scenarioId),
      'debtId': serializer.toJson<String>(debtId),
      'amountCents': serializer.toJson<int>(amountCents),
      'principalPortionCents': serializer.toJson<int>(principalPortionCents),
      'interestPortionCents': serializer.toJson<int>(interestPortionCents),
      'feePortionCents': serializer.toJson<int>(feePortionCents),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<PaymentType>(type),
      'source': serializer.toJson<PaymentSource>(source),
      'note': serializer.toJson<String?>(note),
      'status': serializer.toJson<PaymentStatus>(status),
      'appliedBalanceBeforeCents': serializer.toJson<int>(
        appliedBalanceBeforeCents,
      ),
      'appliedBalanceAfterCents': serializer.toJson<int>(
        appliedBalanceAfterCents,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  PaymentRow copyWith({
    String? id,
    String? scenarioId,
    String? debtId,
    int? amountCents,
    int? principalPortionCents,
    int? interestPortionCents,
    int? feePortionCents,
    DateTime? date,
    PaymentType? type,
    PaymentSource? source,
    Value<String?> note = const Value.absent(),
    PaymentStatus? status,
    int? appliedBalanceBeforeCents,
    int? appliedBalanceAfterCents,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => PaymentRow(
    id: id ?? this.id,
    scenarioId: scenarioId ?? this.scenarioId,
    debtId: debtId ?? this.debtId,
    amountCents: amountCents ?? this.amountCents,
    principalPortionCents: principalPortionCents ?? this.principalPortionCents,
    interestPortionCents: interestPortionCents ?? this.interestPortionCents,
    feePortionCents: feePortionCents ?? this.feePortionCents,
    date: date ?? this.date,
    type: type ?? this.type,
    source: source ?? this.source,
    note: note.present ? note.value : this.note,
    status: status ?? this.status,
    appliedBalanceBeforeCents:
        appliedBalanceBeforeCents ?? this.appliedBalanceBeforeCents,
    appliedBalanceAfterCents:
        appliedBalanceAfterCents ?? this.appliedBalanceAfterCents,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  PaymentRow copyWithCompanion(PaymentsTableCompanion data) {
    return PaymentRow(
      id: data.id.present ? data.id.value : this.id,
      scenarioId: data.scenarioId.present
          ? data.scenarioId.value
          : this.scenarioId,
      debtId: data.debtId.present ? data.debtId.value : this.debtId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      principalPortionCents: data.principalPortionCents.present
          ? data.principalPortionCents.value
          : this.principalPortionCents,
      interestPortionCents: data.interestPortionCents.present
          ? data.interestPortionCents.value
          : this.interestPortionCents,
      feePortionCents: data.feePortionCents.present
          ? data.feePortionCents.value
          : this.feePortionCents,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      source: data.source.present ? data.source.value : this.source,
      note: data.note.present ? data.note.value : this.note,
      status: data.status.present ? data.status.value : this.status,
      appliedBalanceBeforeCents: data.appliedBalanceBeforeCents.present
          ? data.appliedBalanceBeforeCents.value
          : this.appliedBalanceBeforeCents,
      appliedBalanceAfterCents: data.appliedBalanceAfterCents.present
          ? data.appliedBalanceAfterCents.value
          : this.appliedBalanceAfterCents,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('id: $id, ')
          ..write('scenarioId: $scenarioId, ')
          ..write('debtId: $debtId, ')
          ..write('amountCents: $amountCents, ')
          ..write('principalPortionCents: $principalPortionCents, ')
          ..write('interestPortionCents: $interestPortionCents, ')
          ..write('feePortionCents: $feePortionCents, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('source: $source, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('appliedBalanceBeforeCents: $appliedBalanceBeforeCents, ')
          ..write('appliedBalanceAfterCents: $appliedBalanceAfterCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scenarioId,
    debtId,
    amountCents,
    principalPortionCents,
    interestPortionCents,
    feePortionCents,
    date,
    type,
    source,
    note,
    status,
    appliedBalanceBeforeCents,
    appliedBalanceAfterCents,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.id == this.id &&
          other.scenarioId == this.scenarioId &&
          other.debtId == this.debtId &&
          other.amountCents == this.amountCents &&
          other.principalPortionCents == this.principalPortionCents &&
          other.interestPortionCents == this.interestPortionCents &&
          other.feePortionCents == this.feePortionCents &&
          other.date == this.date &&
          other.type == this.type &&
          other.source == this.source &&
          other.note == this.note &&
          other.status == this.status &&
          other.appliedBalanceBeforeCents == this.appliedBalanceBeforeCents &&
          other.appliedBalanceAfterCents == this.appliedBalanceAfterCents &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PaymentsTableCompanion extends UpdateCompanion<PaymentRow> {
  final Value<String> id;
  final Value<String> scenarioId;
  final Value<String> debtId;
  final Value<int> amountCents;
  final Value<int> principalPortionCents;
  final Value<int> interestPortionCents;
  final Value<int> feePortionCents;
  final Value<DateTime> date;
  final Value<PaymentType> type;
  final Value<PaymentSource> source;
  final Value<String?> note;
  final Value<PaymentStatus> status;
  final Value<int> appliedBalanceBeforeCents;
  final Value<int> appliedBalanceAfterCents;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PaymentsTableCompanion({
    this.id = const Value.absent(),
    this.scenarioId = const Value.absent(),
    this.debtId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.principalPortionCents = const Value.absent(),
    this.interestPortionCents = const Value.absent(),
    this.feePortionCents = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.source = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.appliedBalanceBeforeCents = const Value.absent(),
    this.appliedBalanceAfterCents = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsTableCompanion.insert({
    required String id,
    this.scenarioId = const Value.absent(),
    required String debtId,
    required int amountCents,
    required int principalPortionCents,
    required int interestPortionCents,
    this.feePortionCents = const Value.absent(),
    required DateTime date,
    required PaymentType type,
    required PaymentSource source,
    this.note = const Value.absent(),
    required PaymentStatus status,
    required int appliedBalanceBeforeCents,
    required int appliedBalanceAfterCents,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       debtId = Value(debtId),
       amountCents = Value(amountCents),
       principalPortionCents = Value(principalPortionCents),
       interestPortionCents = Value(interestPortionCents),
       date = Value(date),
       type = Value(type),
       source = Value(source),
       status = Value(status),
       appliedBalanceBeforeCents = Value(appliedBalanceBeforeCents),
       appliedBalanceAfterCents = Value(appliedBalanceAfterCents),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PaymentRow> custom({
    Expression<String>? id,
    Expression<String>? scenarioId,
    Expression<String>? debtId,
    Expression<int>? amountCents,
    Expression<int>? principalPortionCents,
    Expression<int>? interestPortionCents,
    Expression<int>? feePortionCents,
    Expression<String>? date,
    Expression<String>? type,
    Expression<String>? source,
    Expression<String>? note,
    Expression<String>? status,
    Expression<int>? appliedBalanceBeforeCents,
    Expression<int>? appliedBalanceAfterCents,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scenarioId != null) 'scenario_id': scenarioId,
      if (debtId != null) 'debt_id': debtId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (principalPortionCents != null)
        'principal_portion_cents': principalPortionCents,
      if (interestPortionCents != null)
        'interest_portion_cents': interestPortionCents,
      if (feePortionCents != null) 'fee_portion_cents': feePortionCents,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (source != null) 'source': source,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (appliedBalanceBeforeCents != null)
        'applied_balance_before_cents': appliedBalanceBeforeCents,
      if (appliedBalanceAfterCents != null)
        'applied_balance_after_cents': appliedBalanceAfterCents,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? scenarioId,
    Value<String>? debtId,
    Value<int>? amountCents,
    Value<int>? principalPortionCents,
    Value<int>? interestPortionCents,
    Value<int>? feePortionCents,
    Value<DateTime>? date,
    Value<PaymentType>? type,
    Value<PaymentSource>? source,
    Value<String?>? note,
    Value<PaymentStatus>? status,
    Value<int>? appliedBalanceBeforeCents,
    Value<int>? appliedBalanceAfterCents,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PaymentsTableCompanion(
      id: id ?? this.id,
      scenarioId: scenarioId ?? this.scenarioId,
      debtId: debtId ?? this.debtId,
      amountCents: amountCents ?? this.amountCents,
      principalPortionCents:
          principalPortionCents ?? this.principalPortionCents,
      interestPortionCents: interestPortionCents ?? this.interestPortionCents,
      feePortionCents: feePortionCents ?? this.feePortionCents,
      date: date ?? this.date,
      type: type ?? this.type,
      source: source ?? this.source,
      note: note ?? this.note,
      status: status ?? this.status,
      appliedBalanceBeforeCents:
          appliedBalanceBeforeCents ?? this.appliedBalanceBeforeCents,
      appliedBalanceAfterCents:
          appliedBalanceAfterCents ?? this.appliedBalanceAfterCents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scenarioId.present) {
      map['scenario_id'] = Variable<String>(scenarioId.value);
    }
    if (debtId.present) {
      map['debt_id'] = Variable<String>(debtId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (principalPortionCents.present) {
      map['principal_portion_cents'] = Variable<int>(
        principalPortionCents.value,
      );
    }
    if (interestPortionCents.present) {
      map['interest_portion_cents'] = Variable<int>(interestPortionCents.value);
    }
    if (feePortionCents.present) {
      map['fee_portion_cents'] = Variable<int>(feePortionCents.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $PaymentsTableTable.$converterdate.toSql(date.value),
      );
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $PaymentsTableTable.$convertertype.toSql(type.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $PaymentsTableTable.$convertersource.toSql(source.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PaymentsTableTable.$converterstatus.toSql(status.value),
      );
    }
    if (appliedBalanceBeforeCents.present) {
      map['applied_balance_before_cents'] = Variable<int>(
        appliedBalanceBeforeCents.value,
      );
    }
    if (appliedBalanceAfterCents.present) {
      map['applied_balance_after_cents'] = Variable<int>(
        appliedBalanceAfterCents.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $PaymentsTableTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $PaymentsTableTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $PaymentsTableTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableCompanion(')
          ..write('id: $id, ')
          ..write('scenarioId: $scenarioId, ')
          ..write('debtId: $debtId, ')
          ..write('amountCents: $amountCents, ')
          ..write('principalPortionCents: $principalPortionCents, ')
          ..write('interestPortionCents: $interestPortionCents, ')
          ..write('feePortionCents: $feePortionCents, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('source: $source, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('appliedBalanceBeforeCents: $appliedBalanceBeforeCents, ')
          ..write('appliedBalanceAfterCents: $appliedBalanceAfterCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlansTableTable extends PlansTable
    with TableInfo<$PlansTableTable, PlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scenarioIdMeta = const VerificationMeta(
    'scenarioId',
  );
  @override
  late final GeneratedColumn<String> scenarioId = GeneratedColumn<String>(
    'scenario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('main'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Strategy, String> strategy =
      GeneratedColumn<String>(
        'strategy',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Strategy>($PlansTableTable.$converterstrategy);
  static const VerificationMeta _extraMonthlyAmountCentsMeta =
      const VerificationMeta('extraMonthlyAmountCents');
  @override
  late final GeneratedColumn<int> extraMonthlyAmountCents =
      GeneratedColumn<int>(
        'extra_monthly_amount_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentCadence, String>
  extraPaymentCadence =
      GeneratedColumn<String>(
        'extra_payment_cadence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PaymentCadence>(
        $PlansTableTable.$converterextraPaymentCadence,
      );
  static const VerificationMeta _customOrderJsonMeta = const VerificationMeta(
    'customOrderJson',
  );
  @override
  late final GeneratedColumn<String> customOrderJson = GeneratedColumn<String>(
    'custom_order_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> lastRecastAt =
      GeneratedColumn<String>(
        'last_recast_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PlansTableTable.$converterlastRecastAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String>
  projectedDebtFreeDate = GeneratedColumn<String>(
    'projected_debt_free_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<DateTime?>($PlansTableTable.$converterprojectedDebtFreeDaten);
  static const VerificationMeta _totalInterestProjectedCentsMeta =
      const VerificationMeta('totalInterestProjectedCents');
  @override
  late final GeneratedColumn<int> totalInterestProjectedCents =
      GeneratedColumn<int>(
        'total_interest_projected_cents',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _totalInterestSavedCentsMeta =
      const VerificationMeta('totalInterestSavedCents');
  @override
  late final GeneratedColumn<int> totalInterestSavedCents =
      GeneratedColumn<int>(
        'total_interest_saved_cents',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PlansTableTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PlansTableTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($PlansTableTable.$converterdeletedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scenarioId,
    strategy,
    extraMonthlyAmountCents,
    extraPaymentCadence,
    customOrderJson,
    lastRecastAt,
    projectedDebtFreeDate,
    totalInterestProjectedCents,
    totalInterestSavedCents,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scenario_id')) {
      context.handle(
        _scenarioIdMeta,
        scenarioId.isAcceptableOrUnknown(data['scenario_id']!, _scenarioIdMeta),
      );
    }
    if (data.containsKey('extra_monthly_amount_cents')) {
      context.handle(
        _extraMonthlyAmountCentsMeta,
        extraMonthlyAmountCents.isAcceptableOrUnknown(
          data['extra_monthly_amount_cents']!,
          _extraMonthlyAmountCentsMeta,
        ),
      );
    }
    if (data.containsKey('custom_order_json')) {
      context.handle(
        _customOrderJsonMeta,
        customOrderJson.isAcceptableOrUnknown(
          data['custom_order_json']!,
          _customOrderJsonMeta,
        ),
      );
    }
    if (data.containsKey('total_interest_projected_cents')) {
      context.handle(
        _totalInterestProjectedCentsMeta,
        totalInterestProjectedCents.isAcceptableOrUnknown(
          data['total_interest_projected_cents']!,
          _totalInterestProjectedCentsMeta,
        ),
      );
    }
    if (data.containsKey('total_interest_saved_cents')) {
      context.handle(
        _totalInterestSavedCentsMeta,
        totalInterestSavedCents.isAcceptableOrUnknown(
          data['total_interest_saved_cents']!,
          _totalInterestSavedCentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scenarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scenario_id'],
      )!,
      strategy: $PlansTableTable.$converterstrategy.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}strategy'],
        )!,
      ),
      extraMonthlyAmountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}extra_monthly_amount_cents'],
      )!,
      extraPaymentCadence: $PlansTableTable.$converterextraPaymentCadence
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}extra_payment_cadence'],
            )!,
          ),
      customOrderJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_order_json'],
      ),
      lastRecastAt: $PlansTableTable.$converterlastRecastAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_recast_at'],
        )!,
      ),
      projectedDebtFreeDate: $PlansTableTable.$converterprojectedDebtFreeDaten
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}projected_debt_free_date'],
            ),
          ),
      totalInterestProjectedCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_interest_projected_cents'],
      ),
      totalInterestSavedCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_interest_saved_cents'],
      ),
      createdAt: $PlansTableTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $PlansTableTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $PlansTableTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
    );
  }

  @override
  $PlansTableTable createAlias(String alias) {
    return $PlansTableTable(attachedDatabase, alias);
  }

  static TypeConverter<Strategy, String> $converterstrategy =
      const StrategyConverter();
  static TypeConverter<PaymentCadence, String> $converterextraPaymentCadence =
      const CadenceConverter();
  static TypeConverter<DateTime, String> $converterlastRecastAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterprojectedDebtFreeDate =
      const LocalDateConverter();
  static TypeConverter<DateTime?, String?> $converterprojectedDebtFreeDaten =
      NullAwareTypeConverter.wrap($converterprojectedDebtFreeDate);
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class PlanRow extends DataClass implements Insertable<PlanRow> {
  final String id;
  final String scenarioId;
  final Strategy strategy;
  final int extraMonthlyAmountCents;
  final PaymentCadence extraPaymentCadence;
  final String? customOrderJson;
  final DateTime lastRecastAt;
  final DateTime? projectedDebtFreeDate;
  final int? totalInterestProjectedCents;
  final int? totalInterestSavedCents;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const PlanRow({
    required this.id,
    required this.scenarioId,
    required this.strategy,
    required this.extraMonthlyAmountCents,
    required this.extraPaymentCadence,
    this.customOrderJson,
    required this.lastRecastAt,
    this.projectedDebtFreeDate,
    this.totalInterestProjectedCents,
    this.totalInterestSavedCents,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scenario_id'] = Variable<String>(scenarioId);
    {
      map['strategy'] = Variable<String>(
        $PlansTableTable.$converterstrategy.toSql(strategy),
      );
    }
    map['extra_monthly_amount_cents'] = Variable<int>(extraMonthlyAmountCents);
    {
      map['extra_payment_cadence'] = Variable<String>(
        $PlansTableTable.$converterextraPaymentCadence.toSql(
          extraPaymentCadence,
        ),
      );
    }
    if (!nullToAbsent || customOrderJson != null) {
      map['custom_order_json'] = Variable<String>(customOrderJson);
    }
    {
      map['last_recast_at'] = Variable<String>(
        $PlansTableTable.$converterlastRecastAt.toSql(lastRecastAt),
      );
    }
    if (!nullToAbsent || projectedDebtFreeDate != null) {
      map['projected_debt_free_date'] = Variable<String>(
        $PlansTableTable.$converterprojectedDebtFreeDaten.toSql(
          projectedDebtFreeDate,
        ),
      );
    }
    if (!nullToAbsent || totalInterestProjectedCents != null) {
      map['total_interest_projected_cents'] = Variable<int>(
        totalInterestProjectedCents,
      );
    }
    if (!nullToAbsent || totalInterestSavedCents != null) {
      map['total_interest_saved_cents'] = Variable<int>(
        totalInterestSavedCents,
      );
    }
    {
      map['created_at'] = Variable<String>(
        $PlansTableTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $PlansTableTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $PlansTableTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    return map;
  }

  PlansTableCompanion toCompanion(bool nullToAbsent) {
    return PlansTableCompanion(
      id: Value(id),
      scenarioId: Value(scenarioId),
      strategy: Value(strategy),
      extraMonthlyAmountCents: Value(extraMonthlyAmountCents),
      extraPaymentCadence: Value(extraPaymentCadence),
      customOrderJson: customOrderJson == null && nullToAbsent
          ? const Value.absent()
          : Value(customOrderJson),
      lastRecastAt: Value(lastRecastAt),
      projectedDebtFreeDate: projectedDebtFreeDate == null && nullToAbsent
          ? const Value.absent()
          : Value(projectedDebtFreeDate),
      totalInterestProjectedCents:
          totalInterestProjectedCents == null && nullToAbsent
          ? const Value.absent()
          : Value(totalInterestProjectedCents),
      totalInterestSavedCents: totalInterestSavedCents == null && nullToAbsent
          ? const Value.absent()
          : Value(totalInterestSavedCents),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRow(
      id: serializer.fromJson<String>(json['id']),
      scenarioId: serializer.fromJson<String>(json['scenarioId']),
      strategy: serializer.fromJson<Strategy>(json['strategy']),
      extraMonthlyAmountCents: serializer.fromJson<int>(
        json['extraMonthlyAmountCents'],
      ),
      extraPaymentCadence: serializer.fromJson<PaymentCadence>(
        json['extraPaymentCadence'],
      ),
      customOrderJson: serializer.fromJson<String?>(json['customOrderJson']),
      lastRecastAt: serializer.fromJson<DateTime>(json['lastRecastAt']),
      projectedDebtFreeDate: serializer.fromJson<DateTime?>(
        json['projectedDebtFreeDate'],
      ),
      totalInterestProjectedCents: serializer.fromJson<int?>(
        json['totalInterestProjectedCents'],
      ),
      totalInterestSavedCents: serializer.fromJson<int?>(
        json['totalInterestSavedCents'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scenarioId': serializer.toJson<String>(scenarioId),
      'strategy': serializer.toJson<Strategy>(strategy),
      'extraMonthlyAmountCents': serializer.toJson<int>(
        extraMonthlyAmountCents,
      ),
      'extraPaymentCadence': serializer.toJson<PaymentCadence>(
        extraPaymentCadence,
      ),
      'customOrderJson': serializer.toJson<String?>(customOrderJson),
      'lastRecastAt': serializer.toJson<DateTime>(lastRecastAt),
      'projectedDebtFreeDate': serializer.toJson<DateTime?>(
        projectedDebtFreeDate,
      ),
      'totalInterestProjectedCents': serializer.toJson<int?>(
        totalInterestProjectedCents,
      ),
      'totalInterestSavedCents': serializer.toJson<int?>(
        totalInterestSavedCents,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  PlanRow copyWith({
    String? id,
    String? scenarioId,
    Strategy? strategy,
    int? extraMonthlyAmountCents,
    PaymentCadence? extraPaymentCadence,
    Value<String?> customOrderJson = const Value.absent(),
    DateTime? lastRecastAt,
    Value<DateTime?> projectedDebtFreeDate = const Value.absent(),
    Value<int?> totalInterestProjectedCents = const Value.absent(),
    Value<int?> totalInterestSavedCents = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => PlanRow(
    id: id ?? this.id,
    scenarioId: scenarioId ?? this.scenarioId,
    strategy: strategy ?? this.strategy,
    extraMonthlyAmountCents:
        extraMonthlyAmountCents ?? this.extraMonthlyAmountCents,
    extraPaymentCadence: extraPaymentCadence ?? this.extraPaymentCadence,
    customOrderJson: customOrderJson.present
        ? customOrderJson.value
        : this.customOrderJson,
    lastRecastAt: lastRecastAt ?? this.lastRecastAt,
    projectedDebtFreeDate: projectedDebtFreeDate.present
        ? projectedDebtFreeDate.value
        : this.projectedDebtFreeDate,
    totalInterestProjectedCents: totalInterestProjectedCents.present
        ? totalInterestProjectedCents.value
        : this.totalInterestProjectedCents,
    totalInterestSavedCents: totalInterestSavedCents.present
        ? totalInterestSavedCents.value
        : this.totalInterestSavedCents,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  PlanRow copyWithCompanion(PlansTableCompanion data) {
    return PlanRow(
      id: data.id.present ? data.id.value : this.id,
      scenarioId: data.scenarioId.present
          ? data.scenarioId.value
          : this.scenarioId,
      strategy: data.strategy.present ? data.strategy.value : this.strategy,
      extraMonthlyAmountCents: data.extraMonthlyAmountCents.present
          ? data.extraMonthlyAmountCents.value
          : this.extraMonthlyAmountCents,
      extraPaymentCadence: data.extraPaymentCadence.present
          ? data.extraPaymentCadence.value
          : this.extraPaymentCadence,
      customOrderJson: data.customOrderJson.present
          ? data.customOrderJson.value
          : this.customOrderJson,
      lastRecastAt: data.lastRecastAt.present
          ? data.lastRecastAt.value
          : this.lastRecastAt,
      projectedDebtFreeDate: data.projectedDebtFreeDate.present
          ? data.projectedDebtFreeDate.value
          : this.projectedDebtFreeDate,
      totalInterestProjectedCents: data.totalInterestProjectedCents.present
          ? data.totalInterestProjectedCents.value
          : this.totalInterestProjectedCents,
      totalInterestSavedCents: data.totalInterestSavedCents.present
          ? data.totalInterestSavedCents.value
          : this.totalInterestSavedCents,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRow(')
          ..write('id: $id, ')
          ..write('scenarioId: $scenarioId, ')
          ..write('strategy: $strategy, ')
          ..write('extraMonthlyAmountCents: $extraMonthlyAmountCents, ')
          ..write('extraPaymentCadence: $extraPaymentCadence, ')
          ..write('customOrderJson: $customOrderJson, ')
          ..write('lastRecastAt: $lastRecastAt, ')
          ..write('projectedDebtFreeDate: $projectedDebtFreeDate, ')
          ..write('totalInterestProjectedCents: $totalInterestProjectedCents, ')
          ..write('totalInterestSavedCents: $totalInterestSavedCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scenarioId,
    strategy,
    extraMonthlyAmountCents,
    extraPaymentCadence,
    customOrderJson,
    lastRecastAt,
    projectedDebtFreeDate,
    totalInterestProjectedCents,
    totalInterestSavedCents,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRow &&
          other.id == this.id &&
          other.scenarioId == this.scenarioId &&
          other.strategy == this.strategy &&
          other.extraMonthlyAmountCents == this.extraMonthlyAmountCents &&
          other.extraPaymentCadence == this.extraPaymentCadence &&
          other.customOrderJson == this.customOrderJson &&
          other.lastRecastAt == this.lastRecastAt &&
          other.projectedDebtFreeDate == this.projectedDebtFreeDate &&
          other.totalInterestProjectedCents ==
              this.totalInterestProjectedCents &&
          other.totalInterestSavedCents == this.totalInterestSavedCents &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PlansTableCompanion extends UpdateCompanion<PlanRow> {
  final Value<String> id;
  final Value<String> scenarioId;
  final Value<Strategy> strategy;
  final Value<int> extraMonthlyAmountCents;
  final Value<PaymentCadence> extraPaymentCadence;
  final Value<String?> customOrderJson;
  final Value<DateTime> lastRecastAt;
  final Value<DateTime?> projectedDebtFreeDate;
  final Value<int?> totalInterestProjectedCents;
  final Value<int?> totalInterestSavedCents;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PlansTableCompanion({
    this.id = const Value.absent(),
    this.scenarioId = const Value.absent(),
    this.strategy = const Value.absent(),
    this.extraMonthlyAmountCents = const Value.absent(),
    this.extraPaymentCadence = const Value.absent(),
    this.customOrderJson = const Value.absent(),
    this.lastRecastAt = const Value.absent(),
    this.projectedDebtFreeDate = const Value.absent(),
    this.totalInterestProjectedCents = const Value.absent(),
    this.totalInterestSavedCents = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlansTableCompanion.insert({
    required String id,
    this.scenarioId = const Value.absent(),
    required Strategy strategy,
    this.extraMonthlyAmountCents = const Value.absent(),
    required PaymentCadence extraPaymentCadence,
    this.customOrderJson = const Value.absent(),
    required DateTime lastRecastAt,
    this.projectedDebtFreeDate = const Value.absent(),
    this.totalInterestProjectedCents = const Value.absent(),
    this.totalInterestSavedCents = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       strategy = Value(strategy),
       extraPaymentCadence = Value(extraPaymentCadence),
       lastRecastAt = Value(lastRecastAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PlanRow> custom({
    Expression<String>? id,
    Expression<String>? scenarioId,
    Expression<String>? strategy,
    Expression<int>? extraMonthlyAmountCents,
    Expression<String>? extraPaymentCadence,
    Expression<String>? customOrderJson,
    Expression<String>? lastRecastAt,
    Expression<String>? projectedDebtFreeDate,
    Expression<int>? totalInterestProjectedCents,
    Expression<int>? totalInterestSavedCents,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scenarioId != null) 'scenario_id': scenarioId,
      if (strategy != null) 'strategy': strategy,
      if (extraMonthlyAmountCents != null)
        'extra_monthly_amount_cents': extraMonthlyAmountCents,
      if (extraPaymentCadence != null)
        'extra_payment_cadence': extraPaymentCadence,
      if (customOrderJson != null) 'custom_order_json': customOrderJson,
      if (lastRecastAt != null) 'last_recast_at': lastRecastAt,
      if (projectedDebtFreeDate != null)
        'projected_debt_free_date': projectedDebtFreeDate,
      if (totalInterestProjectedCents != null)
        'total_interest_projected_cents': totalInterestProjectedCents,
      if (totalInterestSavedCents != null)
        'total_interest_saved_cents': totalInterestSavedCents,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlansTableCompanion copyWith({
    Value<String>? id,
    Value<String>? scenarioId,
    Value<Strategy>? strategy,
    Value<int>? extraMonthlyAmountCents,
    Value<PaymentCadence>? extraPaymentCadence,
    Value<String?>? customOrderJson,
    Value<DateTime>? lastRecastAt,
    Value<DateTime?>? projectedDebtFreeDate,
    Value<int?>? totalInterestProjectedCents,
    Value<int?>? totalInterestSavedCents,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PlansTableCompanion(
      id: id ?? this.id,
      scenarioId: scenarioId ?? this.scenarioId,
      strategy: strategy ?? this.strategy,
      extraMonthlyAmountCents:
          extraMonthlyAmountCents ?? this.extraMonthlyAmountCents,
      extraPaymentCadence: extraPaymentCadence ?? this.extraPaymentCadence,
      customOrderJson: customOrderJson ?? this.customOrderJson,
      lastRecastAt: lastRecastAt ?? this.lastRecastAt,
      projectedDebtFreeDate:
          projectedDebtFreeDate ?? this.projectedDebtFreeDate,
      totalInterestProjectedCents:
          totalInterestProjectedCents ?? this.totalInterestProjectedCents,
      totalInterestSavedCents:
          totalInterestSavedCents ?? this.totalInterestSavedCents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scenarioId.present) {
      map['scenario_id'] = Variable<String>(scenarioId.value);
    }
    if (strategy.present) {
      map['strategy'] = Variable<String>(
        $PlansTableTable.$converterstrategy.toSql(strategy.value),
      );
    }
    if (extraMonthlyAmountCents.present) {
      map['extra_monthly_amount_cents'] = Variable<int>(
        extraMonthlyAmountCents.value,
      );
    }
    if (extraPaymentCadence.present) {
      map['extra_payment_cadence'] = Variable<String>(
        $PlansTableTable.$converterextraPaymentCadence.toSql(
          extraPaymentCadence.value,
        ),
      );
    }
    if (customOrderJson.present) {
      map['custom_order_json'] = Variable<String>(customOrderJson.value);
    }
    if (lastRecastAt.present) {
      map['last_recast_at'] = Variable<String>(
        $PlansTableTable.$converterlastRecastAt.toSql(lastRecastAt.value),
      );
    }
    if (projectedDebtFreeDate.present) {
      map['projected_debt_free_date'] = Variable<String>(
        $PlansTableTable.$converterprojectedDebtFreeDaten.toSql(
          projectedDebtFreeDate.value,
        ),
      );
    }
    if (totalInterestProjectedCents.present) {
      map['total_interest_projected_cents'] = Variable<int>(
        totalInterestProjectedCents.value,
      );
    }
    if (totalInterestSavedCents.present) {
      map['total_interest_saved_cents'] = Variable<int>(
        totalInterestSavedCents.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $PlansTableTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $PlansTableTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $PlansTableTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansTableCompanion(')
          ..write('id: $id, ')
          ..write('scenarioId: $scenarioId, ')
          ..write('strategy: $strategy, ')
          ..write('extraMonthlyAmountCents: $extraMonthlyAmountCents, ')
          ..write('extraPaymentCadence: $extraPaymentCadence, ')
          ..write('customOrderJson: $customOrderJson, ')
          ..write('lastRecastAt: $lastRecastAt, ')
          ..write('projectedDebtFreeDate: $projectedDebtFreeDate, ')
          ..write('totalInterestProjectedCents: $totalInterestProjectedCents, ')
          ..write('totalInterestSavedCents: $totalInterestSavedCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTableTable extends UserSettingsTable
    with TableInfo<$UserSettingsTableTable, UserSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('singleton'),
  );
  static const VerificationMeta _trustLevelMeta = const VerificationMeta(
    'trustLevel',
  );
  @override
  late final GeneratedColumn<int> trustLevel = GeneratedColumn<int>(
    'trust_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _firebaseUidMeta = const VerificationMeta(
    'firebaseUid',
  );
  @override
  late final GeneratedColumn<String> firebaseUid = GeneratedColumn<String>(
    'firebase_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _localeCodeMeta = const VerificationMeta(
    'localeCode',
  );
  @override
  late final GeneratedColumn<String> localeCode = GeneratedColumn<String>(
    'locale_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en-US'),
  );
  static const VerificationMeta _dayCountConventionMeta =
      const VerificationMeta('dayCountConvention');
  @override
  late final GeneratedColumn<String> dayCountConvention =
      GeneratedColumn<String>(
        'day_count_convention',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('actual365'),
      );
  static const VerificationMeta _notifPaymentReminderMeta =
      const VerificationMeta('notifPaymentReminder');
  @override
  late final GeneratedColumn<bool> notifPaymentReminder = GeneratedColumn<bool>(
    'notif_payment_reminder',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notif_payment_reminder" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notifPaymentReminderDaysBeforeMeta =
      const VerificationMeta('notifPaymentReminderDaysBefore');
  @override
  late final GeneratedColumn<int> notifPaymentReminderDaysBefore =
      GeneratedColumn<int>(
        'notif_payment_reminder_days_before',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(3),
      );
  static const VerificationMeta _notifMilestoneMeta = const VerificationMeta(
    'notifMilestone',
  );
  @override
  late final GeneratedColumn<bool> notifMilestone = GeneratedColumn<bool>(
    'notif_milestone',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notif_milestone" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notifMonthlyLogMeta = const VerificationMeta(
    'notifMonthlyLog',
  );
  @override
  late final GeneratedColumn<bool> notifMonthlyLog = GeneratedColumn<bool>(
    'notif_monthly_log',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notif_monthly_log" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _onboardingStepMeta = const VerificationMeta(
    'onboardingStep',
  );
  @override
  late final GeneratedColumn<int> onboardingStep = GeneratedColumn<int>(
    'onboarding_step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String>
  onboardingCompletedAt =
      GeneratedColumn<String>(
        'onboarding_completed_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $UserSettingsTableTable.$converteronboardingCompletedAtn,
      );
  static const VerificationMeta _isPremiumMeta = const VerificationMeta(
    'isPremium',
  );
  @override
  late final GeneratedColumn<bool> isPremium = GeneratedColumn<bool>(
    'is_premium',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_premium" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String>
  premiumExpiresAt =
      GeneratedColumn<String>(
        'premium_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $UserSettingsTableTable.$converterpremiumExpiresAtn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($UserSettingsTableTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($UserSettingsTableTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trustLevel,
    firebaseUid,
    currencyCode,
    localeCode,
    dayCountConvention,
    notifPaymentReminder,
    notifPaymentReminderDaysBefore,
    notifMilestone,
    notifMonthlyLog,
    onboardingStep,
    onboardingCompleted,
    onboardingCompletedAt,
    isPremium,
    premiumExpiresAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trust_level')) {
      context.handle(
        _trustLevelMeta,
        trustLevel.isAcceptableOrUnknown(data['trust_level']!, _trustLevelMeta),
      );
    }
    if (data.containsKey('firebase_uid')) {
      context.handle(
        _firebaseUidMeta,
        firebaseUid.isAcceptableOrUnknown(
          data['firebase_uid']!,
          _firebaseUidMeta,
        ),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('locale_code')) {
      context.handle(
        _localeCodeMeta,
        localeCode.isAcceptableOrUnknown(data['locale_code']!, _localeCodeMeta),
      );
    }
    if (data.containsKey('day_count_convention')) {
      context.handle(
        _dayCountConventionMeta,
        dayCountConvention.isAcceptableOrUnknown(
          data['day_count_convention']!,
          _dayCountConventionMeta,
        ),
      );
    }
    if (data.containsKey('notif_payment_reminder')) {
      context.handle(
        _notifPaymentReminderMeta,
        notifPaymentReminder.isAcceptableOrUnknown(
          data['notif_payment_reminder']!,
          _notifPaymentReminderMeta,
        ),
      );
    }
    if (data.containsKey('notif_payment_reminder_days_before')) {
      context.handle(
        _notifPaymentReminderDaysBeforeMeta,
        notifPaymentReminderDaysBefore.isAcceptableOrUnknown(
          data['notif_payment_reminder_days_before']!,
          _notifPaymentReminderDaysBeforeMeta,
        ),
      );
    }
    if (data.containsKey('notif_milestone')) {
      context.handle(
        _notifMilestoneMeta,
        notifMilestone.isAcceptableOrUnknown(
          data['notif_milestone']!,
          _notifMilestoneMeta,
        ),
      );
    }
    if (data.containsKey('notif_monthly_log')) {
      context.handle(
        _notifMonthlyLogMeta,
        notifMonthlyLog.isAcceptableOrUnknown(
          data['notif_monthly_log']!,
          _notifMonthlyLogMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_step')) {
      context.handle(
        _onboardingStepMeta,
        onboardingStep.isAcceptableOrUnknown(
          data['onboarding_step']!,
          _onboardingStepMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('is_premium')) {
      context.handle(
        _isPremiumMeta,
        isPremium.isAcceptableOrUnknown(data['is_premium']!, _isPremiumMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trustLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trust_level'],
      )!,
      firebaseUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firebase_uid'],
      ),
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      localeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale_code'],
      )!,
      dayCountConvention: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_count_convention'],
      )!,
      notifPaymentReminder: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notif_payment_reminder'],
      )!,
      notifPaymentReminderDaysBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notif_payment_reminder_days_before'],
      )!,
      notifMilestone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notif_milestone'],
      )!,
      notifMonthlyLog: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notif_monthly_log'],
      )!,
      onboardingStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}onboarding_step'],
      )!,
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      onboardingCompletedAt: $UserSettingsTableTable
          .$converteronboardingCompletedAtn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}onboarding_completed_at'],
            ),
          ),
      isPremium: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_premium'],
      )!,
      premiumExpiresAt: $UserSettingsTableTable.$converterpremiumExpiresAtn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}premium_expires_at'],
            ),
          ),
      createdAt: $UserSettingsTableTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $UserSettingsTableTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $UserSettingsTableTable createAlias(String alias) {
    return $UserSettingsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converteronboardingCompletedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converteronboardingCompletedAtn =
      NullAwareTypeConverter.wrap($converteronboardingCompletedAt);
  static TypeConverter<DateTime, String> $converterpremiumExpiresAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterpremiumExpiresAtn =
      NullAwareTypeConverter.wrap($converterpremiumExpiresAt);
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
}

class UserSettingsRow extends DataClass implements Insertable<UserSettingsRow> {
  final String id;
  final int trustLevel;
  final String? firebaseUid;
  final String currencyCode;
  final String localeCode;
  final String dayCountConvention;
  final bool notifPaymentReminder;
  final int notifPaymentReminderDaysBefore;
  final bool notifMilestone;
  final bool notifMonthlyLog;
  final int onboardingStep;
  final bool onboardingCompleted;
  final DateTime? onboardingCompletedAt;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserSettingsRow({
    required this.id,
    required this.trustLevel,
    this.firebaseUid,
    required this.currencyCode,
    required this.localeCode,
    required this.dayCountConvention,
    required this.notifPaymentReminder,
    required this.notifPaymentReminderDaysBefore,
    required this.notifMilestone,
    required this.notifMonthlyLog,
    required this.onboardingStep,
    required this.onboardingCompleted,
    this.onboardingCompletedAt,
    required this.isPremium,
    this.premiumExpiresAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trust_level'] = Variable<int>(trustLevel);
    if (!nullToAbsent || firebaseUid != null) {
      map['firebase_uid'] = Variable<String>(firebaseUid);
    }
    map['currency_code'] = Variable<String>(currencyCode);
    map['locale_code'] = Variable<String>(localeCode);
    map['day_count_convention'] = Variable<String>(dayCountConvention);
    map['notif_payment_reminder'] = Variable<bool>(notifPaymentReminder);
    map['notif_payment_reminder_days_before'] = Variable<int>(
      notifPaymentReminderDaysBefore,
    );
    map['notif_milestone'] = Variable<bool>(notifMilestone);
    map['notif_monthly_log'] = Variable<bool>(notifMonthlyLog);
    map['onboarding_step'] = Variable<int>(onboardingStep);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    if (!nullToAbsent || onboardingCompletedAt != null) {
      map['onboarding_completed_at'] = Variable<String>(
        $UserSettingsTableTable.$converteronboardingCompletedAtn.toSql(
          onboardingCompletedAt,
        ),
      );
    }
    map['is_premium'] = Variable<bool>(isPremium);
    if (!nullToAbsent || premiumExpiresAt != null) {
      map['premium_expires_at'] = Variable<String>(
        $UserSettingsTableTable.$converterpremiumExpiresAtn.toSql(
          premiumExpiresAt,
        ),
      );
    }
    {
      map['created_at'] = Variable<String>(
        $UserSettingsTableTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $UserSettingsTableTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  UserSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsTableCompanion(
      id: Value(id),
      trustLevel: Value(trustLevel),
      firebaseUid: firebaseUid == null && nullToAbsent
          ? const Value.absent()
          : Value(firebaseUid),
      currencyCode: Value(currencyCode),
      localeCode: Value(localeCode),
      dayCountConvention: Value(dayCountConvention),
      notifPaymentReminder: Value(notifPaymentReminder),
      notifPaymentReminderDaysBefore: Value(notifPaymentReminderDaysBefore),
      notifMilestone: Value(notifMilestone),
      notifMonthlyLog: Value(notifMonthlyLog),
      onboardingStep: Value(onboardingStep),
      onboardingCompleted: Value(onboardingCompleted),
      onboardingCompletedAt: onboardingCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingCompletedAt),
      isPremium: Value(isPremium),
      premiumExpiresAt: premiumExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(premiumExpiresAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsRow(
      id: serializer.fromJson<String>(json['id']),
      trustLevel: serializer.fromJson<int>(json['trustLevel']),
      firebaseUid: serializer.fromJson<String?>(json['firebaseUid']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      localeCode: serializer.fromJson<String>(json['localeCode']),
      dayCountConvention: serializer.fromJson<String>(
        json['dayCountConvention'],
      ),
      notifPaymentReminder: serializer.fromJson<bool>(
        json['notifPaymentReminder'],
      ),
      notifPaymentReminderDaysBefore: serializer.fromJson<int>(
        json['notifPaymentReminderDaysBefore'],
      ),
      notifMilestone: serializer.fromJson<bool>(json['notifMilestone']),
      notifMonthlyLog: serializer.fromJson<bool>(json['notifMonthlyLog']),
      onboardingStep: serializer.fromJson<int>(json['onboardingStep']),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      onboardingCompletedAt: serializer.fromJson<DateTime?>(
        json['onboardingCompletedAt'],
      ),
      isPremium: serializer.fromJson<bool>(json['isPremium']),
      premiumExpiresAt: serializer.fromJson<DateTime?>(
        json['premiumExpiresAt'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trustLevel': serializer.toJson<int>(trustLevel),
      'firebaseUid': serializer.toJson<String?>(firebaseUid),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'localeCode': serializer.toJson<String>(localeCode),
      'dayCountConvention': serializer.toJson<String>(dayCountConvention),
      'notifPaymentReminder': serializer.toJson<bool>(notifPaymentReminder),
      'notifPaymentReminderDaysBefore': serializer.toJson<int>(
        notifPaymentReminderDaysBefore,
      ),
      'notifMilestone': serializer.toJson<bool>(notifMilestone),
      'notifMonthlyLog': serializer.toJson<bool>(notifMonthlyLog),
      'onboardingStep': serializer.toJson<int>(onboardingStep),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'onboardingCompletedAt': serializer.toJson<DateTime?>(
        onboardingCompletedAt,
      ),
      'isPremium': serializer.toJson<bool>(isPremium),
      'premiumExpiresAt': serializer.toJson<DateTime?>(premiumExpiresAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSettingsRow copyWith({
    String? id,
    int? trustLevel,
    Value<String?> firebaseUid = const Value.absent(),
    String? currencyCode,
    String? localeCode,
    String? dayCountConvention,
    bool? notifPaymentReminder,
    int? notifPaymentReminderDaysBefore,
    bool? notifMilestone,
    bool? notifMonthlyLog,
    int? onboardingStep,
    bool? onboardingCompleted,
    Value<DateTime?> onboardingCompletedAt = const Value.absent(),
    bool? isPremium,
    Value<DateTime?> premiumExpiresAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserSettingsRow(
    id: id ?? this.id,
    trustLevel: trustLevel ?? this.trustLevel,
    firebaseUid: firebaseUid.present ? firebaseUid.value : this.firebaseUid,
    currencyCode: currencyCode ?? this.currencyCode,
    localeCode: localeCode ?? this.localeCode,
    dayCountConvention: dayCountConvention ?? this.dayCountConvention,
    notifPaymentReminder: notifPaymentReminder ?? this.notifPaymentReminder,
    notifPaymentReminderDaysBefore:
        notifPaymentReminderDaysBefore ?? this.notifPaymentReminderDaysBefore,
    notifMilestone: notifMilestone ?? this.notifMilestone,
    notifMonthlyLog: notifMonthlyLog ?? this.notifMonthlyLog,
    onboardingStep: onboardingStep ?? this.onboardingStep,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    onboardingCompletedAt: onboardingCompletedAt.present
        ? onboardingCompletedAt.value
        : this.onboardingCompletedAt,
    isPremium: isPremium ?? this.isPremium,
    premiumExpiresAt: premiumExpiresAt.present
        ? premiumExpiresAt.value
        : this.premiumExpiresAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserSettingsRow copyWithCompanion(UserSettingsTableCompanion data) {
    return UserSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      trustLevel: data.trustLevel.present
          ? data.trustLevel.value
          : this.trustLevel,
      firebaseUid: data.firebaseUid.present
          ? data.firebaseUid.value
          : this.firebaseUid,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      localeCode: data.localeCode.present
          ? data.localeCode.value
          : this.localeCode,
      dayCountConvention: data.dayCountConvention.present
          ? data.dayCountConvention.value
          : this.dayCountConvention,
      notifPaymentReminder: data.notifPaymentReminder.present
          ? data.notifPaymentReminder.value
          : this.notifPaymentReminder,
      notifPaymentReminderDaysBefore:
          data.notifPaymentReminderDaysBefore.present
          ? data.notifPaymentReminderDaysBefore.value
          : this.notifPaymentReminderDaysBefore,
      notifMilestone: data.notifMilestone.present
          ? data.notifMilestone.value
          : this.notifMilestone,
      notifMonthlyLog: data.notifMonthlyLog.present
          ? data.notifMonthlyLog.value
          : this.notifMonthlyLog,
      onboardingStep: data.onboardingStep.present
          ? data.onboardingStep.value
          : this.onboardingStep,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      onboardingCompletedAt: data.onboardingCompletedAt.present
          ? data.onboardingCompletedAt.value
          : this.onboardingCompletedAt,
      isPremium: data.isPremium.present ? data.isPremium.value : this.isPremium,
      premiumExpiresAt: data.premiumExpiresAt.present
          ? data.premiumExpiresAt.value
          : this.premiumExpiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsRow(')
          ..write('id: $id, ')
          ..write('trustLevel: $trustLevel, ')
          ..write('firebaseUid: $firebaseUid, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('localeCode: $localeCode, ')
          ..write('dayCountConvention: $dayCountConvention, ')
          ..write('notifPaymentReminder: $notifPaymentReminder, ')
          ..write(
            'notifPaymentReminderDaysBefore: $notifPaymentReminderDaysBefore, ',
          )
          ..write('notifMilestone: $notifMilestone, ')
          ..write('notifMonthlyLog: $notifMonthlyLog, ')
          ..write('onboardingStep: $onboardingStep, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('isPremium: $isPremium, ')
          ..write('premiumExpiresAt: $premiumExpiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trustLevel,
    firebaseUid,
    currencyCode,
    localeCode,
    dayCountConvention,
    notifPaymentReminder,
    notifPaymentReminderDaysBefore,
    notifMilestone,
    notifMonthlyLog,
    onboardingStep,
    onboardingCompleted,
    onboardingCompletedAt,
    isPremium,
    premiumExpiresAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsRow &&
          other.id == this.id &&
          other.trustLevel == this.trustLevel &&
          other.firebaseUid == this.firebaseUid &&
          other.currencyCode == this.currencyCode &&
          other.localeCode == this.localeCode &&
          other.dayCountConvention == this.dayCountConvention &&
          other.notifPaymentReminder == this.notifPaymentReminder &&
          other.notifPaymentReminderDaysBefore ==
              this.notifPaymentReminderDaysBefore &&
          other.notifMilestone == this.notifMilestone &&
          other.notifMonthlyLog == this.notifMonthlyLog &&
          other.onboardingStep == this.onboardingStep &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.onboardingCompletedAt == this.onboardingCompletedAt &&
          other.isPremium == this.isPremium &&
          other.premiumExpiresAt == this.premiumExpiresAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsTableCompanion extends UpdateCompanion<UserSettingsRow> {
  final Value<String> id;
  final Value<int> trustLevel;
  final Value<String?> firebaseUid;
  final Value<String> currencyCode;
  final Value<String> localeCode;
  final Value<String> dayCountConvention;
  final Value<bool> notifPaymentReminder;
  final Value<int> notifPaymentReminderDaysBefore;
  final Value<bool> notifMilestone;
  final Value<bool> notifMonthlyLog;
  final Value<int> onboardingStep;
  final Value<bool> onboardingCompleted;
  final Value<DateTime?> onboardingCompletedAt;
  final Value<bool> isPremium;
  final Value<DateTime?> premiumExpiresAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserSettingsTableCompanion({
    this.id = const Value.absent(),
    this.trustLevel = const Value.absent(),
    this.firebaseUid = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.dayCountConvention = const Value.absent(),
    this.notifPaymentReminder = const Value.absent(),
    this.notifPaymentReminderDaysBefore = const Value.absent(),
    this.notifMilestone = const Value.absent(),
    this.notifMonthlyLog = const Value.absent(),
    this.onboardingStep = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.premiumExpiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.trustLevel = const Value.absent(),
    this.firebaseUid = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.dayCountConvention = const Value.absent(),
    this.notifPaymentReminder = const Value.absent(),
    this.notifPaymentReminderDaysBefore = const Value.absent(),
    this.notifMilestone = const Value.absent(),
    this.notifMonthlyLog = const Value.absent(),
    this.onboardingStep = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.premiumExpiresAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserSettingsRow> custom({
    Expression<String>? id,
    Expression<int>? trustLevel,
    Expression<String>? firebaseUid,
    Expression<String>? currencyCode,
    Expression<String>? localeCode,
    Expression<String>? dayCountConvention,
    Expression<bool>? notifPaymentReminder,
    Expression<int>? notifPaymentReminderDaysBefore,
    Expression<bool>? notifMilestone,
    Expression<bool>? notifMonthlyLog,
    Expression<int>? onboardingStep,
    Expression<bool>? onboardingCompleted,
    Expression<String>? onboardingCompletedAt,
    Expression<bool>? isPremium,
    Expression<String>? premiumExpiresAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trustLevel != null) 'trust_level': trustLevel,
      if (firebaseUid != null) 'firebase_uid': firebaseUid,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (localeCode != null) 'locale_code': localeCode,
      if (dayCountConvention != null)
        'day_count_convention': dayCountConvention,
      if (notifPaymentReminder != null)
        'notif_payment_reminder': notifPaymentReminder,
      if (notifPaymentReminderDaysBefore != null)
        'notif_payment_reminder_days_before': notifPaymentReminderDaysBefore,
      if (notifMilestone != null) 'notif_milestone': notifMilestone,
      if (notifMonthlyLog != null) 'notif_monthly_log': notifMonthlyLog,
      if (onboardingStep != null) 'onboarding_step': onboardingStep,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (onboardingCompletedAt != null)
        'onboarding_completed_at': onboardingCompletedAt,
      if (isPremium != null) 'is_premium': isPremium,
      if (premiumExpiresAt != null) 'premium_expires_at': premiumExpiresAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsTableCompanion copyWith({
    Value<String>? id,
    Value<int>? trustLevel,
    Value<String?>? firebaseUid,
    Value<String>? currencyCode,
    Value<String>? localeCode,
    Value<String>? dayCountConvention,
    Value<bool>? notifPaymentReminder,
    Value<int>? notifPaymentReminderDaysBefore,
    Value<bool>? notifMilestone,
    Value<bool>? notifMonthlyLog,
    Value<int>? onboardingStep,
    Value<bool>? onboardingCompleted,
    Value<DateTime?>? onboardingCompletedAt,
    Value<bool>? isPremium,
    Value<DateTime?>? premiumExpiresAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserSettingsTableCompanion(
      id: id ?? this.id,
      trustLevel: trustLevel ?? this.trustLevel,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      currencyCode: currencyCode ?? this.currencyCode,
      localeCode: localeCode ?? this.localeCode,
      dayCountConvention: dayCountConvention ?? this.dayCountConvention,
      notifPaymentReminder: notifPaymentReminder ?? this.notifPaymentReminder,
      notifPaymentReminderDaysBefore:
          notifPaymentReminderDaysBefore ?? this.notifPaymentReminderDaysBefore,
      notifMilestone: notifMilestone ?? this.notifMilestone,
      notifMonthlyLog: notifMonthlyLog ?? this.notifMonthlyLog,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (trustLevel.present) {
      map['trust_level'] = Variable<int>(trustLevel.value);
    }
    if (firebaseUid.present) {
      map['firebase_uid'] = Variable<String>(firebaseUid.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (localeCode.present) {
      map['locale_code'] = Variable<String>(localeCode.value);
    }
    if (dayCountConvention.present) {
      map['day_count_convention'] = Variable<String>(dayCountConvention.value);
    }
    if (notifPaymentReminder.present) {
      map['notif_payment_reminder'] = Variable<bool>(
        notifPaymentReminder.value,
      );
    }
    if (notifPaymentReminderDaysBefore.present) {
      map['notif_payment_reminder_days_before'] = Variable<int>(
        notifPaymentReminderDaysBefore.value,
      );
    }
    if (notifMilestone.present) {
      map['notif_milestone'] = Variable<bool>(notifMilestone.value);
    }
    if (notifMonthlyLog.present) {
      map['notif_monthly_log'] = Variable<bool>(notifMonthlyLog.value);
    }
    if (onboardingStep.present) {
      map['onboarding_step'] = Variable<int>(onboardingStep.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (onboardingCompletedAt.present) {
      map['onboarding_completed_at'] = Variable<String>(
        $UserSettingsTableTable.$converteronboardingCompletedAtn.toSql(
          onboardingCompletedAt.value,
        ),
      );
    }
    if (isPremium.present) {
      map['is_premium'] = Variable<bool>(isPremium.value);
    }
    if (premiumExpiresAt.present) {
      map['premium_expires_at'] = Variable<String>(
        $UserSettingsTableTable.$converterpremiumExpiresAtn.toSql(
          premiumExpiresAt.value,
        ),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $UserSettingsTableTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $UserSettingsTableTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('trustLevel: $trustLevel, ')
          ..write('firebaseUid: $firebaseUid, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('localeCode: $localeCode, ')
          ..write('dayCountConvention: $dayCountConvention, ')
          ..write('notifPaymentReminder: $notifPaymentReminder, ')
          ..write(
            'notifPaymentReminderDaysBefore: $notifPaymentReminderDaysBefore, ',
          )
          ..write('notifMilestone: $notifMilestone, ')
          ..write('notifMonthlyLog: $notifMonthlyLog, ')
          ..write('onboardingStep: $onboardingStep, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('isPremium: $isPremium, ')
          ..write('premiumExpiresAt: $premiumExpiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MilestonesTableTable extends MilestonesTable
    with TableInfo<$MilestonesTableTable, MilestoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilestonesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scenarioIdMeta = const VerificationMeta(
    'scenarioId',
  );
  @override
  late final GeneratedColumn<String> scenarioId = GeneratedColumn<String>(
    'scenario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('main'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MilestoneType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MilestoneType>($MilestonesTableTable.$convertertype);
  static const VerificationMeta _debtIdMeta = const VerificationMeta('debtId');
  @override
  late final GeneratedColumn<String> debtId = GeneratedColumn<String>(
    'debt_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES debts (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> achievedAt =
      GeneratedColumn<String>(
        'achieved_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($MilestonesTableTable.$converterachievedAt);
  static const VerificationMeta _seenMeta = const VerificationMeta('seen');
  @override
  late final GeneratedColumn<bool> seen = GeneratedColumn<bool>(
    'seen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("seen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($MilestonesTableTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($MilestonesTableTable.$converterdeletedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scenarioId,
    type,
    debtId,
    achievedAt,
    seen,
    metadata,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milestones';
  @override
  VerificationContext validateIntegrity(
    Insertable<MilestoneRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scenario_id')) {
      context.handle(
        _scenarioIdMeta,
        scenarioId.isAcceptableOrUnknown(data['scenario_id']!, _scenarioIdMeta),
      );
    }
    if (data.containsKey('debt_id')) {
      context.handle(
        _debtIdMeta,
        debtId.isAcceptableOrUnknown(data['debt_id']!, _debtIdMeta),
      );
    }
    if (data.containsKey('seen')) {
      context.handle(
        _seenMeta,
        seen.isAcceptableOrUnknown(data['seen']!, _seenMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MilestoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MilestoneRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scenarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scenario_id'],
      )!,
      type: $MilestonesTableTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      debtId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}debt_id'],
      ),
      achievedAt: $MilestonesTableTable.$converterachievedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}achieved_at'],
        )!,
      ),
      seen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}seen'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      createdAt: $MilestonesTableTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      deletedAt: $MilestonesTableTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
    );
  }

  @override
  $MilestonesTableTable createAlias(String alias) {
    return $MilestonesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<MilestoneType, String> $convertertype =
      const MilestoneTypeConverter();
  static TypeConverter<DateTime, String> $converterachievedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class MilestoneRow extends DataClass implements Insertable<MilestoneRow> {
  final String id;
  final String scenarioId;
  final MilestoneType type;
  final String? debtId;
  final DateTime achievedAt;
  final bool seen;
  final String? metadata;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const MilestoneRow({
    required this.id,
    required this.scenarioId,
    required this.type,
    this.debtId,
    required this.achievedAt,
    required this.seen,
    this.metadata,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scenario_id'] = Variable<String>(scenarioId);
    {
      map['type'] = Variable<String>(
        $MilestonesTableTable.$convertertype.toSql(type),
      );
    }
    if (!nullToAbsent || debtId != null) {
      map['debt_id'] = Variable<String>(debtId);
    }
    {
      map['achieved_at'] = Variable<String>(
        $MilestonesTableTable.$converterachievedAt.toSql(achievedAt),
      );
    }
    map['seen'] = Variable<bool>(seen);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    {
      map['created_at'] = Variable<String>(
        $MilestonesTableTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $MilestonesTableTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    return map;
  }

  MilestonesTableCompanion toCompanion(bool nullToAbsent) {
    return MilestonesTableCompanion(
      id: Value(id),
      scenarioId: Value(scenarioId),
      type: Value(type),
      debtId: debtId == null && nullToAbsent
          ? const Value.absent()
          : Value(debtId),
      achievedAt: Value(achievedAt),
      seen: Value(seen),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory MilestoneRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MilestoneRow(
      id: serializer.fromJson<String>(json['id']),
      scenarioId: serializer.fromJson<String>(json['scenarioId']),
      type: serializer.fromJson<MilestoneType>(json['type']),
      debtId: serializer.fromJson<String?>(json['debtId']),
      achievedAt: serializer.fromJson<DateTime>(json['achievedAt']),
      seen: serializer.fromJson<bool>(json['seen']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scenarioId': serializer.toJson<String>(scenarioId),
      'type': serializer.toJson<MilestoneType>(type),
      'debtId': serializer.toJson<String?>(debtId),
      'achievedAt': serializer.toJson<DateTime>(achievedAt),
      'seen': serializer.toJson<bool>(seen),
      'metadata': serializer.toJson<String?>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  MilestoneRow copyWith({
    String? id,
    String? scenarioId,
    MilestoneType? type,
    Value<String?> debtId = const Value.absent(),
    DateTime? achievedAt,
    bool? seen,
    Value<String?> metadata = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => MilestoneRow(
    id: id ?? this.id,
    scenarioId: scenarioId ?? this.scenarioId,
    type: type ?? this.type,
    debtId: debtId.present ? debtId.value : this.debtId,
    achievedAt: achievedAt ?? this.achievedAt,
    seen: seen ?? this.seen,
    metadata: metadata.present ? metadata.value : this.metadata,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  MilestoneRow copyWithCompanion(MilestonesTableCompanion data) {
    return MilestoneRow(
      id: data.id.present ? data.id.value : this.id,
      scenarioId: data.scenarioId.present
          ? data.scenarioId.value
          : this.scenarioId,
      type: data.type.present ? data.type.value : this.type,
      debtId: data.debtId.present ? data.debtId.value : this.debtId,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
      seen: data.seen.present ? data.seen.value : this.seen,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MilestoneRow(')
          ..write('id: $id, ')
          ..write('scenarioId: $scenarioId, ')
          ..write('type: $type, ')
          ..write('debtId: $debtId, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('seen: $seen, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scenarioId,
    type,
    debtId,
    achievedAt,
    seen,
    metadata,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MilestoneRow &&
          other.id == this.id &&
          other.scenarioId == this.scenarioId &&
          other.type == this.type &&
          other.debtId == this.debtId &&
          other.achievedAt == this.achievedAt &&
          other.seen == this.seen &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class MilestonesTableCompanion extends UpdateCompanion<MilestoneRow> {
  final Value<String> id;
  final Value<String> scenarioId;
  final Value<MilestoneType> type;
  final Value<String?> debtId;
  final Value<DateTime> achievedAt;
  final Value<bool> seen;
  final Value<String?> metadata;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const MilestonesTableCompanion({
    this.id = const Value.absent(),
    this.scenarioId = const Value.absent(),
    this.type = const Value.absent(),
    this.debtId = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.seen = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MilestonesTableCompanion.insert({
    required String id,
    this.scenarioId = const Value.absent(),
    required MilestoneType type,
    this.debtId = const Value.absent(),
    required DateTime achievedAt,
    this.seen = const Value.absent(),
    this.metadata = const Value.absent(),
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       achievedAt = Value(achievedAt),
       createdAt = Value(createdAt);
  static Insertable<MilestoneRow> custom({
    Expression<String>? id,
    Expression<String>? scenarioId,
    Expression<String>? type,
    Expression<String>? debtId,
    Expression<String>? achievedAt,
    Expression<bool>? seen,
    Expression<String>? metadata,
    Expression<String>? createdAt,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scenarioId != null) 'scenario_id': scenarioId,
      if (type != null) 'type': type,
      if (debtId != null) 'debt_id': debtId,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (seen != null) 'seen': seen,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MilestonesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? scenarioId,
    Value<MilestoneType>? type,
    Value<String?>? debtId,
    Value<DateTime>? achievedAt,
    Value<bool>? seen,
    Value<String?>? metadata,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return MilestonesTableCompanion(
      id: id ?? this.id,
      scenarioId: scenarioId ?? this.scenarioId,
      type: type ?? this.type,
      debtId: debtId ?? this.debtId,
      achievedAt: achievedAt ?? this.achievedAt,
      seen: seen ?? this.seen,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scenarioId.present) {
      map['scenario_id'] = Variable<String>(scenarioId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $MilestonesTableTable.$convertertype.toSql(type.value),
      );
    }
    if (debtId.present) {
      map['debt_id'] = Variable<String>(debtId.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<String>(
        $MilestonesTableTable.$converterachievedAt.toSql(achievedAt.value),
      );
    }
    if (seen.present) {
      map['seen'] = Variable<bool>(seen.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $MilestonesTableTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $MilestonesTableTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilestonesTableCompanion(')
          ..write('id: $id, ')
          ..write('scenarioId: $scenarioId, ')
          ..write('type: $type, ')
          ..write('debtId: $debtId, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('seen: $seen, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InterestRateHistoryTableTable extends InterestRateHistoryTable
    with TableInfo<$InterestRateHistoryTableTable, InterestRateHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InterestRateHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _debtIdMeta = const VerificationMeta('debtId');
  @override
  late final GeneratedColumn<String> debtId = GeneratedColumn<String>(
    'debt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES debts (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> apr =
      GeneratedColumn<String>(
        'apr',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($InterestRateHistoryTableTable.$converterapr);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> effectiveFrom =
      GeneratedColumn<String>(
        'effective_from',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $InterestRateHistoryTableTable.$convertereffectiveFrom,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> effectiveTo =
      GeneratedColumn<String>(
        'effective_to',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $InterestRateHistoryTableTable.$convertereffectiveTon,
      );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $InterestRateHistoryTableTable.$convertercreatedAt,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $InterestRateHistoryTableTable.$converterupdatedAt,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $InterestRateHistoryTableTable.$converterdeletedAtn,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    debtId,
    apr,
    effectiveFrom,
    effectiveTo,
    reason,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'interest_rate_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<InterestRateHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('debt_id')) {
      context.handle(
        _debtIdMeta,
        debtId.isAcceptableOrUnknown(data['debt_id']!, _debtIdMeta),
      );
    } else if (isInserting) {
      context.missing(_debtIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InterestRateHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InterestRateHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      debtId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}debt_id'],
      )!,
      apr: $InterestRateHistoryTableTable.$converterapr.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}apr'],
        )!,
      ),
      effectiveFrom: $InterestRateHistoryTableTable.$convertereffectiveFrom
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}effective_from'],
            )!,
          ),
      effectiveTo: $InterestRateHistoryTableTable.$convertereffectiveTon
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}effective_to'],
            ),
          ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      createdAt: $InterestRateHistoryTableTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $InterestRateHistoryTableTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $InterestRateHistoryTableTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
    );
  }

  @override
  $InterestRateHistoryTableTable createAlias(String alias) {
    return $InterestRateHistoryTableTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterapr =
      const DecimalConverter();
  static TypeConverter<DateTime, String> $convertereffectiveFrom =
      const LocalDateConverter();
  static TypeConverter<DateTime, String> $convertereffectiveTo =
      const LocalDateConverter();
  static TypeConverter<DateTime?, String?> $convertereffectiveTon =
      NullAwareTypeConverter.wrap($convertereffectiveTo);
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class InterestRateHistoryRow extends DataClass
    implements Insertable<InterestRateHistoryRow> {
  final String id;
  final String debtId;
  final Decimal apr;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final String? reason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const InterestRateHistoryRow({
    required this.id,
    required this.debtId,
    required this.apr,
    required this.effectiveFrom,
    this.effectiveTo,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['debt_id'] = Variable<String>(debtId);
    {
      map['apr'] = Variable<String>(
        $InterestRateHistoryTableTable.$converterapr.toSql(apr),
      );
    }
    {
      map['effective_from'] = Variable<String>(
        $InterestRateHistoryTableTable.$convertereffectiveFrom.toSql(
          effectiveFrom,
        ),
      );
    }
    if (!nullToAbsent || effectiveTo != null) {
      map['effective_to'] = Variable<String>(
        $InterestRateHistoryTableTable.$convertereffectiveTon.toSql(
          effectiveTo,
        ),
      );
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    {
      map['created_at'] = Variable<String>(
        $InterestRateHistoryTableTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $InterestRateHistoryTableTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $InterestRateHistoryTableTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    return map;
  }

  InterestRateHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return InterestRateHistoryTableCompanion(
      id: Value(id),
      debtId: Value(debtId),
      apr: Value(apr),
      effectiveFrom: Value(effectiveFrom),
      effectiveTo: effectiveTo == null && nullToAbsent
          ? const Value.absent()
          : Value(effectiveTo),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory InterestRateHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InterestRateHistoryRow(
      id: serializer.fromJson<String>(json['id']),
      debtId: serializer.fromJson<String>(json['debtId']),
      apr: serializer.fromJson<Decimal>(json['apr']),
      effectiveFrom: serializer.fromJson<DateTime>(json['effectiveFrom']),
      effectiveTo: serializer.fromJson<DateTime?>(json['effectiveTo']),
      reason: serializer.fromJson<String?>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'debtId': serializer.toJson<String>(debtId),
      'apr': serializer.toJson<Decimal>(apr),
      'effectiveFrom': serializer.toJson<DateTime>(effectiveFrom),
      'effectiveTo': serializer.toJson<DateTime?>(effectiveTo),
      'reason': serializer.toJson<String?>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  InterestRateHistoryRow copyWith({
    String? id,
    String? debtId,
    Decimal? apr,
    DateTime? effectiveFrom,
    Value<DateTime?> effectiveTo = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => InterestRateHistoryRow(
    id: id ?? this.id,
    debtId: debtId ?? this.debtId,
    apr: apr ?? this.apr,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    effectiveTo: effectiveTo.present ? effectiveTo.value : this.effectiveTo,
    reason: reason.present ? reason.value : this.reason,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  InterestRateHistoryRow copyWithCompanion(
    InterestRateHistoryTableCompanion data,
  ) {
    return InterestRateHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      debtId: data.debtId.present ? data.debtId.value : this.debtId,
      apr: data.apr.present ? data.apr.value : this.apr,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      effectiveTo: data.effectiveTo.present
          ? data.effectiveTo.value
          : this.effectiveTo,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InterestRateHistoryRow(')
          ..write('id: $id, ')
          ..write('debtId: $debtId, ')
          ..write('apr: $apr, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveTo: $effectiveTo, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    debtId,
    apr,
    effectiveFrom,
    effectiveTo,
    reason,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterestRateHistoryRow &&
          other.id == this.id &&
          other.debtId == this.debtId &&
          other.apr == this.apr &&
          other.effectiveFrom == this.effectiveFrom &&
          other.effectiveTo == this.effectiveTo &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class InterestRateHistoryTableCompanion
    extends UpdateCompanion<InterestRateHistoryRow> {
  final Value<String> id;
  final Value<String> debtId;
  final Value<Decimal> apr;
  final Value<DateTime> effectiveFrom;
  final Value<DateTime?> effectiveTo;
  final Value<String?> reason;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const InterestRateHistoryTableCompanion({
    this.id = const Value.absent(),
    this.debtId = const Value.absent(),
    this.apr = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.effectiveTo = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InterestRateHistoryTableCompanion.insert({
    required String id,
    required String debtId,
    required Decimal apr,
    required DateTime effectiveFrom,
    this.effectiveTo = const Value.absent(),
    this.reason = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       debtId = Value(debtId),
       apr = Value(apr),
       effectiveFrom = Value(effectiveFrom),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<InterestRateHistoryRow> custom({
    Expression<String>? id,
    Expression<String>? debtId,
    Expression<String>? apr,
    Expression<String>? effectiveFrom,
    Expression<String>? effectiveTo,
    Expression<String>? reason,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (debtId != null) 'debt_id': debtId,
      if (apr != null) 'apr': apr,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (effectiveTo != null) 'effective_to': effectiveTo,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InterestRateHistoryTableCompanion copyWith({
    Value<String>? id,
    Value<String>? debtId,
    Value<Decimal>? apr,
    Value<DateTime>? effectiveFrom,
    Value<DateTime?>? effectiveTo,
    Value<String?>? reason,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return InterestRateHistoryTableCompanion(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      apr: apr ?? this.apr,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (debtId.present) {
      map['debt_id'] = Variable<String>(debtId.value);
    }
    if (apr.present) {
      map['apr'] = Variable<String>(
        $InterestRateHistoryTableTable.$converterapr.toSql(apr.value),
      );
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<String>(
        $InterestRateHistoryTableTable.$convertereffectiveFrom.toSql(
          effectiveFrom.value,
        ),
      );
    }
    if (effectiveTo.present) {
      map['effective_to'] = Variable<String>(
        $InterestRateHistoryTableTable.$convertereffectiveTon.toSql(
          effectiveTo.value,
        ),
      );
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $InterestRateHistoryTableTable.$convertercreatedAt.toSql(
          createdAt.value,
        ),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $InterestRateHistoryTableTable.$converterupdatedAt.toSql(
          updatedAt.value,
        ),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $InterestRateHistoryTableTable.$converterdeletedAtn.toSql(
          deletedAt.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterestRateHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('debtId: $debtId, ')
          ..write('apr: $apr, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveTo: $effectiveTo, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTableTable extends SyncStateTable
    with TableInfo<$SyncStateTableTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tableSyncNameMeta = const VerificationMeta(
    'tableSyncName',
  );
  @override
  late final GeneratedColumn<String> tableSyncName = GeneratedColumn<String>(
    'table_sync_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> lastPulledAt =
      GeneratedColumn<String>(
        'last_pulled_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($SyncStateTableTable.$converterlastPulledAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> lastPushedAt =
      GeneratedColumn<String>(
        'last_pushed_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($SyncStateTableTable.$converterlastPushedAtn);
  static const VerificationMeta _pendingWritesMeta = const VerificationMeta(
    'pendingWrites',
  );
  @override
  late final GeneratedColumn<int> pendingWrites = GeneratedColumn<int>(
    'pending_writes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSyncErrorMeta = const VerificationMeta(
    'lastSyncError',
  );
  @override
  late final GeneratedColumn<String> lastSyncError = GeneratedColumn<String>(
    'last_sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SyncStateTableTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    tableSyncName,
    lastPulledAt,
    lastPushedAt,
    pendingWrites,
    lastSyncError,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('table_sync_name')) {
      context.handle(
        _tableSyncNameMeta,
        tableSyncName.isAcceptableOrUnknown(
          data['table_sync_name']!,
          _tableSyncNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tableSyncNameMeta);
    }
    if (data.containsKey('pending_writes')) {
      context.handle(
        _pendingWritesMeta,
        pendingWrites.isAcceptableOrUnknown(
          data['pending_writes']!,
          _pendingWritesMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_error')) {
      context.handle(
        _lastSyncErrorMeta,
        lastSyncError.isAcceptableOrUnknown(
          data['last_sync_error']!,
          _lastSyncErrorMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tableSyncName};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      tableSyncName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_sync_name'],
      )!,
      lastPulledAt: $SyncStateTableTable.$converterlastPulledAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_pulled_at'],
        ),
      ),
      lastPushedAt: $SyncStateTableTable.$converterlastPushedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_pushed_at'],
        ),
      ),
      pendingWrites: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pending_writes'],
      )!,
      lastSyncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_error'],
      ),
      updatedAt: $SyncStateTableTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $SyncStateTableTable createAlias(String alias) {
    return $SyncStateTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterlastPulledAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterlastPulledAtn =
      NullAwareTypeConverter.wrap($converterlastPulledAt);
  static TypeConverter<DateTime, String> $converterlastPushedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterlastPushedAtn =
      NullAwareTypeConverter.wrap($converterlastPushedAt);
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcDateTimeConverter();
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final String tableSyncName;
  final DateTime? lastPulledAt;
  final DateTime? lastPushedAt;
  final int pendingWrites;
  final String? lastSyncError;
  final DateTime updatedAt;
  const SyncStateRow({
    required this.tableSyncName,
    this.lastPulledAt,
    this.lastPushedAt,
    required this.pendingWrites,
    this.lastSyncError,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['table_sync_name'] = Variable<String>(tableSyncName);
    if (!nullToAbsent || lastPulledAt != null) {
      map['last_pulled_at'] = Variable<String>(
        $SyncStateTableTable.$converterlastPulledAtn.toSql(lastPulledAt),
      );
    }
    if (!nullToAbsent || lastPushedAt != null) {
      map['last_pushed_at'] = Variable<String>(
        $SyncStateTableTable.$converterlastPushedAtn.toSql(lastPushedAt),
      );
    }
    map['pending_writes'] = Variable<int>(pendingWrites);
    if (!nullToAbsent || lastSyncError != null) {
      map['last_sync_error'] = Variable<String>(lastSyncError);
    }
    {
      map['updated_at'] = Variable<String>(
        $SyncStateTableTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  SyncStateTableCompanion toCompanion(bool nullToAbsent) {
    return SyncStateTableCompanion(
      tableSyncName: Value(tableSyncName),
      lastPulledAt: lastPulledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPulledAt),
      lastPushedAt: lastPushedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushedAt),
      pendingWrites: Value(pendingWrites),
      lastSyncError: lastSyncError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncError),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      tableSyncName: serializer.fromJson<String>(json['tableSyncName']),
      lastPulledAt: serializer.fromJson<DateTime?>(json['lastPulledAt']),
      lastPushedAt: serializer.fromJson<DateTime?>(json['lastPushedAt']),
      pendingWrites: serializer.fromJson<int>(json['pendingWrites']),
      lastSyncError: serializer.fromJson<String?>(json['lastSyncError']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tableSyncName': serializer.toJson<String>(tableSyncName),
      'lastPulledAt': serializer.toJson<DateTime?>(lastPulledAt),
      'lastPushedAt': serializer.toJson<DateTime?>(lastPushedAt),
      'pendingWrites': serializer.toJson<int>(pendingWrites),
      'lastSyncError': serializer.toJson<String?>(lastSyncError),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncStateRow copyWith({
    String? tableSyncName,
    Value<DateTime?> lastPulledAt = const Value.absent(),
    Value<DateTime?> lastPushedAt = const Value.absent(),
    int? pendingWrites,
    Value<String?> lastSyncError = const Value.absent(),
    DateTime? updatedAt,
  }) => SyncStateRow(
    tableSyncName: tableSyncName ?? this.tableSyncName,
    lastPulledAt: lastPulledAt.present ? lastPulledAt.value : this.lastPulledAt,
    lastPushedAt: lastPushedAt.present ? lastPushedAt.value : this.lastPushedAt,
    pendingWrites: pendingWrites ?? this.pendingWrites,
    lastSyncError: lastSyncError.present
        ? lastSyncError.value
        : this.lastSyncError,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncStateRow copyWithCompanion(SyncStateTableCompanion data) {
    return SyncStateRow(
      tableSyncName: data.tableSyncName.present
          ? data.tableSyncName.value
          : this.tableSyncName,
      lastPulledAt: data.lastPulledAt.present
          ? data.lastPulledAt.value
          : this.lastPulledAt,
      lastPushedAt: data.lastPushedAt.present
          ? data.lastPushedAt.value
          : this.lastPushedAt,
      pendingWrites: data.pendingWrites.present
          ? data.pendingWrites.value
          : this.pendingWrites,
      lastSyncError: data.lastSyncError.present
          ? data.lastSyncError.value
          : this.lastSyncError,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('tableSyncName: $tableSyncName, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('lastPushedAt: $lastPushedAt, ')
          ..write('pendingWrites: $pendingWrites, ')
          ..write('lastSyncError: $lastSyncError, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    tableSyncName,
    lastPulledAt,
    lastPushedAt,
    pendingWrites,
    lastSyncError,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.tableSyncName == this.tableSyncName &&
          other.lastPulledAt == this.lastPulledAt &&
          other.lastPushedAt == this.lastPushedAt &&
          other.pendingWrites == this.pendingWrites &&
          other.lastSyncError == this.lastSyncError &&
          other.updatedAt == this.updatedAt);
}

class SyncStateTableCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> tableSyncName;
  final Value<DateTime?> lastPulledAt;
  final Value<DateTime?> lastPushedAt;
  final Value<int> pendingWrites;
  final Value<String?> lastSyncError;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncStateTableCompanion({
    this.tableSyncName = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.lastPushedAt = const Value.absent(),
    this.pendingWrites = const Value.absent(),
    this.lastSyncError = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateTableCompanion.insert({
    required String tableSyncName,
    this.lastPulledAt = const Value.absent(),
    this.lastPushedAt = const Value.absent(),
    this.pendingWrites = const Value.absent(),
    this.lastSyncError = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : tableSyncName = Value(tableSyncName),
       updatedAt = Value(updatedAt);
  static Insertable<SyncStateRow> custom({
    Expression<String>? tableSyncName,
    Expression<String>? lastPulledAt,
    Expression<String>? lastPushedAt,
    Expression<int>? pendingWrites,
    Expression<String>? lastSyncError,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tableSyncName != null) 'table_sync_name': tableSyncName,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (lastPushedAt != null) 'last_pushed_at': lastPushedAt,
      if (pendingWrites != null) 'pending_writes': pendingWrites,
      if (lastSyncError != null) 'last_sync_error': lastSyncError,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateTableCompanion copyWith({
    Value<String>? tableSyncName,
    Value<DateTime?>? lastPulledAt,
    Value<DateTime?>? lastPushedAt,
    Value<int>? pendingWrites,
    Value<String?>? lastSyncError,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncStateTableCompanion(
      tableSyncName: tableSyncName ?? this.tableSyncName,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      lastPushedAt: lastPushedAt ?? this.lastPushedAt,
      pendingWrites: pendingWrites ?? this.pendingWrites,
      lastSyncError: lastSyncError ?? this.lastSyncError,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tableSyncName.present) {
      map['table_sync_name'] = Variable<String>(tableSyncName.value);
    }
    if (lastPulledAt.present) {
      map['last_pulled_at'] = Variable<String>(
        $SyncStateTableTable.$converterlastPulledAtn.toSql(lastPulledAt.value),
      );
    }
    if (lastPushedAt.present) {
      map['last_pushed_at'] = Variable<String>(
        $SyncStateTableTable.$converterlastPushedAtn.toSql(lastPushedAt.value),
      );
    }
    if (pendingWrites.present) {
      map['pending_writes'] = Variable<int>(pendingWrites.value);
    }
    if (lastSyncError.present) {
      map['last_sync_error'] = Variable<String>(lastSyncError.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $SyncStateTableTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateTableCompanion(')
          ..write('tableSyncName: $tableSyncName, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('lastPushedAt: $lastPushedAt, ')
          ..write('pendingWrites: $pendingWrites, ')
          ..write('lastSyncError: $lastSyncError, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimelineCacheTableTable extends TimelineCacheTable
    with TableInfo<$TimelineCacheTableTable, TimelineCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimelineCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthIndexMeta = const VerificationMeta(
    'monthIndex',
  );
  @override
  late final GeneratedColumn<int> monthIndex = GeneratedColumn<int>(
    'month_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMonthMeta = const VerificationMeta(
    'yearMonth',
  );
  @override
  late final GeneratedColumn<String> yearMonth = GeneratedColumn<String>(
    'year_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entriesJsonMeta = const VerificationMeta(
    'entriesJson',
  );
  @override
  late final GeneratedColumn<String> entriesJson = GeneratedColumn<String>(
    'entries_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPaymentCentsMeta = const VerificationMeta(
    'totalPaymentCents',
  );
  @override
  late final GeneratedColumn<int> totalPaymentCents = GeneratedColumn<int>(
    'total_payment_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalInterestCentsMeta =
      const VerificationMeta('totalInterestCents');
  @override
  late final GeneratedColumn<int> totalInterestCents = GeneratedColumn<int>(
    'total_interest_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalBalanceEndCentsMeta =
      const VerificationMeta('totalBalanceEndCents');
  @override
  late final GeneratedColumn<int> totalBalanceEndCents = GeneratedColumn<int>(
    'total_balance_end_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> generatedAt =
      GeneratedColumn<String>(
        'generated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($TimelineCacheTableTable.$convertergeneratedAt);
  @override
  List<GeneratedColumn> get $columns => [
    planId,
    monthIndex,
    yearMonth,
    entriesJson,
    totalPaymentCents,
    totalInterestCents,
    totalBalanceEndCents,
    generatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timeline_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimelineCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('month_index')) {
      context.handle(
        _monthIndexMeta,
        monthIndex.isAcceptableOrUnknown(data['month_index']!, _monthIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_monthIndexMeta);
    }
    if (data.containsKey('year_month')) {
      context.handle(
        _yearMonthMeta,
        yearMonth.isAcceptableOrUnknown(data['year_month']!, _yearMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMonthMeta);
    }
    if (data.containsKey('entries_json')) {
      context.handle(
        _entriesJsonMeta,
        entriesJson.isAcceptableOrUnknown(
          data['entries_json']!,
          _entriesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entriesJsonMeta);
    }
    if (data.containsKey('total_payment_cents')) {
      context.handle(
        _totalPaymentCentsMeta,
        totalPaymentCents.isAcceptableOrUnknown(
          data['total_payment_cents']!,
          _totalPaymentCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalPaymentCentsMeta);
    }
    if (data.containsKey('total_interest_cents')) {
      context.handle(
        _totalInterestCentsMeta,
        totalInterestCents.isAcceptableOrUnknown(
          data['total_interest_cents']!,
          _totalInterestCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalInterestCentsMeta);
    }
    if (data.containsKey('total_balance_end_cents')) {
      context.handle(
        _totalBalanceEndCentsMeta,
        totalBalanceEndCents.isAcceptableOrUnknown(
          data['total_balance_end_cents']!,
          _totalBalanceEndCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalBalanceEndCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {planId, monthIndex};
  @override
  TimelineCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineCacheRow(
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      monthIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_index'],
      )!,
      yearMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year_month'],
      )!,
      entriesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entries_json'],
      )!,
      totalPaymentCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_payment_cents'],
      )!,
      totalInterestCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_interest_cents'],
      )!,
      totalBalanceEndCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_balance_end_cents'],
      )!,
      generatedAt: $TimelineCacheTableTable.$convertergeneratedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}generated_at'],
        )!,
      ),
    );
  }

  @override
  $TimelineCacheTableTable createAlias(String alias) {
    return $TimelineCacheTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertergeneratedAt =
      const UtcDateTimeConverter();
}

class TimelineCacheRow extends DataClass
    implements Insertable<TimelineCacheRow> {
  final String planId;
  final int monthIndex;
  final String yearMonth;
  final String entriesJson;
  final int totalPaymentCents;
  final int totalInterestCents;
  final int totalBalanceEndCents;
  final DateTime generatedAt;
  const TimelineCacheRow({
    required this.planId,
    required this.monthIndex,
    required this.yearMonth,
    required this.entriesJson,
    required this.totalPaymentCents,
    required this.totalInterestCents,
    required this.totalBalanceEndCents,
    required this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plan_id'] = Variable<String>(planId);
    map['month_index'] = Variable<int>(monthIndex);
    map['year_month'] = Variable<String>(yearMonth);
    map['entries_json'] = Variable<String>(entriesJson);
    map['total_payment_cents'] = Variable<int>(totalPaymentCents);
    map['total_interest_cents'] = Variable<int>(totalInterestCents);
    map['total_balance_end_cents'] = Variable<int>(totalBalanceEndCents);
    {
      map['generated_at'] = Variable<String>(
        $TimelineCacheTableTable.$convertergeneratedAt.toSql(generatedAt),
      );
    }
    return map;
  }

  TimelineCacheTableCompanion toCompanion(bool nullToAbsent) {
    return TimelineCacheTableCompanion(
      planId: Value(planId),
      monthIndex: Value(monthIndex),
      yearMonth: Value(yearMonth),
      entriesJson: Value(entriesJson),
      totalPaymentCents: Value(totalPaymentCents),
      totalInterestCents: Value(totalInterestCents),
      totalBalanceEndCents: Value(totalBalanceEndCents),
      generatedAt: Value(generatedAt),
    );
  }

  factory TimelineCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineCacheRow(
      planId: serializer.fromJson<String>(json['planId']),
      monthIndex: serializer.fromJson<int>(json['monthIndex']),
      yearMonth: serializer.fromJson<String>(json['yearMonth']),
      entriesJson: serializer.fromJson<String>(json['entriesJson']),
      totalPaymentCents: serializer.fromJson<int>(json['totalPaymentCents']),
      totalInterestCents: serializer.fromJson<int>(json['totalInterestCents']),
      totalBalanceEndCents: serializer.fromJson<int>(
        json['totalBalanceEndCents'],
      ),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'planId': serializer.toJson<String>(planId),
      'monthIndex': serializer.toJson<int>(monthIndex),
      'yearMonth': serializer.toJson<String>(yearMonth),
      'entriesJson': serializer.toJson<String>(entriesJson),
      'totalPaymentCents': serializer.toJson<int>(totalPaymentCents),
      'totalInterestCents': serializer.toJson<int>(totalInterestCents),
      'totalBalanceEndCents': serializer.toJson<int>(totalBalanceEndCents),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  TimelineCacheRow copyWith({
    String? planId,
    int? monthIndex,
    String? yearMonth,
    String? entriesJson,
    int? totalPaymentCents,
    int? totalInterestCents,
    int? totalBalanceEndCents,
    DateTime? generatedAt,
  }) => TimelineCacheRow(
    planId: planId ?? this.planId,
    monthIndex: monthIndex ?? this.monthIndex,
    yearMonth: yearMonth ?? this.yearMonth,
    entriesJson: entriesJson ?? this.entriesJson,
    totalPaymentCents: totalPaymentCents ?? this.totalPaymentCents,
    totalInterestCents: totalInterestCents ?? this.totalInterestCents,
    totalBalanceEndCents: totalBalanceEndCents ?? this.totalBalanceEndCents,
    generatedAt: generatedAt ?? this.generatedAt,
  );
  TimelineCacheRow copyWithCompanion(TimelineCacheTableCompanion data) {
    return TimelineCacheRow(
      planId: data.planId.present ? data.planId.value : this.planId,
      monthIndex: data.monthIndex.present
          ? data.monthIndex.value
          : this.monthIndex,
      yearMonth: data.yearMonth.present ? data.yearMonth.value : this.yearMonth,
      entriesJson: data.entriesJson.present
          ? data.entriesJson.value
          : this.entriesJson,
      totalPaymentCents: data.totalPaymentCents.present
          ? data.totalPaymentCents.value
          : this.totalPaymentCents,
      totalInterestCents: data.totalInterestCents.present
          ? data.totalInterestCents.value
          : this.totalInterestCents,
      totalBalanceEndCents: data.totalBalanceEndCents.present
          ? data.totalBalanceEndCents.value
          : this.totalBalanceEndCents,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineCacheRow(')
          ..write('planId: $planId, ')
          ..write('monthIndex: $monthIndex, ')
          ..write('yearMonth: $yearMonth, ')
          ..write('entriesJson: $entriesJson, ')
          ..write('totalPaymentCents: $totalPaymentCents, ')
          ..write('totalInterestCents: $totalInterestCents, ')
          ..write('totalBalanceEndCents: $totalBalanceEndCents, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    planId,
    monthIndex,
    yearMonth,
    entriesJson,
    totalPaymentCents,
    totalInterestCents,
    totalBalanceEndCents,
    generatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineCacheRow &&
          other.planId == this.planId &&
          other.monthIndex == this.monthIndex &&
          other.yearMonth == this.yearMonth &&
          other.entriesJson == this.entriesJson &&
          other.totalPaymentCents == this.totalPaymentCents &&
          other.totalInterestCents == this.totalInterestCents &&
          other.totalBalanceEndCents == this.totalBalanceEndCents &&
          other.generatedAt == this.generatedAt);
}

class TimelineCacheTableCompanion extends UpdateCompanion<TimelineCacheRow> {
  final Value<String> planId;
  final Value<int> monthIndex;
  final Value<String> yearMonth;
  final Value<String> entriesJson;
  final Value<int> totalPaymentCents;
  final Value<int> totalInterestCents;
  final Value<int> totalBalanceEndCents;
  final Value<DateTime> generatedAt;
  final Value<int> rowid;
  const TimelineCacheTableCompanion({
    this.planId = const Value.absent(),
    this.monthIndex = const Value.absent(),
    this.yearMonth = const Value.absent(),
    this.entriesJson = const Value.absent(),
    this.totalPaymentCents = const Value.absent(),
    this.totalInterestCents = const Value.absent(),
    this.totalBalanceEndCents = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimelineCacheTableCompanion.insert({
    required String planId,
    required int monthIndex,
    required String yearMonth,
    required String entriesJson,
    required int totalPaymentCents,
    required int totalInterestCents,
    required int totalBalanceEndCents,
    required DateTime generatedAt,
    this.rowid = const Value.absent(),
  }) : planId = Value(planId),
       monthIndex = Value(monthIndex),
       yearMonth = Value(yearMonth),
       entriesJson = Value(entriesJson),
       totalPaymentCents = Value(totalPaymentCents),
       totalInterestCents = Value(totalInterestCents),
       totalBalanceEndCents = Value(totalBalanceEndCents),
       generatedAt = Value(generatedAt);
  static Insertable<TimelineCacheRow> custom({
    Expression<String>? planId,
    Expression<int>? monthIndex,
    Expression<String>? yearMonth,
    Expression<String>? entriesJson,
    Expression<int>? totalPaymentCents,
    Expression<int>? totalInterestCents,
    Expression<int>? totalBalanceEndCents,
    Expression<String>? generatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (planId != null) 'plan_id': planId,
      if (monthIndex != null) 'month_index': monthIndex,
      if (yearMonth != null) 'year_month': yearMonth,
      if (entriesJson != null) 'entries_json': entriesJson,
      if (totalPaymentCents != null) 'total_payment_cents': totalPaymentCents,
      if (totalInterestCents != null)
        'total_interest_cents': totalInterestCents,
      if (totalBalanceEndCents != null)
        'total_balance_end_cents': totalBalanceEndCents,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimelineCacheTableCompanion copyWith({
    Value<String>? planId,
    Value<int>? monthIndex,
    Value<String>? yearMonth,
    Value<String>? entriesJson,
    Value<int>? totalPaymentCents,
    Value<int>? totalInterestCents,
    Value<int>? totalBalanceEndCents,
    Value<DateTime>? generatedAt,
    Value<int>? rowid,
  }) {
    return TimelineCacheTableCompanion(
      planId: planId ?? this.planId,
      monthIndex: monthIndex ?? this.monthIndex,
      yearMonth: yearMonth ?? this.yearMonth,
      entriesJson: entriesJson ?? this.entriesJson,
      totalPaymentCents: totalPaymentCents ?? this.totalPaymentCents,
      totalInterestCents: totalInterestCents ?? this.totalInterestCents,
      totalBalanceEndCents: totalBalanceEndCents ?? this.totalBalanceEndCents,
      generatedAt: generatedAt ?? this.generatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (monthIndex.present) {
      map['month_index'] = Variable<int>(monthIndex.value);
    }
    if (yearMonth.present) {
      map['year_month'] = Variable<String>(yearMonth.value);
    }
    if (entriesJson.present) {
      map['entries_json'] = Variable<String>(entriesJson.value);
    }
    if (totalPaymentCents.present) {
      map['total_payment_cents'] = Variable<int>(totalPaymentCents.value);
    }
    if (totalInterestCents.present) {
      map['total_interest_cents'] = Variable<int>(totalInterestCents.value);
    }
    if (totalBalanceEndCents.present) {
      map['total_balance_end_cents'] = Variable<int>(
        totalBalanceEndCents.value,
      );
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<String>(
        $TimelineCacheTableTable.$convertergeneratedAt.toSql(generatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimelineCacheTableCompanion(')
          ..write('planId: $planId, ')
          ..write('monthIndex: $monthIndex, ')
          ..write('yearMonth: $yearMonth, ')
          ..write('entriesJson: $entriesJson, ')
          ..write('totalPaymentCents: $totalPaymentCents, ')
          ..write('totalInterestCents: $totalInterestCents, ')
          ..write('totalBalanceEndCents: $totalBalanceEndCents, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DebtsTableTable debtsTable = $DebtsTableTable(this);
  late final $PaymentsTableTable paymentsTable = $PaymentsTableTable(this);
  late final $PlansTableTable plansTable = $PlansTableTable(this);
  late final $UserSettingsTableTable userSettingsTable =
      $UserSettingsTableTable(this);
  late final $MilestonesTableTable milestonesTable = $MilestonesTableTable(
    this,
  );
  late final $InterestRateHistoryTableTable interestRateHistoryTable =
      $InterestRateHistoryTableTable(this);
  late final $SyncStateTableTable syncStateTable = $SyncStateTableTable(this);
  late final $TimelineCacheTableTable timelineCacheTable =
      $TimelineCacheTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    debtsTable,
    paymentsTable,
    plansTable,
    userSettingsTable,
    milestonesTable,
    interestRateHistoryTable,
    syncStateTable,
    timelineCacheTable,
  ];
}

typedef $$DebtsTableTableCreateCompanionBuilder =
    DebtsTableCompanion Function({
      required String id,
      Value<String> scenarioId,
      required String name,
      required DebtType type,
      required int originalPrincipalCents,
      required int currentBalanceCents,
      required Decimal apr,
      required InterestMethod interestMethod,
      Value<int> minimumPaymentCents,
      required MinPaymentType minimumPaymentType,
      Value<Decimal?> minimumPaymentPercent,
      Value<int?> minimumPaymentFloorCents,
      required PaymentCadence paymentCadence,
      Value<int?> dueDayOfMonth,
      required DateTime firstDueDate,
      required DebtStatus status,
      Value<DateTime?> pausedUntil,
      Value<int?> priority,
      Value<bool> excludeFromStrategy,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> paidOffAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$DebtsTableTableUpdateCompanionBuilder =
    DebtsTableCompanion Function({
      Value<String> id,
      Value<String> scenarioId,
      Value<String> name,
      Value<DebtType> type,
      Value<int> originalPrincipalCents,
      Value<int> currentBalanceCents,
      Value<Decimal> apr,
      Value<InterestMethod> interestMethod,
      Value<int> minimumPaymentCents,
      Value<MinPaymentType> minimumPaymentType,
      Value<Decimal?> minimumPaymentPercent,
      Value<int?> minimumPaymentFloorCents,
      Value<PaymentCadence> paymentCadence,
      Value<int?> dueDayOfMonth,
      Value<DateTime> firstDueDate,
      Value<DebtStatus> status,
      Value<DateTime?> pausedUntil,
      Value<int?> priority,
      Value<bool> excludeFromStrategy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> paidOffAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$DebtsTableTableReferences
    extends BaseReferences<_$AppDatabase, $DebtsTableTable, DebtRow> {
  $$DebtsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PaymentsTableTable, List<PaymentRow>>
  _paymentsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.paymentsTable,
    aliasName: $_aliasNameGenerator(db.debtsTable.id, db.paymentsTable.debtId),
  );

  $$PaymentsTableTableProcessedTableManager get paymentsTableRefs {
    final manager = $$PaymentsTableTableTableManager(
      $_db,
      $_db.paymentsTable,
    ).filter((f) => f.debtId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MilestonesTableTable, List<MilestoneRow>>
  _milestonesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.milestonesTable,
    aliasName: $_aliasNameGenerator(
      db.debtsTable.id,
      db.milestonesTable.debtId,
    ),
  );

  $$MilestonesTableTableProcessedTableManager get milestonesTableRefs {
    final manager = $$MilestonesTableTableTableManager(
      $_db,
      $_db.milestonesTable,
    ).filter((f) => f.debtId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _milestonesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $InterestRateHistoryTableTable,
    List<InterestRateHistoryRow>
  >
  _interestRateHistoryTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.interestRateHistoryTable,
        aliasName: $_aliasNameGenerator(
          db.debtsTable.id,
          db.interestRateHistoryTable.debtId,
        ),
      );

  $$InterestRateHistoryTableTableProcessedTableManager
  get interestRateHistoryTableRefs {
    final manager = $$InterestRateHistoryTableTableTableManager(
      $_db,
      $_db.interestRateHistoryTable,
    ).filter((f) => f.debtId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _interestRateHistoryTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DebtsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DebtsTableTable> {
  $$DebtsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DebtType, DebtType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get originalPrincipalCents => $composableBuilder(
    column: $table.originalPrincipalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentBalanceCents => $composableBuilder(
    column: $table.currentBalanceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get apr =>
      $composableBuilder(
        column: $table.apr,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<InterestMethod, InterestMethod, String>
  get interestMethod => $composableBuilder(
    column: $table.interestMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get minimumPaymentCents => $composableBuilder(
    column: $table.minimumPaymentCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MinPaymentType, MinPaymentType, String>
  get minimumPaymentType => $composableBuilder(
    column: $table.minimumPaymentType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String>
  get minimumPaymentPercent => $composableBuilder(
    column: $table.minimumPaymentPercent,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get minimumPaymentFloorCents => $composableBuilder(
    column: $table.minimumPaymentFloorCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentCadence, PaymentCadence, String>
  get paymentCadence => $composableBuilder(
    column: $table.paymentCadence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get dueDayOfMonth => $composableBuilder(
    column: $table.dueDayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get firstDueDate =>
      $composableBuilder(
        column: $table.firstDueDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DebtStatus, DebtStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get pausedUntil =>
      $composableBuilder(
        column: $table.pausedUntil,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excludeFromStrategy => $composableBuilder(
    column: $table.excludeFromStrategy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get paidOffAt =>
      $composableBuilder(
        column: $table.paidOffAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> paymentsTableRefs(
    Expression<bool> Function($$PaymentsTableTableFilterComposer f) f,
  ) {
    final $$PaymentsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentsTable,
      getReferencedColumn: (t) => t.debtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableTableFilterComposer(
            $db: $db,
            $table: $db.paymentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> milestonesTableRefs(
    Expression<bool> Function($$MilestonesTableTableFilterComposer f) f,
  ) {
    final $$MilestonesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestonesTable,
      getReferencedColumn: (t) => t.debtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableTableFilterComposer(
            $db: $db,
            $table: $db.milestonesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> interestRateHistoryTableRefs(
    Expression<bool> Function($$InterestRateHistoryTableTableFilterComposer f)
    f,
  ) {
    final $$InterestRateHistoryTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.interestRateHistoryTable,
          getReferencedColumn: (t) => t.debtId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InterestRateHistoryTableTableFilterComposer(
                $db: $db,
                $table: $db.interestRateHistoryTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DebtsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTableTable> {
  $$DebtsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalPrincipalCents => $composableBuilder(
    column: $table.originalPrincipalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentBalanceCents => $composableBuilder(
    column: $table.currentBalanceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apr => $composableBuilder(
    column: $table.apr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestMethod => $composableBuilder(
    column: $table.interestMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumPaymentCents => $composableBuilder(
    column: $table.minimumPaymentCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get minimumPaymentType => $composableBuilder(
    column: $table.minimumPaymentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get minimumPaymentPercent => $composableBuilder(
    column: $table.minimumPaymentPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumPaymentFloorCents => $composableBuilder(
    column: $table.minimumPaymentFloorCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentCadence => $composableBuilder(
    column: $table.paymentCadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDayOfMonth => $composableBuilder(
    column: $table.dueDayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstDueDate => $composableBuilder(
    column: $table.firstDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pausedUntil => $composableBuilder(
    column: $table.pausedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excludeFromStrategy => $composableBuilder(
    column: $table.excludeFromStrategy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paidOffAt => $composableBuilder(
    column: $table.paidOffAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTableTable> {
  $$DebtsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DebtType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get originalPrincipalCents => $composableBuilder(
    column: $table.originalPrincipalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentBalanceCents => $composableBuilder(
    column: $table.currentBalanceCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Decimal, String> get apr =>
      $composableBuilder(column: $table.apr, builder: (column) => column);

  GeneratedColumnWithTypeConverter<InterestMethod, String> get interestMethod =>
      $composableBuilder(
        column: $table.interestMethod,
        builder: (column) => column,
      );

  GeneratedColumn<int> get minimumPaymentCents => $composableBuilder(
    column: $table.minimumPaymentCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MinPaymentType, String>
  get minimumPaymentType => $composableBuilder(
    column: $table.minimumPaymentType,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Decimal?, String>
  get minimumPaymentPercent => $composableBuilder(
    column: $table.minimumPaymentPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minimumPaymentFloorCents => $composableBuilder(
    column: $table.minimumPaymentFloorCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PaymentCadence, String> get paymentCadence =>
      $composableBuilder(
        column: $table.paymentCadence,
        builder: (column) => column,
      );

  GeneratedColumn<int> get dueDayOfMonth => $composableBuilder(
    column: $table.dueDayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get firstDueDate =>
      $composableBuilder(
        column: $table.firstDueDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DebtStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get pausedUntil =>
      $composableBuilder(
        column: $table.pausedUntil,
        builder: (column) => column,
      );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get excludeFromStrategy => $composableBuilder(
    column: $table.excludeFromStrategy,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get paidOffAt =>
      $composableBuilder(column: $table.paidOffAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> paymentsTableRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentsTable,
      getReferencedColumn: (t) => t.debtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> milestonesTableRefs<T extends Object>(
    Expression<T> Function($$MilestonesTableTableAnnotationComposer a) f,
  ) {
    final $$MilestonesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestonesTable,
      getReferencedColumn: (t) => t.debtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.milestonesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> interestRateHistoryTableRefs<T extends Object>(
    Expression<T> Function($$InterestRateHistoryTableTableAnnotationComposer a)
    f,
  ) {
    final $$InterestRateHistoryTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.interestRateHistoryTable,
          getReferencedColumn: (t) => t.debtId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InterestRateHistoryTableTableAnnotationComposer(
                $db: $db,
                $table: $db.interestRateHistoryTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DebtsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtsTableTable,
          DebtRow,
          $$DebtsTableTableFilterComposer,
          $$DebtsTableTableOrderingComposer,
          $$DebtsTableTableAnnotationComposer,
          $$DebtsTableTableCreateCompanionBuilder,
          $$DebtsTableTableUpdateCompanionBuilder,
          (DebtRow, $$DebtsTableTableReferences),
          DebtRow,
          PrefetchHooks Function({
            bool paymentsTableRefs,
            bool milestonesTableRefs,
            bool interestRateHistoryTableRefs,
          })
        > {
  $$DebtsTableTableTableManager(_$AppDatabase db, $DebtsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scenarioId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DebtType> type = const Value.absent(),
                Value<int> originalPrincipalCents = const Value.absent(),
                Value<int> currentBalanceCents = const Value.absent(),
                Value<Decimal> apr = const Value.absent(),
                Value<InterestMethod> interestMethod = const Value.absent(),
                Value<int> minimumPaymentCents = const Value.absent(),
                Value<MinPaymentType> minimumPaymentType = const Value.absent(),
                Value<Decimal?> minimumPaymentPercent = const Value.absent(),
                Value<int?> minimumPaymentFloorCents = const Value.absent(),
                Value<PaymentCadence> paymentCadence = const Value.absent(),
                Value<int?> dueDayOfMonth = const Value.absent(),
                Value<DateTime> firstDueDate = const Value.absent(),
                Value<DebtStatus> status = const Value.absent(),
                Value<DateTime?> pausedUntil = const Value.absent(),
                Value<int?> priority = const Value.absent(),
                Value<bool> excludeFromStrategy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> paidOffAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtsTableCompanion(
                id: id,
                scenarioId: scenarioId,
                name: name,
                type: type,
                originalPrincipalCents: originalPrincipalCents,
                currentBalanceCents: currentBalanceCents,
                apr: apr,
                interestMethod: interestMethod,
                minimumPaymentCents: minimumPaymentCents,
                minimumPaymentType: minimumPaymentType,
                minimumPaymentPercent: minimumPaymentPercent,
                minimumPaymentFloorCents: minimumPaymentFloorCents,
                paymentCadence: paymentCadence,
                dueDayOfMonth: dueDayOfMonth,
                firstDueDate: firstDueDate,
                status: status,
                pausedUntil: pausedUntil,
                priority: priority,
                excludeFromStrategy: excludeFromStrategy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                paidOffAt: paidOffAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> scenarioId = const Value.absent(),
                required String name,
                required DebtType type,
                required int originalPrincipalCents,
                required int currentBalanceCents,
                required Decimal apr,
                required InterestMethod interestMethod,
                Value<int> minimumPaymentCents = const Value.absent(),
                required MinPaymentType minimumPaymentType,
                Value<Decimal?> minimumPaymentPercent = const Value.absent(),
                Value<int?> minimumPaymentFloorCents = const Value.absent(),
                required PaymentCadence paymentCadence,
                Value<int?> dueDayOfMonth = const Value.absent(),
                required DateTime firstDueDate,
                required DebtStatus status,
                Value<DateTime?> pausedUntil = const Value.absent(),
                Value<int?> priority = const Value.absent(),
                Value<bool> excludeFromStrategy = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> paidOffAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtsTableCompanion.insert(
                id: id,
                scenarioId: scenarioId,
                name: name,
                type: type,
                originalPrincipalCents: originalPrincipalCents,
                currentBalanceCents: currentBalanceCents,
                apr: apr,
                interestMethod: interestMethod,
                minimumPaymentCents: minimumPaymentCents,
                minimumPaymentType: minimumPaymentType,
                minimumPaymentPercent: minimumPaymentPercent,
                minimumPaymentFloorCents: minimumPaymentFloorCents,
                paymentCadence: paymentCadence,
                dueDayOfMonth: dueDayOfMonth,
                firstDueDate: firstDueDate,
                status: status,
                pausedUntil: pausedUntil,
                priority: priority,
                excludeFromStrategy: excludeFromStrategy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                paidOffAt: paidOffAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DebtsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                paymentsTableRefs = false,
                milestonesTableRefs = false,
                interestRateHistoryTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentsTableRefs) db.paymentsTable,
                    if (milestonesTableRefs) db.milestonesTable,
                    if (interestRateHistoryTableRefs)
                      db.interestRateHistoryTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentsTableRefs)
                        await $_getPrefetchedData<
                          DebtRow,
                          $DebtsTableTable,
                          PaymentRow
                        >(
                          currentTable: table,
                          referencedTable: $$DebtsTableTableReferences
                              ._paymentsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DebtsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.debtId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (milestonesTableRefs)
                        await $_getPrefetchedData<
                          DebtRow,
                          $DebtsTableTable,
                          MilestoneRow
                        >(
                          currentTable: table,
                          referencedTable: $$DebtsTableTableReferences
                              ._milestonesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DebtsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).milestonesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.debtId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (interestRateHistoryTableRefs)
                        await $_getPrefetchedData<
                          DebtRow,
                          $DebtsTableTable,
                          InterestRateHistoryRow
                        >(
                          currentTable: table,
                          referencedTable: $$DebtsTableTableReferences
                              ._interestRateHistoryTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DebtsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).interestRateHistoryTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.debtId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DebtsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtsTableTable,
      DebtRow,
      $$DebtsTableTableFilterComposer,
      $$DebtsTableTableOrderingComposer,
      $$DebtsTableTableAnnotationComposer,
      $$DebtsTableTableCreateCompanionBuilder,
      $$DebtsTableTableUpdateCompanionBuilder,
      (DebtRow, $$DebtsTableTableReferences),
      DebtRow,
      PrefetchHooks Function({
        bool paymentsTableRefs,
        bool milestonesTableRefs,
        bool interestRateHistoryTableRefs,
      })
    >;
typedef $$PaymentsTableTableCreateCompanionBuilder =
    PaymentsTableCompanion Function({
      required String id,
      Value<String> scenarioId,
      required String debtId,
      required int amountCents,
      required int principalPortionCents,
      required int interestPortionCents,
      Value<int> feePortionCents,
      required DateTime date,
      required PaymentType type,
      required PaymentSource source,
      Value<String?> note,
      required PaymentStatus status,
      required int appliedBalanceBeforeCents,
      required int appliedBalanceAfterCents,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$PaymentsTableTableUpdateCompanionBuilder =
    PaymentsTableCompanion Function({
      Value<String> id,
      Value<String> scenarioId,
      Value<String> debtId,
      Value<int> amountCents,
      Value<int> principalPortionCents,
      Value<int> interestPortionCents,
      Value<int> feePortionCents,
      Value<DateTime> date,
      Value<PaymentType> type,
      Value<PaymentSource> source,
      Value<String?> note,
      Value<PaymentStatus> status,
      Value<int> appliedBalanceBeforeCents,
      Value<int> appliedBalanceAfterCents,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$PaymentsTableTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTableTable, PaymentRow> {
  $$PaymentsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DebtsTableTable _debtIdTable(_$AppDatabase db) =>
      db.debtsTable.createAlias(
        $_aliasNameGenerator(db.paymentsTable.debtId, db.debtsTable.id),
      );

  $$DebtsTableTableProcessedTableManager get debtId {
    final $_column = $_itemColumn<String>('debt_id')!;

    final manager = $$DebtsTableTableTableManager(
      $_db,
      $_db.debtsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_debtIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get principalPortionCents => $composableBuilder(
    column: $table.principalPortionCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interestPortionCents => $composableBuilder(
    column: $table.interestPortionCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feePortionCents => $composableBuilder(
    column: $table.feePortionCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PaymentType, PaymentType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PaymentSource, PaymentSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentStatus, PaymentStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get appliedBalanceBeforeCents => $composableBuilder(
    column: $table.appliedBalanceBeforeCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get appliedBalanceAfterCents => $composableBuilder(
    column: $table.appliedBalanceAfterCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$DebtsTableTableFilterComposer get debtId {
    final $$DebtsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableFilterComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get principalPortionCents => $composableBuilder(
    column: $table.principalPortionCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interestPortionCents => $composableBuilder(
    column: $table.interestPortionCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feePortionCents => $composableBuilder(
    column: $table.feePortionCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get appliedBalanceBeforeCents => $composableBuilder(
    column: $table.appliedBalanceBeforeCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get appliedBalanceAfterCents => $composableBuilder(
    column: $table.appliedBalanceAfterCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DebtsTableTableOrderingComposer get debtId {
    final $$DebtsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableOrderingComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get principalPortionCents => $composableBuilder(
    column: $table.principalPortionCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get interestPortionCents => $composableBuilder(
    column: $table.interestPortionCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get feePortionCents => $composableBuilder(
    column: $table.feePortionCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get appliedBalanceBeforeCents => $composableBuilder(
    column: $table.appliedBalanceBeforeCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get appliedBalanceAfterCents => $composableBuilder(
    column: $table.appliedBalanceAfterCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$DebtsTableTableAnnotationComposer get debtId {
    final $$DebtsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTableTable,
          PaymentRow,
          $$PaymentsTableTableFilterComposer,
          $$PaymentsTableTableOrderingComposer,
          $$PaymentsTableTableAnnotationComposer,
          $$PaymentsTableTableCreateCompanionBuilder,
          $$PaymentsTableTableUpdateCompanionBuilder,
          (PaymentRow, $$PaymentsTableTableReferences),
          PaymentRow,
          PrefetchHooks Function({bool debtId})
        > {
  $$PaymentsTableTableTableManager(_$AppDatabase db, $PaymentsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scenarioId = const Value.absent(),
                Value<String> debtId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<int> principalPortionCents = const Value.absent(),
                Value<int> interestPortionCents = const Value.absent(),
                Value<int> feePortionCents = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<PaymentType> type = const Value.absent(),
                Value<PaymentSource> source = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<PaymentStatus> status = const Value.absent(),
                Value<int> appliedBalanceBeforeCents = const Value.absent(),
                Value<int> appliedBalanceAfterCents = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsTableCompanion(
                id: id,
                scenarioId: scenarioId,
                debtId: debtId,
                amountCents: amountCents,
                principalPortionCents: principalPortionCents,
                interestPortionCents: interestPortionCents,
                feePortionCents: feePortionCents,
                date: date,
                type: type,
                source: source,
                note: note,
                status: status,
                appliedBalanceBeforeCents: appliedBalanceBeforeCents,
                appliedBalanceAfterCents: appliedBalanceAfterCents,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> scenarioId = const Value.absent(),
                required String debtId,
                required int amountCents,
                required int principalPortionCents,
                required int interestPortionCents,
                Value<int> feePortionCents = const Value.absent(),
                required DateTime date,
                required PaymentType type,
                required PaymentSource source,
                Value<String?> note = const Value.absent(),
                required PaymentStatus status,
                required int appliedBalanceBeforeCents,
                required int appliedBalanceAfterCents,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsTableCompanion.insert(
                id: id,
                scenarioId: scenarioId,
                debtId: debtId,
                amountCents: amountCents,
                principalPortionCents: principalPortionCents,
                interestPortionCents: interestPortionCents,
                feePortionCents: feePortionCents,
                date: date,
                type: type,
                source: source,
                note: note,
                status: status,
                appliedBalanceBeforeCents: appliedBalanceBeforeCents,
                appliedBalanceAfterCents: appliedBalanceAfterCents,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({debtId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (debtId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.debtId,
                                referencedTable: $$PaymentsTableTableReferences
                                    ._debtIdTable(db),
                                referencedColumn: $$PaymentsTableTableReferences
                                    ._debtIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTableTable,
      PaymentRow,
      $$PaymentsTableTableFilterComposer,
      $$PaymentsTableTableOrderingComposer,
      $$PaymentsTableTableAnnotationComposer,
      $$PaymentsTableTableCreateCompanionBuilder,
      $$PaymentsTableTableUpdateCompanionBuilder,
      (PaymentRow, $$PaymentsTableTableReferences),
      PaymentRow,
      PrefetchHooks Function({bool debtId})
    >;
typedef $$PlansTableTableCreateCompanionBuilder =
    PlansTableCompanion Function({
      required String id,
      Value<String> scenarioId,
      required Strategy strategy,
      Value<int> extraMonthlyAmountCents,
      required PaymentCadence extraPaymentCadence,
      Value<String?> customOrderJson,
      required DateTime lastRecastAt,
      Value<DateTime?> projectedDebtFreeDate,
      Value<int?> totalInterestProjectedCents,
      Value<int?> totalInterestSavedCents,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$PlansTableTableUpdateCompanionBuilder =
    PlansTableCompanion Function({
      Value<String> id,
      Value<String> scenarioId,
      Value<Strategy> strategy,
      Value<int> extraMonthlyAmountCents,
      Value<PaymentCadence> extraPaymentCadence,
      Value<String?> customOrderJson,
      Value<DateTime> lastRecastAt,
      Value<DateTime?> projectedDebtFreeDate,
      Value<int?> totalInterestProjectedCents,
      Value<int?> totalInterestSavedCents,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$PlansTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlansTableTable> {
  $$PlansTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Strategy, Strategy, String> get strategy =>
      $composableBuilder(
        column: $table.strategy,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get extraMonthlyAmountCents => $composableBuilder(
    column: $table.extraMonthlyAmountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentCadence, PaymentCadence, String>
  get extraPaymentCadence => $composableBuilder(
    column: $table.extraPaymentCadence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get customOrderJson => $composableBuilder(
    column: $table.customOrderJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get lastRecastAt =>
      $composableBuilder(
        column: $table.lastRecastAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
  get projectedDebtFreeDate => $composableBuilder(
    column: $table.projectedDebtFreeDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get totalInterestProjectedCents => $composableBuilder(
    column: $table.totalInterestProjectedCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalInterestSavedCents => $composableBuilder(
    column: $table.totalInterestSavedCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$PlansTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlansTableTable> {
  $$PlansTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strategy => $composableBuilder(
    column: $table.strategy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get extraMonthlyAmountCents => $composableBuilder(
    column: $table.extraMonthlyAmountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraPaymentCadence => $composableBuilder(
    column: $table.extraPaymentCadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customOrderJson => $composableBuilder(
    column: $table.customOrderJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastRecastAt => $composableBuilder(
    column: $table.lastRecastAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectedDebtFreeDate => $composableBuilder(
    column: $table.projectedDebtFreeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalInterestProjectedCents => $composableBuilder(
    column: $table.totalInterestProjectedCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalInterestSavedCents => $composableBuilder(
    column: $table.totalInterestSavedCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlansTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlansTableTable> {
  $$PlansTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Strategy, String> get strategy =>
      $composableBuilder(column: $table.strategy, builder: (column) => column);

  GeneratedColumn<int> get extraMonthlyAmountCents => $composableBuilder(
    column: $table.extraMonthlyAmountCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PaymentCadence, String>
  get extraPaymentCadence => $composableBuilder(
    column: $table.extraPaymentCadence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customOrderJson => $composableBuilder(
    column: $table.customOrderJson,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get lastRecastAt =>
      $composableBuilder(
        column: $table.lastRecastAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, String>
  get projectedDebtFreeDate => $composableBuilder(
    column: $table.projectedDebtFreeDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalInterestProjectedCents => $composableBuilder(
    column: $table.totalInterestProjectedCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalInterestSavedCents => $composableBuilder(
    column: $table.totalInterestSavedCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PlansTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlansTableTable,
          PlanRow,
          $$PlansTableTableFilterComposer,
          $$PlansTableTableOrderingComposer,
          $$PlansTableTableAnnotationComposer,
          $$PlansTableTableCreateCompanionBuilder,
          $$PlansTableTableUpdateCompanionBuilder,
          (PlanRow, BaseReferences<_$AppDatabase, $PlansTableTable, PlanRow>),
          PlanRow,
          PrefetchHooks Function()
        > {
  $$PlansTableTableTableManager(_$AppDatabase db, $PlansTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scenarioId = const Value.absent(),
                Value<Strategy> strategy = const Value.absent(),
                Value<int> extraMonthlyAmountCents = const Value.absent(),
                Value<PaymentCadence> extraPaymentCadence =
                    const Value.absent(),
                Value<String?> customOrderJson = const Value.absent(),
                Value<DateTime> lastRecastAt = const Value.absent(),
                Value<DateTime?> projectedDebtFreeDate = const Value.absent(),
                Value<int?> totalInterestProjectedCents = const Value.absent(),
                Value<int?> totalInterestSavedCents = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlansTableCompanion(
                id: id,
                scenarioId: scenarioId,
                strategy: strategy,
                extraMonthlyAmountCents: extraMonthlyAmountCents,
                extraPaymentCadence: extraPaymentCadence,
                customOrderJson: customOrderJson,
                lastRecastAt: lastRecastAt,
                projectedDebtFreeDate: projectedDebtFreeDate,
                totalInterestProjectedCents: totalInterestProjectedCents,
                totalInterestSavedCents: totalInterestSavedCents,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> scenarioId = const Value.absent(),
                required Strategy strategy,
                Value<int> extraMonthlyAmountCents = const Value.absent(),
                required PaymentCadence extraPaymentCadence,
                Value<String?> customOrderJson = const Value.absent(),
                required DateTime lastRecastAt,
                Value<DateTime?> projectedDebtFreeDate = const Value.absent(),
                Value<int?> totalInterestProjectedCents = const Value.absent(),
                Value<int?> totalInterestSavedCents = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlansTableCompanion.insert(
                id: id,
                scenarioId: scenarioId,
                strategy: strategy,
                extraMonthlyAmountCents: extraMonthlyAmountCents,
                extraPaymentCadence: extraPaymentCadence,
                customOrderJson: customOrderJson,
                lastRecastAt: lastRecastAt,
                projectedDebtFreeDate: projectedDebtFreeDate,
                totalInterestProjectedCents: totalInterestProjectedCents,
                totalInterestSavedCents: totalInterestSavedCents,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlansTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlansTableTable,
      PlanRow,
      $$PlansTableTableFilterComposer,
      $$PlansTableTableOrderingComposer,
      $$PlansTableTableAnnotationComposer,
      $$PlansTableTableCreateCompanionBuilder,
      $$PlansTableTableUpdateCompanionBuilder,
      (PlanRow, BaseReferences<_$AppDatabase, $PlansTableTable, PlanRow>),
      PlanRow,
      PrefetchHooks Function()
    >;
typedef $$UserSettingsTableTableCreateCompanionBuilder =
    UserSettingsTableCompanion Function({
      Value<String> id,
      Value<int> trustLevel,
      Value<String?> firebaseUid,
      Value<String> currencyCode,
      Value<String> localeCode,
      Value<String> dayCountConvention,
      Value<bool> notifPaymentReminder,
      Value<int> notifPaymentReminderDaysBefore,
      Value<bool> notifMilestone,
      Value<bool> notifMonthlyLog,
      Value<int> onboardingStep,
      Value<bool> onboardingCompleted,
      Value<DateTime?> onboardingCompletedAt,
      Value<bool> isPremium,
      Value<DateTime?> premiumExpiresAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserSettingsTableTableUpdateCompanionBuilder =
    UserSettingsTableCompanion Function({
      Value<String> id,
      Value<int> trustLevel,
      Value<String?> firebaseUid,
      Value<String> currencyCode,
      Value<String> localeCode,
      Value<String> dayCountConvention,
      Value<bool> notifPaymentReminder,
      Value<int> notifPaymentReminderDaysBefore,
      Value<bool> notifMilestone,
      Value<bool> notifMonthlyLog,
      Value<int> onboardingStep,
      Value<bool> onboardingCompleted,
      Value<DateTime?> onboardingCompletedAt,
      Value<bool> isPremium,
      Value<DateTime?> premiumExpiresAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trustLevel => $composableBuilder(
    column: $table.trustLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firebaseUid => $composableBuilder(
    column: $table.firebaseUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayCountConvention => $composableBuilder(
    column: $table.dayCountConvention,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifPaymentReminder => $composableBuilder(
    column: $table.notifPaymentReminder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifPaymentReminderDaysBefore => $composableBuilder(
    column: $table.notifPaymentReminderDaysBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifMilestone => $composableBuilder(
    column: $table.notifMilestone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifMonthlyLog => $composableBuilder(
    column: $table.notifMonthlyLog,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get onboardingStep => $composableBuilder(
    column: $table.onboardingStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
  get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isPremium => $composableBuilder(
    column: $table.isPremium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
  get premiumExpiresAt => $composableBuilder(
    column: $table.premiumExpiresAt,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$UserSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trustLevel => $composableBuilder(
    column: $table.trustLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firebaseUid => $composableBuilder(
    column: $table.firebaseUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayCountConvention => $composableBuilder(
    column: $table.dayCountConvention,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifPaymentReminder => $composableBuilder(
    column: $table.notifPaymentReminder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifPaymentReminderDaysBefore => $composableBuilder(
    column: $table.notifPaymentReminderDaysBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifMilestone => $composableBuilder(
    column: $table.notifMilestone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifMonthlyLog => $composableBuilder(
    column: $table.notifMonthlyLog,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get onboardingStep => $composableBuilder(
    column: $table.onboardingStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPremium => $composableBuilder(
    column: $table.isPremium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get premiumExpiresAt => $composableBuilder(
    column: $table.premiumExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get trustLevel => $composableBuilder(
    column: $table.trustLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firebaseUid => $composableBuilder(
    column: $table.firebaseUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dayCountConvention => $composableBuilder(
    column: $table.dayCountConvention,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifPaymentReminder => $composableBuilder(
    column: $table.notifPaymentReminder,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notifPaymentReminderDaysBefore => $composableBuilder(
    column: $table.notifPaymentReminderDaysBefore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifMilestone => $composableBuilder(
    column: $table.notifMilestone,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifMonthlyLog => $composableBuilder(
    column: $table.notifMonthlyLog,
    builder: (column) => column,
  );

  GeneratedColumn<int> get onboardingStep => $composableBuilder(
    column: $table.onboardingStep,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, String>
  get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPremium =>
      $composableBuilder(column: $table.isPremium, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get premiumExpiresAt =>
      $composableBuilder(
        column: $table.premiumExpiresAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTableTable,
          UserSettingsRow,
          $$UserSettingsTableTableFilterComposer,
          $$UserSettingsTableTableOrderingComposer,
          $$UserSettingsTableTableAnnotationComposer,
          $$UserSettingsTableTableCreateCompanionBuilder,
          $$UserSettingsTableTableUpdateCompanionBuilder,
          (
            UserSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $UserSettingsTableTable,
              UserSettingsRow
            >,
          ),
          UserSettingsRow,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableTableManager(
    _$AppDatabase db,
    $UserSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> trustLevel = const Value.absent(),
                Value<String?> firebaseUid = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> localeCode = const Value.absent(),
                Value<String> dayCountConvention = const Value.absent(),
                Value<bool> notifPaymentReminder = const Value.absent(),
                Value<int> notifPaymentReminderDaysBefore =
                    const Value.absent(),
                Value<bool> notifMilestone = const Value.absent(),
                Value<bool> notifMonthlyLog = const Value.absent(),
                Value<int> onboardingStep = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<DateTime?> onboardingCompletedAt = const Value.absent(),
                Value<bool> isPremium = const Value.absent(),
                Value<DateTime?> premiumExpiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsTableCompanion(
                id: id,
                trustLevel: trustLevel,
                firebaseUid: firebaseUid,
                currencyCode: currencyCode,
                localeCode: localeCode,
                dayCountConvention: dayCountConvention,
                notifPaymentReminder: notifPaymentReminder,
                notifPaymentReminderDaysBefore: notifPaymentReminderDaysBefore,
                notifMilestone: notifMilestone,
                notifMonthlyLog: notifMonthlyLog,
                onboardingStep: onboardingStep,
                onboardingCompleted: onboardingCompleted,
                onboardingCompletedAt: onboardingCompletedAt,
                isPremium: isPremium,
                premiumExpiresAt: premiumExpiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> trustLevel = const Value.absent(),
                Value<String?> firebaseUid = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> localeCode = const Value.absent(),
                Value<String> dayCountConvention = const Value.absent(),
                Value<bool> notifPaymentReminder = const Value.absent(),
                Value<int> notifPaymentReminderDaysBefore =
                    const Value.absent(),
                Value<bool> notifMilestone = const Value.absent(),
                Value<bool> notifMonthlyLog = const Value.absent(),
                Value<int> onboardingStep = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<DateTime?> onboardingCompletedAt = const Value.absent(),
                Value<bool> isPremium = const Value.absent(),
                Value<DateTime?> premiumExpiresAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsTableCompanion.insert(
                id: id,
                trustLevel: trustLevel,
                firebaseUid: firebaseUid,
                currencyCode: currencyCode,
                localeCode: localeCode,
                dayCountConvention: dayCountConvention,
                notifPaymentReminder: notifPaymentReminder,
                notifPaymentReminderDaysBefore: notifPaymentReminderDaysBefore,
                notifMilestone: notifMilestone,
                notifMonthlyLog: notifMonthlyLog,
                onboardingStep: onboardingStep,
                onboardingCompleted: onboardingCompleted,
                onboardingCompletedAt: onboardingCompletedAt,
                isPremium: isPremium,
                premiumExpiresAt: premiumExpiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTableTable,
      UserSettingsRow,
      $$UserSettingsTableTableFilterComposer,
      $$UserSettingsTableTableOrderingComposer,
      $$UserSettingsTableTableAnnotationComposer,
      $$UserSettingsTableTableCreateCompanionBuilder,
      $$UserSettingsTableTableUpdateCompanionBuilder,
      (
        UserSettingsRow,
        BaseReferences<_$AppDatabase, $UserSettingsTableTable, UserSettingsRow>,
      ),
      UserSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$MilestonesTableTableCreateCompanionBuilder =
    MilestonesTableCompanion Function({
      required String id,
      Value<String> scenarioId,
      required MilestoneType type,
      Value<String?> debtId,
      required DateTime achievedAt,
      Value<bool> seen,
      Value<String?> metadata,
      required DateTime createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$MilestonesTableTableUpdateCompanionBuilder =
    MilestonesTableCompanion Function({
      Value<String> id,
      Value<String> scenarioId,
      Value<MilestoneType> type,
      Value<String?> debtId,
      Value<DateTime> achievedAt,
      Value<bool> seen,
      Value<String?> metadata,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$MilestonesTableTableReferences
    extends BaseReferences<_$AppDatabase, $MilestonesTableTable, MilestoneRow> {
  $$MilestonesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DebtsTableTable _debtIdTable(_$AppDatabase db) =>
      db.debtsTable.createAlias(
        $_aliasNameGenerator(db.milestonesTable.debtId, db.debtsTable.id),
      );

  $$DebtsTableTableProcessedTableManager? get debtId {
    final $_column = $_itemColumn<String>('debt_id');
    if ($_column == null) return null;
    final manager = $$DebtsTableTableTableManager(
      $_db,
      $_db.debtsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_debtIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MilestonesTableTableFilterComposer
    extends Composer<_$AppDatabase, $MilestonesTableTable> {
  $$MilestonesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MilestoneType, MilestoneType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get achievedAt =>
      $composableBuilder(
        column: $table.achievedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$DebtsTableTableFilterComposer get debtId {
    final $$DebtsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableFilterComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestonesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MilestonesTableTable> {
  $$MilestonesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DebtsTableTableOrderingComposer get debtId {
    final $$DebtsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableOrderingComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestonesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MilestonesTableTable> {
  $$MilestonesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MilestoneType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get achievedAt =>
      $composableBuilder(
        column: $table.achievedAt,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get seen =>
      $composableBuilder(column: $table.seen, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$DebtsTableTableAnnotationComposer get debtId {
    final $$DebtsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestonesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MilestonesTableTable,
          MilestoneRow,
          $$MilestonesTableTableFilterComposer,
          $$MilestonesTableTableOrderingComposer,
          $$MilestonesTableTableAnnotationComposer,
          $$MilestonesTableTableCreateCompanionBuilder,
          $$MilestonesTableTableUpdateCompanionBuilder,
          (MilestoneRow, $$MilestonesTableTableReferences),
          MilestoneRow,
          PrefetchHooks Function({bool debtId})
        > {
  $$MilestonesTableTableTableManager(
    _$AppDatabase db,
    $MilestonesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MilestonesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MilestonesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MilestonesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scenarioId = const Value.absent(),
                Value<MilestoneType> type = const Value.absent(),
                Value<String?> debtId = const Value.absent(),
                Value<DateTime> achievedAt = const Value.absent(),
                Value<bool> seen = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilestonesTableCompanion(
                id: id,
                scenarioId: scenarioId,
                type: type,
                debtId: debtId,
                achievedAt: achievedAt,
                seen: seen,
                metadata: metadata,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> scenarioId = const Value.absent(),
                required MilestoneType type,
                Value<String?> debtId = const Value.absent(),
                required DateTime achievedAt,
                Value<bool> seen = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilestonesTableCompanion.insert(
                id: id,
                scenarioId: scenarioId,
                type: type,
                debtId: debtId,
                achievedAt: achievedAt,
                seen: seen,
                metadata: metadata,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MilestonesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({debtId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (debtId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.debtId,
                                referencedTable:
                                    $$MilestonesTableTableReferences
                                        ._debtIdTable(db),
                                referencedColumn:
                                    $$MilestonesTableTableReferences
                                        ._debtIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MilestonesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MilestonesTableTable,
      MilestoneRow,
      $$MilestonesTableTableFilterComposer,
      $$MilestonesTableTableOrderingComposer,
      $$MilestonesTableTableAnnotationComposer,
      $$MilestonesTableTableCreateCompanionBuilder,
      $$MilestonesTableTableUpdateCompanionBuilder,
      (MilestoneRow, $$MilestonesTableTableReferences),
      MilestoneRow,
      PrefetchHooks Function({bool debtId})
    >;
typedef $$InterestRateHistoryTableTableCreateCompanionBuilder =
    InterestRateHistoryTableCompanion Function({
      required String id,
      required String debtId,
      required Decimal apr,
      required DateTime effectiveFrom,
      Value<DateTime?> effectiveTo,
      Value<String?> reason,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$InterestRateHistoryTableTableUpdateCompanionBuilder =
    InterestRateHistoryTableCompanion Function({
      Value<String> id,
      Value<String> debtId,
      Value<Decimal> apr,
      Value<DateTime> effectiveFrom,
      Value<DateTime?> effectiveTo,
      Value<String?> reason,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$InterestRateHistoryTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InterestRateHistoryTableTable,
          InterestRateHistoryRow
        > {
  $$InterestRateHistoryTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DebtsTableTable _debtIdTable(_$AppDatabase db) =>
      db.debtsTable.createAlias(
        $_aliasNameGenerator(
          db.interestRateHistoryTable.debtId,
          db.debtsTable.id,
        ),
      );

  $$DebtsTableTableProcessedTableManager get debtId {
    final $_column = $_itemColumn<String>('debt_id')!;

    final manager = $$DebtsTableTableTableManager(
      $_db,
      $_db.debtsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_debtIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InterestRateHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $InterestRateHistoryTableTable> {
  $$InterestRateHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get apr =>
      $composableBuilder(
        column: $table.apr,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String>
  get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get effectiveTo =>
      $composableBuilder(
        column: $table.effectiveTo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$DebtsTableTableFilterComposer get debtId {
    final $$DebtsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableFilterComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InterestRateHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $InterestRateHistoryTableTable> {
  $$InterestRateHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apr => $composableBuilder(
    column: $table.apr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveTo => $composableBuilder(
    column: $table.effectiveTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DebtsTableTableOrderingComposer get debtId {
    final $$DebtsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableOrderingComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InterestRateHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $InterestRateHistoryTableTable> {
  $$InterestRateHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal, String> get apr =>
      $composableBuilder(column: $table.apr, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get effectiveFrom =>
      $composableBuilder(
        column: $table.effectiveFrom,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, String> get effectiveTo =>
      $composableBuilder(
        column: $table.effectiveTo,
        builder: (column) => column,
      );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$DebtsTableTableAnnotationComposer get debtId {
    final $$DebtsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debtsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.debtsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InterestRateHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InterestRateHistoryTableTable,
          InterestRateHistoryRow,
          $$InterestRateHistoryTableTableFilterComposer,
          $$InterestRateHistoryTableTableOrderingComposer,
          $$InterestRateHistoryTableTableAnnotationComposer,
          $$InterestRateHistoryTableTableCreateCompanionBuilder,
          $$InterestRateHistoryTableTableUpdateCompanionBuilder,
          (InterestRateHistoryRow, $$InterestRateHistoryTableTableReferences),
          InterestRateHistoryRow,
          PrefetchHooks Function({bool debtId})
        > {
  $$InterestRateHistoryTableTableTableManager(
    _$AppDatabase db,
    $InterestRateHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InterestRateHistoryTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InterestRateHistoryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InterestRateHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> debtId = const Value.absent(),
                Value<Decimal> apr = const Value.absent(),
                Value<DateTime> effectiveFrom = const Value.absent(),
                Value<DateTime?> effectiveTo = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterestRateHistoryTableCompanion(
                id: id,
                debtId: debtId,
                apr: apr,
                effectiveFrom: effectiveFrom,
                effectiveTo: effectiveTo,
                reason: reason,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String debtId,
                required Decimal apr,
                required DateTime effectiveFrom,
                Value<DateTime?> effectiveTo = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterestRateHistoryTableCompanion.insert(
                id: id,
                debtId: debtId,
                apr: apr,
                effectiveFrom: effectiveFrom,
                effectiveTo: effectiveTo,
                reason: reason,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InterestRateHistoryTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({debtId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (debtId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.debtId,
                                referencedTable:
                                    $$InterestRateHistoryTableTableReferences
                                        ._debtIdTable(db),
                                referencedColumn:
                                    $$InterestRateHistoryTableTableReferences
                                        ._debtIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InterestRateHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InterestRateHistoryTableTable,
      InterestRateHistoryRow,
      $$InterestRateHistoryTableTableFilterComposer,
      $$InterestRateHistoryTableTableOrderingComposer,
      $$InterestRateHistoryTableTableAnnotationComposer,
      $$InterestRateHistoryTableTableCreateCompanionBuilder,
      $$InterestRateHistoryTableTableUpdateCompanionBuilder,
      (InterestRateHistoryRow, $$InterestRateHistoryTableTableReferences),
      InterestRateHistoryRow,
      PrefetchHooks Function({bool debtId})
    >;
typedef $$SyncStateTableTableCreateCompanionBuilder =
    SyncStateTableCompanion Function({
      required String tableSyncName,
      Value<DateTime?> lastPulledAt,
      Value<DateTime?> lastPushedAt,
      Value<int> pendingWrites,
      Value<String?> lastSyncError,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncStateTableTableUpdateCompanionBuilder =
    SyncStateTableCompanion Function({
      Value<String> tableSyncName,
      Value<DateTime?> lastPulledAt,
      Value<DateTime?> lastPushedAt,
      Value<int> pendingWrites,
      Value<String?> lastSyncError,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTableTable> {
  $$SyncStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tableSyncName => $composableBuilder(
    column: $table.tableSyncName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
  get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
  get lastPushedAt => $composableBuilder(
    column: $table.lastPushedAt,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get pendingWrites => $composableBuilder(
    column: $table.pendingWrites,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$SyncStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTableTable> {
  $$SyncStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tableSyncName => $composableBuilder(
    column: $table.tableSyncName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPushedAt => $composableBuilder(
    column: $table.lastPushedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingWrites => $composableBuilder(
    column: $table.pendingWrites,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTableTable> {
  $$SyncStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tableSyncName => $composableBuilder(
    column: $table.tableSyncName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, String> get lastPulledAt =>
      $composableBuilder(
        column: $table.lastPulledAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, String> get lastPushedAt =>
      $composableBuilder(
        column: $table.lastPushedAt,
        builder: (column) => column,
      );

  GeneratedColumn<int> get pendingWrites => $composableBuilder(
    column: $table.pendingWrites,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncStateTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTableTable,
          SyncStateRow,
          $$SyncStateTableTableFilterComposer,
          $$SyncStateTableTableOrderingComposer,
          $$SyncStateTableTableAnnotationComposer,
          $$SyncStateTableTableCreateCompanionBuilder,
          $$SyncStateTableTableUpdateCompanionBuilder,
          (
            SyncStateRow,
            BaseReferences<_$AppDatabase, $SyncStateTableTable, SyncStateRow>,
          ),
          SyncStateRow,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableTableManager(
    _$AppDatabase db,
    $SyncStateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tableSyncName = const Value.absent(),
                Value<DateTime?> lastPulledAt = const Value.absent(),
                Value<DateTime?> lastPushedAt = const Value.absent(),
                Value<int> pendingWrites = const Value.absent(),
                Value<String?> lastSyncError = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateTableCompanion(
                tableSyncName: tableSyncName,
                lastPulledAt: lastPulledAt,
                lastPushedAt: lastPushedAt,
                pendingWrites: pendingWrites,
                lastSyncError: lastSyncError,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tableSyncName,
                Value<DateTime?> lastPulledAt = const Value.absent(),
                Value<DateTime?> lastPushedAt = const Value.absent(),
                Value<int> pendingWrites = const Value.absent(),
                Value<String?> lastSyncError = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncStateTableCompanion.insert(
                tableSyncName: tableSyncName,
                lastPulledAt: lastPulledAt,
                lastPushedAt: lastPushedAt,
                pendingWrites: pendingWrites,
                lastSyncError: lastSyncError,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTableTable,
      SyncStateRow,
      $$SyncStateTableTableFilterComposer,
      $$SyncStateTableTableOrderingComposer,
      $$SyncStateTableTableAnnotationComposer,
      $$SyncStateTableTableCreateCompanionBuilder,
      $$SyncStateTableTableUpdateCompanionBuilder,
      (
        SyncStateRow,
        BaseReferences<_$AppDatabase, $SyncStateTableTable, SyncStateRow>,
      ),
      SyncStateRow,
      PrefetchHooks Function()
    >;
typedef $$TimelineCacheTableTableCreateCompanionBuilder =
    TimelineCacheTableCompanion Function({
      required String planId,
      required int monthIndex,
      required String yearMonth,
      required String entriesJson,
      required int totalPaymentCents,
      required int totalInterestCents,
      required int totalBalanceEndCents,
      required DateTime generatedAt,
      Value<int> rowid,
    });
typedef $$TimelineCacheTableTableUpdateCompanionBuilder =
    TimelineCacheTableCompanion Function({
      Value<String> planId,
      Value<int> monthIndex,
      Value<String> yearMonth,
      Value<String> entriesJson,
      Value<int> totalPaymentCents,
      Value<int> totalInterestCents,
      Value<int> totalBalanceEndCents,
      Value<DateTime> generatedAt,
      Value<int> rowid,
    });

class $$TimelineCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $TimelineCacheTableTable> {
  $$TimelineCacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthIndex => $composableBuilder(
    column: $table.monthIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get yearMonth => $composableBuilder(
    column: $table.yearMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entriesJson => $composableBuilder(
    column: $table.entriesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPaymentCents => $composableBuilder(
    column: $table.totalPaymentCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalInterestCents => $composableBuilder(
    column: $table.totalInterestCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBalanceEndCents => $composableBuilder(
    column: $table.totalBalanceEndCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get generatedAt =>
      $composableBuilder(
        column: $table.generatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$TimelineCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TimelineCacheTableTable> {
  $$TimelineCacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthIndex => $composableBuilder(
    column: $table.monthIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get yearMonth => $composableBuilder(
    column: $table.yearMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entriesJson => $composableBuilder(
    column: $table.entriesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPaymentCents => $composableBuilder(
    column: $table.totalPaymentCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalInterestCents => $composableBuilder(
    column: $table.totalInterestCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBalanceEndCents => $composableBuilder(
    column: $table.totalBalanceEndCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimelineCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimelineCacheTableTable> {
  $$TimelineCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<int> get monthIndex => $composableBuilder(
    column: $table.monthIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get yearMonth =>
      $composableBuilder(column: $table.yearMonth, builder: (column) => column);

  GeneratedColumn<String> get entriesJson => $composableBuilder(
    column: $table.entriesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPaymentCents => $composableBuilder(
    column: $table.totalPaymentCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalInterestCents => $composableBuilder(
    column: $table.totalInterestCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBalanceEndCents => $composableBuilder(
    column: $table.totalBalanceEndCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get generatedAt =>
      $composableBuilder(
        column: $table.generatedAt,
        builder: (column) => column,
      );
}

class $$TimelineCacheTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimelineCacheTableTable,
          TimelineCacheRow,
          $$TimelineCacheTableTableFilterComposer,
          $$TimelineCacheTableTableOrderingComposer,
          $$TimelineCacheTableTableAnnotationComposer,
          $$TimelineCacheTableTableCreateCompanionBuilder,
          $$TimelineCacheTableTableUpdateCompanionBuilder,
          (
            TimelineCacheRow,
            BaseReferences<
              _$AppDatabase,
              $TimelineCacheTableTable,
              TimelineCacheRow
            >,
          ),
          TimelineCacheRow,
          PrefetchHooks Function()
        > {
  $$TimelineCacheTableTableTableManager(
    _$AppDatabase db,
    $TimelineCacheTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimelineCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimelineCacheTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimelineCacheTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> planId = const Value.absent(),
                Value<int> monthIndex = const Value.absent(),
                Value<String> yearMonth = const Value.absent(),
                Value<String> entriesJson = const Value.absent(),
                Value<int> totalPaymentCents = const Value.absent(),
                Value<int> totalInterestCents = const Value.absent(),
                Value<int> totalBalanceEndCents = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimelineCacheTableCompanion(
                planId: planId,
                monthIndex: monthIndex,
                yearMonth: yearMonth,
                entriesJson: entriesJson,
                totalPaymentCents: totalPaymentCents,
                totalInterestCents: totalInterestCents,
                totalBalanceEndCents: totalBalanceEndCents,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String planId,
                required int monthIndex,
                required String yearMonth,
                required String entriesJson,
                required int totalPaymentCents,
                required int totalInterestCents,
                required int totalBalanceEndCents,
                required DateTime generatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TimelineCacheTableCompanion.insert(
                planId: planId,
                monthIndex: monthIndex,
                yearMonth: yearMonth,
                entriesJson: entriesJson,
                totalPaymentCents: totalPaymentCents,
                totalInterestCents: totalInterestCents,
                totalBalanceEndCents: totalBalanceEndCents,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimelineCacheTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimelineCacheTableTable,
      TimelineCacheRow,
      $$TimelineCacheTableTableFilterComposer,
      $$TimelineCacheTableTableOrderingComposer,
      $$TimelineCacheTableTableAnnotationComposer,
      $$TimelineCacheTableTableCreateCompanionBuilder,
      $$TimelineCacheTableTableUpdateCompanionBuilder,
      (
        TimelineCacheRow,
        BaseReferences<
          _$AppDatabase,
          $TimelineCacheTableTable,
          TimelineCacheRow
        >,
      ),
      TimelineCacheRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DebtsTableTableTableManager get debtsTable =>
      $$DebtsTableTableTableManager(_db, _db.debtsTable);
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db, _db.paymentsTable);
  $$PlansTableTableTableManager get plansTable =>
      $$PlansTableTableTableManager(_db, _db.plansTable);
  $$UserSettingsTableTableTableManager get userSettingsTable =>
      $$UserSettingsTableTableTableManager(_db, _db.userSettingsTable);
  $$MilestonesTableTableTableManager get milestonesTable =>
      $$MilestonesTableTableTableManager(_db, _db.milestonesTable);
  $$InterestRateHistoryTableTableTableManager get interestRateHistoryTable =>
      $$InterestRateHistoryTableTableTableManager(
        _db,
        _db.interestRateHistoryTable,
      );
  $$SyncStateTableTableTableManager get syncStateTable =>
      $$SyncStateTableTableTableManager(_db, _db.syncStateTable);
  $$TimelineCacheTableTableTableManager get timelineCacheTable =>
      $$TimelineCacheTableTableTableManager(_db, _db.timelineCacheTable);
}
