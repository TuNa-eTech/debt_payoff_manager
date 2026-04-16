# Data Schema — Drift Tables

> Schema chi tiết cho local database Drift. Mỗi table có: columns, constraints, indexes, invariants DB-level, và mapping sang domain model.
> **Reference:** financial-engine-spec.md §3 (conceptual model), architecture-decisions.md (ADR-004, 005, 006, 007, 008, 014).
> **Quy ước đặt tên:** snake_case trong DB, camelCase trong Dart (Drift tự convert).

---

## Mục lục

1. [Convention chung](#1-convention-chung)
2. [Type Converters](#2-type-converters)
3. [Table: debts](#3-table-debts)
4. [Table: payments](#4-table-payments)
5. [Table: plans](#5-table-plans)
6. [Table: interest_rate_history](#6-table-interest_rate_history)
7. [Table: user_settings](#7-table-user_settings)
8. [Table: milestones](#8-table-milestones) — progress & motivation tracking
9. [Table: sync_state](#9-table-sync_state)
10. [Table: timeline_cache](#10-table-timeline_cache) — local only, không sync
11. [Indexes](#11-indexes)
12. [Invariants & Constraints](#12-invariants--constraints)
13. [Migration strategy](#13-migration-strategy)
14. [Domain Model Mapping](#14-domain-model-mapping)
15. [Design Notes](#15-design-notes)

---

## 1. Convention chung

### Columns mặc định ở mọi table sync được

| Column | Type | Note |
|---|---|---|
| `id` | TEXT PRIMARY KEY | UUID v4 — ADR-005 |
| `created_at` | TEXT NOT NULL | ISO-8601 UTC — ADR-008 |
| `updated_at` | TEXT NOT NULL | ISO-8601 UTC, set on every write |
| `deleted_at` | TEXT | NULL = active, non-NULL = soft deleted — ADR-006 |
| `scenario_id` | TEXT NOT NULL DEFAULT 'main' | ADR-014 — cho What-If Tier 2 |

Các table không sync (`timeline_cache`, `sync_state`) không có `scenario_id`.

### Money columns

- Tất cả lưu `INTEGER` cents — ADR-004
- Tên column phải có suffix `_cents` để rõ unit: `balance_cents`, `minimum_payment_cents`
- Drift type: `IntColumn`

### Decimal (non-money) columns

- Lưu `TEXT` dạng Decimal string (VD `"0.1899"`)
- Drift type: `TextColumn` với `TypeConverter<Decimal, String>`
- Dùng cho: APR, percent fields

### Enum columns

- Lưu `TEXT` (string name) — ADR-007
- Drift type: `TextColumn` với `TypeConverter<EnumType, String>`

### Date vs Timestamp

- **Timestamp** (point-in-time): `TEXT` ISO-8601 UTC với 'Z' suffix (VD `"2026-04-16T08:52:00.000Z"`)
- **Date** (calendar day): `TEXT` ISO-8601 date only (VD `"2026-04-16"`)

---

## 2. Type Converters

Drift `TypeConverter` bridges giữa SQL types và Dart types. Định nghĩa một lần, reuse khắp nơi.

```dart
// Decimal ↔ String
class DecimalConverter extends TypeConverter<Decimal, String> {
  const DecimalConverter();
  @override
  Decimal fromSql(String v) => Decimal.parse(v);
  @override
  String toSql(Decimal v) => v.toString();
}

// DateTime (UTC) ↔ String
class UtcDateTimeConverter extends TypeConverter<DateTime, String> {
  const UtcDateTimeConverter();
  @override
  DateTime fromSql(String v) => DateTime.parse(v).toUtc();
  @override
  String toSql(DateTime v) => v.toUtc().toIso8601String();
}

// Date (local calendar) ↔ String
class LocalDateConverter extends TypeConverter<DateTime, String> {
  const LocalDateConverter();
  @override
  DateTime fromSql(String v) => DateTime.parse(v); // keep local
  @override
  String toSql(DateTime v) => v.toIso8601String().substring(0, 10); // YYYY-MM-DD
}

// Enum ↔ String (generic, one per enum)
class DebtTypeConverter extends TypeConverter<DebtType, String> {
  const DebtTypeConverter();
  @override
  DebtType fromSql(String v) => DebtType.values.byName(v);
  @override
  String toSql(DebtType v) => v.name;
}
// (Lặp lại cho DebtStatus, Strategy, PaymentType, ... — codegen được nếu cần)
```

---

## 3. Table: `debts`

Entity chính — 1 row = 1 khoản nợ của user.

```dart
class Debts extends Table {
  // Identity & sync
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get scenarioId => text().withDefault(const Constant('main'))();
  
  // Basic info
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get type => text().map(const DebtTypeConverter())();
  
  // Money (cents)
  IntColumn get originalPrincipalCents => integer().check(originalPrincipalCents.isBiggerThanValue(0))();
  IntColumn get currentBalanceCents => integer().check(currentBalanceCents.isBiggerOrEqualValue(0))();
  
  // Interest
  TextColumn get apr => text().map(const DecimalConverter())();  // "0.1899"
  TextColumn get interestMethod => text().map(const InterestMethodConverter())();
  
  // Minimum payment
  IntColumn get minimumPaymentCents => integer().withDefault(const Constant(0))();
  TextColumn get minimumPaymentType => text().map(const MinPaymentTypeConverter())();
  TextColumn get minimumPaymentPercent => text().nullable().map(const DecimalConverter().asNullable())();
  IntColumn get minimumPaymentFloorCents => integer().nullable()();
  
  // Schedule
  TextColumn get paymentCadence => text().map(const CadenceConverter())();
  IntColumn get dueDayOfMonth => integer().nullable()
    .check(dueDayOfMonth.isBetweenValues(1, 31))();
  TextColumn get firstDueDate => text().map(const LocalDateConverter())();
  
  // Lifecycle
  TextColumn get status => text().map(const DebtStatusConverter())();
  TextColumn get pausedUntil => text().nullable().map(const LocalDateConverter().asNullable())();
  
  // Strategy
  IntColumn get priority => integer().nullable()();
  BoolColumn get excludeFromStrategy => boolean().withDefault(const Constant(false))();
  
  // Audit
  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().map(const UtcDateTimeConverter())();
  TextColumn get paidOffAt => text().nullable().map(const UtcDateTimeConverter().asNullable())();
  TextColumn get deletedAt => text().nullable().map(const UtcDateTimeConverter().asNullable())();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

### Enums

```dart
enum DebtType { creditCard, studentLoan, carLoan, mortgage, personal, medical, other }
enum DebtStatus { active, paidOff, archived, paused }
enum InterestMethod { simpleMonthly, compoundDaily, compoundMonthly }
enum MinPaymentType { fixed, percentOfBalance, interestPlusPercent }
enum Cadence { monthly, biweekly, weekly, semimonthly }
```

### Row-level invariants (enforced ở repository, không phải DB CHECK)

- Nếu `minimumPaymentType == percentOfBalance` → `minimumPaymentPercent` phải NOT NULL
- Nếu `minimumPaymentType == interestPlusPercent` → `minimumPaymentPercent` phải NOT NULL
- Nếu `status == paused` → `pausedUntil` phải NOT NULL
- `apr` phải nằm `[0, 1]` (0% đến 100%)
- `currentBalance <= originalPrincipal * 1.5` → warning (không reject)

---

## 4. Table: `payments`

Log payment thật (hoặc planned). Immutable sau khi log trừ khi edit.

```dart
class Payments extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get scenarioId => text().withDefault(const Constant('main'))();
  TextColumn get debtId => text().references(Debts, #id)();
  
  // Money (cents) — invariant: amount = principal + interest + fee
  IntColumn get amountCents => integer().check(amountCents.isBiggerThanValue(0))();
  IntColumn get principalPortionCents => integer()();
  IntColumn get interestPortionCents => integer()();
  IntColumn get feePortionCents => integer().withDefault(const Constant(0))();
  
  // Meta
  TextColumn get date => text().map(const LocalDateConverter())();  // ngày payment áp dụng
  TextColumn get type => text().map(const PaymentTypeConverter())();
  TextColumn get source => text().map(const PaymentSourceConverter())();
  TextColumn get note => text().nullable().withLength(max: 200)();
  TextColumn get status => text().map(const PaymentStatusConverter())();
  
  // Audit trail (snapshot, không update)
  IntColumn get appliedBalanceBeforeCents => integer()();
  IntColumn get appliedBalanceAfterCents => integer()();
  
  // Standard
  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().map(const UtcDateTimeConverter())();
  TextColumn get deletedAt => text().nullable().map(const UtcDateTimeConverter().asNullable())();
  
  @override
  Set<Column> get primaryKey => {id};
}

enum PaymentType { minimum, extra, lumpSum, fee, refund, charge }  // charge = balance tăng
enum PaymentSource { scheduled, manual, windfall, checkOff, import }
enum PaymentStatus { planned, completed, missed }
```

### Invariants (repository-level)

- `principalPortionCents + interestPortionCents + feePortionCents == amountCents`
- Ngoại lệ: `type == charge` → `principalPortionCents < 0` (balance tăng), chấp nhận
- `appliedBalanceAfterCents >= 0` trừ khi refund/charge
- `date <= today()` cho status=completed; `date >= today()` cho status=planned

### Monthly Action View — Design Decision (ADR-021)

Monthly scheduled payments **không pre-generate vào DB**. Thay vào đó, Monthly Action View **compute on-the-fly** danh sách "tháng này phải trả gì" từ active debts + plan:

- Khi user mở Monthly Action View: `compute_monthly_schedule(active_debts, plan)` → virtual list
- Khi user **check off** 1 payment → tạo `Payment` record mới với `source = checkOff`, `status = completed`
- Khi user chưa check off cuối tháng → **không tự tạo missed record**. App chỉ cảnh báo "bạn chưa log payment cho [Debt X]"

**Lý do chọn on-the-fly thay vì pre-generate:**
- Đúng nguyên tắc Living Plan (recompute, không pre-generate static data)
- Không cần batch job đầu tháng → đơn giản hơn
- Khi edit debt/plan → monthly view tự cập nhật, không cần cleanup planned records cũ
- Idempotent: mở view 10 lần không tạo duplicate planned payments

---

## 5. Table: `plans`

Singleton per scenario (main scenario có 1 plan; what-if scenarios mỗi cái 1 plan).

```dart
class Plans extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get scenarioId => text().withDefault(const Constant('main'))();
  
  // Strategy
  TextColumn get strategy => text().map(const StrategyConverter())();
  IntColumn get extraMonthlyAmountCents => integer().withDefault(const Constant(0))();
  TextColumn get extraPaymentCadence => text().map(const CadenceConverter())();
  
  // Custom ordering (JSON array of debt IDs)
  TextColumn get customOrderJson => text().nullable()();  // '["uuid1", "uuid2"]'
  
  // Cached compute (recomputed on recast)
  TextColumn get lastRecastAt => text().map(const UtcDateTimeConverter())();
  TextColumn get projectedDebtFreeDate => text().nullable()
    .map(const LocalDateConverter().asNullable())();
  IntColumn get totalInterestProjectedCents => integer().nullable()();
  IntColumn get totalInterestSavedCents => integer().nullable()();
  
  // Standard
  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().map(const UtcDateTimeConverter())();
  TextColumn get deletedAt => text().nullable().map(const UtcDateTimeConverter().asNullable())();
  
  @override
  Set<Column> get primaryKey => {id};
}

enum Strategy { snowball, avalanche, custom }
```

### Invariants

- Exactly 1 Plan per scenarioId (enforce qua unique index)
- Nếu `strategy == custom` → `customOrderJson` phải NOT NULL
- `extraMonthlyAmountCents >= 0`

---

## 6. Table: `interest_rate_history`

Lưu lịch sử thay đổi APR của 1 debt (cho promo rate, refinance) — Tier 2 feature 2.2.

```dart
class InterestRateHistories extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get debtId => text().references(Debts, #id)();
  
  TextColumn get apr => text().map(const DecimalConverter())();
  TextColumn get effectiveFrom => text().map(const LocalDateConverter())();
  TextColumn get effectiveTo => text().nullable().map(const LocalDateConverter().asNullable())();
  TextColumn get reason => text().nullable().withLength(max: 120)();
  
  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().map(const UtcDateTimeConverter())();
  TextColumn get deletedAt => text().nullable().map(const UtcDateTimeConverter().asNullable())();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

### Invariants

- `effectiveTo == NULL` = rate hiện tại đang active
- Chỉ tối đa 1 row có `effectiveTo IS NULL` per debt
- `effectiveFrom < effectiveTo` khi cả 2 non-null
- Ranges không được overlap per debt

### Query pattern: lấy APR cho tháng cụ thể

```sql
SELECT apr FROM interest_rate_history
WHERE debt_id = ?
  AND deleted_at IS NULL
  AND effective_from <= ?
  AND (effective_to IS NULL OR effective_to > ?)
ORDER BY effective_from DESC
LIMIT 1
```

---

## 7. Table: `user_settings`

Singleton per user — UI preferences, notification settings, trust level.

```dart
class UserSettings extends Table {
  TextColumn get id => text().withDefault(const Constant('singleton'))();  // PK luôn là 'singleton'
  
  // Trust level (ADR-003)
  IntColumn get trustLevel => integer().withDefault(const Constant(0))();  // 0, 1, 2
  TextColumn get firebaseUid => text().nullable()();  // non-null khi Level >= 1
  
  // Display
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  TextColumn get localeCode => text().withDefault(const Constant('en-US'))();
  TextColumn get dayCountConvention => text().withDefault(const Constant('actual365'))();
  
  // Notifications
  // Note: notifPaymentReminderDaysBefore là single int, user chọn 1 trong {1, 3, 7}.
  // MVP giữ simple — nếu user feedback yêu cầu multiple reminders, extend thành JSON array sau.
  BoolColumn get notifPaymentReminder => boolean().withDefault(const Constant(true))();
  IntColumn get notifPaymentReminderDaysBefore => integer().withDefault(const Constant(3))();
  BoolColumn get notifMilestone => boolean().withDefault(const Constant(true))();
  BoolColumn get notifMonthlyLog => boolean().withDefault(const Constant(true))();
  
  // Onboarding
  // onboardingStep tracks resume point nếu user thoát giữa chừng.
  // 0=not started, 1=welcome seen, 2=first debt entered, 3=strategy selected,
  // 4=extra amount set, 5=completed. Khi step=5, onboardingCompleted=true.
  IntColumn get onboardingStep => integer().withDefault(const Constant(0))();
  BoolColumn get onboardingCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get onboardingCompletedAt => text().nullable().map(const UtcDateTimeConverter().asNullable())();
  
  // Premium
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();
  TextColumn get premiumExpiresAt => text().nullable().map(const UtcDateTimeConverter().asNullable())();
  
  // Standard
  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().map(const UtcDateTimeConverter())();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

### Invariants

- Chỉ 1 row duy nhất với `id = 'singleton'`
- `trustLevel >= 1` → `firebaseUid` phải NOT NULL
- `trustLevel == 2` → `firebaseUid` NOT NULL AND từ email provider (không anonymous)

---

## 8. Table: `milestones`

Tracking user achievements và progress celebrations — Feature §2.3.

```dart
class Milestones extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get scenarioId => text().withDefault(const Constant('main'))();
  
  // Milestone info
  TextColumn get type => text().map(const MilestoneTypeConverter())();
  TextColumn get debtId => text().nullable().references(Debts, #id)();  // nullable: vài milestone là global
  TextColumn get achievedAt => text().map(const UtcDateTimeConverter())();
  BoolColumn get seen => boolean().withDefault(const Constant(false))();  // user đã dismiss notification chưa
  TextColumn get metadata => text().nullable()();  // JSON: VD {"savedAmount": 1580, "months": 6}
  
  // Standard
  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();
  TextColumn get deletedAt => text().nullable().map(const UtcDateTimeConverter().asNullable())();
  
  @override
  Set<Column> get primaryKey => {id};
}

enum MilestoneType {
  debtPaidOff,        // 1 khoản nợ trả xong
  percentComplete25,  // 25% tổng hành trình
  percentComplete50,  // 50%
  percentComplete75,  // 75%
  allDebtFree,        // 100% — hết nợ!
  streakMonths3,      // 3 tháng liên tiếp trả đúng hạn
  streakMonths6,      // 6 tháng
  streakMonths12,     // 12 tháng
  interestSaved1000,  // tiết kiệm $1,000 lãi
  interestSaved5000,  // tiết kiệm $5,000 lãi
  firstPayment,       // log payment đầu tiên
}
```

### Invariants

- Mỗi `(type, debtId)` pair tối đa 1 lần achieve (trừ `debtPaidOff` với debt IDs khác nhau)
- `achievedAt` phải <= now
- `debtId` NOT NULL cho `debtPaidOff`, nullable cho global milestones

### Streak tracking

Streak (số tháng liên tiếp trả đúng hạn) **compute on-the-fly** từ payment history, không lưu column riêng:

```sql
-- Kiểm tra tháng N có completed payment cho debt X
SELECT COUNT(*) > 0 FROM payments
WHERE debt_id = ? AND status = 'completed'
  AND date >= ? AND date < ?  -- month range
  AND deleted_at IS NULL
```

Khi streak đạt threshold (3, 6, 12) → tạo milestone record. Milestone service check sau mỗi payment log.

---

## 9. Table: `sync_state`

Metadata cho delta sync — local only, không sync lên cloud.

```dart
class SyncState extends Table {
  TextColumn get tableName => text()();  // 'debts', 'payments', ...
  TextColumn get lastPulledAt => text().nullable().map(const UtcDateTimeConverter().asNullable())();
  TextColumn get lastPushedAt => text().nullable().map(const UtcDateTimeConverter().asNullable())();
  IntColumn get pendingWrites => integer().withDefault(const Constant(0))();
  TextColumn get lastSyncError => text().nullable()();
  TextColumn get updatedAt => text().map(const UtcDateTimeConverter())();
  
  @override
  Set<Column> get primaryKey => {tableName};
}
```

---

## 10. Table: `timeline_cache`

Cache cho compute-heavy timeline projection. **Local only, không sync** — recompute sau mỗi thay đổi (ADR-011).

```dart
class TimelineCache extends Table {
  TextColumn get planId => text()();
  IntColumn get monthIndex => integer()();  // 0 = current month
  TextColumn get yearMonth => text()();  // "2026-04"
  TextColumn get entriesJson => text()();  // JSON serialized [DebtMonthEntry]
  IntColumn get totalPaymentCents => integer()();
  IntColumn get totalInterestCents => integer()();
  IntColumn get totalBalanceEndCents => integer()();
  TextColumn get generatedAt => text().map(const UtcDateTimeConverter())();
  
  @override
  Set<Column> get primaryKey => {planId, monthIndex};
}
```

### Invalidation rule

Khi `debts`, `payments`, `plans`, `interest_rate_history` thay đổi (trong cùng scenario) → xóa toàn bộ rows trong `timeline_cache` cho scenario đó, recompute lazy.

---

## 11. Indexes

```sql
-- debts
CREATE INDEX idx_debts_scenario_status ON debts(scenario_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_debts_updated_at ON debts(updated_at) WHERE deleted_at IS NULL;

-- payments
CREATE INDEX idx_payments_debt_date ON payments(debt_id, date) WHERE deleted_at IS NULL;
CREATE INDEX idx_payments_scenario_date ON payments(scenario_id, date) WHERE deleted_at IS NULL;
CREATE INDEX idx_payments_updated_at ON payments(updated_at) WHERE deleted_at IS NULL;

-- plans
CREATE UNIQUE INDEX idx_plans_scenario ON plans(scenario_id) WHERE deleted_at IS NULL;

-- interest_rate_history
CREATE INDEX idx_irh_debt_range ON interest_rate_history(debt_id, effective_from, effective_to);

-- milestones
CREATE INDEX idx_milestones_type ON milestones(type, seen) WHERE deleted_at IS NULL;
CREATE INDEX idx_milestones_debt ON milestones(debt_id) WHERE deleted_at IS NULL;

-- timeline_cache
CREATE INDEX idx_tc_plan_month ON timeline_cache(plan_id, month_index);
```

### Lý do chọn index

- `debts(scenario_id, status)`: query chính "lấy active debts của main scenario"
- `payments(debt_id, date)`: query "payment history của debt X theo ngày"
- `payments(scenario_id, date)`: query "payments tháng này của main scenario"
- `*_updated_at`: delta sync `WHERE updated_at > lastSyncTime`
- `plans(scenario_id) UNIQUE`: enforce 1-plan-per-scenario invariant
- `milestones(type, seen)`: query "unseen milestones" cho celebration UI
- `milestones(debt_id)`: query "milestones cho debt cụ thể"

---

## 12. Invariants & Constraints

### DB-level (CHECK constraints, UNIQUE indexes)

| Invariant | Cơ chế |
|---|---|
| `apr` trong `[0, 1]` | CHECK tại Drift table |
| `due_day_of_month` trong `[1, 31]` | CHECK tại Drift table |
| `*_cents` >= 0 (trừ `principal_portion_cents`) | CHECK tại Drift table |
| 1 plan per scenario | UNIQUE INDEX partial |
| 1 UserSettings singleton | PK = 'singleton' constant |

### Repository-level (enforce trong Dart code trước khi write)

| Invariant | Lý do không đưa vào DB |
|---|---|
| `amount == principal + interest + fee` | Phụ thuộc multiple columns, cross-column CHECK phức tạp |
| Conditional NOT NULL (VD `minimumPaymentType == percentOfBalance` → `minimumPaymentPercent` NOT NULL) | SQLite không hỗ trợ conditional CHECK thanh lịch |
| InterestRateHistory ranges không overlap | Cần query trước khi insert |
| TimelineCache freshness | Logic thuộc business layer |
| Milestone uniqueness (`type` + `debtId` pair) | Business logic, cần query trước khi insert |
| `onboardingStep` trong `[0, 5]` và consistent với `onboardingCompleted` | Cross-column dependency |

### Application-level (runtime warnings, không block)

| Warning | Reference |
|---|---|
| `currentBalance > originalPrincipal × 1.5` | Engine spec §11.2 |
| `apr > 0.36` | Engine spec §11.2 |
| `minimum_payment < monthly_interest` | Engine spec §11.2 |

---

## 13. Migration strategy

### Versioning

```dart
@DriftDatabase(tables: [Debts, Payments, Plans, InterestRateHistories, UserSettings, Milestones, SyncState, TimelineCache])
class AppDatabase extends _$AppDatabase {
  @override
  int get schemaVersion => 1;  // v1 = initial MVP schema
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {
      // future migrations here
    },
    beforeOpen: (details) async {
      if (details.wasCreated) {
        // seed initial UserSettings singleton + main Plan
        await into(userSettings).insert(UserSettingsCompanion.insert(
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ));
      }
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
```

### Version history (anticipated)

| Version | Changes | Target release |
|---|---|---|
| 1 | Initial MVP schema (8 tables, including `milestones`) | v1.0 |
| 2 | Add `debts.pause_reason`, `debts.pause_accrues_interest` | v1.x Tier 2 forbearance |
| 3 | Add `scenarios` table (upgrade from `scenario_id` TEXT column) | v2.0 What-If full |
| 4 | Add `shared_plans` + partner fields (Firestore-only, xem Design Note §15.2) | v2.x Partner Sharing |

### Verification (CI)

Sau mỗi release:
```bash
dart run drift_dev schema dump lib/data/database.dart drift_schemas/
```
→ commit `drift_schemas/` into git. CI chạy migration test từ mỗi version cũ lên head.

---

## 14. Domain Model Mapping

Drift row classes **không expose ra domain/UI** — ADR-018. Repository layer convert sang domain model.

### Example: Debt

```dart
// Domain model (pure Dart, no Drift import)
class Debt {
  final String id;
  final String scenarioId;
  final String name;
  final DebtType type;
  final Money originalPrincipal;  // wrapper class cho cents
  final Money currentBalance;
  final Decimal apr;
  final InterestMethod interestMethod;
  final MinimumPaymentConfig minimumPayment;
  final PaymentSchedule schedule;
  final DebtStatus status;
  final DateTime? pausedUntil;
  final int? priority;
  final bool excludeFromStrategy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidOffAt;
  
  const Debt({...});
  
  // Computed
  bool get isPaused => status == DebtStatus.paused;
  bool get isActive => status == DebtStatus.active;
  Money monthlyInterest(Decimal rate) => ...;  // delegates to FinancialEngine
}

// Money value object (prevents accidentally mixing with raw int)
class Money {
  final int cents;
  const Money.cents(this.cents);
  Money.dollars(num dollars) : cents = (dollars * 100).round();
  
  Decimal toDecimal() => Decimal.fromInt(cents) / Decimal.fromInt(100);
  String toString() => '\$${(cents / 100).toStringAsFixed(2)}';
  
  Money operator +(Money other) => Money.cents(cents + other.cents);
  Money operator -(Money other) => Money.cents(cents - other.cents);
  // ...
}
```

### Mapper

```dart
extension DebtMapper on DebtsData {
  Debt toDomain() => Debt(
    id: id,
    scenarioId: scenarioId,
    name: name,
    type: type,
    originalPrincipal: Money.cents(originalPrincipalCents),
    currentBalance: Money.cents(currentBalanceCents),
    apr: apr,
    // ...
  );
}

extension DebtCompanionFromDomain on Debt {
  DebtsCompanion toCompanion() => DebtsCompanion(
    id: Value(id),
    scenarioId: Value(scenarioId),
    name: Value(name),
    type: Value(type),
    originalPrincipalCents: Value(originalPrincipal.cents),
    // ...
  );
}
```

### Repository boundary example

```dart
class DebtRepository {
  final AppDatabase _db;
  DebtRepository(this._db);
  
  Stream<List<Debt>> watchActiveDebts({String scenarioId = 'main'}) {
    return (_db.select(_db.debts)
          ..where((d) => d.scenarioId.equals(scenarioId))
          ..where((d) => d.status.equals(DebtStatus.active.name))
          ..where((d) => d.deletedAt.isNull()))
        .watch()
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }
  
  Future<void> addDebt(Debt debt) async {
    _validateInvariants(debt);  // app-level checks
    await _db.into(_db.debts).insert(debt.toCompanion());
    // TimelineCache invalidate sẽ trigger qua Drift stream chain
  }
  
  void _validateInvariants(Debt d) {
    if (d.apr < Decimal.zero || d.apr > Decimal.one) {
      throw InvalidDebtException('APR must be between 0 and 1');
    }
    if (d.minimumPayment.type == MinPaymentType.percentOfBalance &&
        d.minimumPayment.percent == null) {
      throw InvalidDebtException('percent required for percentOfBalance type');
    }
    // ...
  }
}
```

---

## Summary — File layout trong lib/

```
lib/
├── data/
│   ├── database.dart                 # AppDatabase with @DriftDatabase
│   ├── tables/
│   │   ├── debts.dart
│   │   ├── payments.dart
│   │   ├── plans.dart
│   │   ├── interest_rate_history.dart
│   │   ├── user_settings.dart
│   │   ├── milestones.dart
│   │   ├── sync_state.dart
│   │   └── timeline_cache.dart
│   ├── converters/
│   │   ├── decimal_converter.dart
│   │   ├── datetime_converters.dart
│   │   └── enum_converters.dart
│   └── repositories/
│       ├── debt_repository.dart
│       ├── payment_repository.dart
│       ├── plan_repository.dart
│       ├── milestone_repository.dart
│       └── settings_repository.dart
├── domain/
│   ├── models/
│   │   ├── debt.dart
│   │   ├── payment.dart
│   │   ├── plan.dart
│   │   ├── milestone.dart
│   │   └── money.dart
│   ├── engine/
│   │   ├── financial_engine.dart
│   │   ├── amortization.dart
│   │   ├── strategy.dart
│   │   └── timeline_simulator.dart
│   └── services/
│       └── milestone_service.dart    # check & award milestones sau mỗi payment
└── sync/
    ├── firestore_sync_service.dart
    ├── sync_queue.dart
    └── conflict_resolver.dart
```

---

## 15. Design Notes

Các design decisions bổ sung được ghi nhận trong quá trình review.

### 15.1 Monthly Action View — Computed, không Pre-generated

Xem chi tiết tại §4 Payments → "Monthly Action View — Design Decision".

Tóm tắt: scheduled payments cho Monthly Action View là **computed on-the-fly**, không tạo planned records trong DB trước. Khi user check off → tạo Payment record với `source = checkOff`.

### 15.2 Partner Sharing Data — Firestore Only

Partner/household sharing (Feature §2.4, ADR-003 Level 2) data **không lưu trong local Drift DB**:

- `sharedPlans/{planId}` — Firestore collection chứa owner UID, partner UIDs, permissions
- Partner access qua Firestore security rules, không replicate vào local
- **Lý do:** Sharing metadata chỉ relevant khi online. Local DB giữ đúng 1 user's data.
- Khi implement Tier 2.4: có thể thêm lightweight local cache cho partner display name/email, nhưng **không phải source of truth**.

### 15.3 Notification Reminder — Single Value MVP

`notifPaymentReminderDaysBefore` là single integer ({1, 3, 7}). Nếu user feedback yêu cầu multiple reminders (VD: cả 3 ngày VÀ 1 ngày trước), extend thành JSON array trong schema v2+.

### 15.4 Onboarding Step — Explicit Tracking

`onboardingStep` (0–5) cho phép resume onboarding flow nếu user thoát app giữa chừng. Kết hợp với `onboardingCompleted` boolean cho quick check.

---

> **Next step sau khi approve schema này:**
> 1. Viết `lib/data/database.dart` + tables theo spec này
> 2. Chạy `build_runner` sinh Drift code
> 3. Viết `DebtRepository` + unit test với in-memory DB
> 4. Song song: viết `FinancialEngine` theo financial-engine-spec.md với test vectors
