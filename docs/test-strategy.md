# Test Strategy — Correctness is a Feature

> Chiến lược test toàn diện cho Debt Payoff Manager. Với app tài chính, **sai 1 công thức = mất trust toàn bộ**.
> **Nguyên tắc:** Test là hàng rào cuối chống mất trust của user. Không compromise.
> **Reference:** financial-engine-spec.md §11, §12; architecture-decisions.md ADR-015, 016.

---

## Mục lục

1. [Test philosophy](#1-test-philosophy)
2. [Test pyramid](#2-test-pyramid)
3. [Test taxonomy](#3-test-taxonomy)
4. [Layer 1 — Unit tests](#4-layer-1--unit-tests)
5. [Layer 2 — Engine tests (golden + property-based)](#5-layer-2--engine-tests-golden--property-based)
6. [Layer 3 — Integration tests](#6-layer-3--integration-tests)
7. [Layer 4 — Widget tests](#7-layer-4--widget-tests)
8. [Layer 5 — End-to-end tests](#8-layer-5--end-to-end-tests)
9. [Layer 6 — Manual QA & UAT](#9-layer-6--manual-qa--uat)
10. [Specialty: Firestore rules tests](#10-specialty-firestore-rules-tests)
11. [Specialty: Migration tests](#11-specialty-migration-tests)
12. [Specialty: Performance tests](#12-specialty-performance-tests)
13. [Coverage targets](#13-coverage-targets)
14. [CI pipeline](#14-ci-pipeline)
15. [Regression prevention](#15-regression-prevention)
16. [Bug handling protocol](#16-bug-handling-protocol)

---

## 1. Test philosophy

### Why test heavily?

1. **Financial correctness có tính catastrophic** — 1 user phát hiện debt-free date lệch 2 tháng → review 1⭐, app chết
2. **Math không self-evident** — reviewer không verify được công thức bằng mắt; chỉ test mới bắt được
3. **Refactoring sẽ xảy ra** — không có test suite = không dám refactor = codebase rotten
4. **Multi-device sync có race conditions** — chỉ test suite với Firebase emulator mới cover được
5. **Living Plan means every state transition matters** — nhiều trạng thái, nhiều edge case

### Testing mindset

- **Test the contract, not the implementation** — refactor không break test
- **Fail loud, fail early** — test phải fail với message rõ cause
- **Tests are docs** — test name như spec: `should_rollover_extra_to_next_debt_when_priority_paid_off_midmonth`
- **Cheap tests abundance, expensive tests judgment** — viết nhiều unit test, ít e2e
- **Write tests for bugs before fixing** — regression protection

### Non-negotiables

- [ ] Financial engine có 100% test coverage cho public API
- [ ] Mọi bug fix có test đi kèm (regression test)
- [ ] CI green = requirement cho PR merge (không bypass)
- [ ] Property-based tests chạy ≥ 1000 iterations mỗi build
- [ ] Test vectors pass trước khi ship mọi release

---

## 2. Test pyramid

```
                        ▲
                       / \
                      /   \
                     / E2E \           ~10 tests      | Slow, fragile, expensive
                    /───────\                         | Critical user journeys only
                   /Integration\       ~50 tests      | Drift + Engine + Sync
                  /─────────────\
                 /  Widget Tests  \    ~100 tests     | UI rendering + state
                /───────────────── \
               /    Unit Tests       \  ~500+ tests   | Fast, granular
              /───────────────────────\
             / Engine: Golden + Prop-  \ ~50 + ∞      | Critical accuracy
            /         based              \
           /─────────────────────────────\
```

### Distribution targets

| Layer | Count target | Runtime target | When runs |
|---|---|---|---|
| Engine golden + property | 50 golden + ∞ property | < 30s | Every commit |
| Unit tests | 500+ | < 20s | Every commit |
| Widget tests | 100 | < 60s | Every commit |
| Integration tests | 50 | < 3min | Every commit |
| Firestore rules tests | 30 | < 30s | Every commit |
| Migration tests | 10 | < 30s | Every commit |
| E2E tests | 10 | < 15min | Pre-release + nightly |
| Performance tests | 5 | < 5min | Nightly |
| Manual QA | checklist | varies | Pre-release |

**Total CI time budget:** < 10 min per push (tight loop for dev flow).

---

## 3. Test taxonomy

### By layer

- **Unit** — pure functions, domain logic, mappers
- **Integration** — DB + repository + engine wiring
- **Widget** — Flutter UI component rendering + interaction
- **E2E** — full app flow through multiple screens

### By concern

- **Correctness** — does it compute right?
- **Behavior** — does it do the right action on event?
- **State** — does state transition correctly?
- **Performance** — does it stay within budget?
- **Security** — can only authorized user access data?
- **Resilience** — does it recover from failures?

### By technique

- **Example-based** — specific input → expected output
- **Property-based** — invariant holds for ANY input (randomized)
- **Golden** — snapshot of output, flag changes
- **Mutation testing** — verify tests catch introduced bugs

---

## 4. Layer 1 — Unit tests

### Scope

- Pure functions trong `lib/domain/`
- Mappers giữa Drift row ↔ domain model
- Money, Decimal wrappers
- Validators (invariants, business rules)
- Utility functions

### Tech stack

- `flutter_test` (built-in)
- `mocktail` cho mocking (preferred over `mockito`, cleaner API)
- `test_coverage` cho measurement

### Example: Money value object

```dart
// test/domain/models/money_test.dart
void main() {
  group('Money', () {
    test('constructs from cents', () {
      expect(Money.cents(12345).cents, 12345);
    });
    
    test('constructs from dollars with rounding', () {
      expect(Money.dollars(123.456).cents, 12346); // round half up
      expect(Money.dollars(123.454).cents, 12345);
    });
    
    test('addition', () {
      expect(Money.cents(100) + Money.cents(250), Money.cents(350));
    });
    
    test('subtraction never goes negative unexpectedly', () {
      expect(
        () => Money.cents(100).subtractClamp(Money.cents(500)),
        returnsNormally,
      );
      expect(Money.cents(100).subtractClamp(Money.cents(500)), Money.zero);
    });
    
    test('decimal conversion preserves precision', () {
      final m = Money.cents(12345);
      expect(m.toDecimal(), Decimal.parse('123.45'));
    });
    
    test('toString formats with locale', () {
      expect(Money.cents(123456).format('en-US'), '\$1,234.56');
      expect(Money.cents(123456).format('vi-VN'), '1.234,56 \$');
    });
  });
}
```

### Example: Debt validator

```dart
// test/domain/validators/debt_validator_test.dart
void main() {
  group('DebtValidator', () {
    test('rejects negative APR', () {
      final debt = _buildDebt(apr: Decimal.parse('-0.01'));
      expect(
        () => DebtValidator.validate(debt),
        throwsA(isA<InvalidDebtException>()),
      );
    });
    
    test('rejects APR > 100%', () {
      final debt = _buildDebt(apr: Decimal.parse('1.5'));
      expect(
        () => DebtValidator.validate(debt),
        throwsA(isA<InvalidDebtException>()),
      );
    });
    
    test('accepts 0% APR (promo rate)', () {
      final debt = _buildDebt(apr: Decimal.zero);
      expect(() => DebtValidator.validate(debt), returnsNormally);
    });
    
    test('requires minimumPaymentPercent when type is percentOfBalance', () {
      final debt = _buildDebt(
        minimumPaymentType: MinPaymentType.percentOfBalance,
        minimumPaymentPercent: null,
      );
      expect(
        () => DebtValidator.validate(debt),
        throwsA(isA<InvalidDebtException>()),
      );
    });
    
    test('requires pausedUntil when status is paused', () {
      final debt = _buildDebt(status: DebtStatus.paused, pausedUntil: null);
      expect(
        () => DebtValidator.validate(debt),
        throwsA(isA<InvalidDebtException>()),
      );
    });
  });
}
```

### Rules

- **Pure functions preferred** — easier to test
- **One assertion per test** — diagnostic clarity
- **Arrange-Act-Assert** — explicit structure
- **Test names describe behavior** — not the method name
- **Helpers for fixtures** — `_buildDebt(...)`, `_buildPayment(...)` for brevity

---

## 5. Layer 2 — Engine tests (golden + property-based)

### Why a dedicated layer

Financial engine is **the** component where correctness matters most. Treat it as a separate concern with its own test approach.

### 5.1 Golden tests (test vectors)

Each formula in financial-engine-spec has a matching golden test. Hard-coded input → fixed expected output.

```dart
// test/domain/engine/amortization_test.dart

/// Test Vector TV-1 from financial-engine-spec §12
test('TV-1: standard amortization $10k @ 6% / 60 months', () {
  final result = AmortizationEngine.fixedPayment(
    principal: Money.dollars(10000),
    apr: Decimal.parse('0.06'),
    termMonths: 60,
  );
  
  // Expected from authoritative source (Excel PMT function)
  expect(result.monthlyPayment, Money.dollars(193.33));
  expect(result.totalInterest, Money.dollars(1599.68));
  expect(result.totalPaid, Money.dollars(11599.68));
});

/// Test Vector TV-2: credit card minimum payment trap
test('TV-2: credit card minimum only payoff', () {
  final debt = _buildDebt(
    balance: Money.dollars(5000),
    apr: Decimal.parse('0.1999'),
    minimumPaymentType: MinPaymentType.interestPlusPercent,
    minimumPaymentPercent: Decimal.parse('0.01'),
    minimumPaymentFloor: Money.dollars(25),
  );
  
  final result = TimelineSimulator.simulate(
    debts: [debt],
    plan: _buildPlan(extraMonthlyAmount: Money.zero),
  );
  
  expect(result.months, inInclusiveRange(270, 275)); // ~272 months
  expect(result.totalInterest, closeToMoney(Money.dollars(6923), tolerance: 50));
});
```

### 5.2 Property-based tests

Use `glados` package. Tests run 1000+ randomized scenarios per invariant.

```dart
// test/domain/engine/properties_test.dart
import 'package:glados/glados.dart';

void main() {
  group('FinancialEngine properties', () {
    
    /// Property 1: Monotonicity of extra payment
    /// Increasing extra monthly amount never makes debt-free date later.
    Glados2<List<DebtSpec>, int>(
      anyDebtSpecList,
      any.intInRange(0, 5000),
    ).test('more extra ≤ sooner debt-free', (debts, extraLow) {
      final extraHigh = extraLow + 100;
      
      final resultLow = TimelineSimulator.simulate(
        debts: debts.map(_toDomainDebt).toList(),
        plan: _buildPlan(extraMonthlyAmount: Money.dollars(extraLow)),
      );
      final resultHigh = TimelineSimulator.simulate(
        debts: debts.map(_toDomainDebt).toList(),
        plan: _buildPlan(extraMonthlyAmount: Money.dollars(extraHigh)),
      );
      
      expect(resultHigh.debtFreeMonth, lessThanOrEqualTo(resultLow.debtFreeMonth));
    });
    
    /// Property 2: Avalanche optimality
    /// Total interest(avalanche) ≤ total interest(snowball) for same inputs.
    Glados(anyDebtSpecList).test('avalanche total interest ≤ snowball', (debts) {
      final domainDebts = debts.map(_toDomainDebt).toList();
      
      final snowball = TimelineSimulator.simulate(
        debts: domainDebts,
        plan: _buildPlan(strategy: Strategy.snowball, extraMonthlyAmount: Money.dollars(100)),
      );
      final avalanche = TimelineSimulator.simulate(
        debts: domainDebts,
        plan: _buildPlan(strategy: Strategy.avalanche, extraMonthlyAmount: Money.dollars(100)),
      );
      
      expect(avalanche.totalInterest.cents, lessThanOrEqualTo(snowball.totalInterest.cents));
    });
    
    /// Property 3: Principal conservation
    /// Σ principal paid + Σ final balance == Σ initial balance
    Glados(anyDebtSpecList).test('principal conservation', (debts) {
      final domainDebts = debts.map(_toDomainDebt).toList();
      final initialTotal = domainDebts.fold<int>(
        0, (sum, d) => sum + d.currentBalance.cents,
      );
      
      final result = TimelineSimulator.simulate(
        debts: domainDebts,
        plan: _buildPlan(extraMonthlyAmount: Money.dollars(200)),
      );
      
      final totalPrincipalPaid = result.totalPrincipalPaid.cents;
      final finalBalance = result.finalBalance.cents;
      
      expect(totalPrincipalPaid + finalBalance, equals(initialTotal));
    });
    
    /// Property 4: Rollover correctness
    /// When debt A paid off mid-month, A's full payment appears in next priority
    /// within same month.
    Glados2<DebtSpec, DebtSpec>(
      anyDebtSpec,
      anyDebtSpec,
    ).test('rollover within same month', (aSpec, bSpec) {
      // Build so A is smaller balance (snowball priority)
      final a = _toDomainDebt(aSpec.copyWith(balance: 50));
      final b = _toDomainDebt(bSpec.copyWith(balance: 1000));
      
      final result = TimelineSimulator.simulate(
        debts: [a, b],
        plan: _buildPlan(
          strategy: Strategy.snowball,
          extraMonthlyAmount: Money.dollars(200), // enough to pay off A month 1
        ),
      );
      
      final month1 = result.months[0];
      final aEntry = month1.entriesFor(a.id);
      final bEntry = month1.entriesFor(b.id);
      
      expect(aEntry.endingBalance, Money.zero);
      expect(bEntry.paymentApplied, greaterThan(b.minimumPayment));
    });
    
    /// Property 5: Idempotency
    /// Running simulation twice with same inputs → same output
    Glados2<List<DebtSpec>, int>(
      anyDebtSpecList,
      any.intInRange(0, 1000),
    ).test('simulation is idempotent', (debts, extra) {
      final domainDebts = debts.map(_toDomainDebt).toList();
      final plan = _buildPlan(extraMonthlyAmount: Money.dollars(extra));
      
      final result1 = TimelineSimulator.simulate(debts: domainDebts, plan: plan);
      final result2 = TimelineSimulator.simulate(debts: domainDebts, plan: plan);
      
      expect(result1, equals(result2));
    });
  });
}
```

### 5.3 Generators (for property-based)

```dart
/// Generator: random DebtSpec with valid but diverse parameters
Generator<DebtSpec> get anyDebtSpec => any.combine6(
  any.stringOfLength(any.intInRange(1, 30)),          // name
  any.choose([...DebtType.values]),                   // type
  any.intInRange(100, 100000),                        // balance dollars
  any.decimalInRange(Decimal.zero, Decimal.parse('0.35')),  // apr 0-35%
  any.intInRange(25, 500),                            // min payment dollars
  any.intInRange(1, 28),                              // due day
  (name, type, balance, apr, minPay, day) => DebtSpec(
    name: name,
    type: type,
    balanceDollars: balance,
    apr: apr,
    minPaymentDollars: minPay,
    dueDay: day,
  ),
);

Generator<List<DebtSpec>> get anyDebtSpecList =>
  any.listWithLengthInRange(1, 10, anyDebtSpec);
```

### 5.4 Edge case tests (must-have examples)

- 0% APR debt
- Minimum payment < monthly interest (negative amortization → app warns)
- Balance tăng (new charge) mid-simulation
- All debts paid off in month 1 (large lump sum)
- Forbearance pause across multiple months
- Interest rate change mid-timeline
- 1 debt with $0.01 balance (rounding edge)
- 100 debts (stress test)
- 50-year mortgage (timeline length)
- Bi-weekly cadence (approximation accuracy)

---

## 6. Layer 3 — Integration tests

### Scope

- Drift DB + repositories (real DB, in-memory)
- Repositories + engine (end-to-end calculation from DB data)
- Sync engine + Firestore emulator

### Drift + Repository

```dart
// test/data/repositories/debt_repository_test.dart
void main() {
  late AppDatabase db;
  late DebtRepository repo;
  
  setUp(() {
    db = AppDatabase.inMemory();
    repo = DebtRepository(db);
  });
  
  tearDown(() => db.close());
  
  test('watchActiveDebts emits on insert', () async {
    final stream = repo.watchActiveDebts();
    final values = <List<Debt>>[];
    final sub = stream.listen(values.add);
    
    await Future.delayed(Duration.zero); // let first emit
    expect(values.first, isEmpty);
    
    await repo.addDebt(_buildDebt(name: 'Test'));
    await Future.delayed(Duration.zero);
    
    expect(values.last, hasLength(1));
    expect(values.last.first.name, 'Test');
    
    await sub.cancel();
  });
  
  test('soft delete hides from watchActiveDebts', () async {
    await repo.addDebt(_buildDebt(name: 'ToDelete'));
    final active = await repo.watchActiveDebts().first;
    expect(active, hasLength(1));
    
    await repo.softDelete(active.first.id);
    final activeAfter = await repo.watchActiveDebts().first;
    expect(activeAfter, isEmpty);
  });
  
  test('rejects debt with negative balance', () async {
    expect(
      () => repo.addDebt(_buildDebt(balance: Money.dollars(-100))),
      throwsA(isA<InvalidDebtException>()),
    );
  });
}
```

### Repository + Engine

```dart
test('engine receives live updates when debts change', () async {
  final debtRepo = DebtRepository(db);
  final planRepo = PlanRepository(db);
  final planService = PlanService(debtRepo, planRepo, TimelineSimulator());
  
  await debtRepo.addDebt(_buildDebt(balance: Money.dollars(1000)));
  await debtRepo.addDebt(_buildDebt(balance: Money.dollars(2000)));
  
  var projection = await planService.watchProjection().first;
  expect(projection.totalBalance, Money.dollars(3000));
  
  await debtRepo.addDebt(_buildDebt(balance: Money.dollars(500)));
  projection = await planService.watchProjection().first;
  expect(projection.totalBalance, Money.dollars(3500));
});
```

---

## 7. Layer 4 — Widget tests

### Scope

- Flutter widgets render correctly given state
- User interactions trigger correct callbacks
- State management integration (BLoC/Riverpod)

### Tech

- `flutter_test` + `golden_toolkit` for pixel snapshots
- Mock repositories via `mocktail`

### Example: Debt list widget

```dart
// test/ui/screens/debts/debt_list_screen_test.dart
void main() {
  testWidgets('shows empty state when no debts', (tester) async {
    final mockRepo = MockDebtRepository();
    when(() => mockRepo.watchActiveDebts())
        .thenAnswer((_) => Stream.value([]));
    
    await tester.pumpWidget(_wrapWithProviders(DebtListScreen(), repo: mockRepo));
    
    expect(find.text('Chưa có khoản nợ nào'), findsOneWidget);
    expect(find.text('Thêm khoản nợ đầu tiên'), findsOneWidget);
  });
  
  testWidgets('shows list of debts', (tester) async {
    final mockRepo = MockDebtRepository();
    when(() => mockRepo.watchActiveDebts()).thenAnswer(
      (_) => Stream.value([
        _buildDebt(name: 'Chase Sapphire', balance: Money.dollars(5000)),
        _buildDebt(name: 'Student Loan', balance: Money.dollars(20000)),
      ]),
    );
    
    await tester.pumpWidget(_wrapWithProviders(DebtListScreen(), repo: mockRepo));
    await tester.pumpAndSettle();
    
    expect(find.text('Chase Sapphire'), findsOneWidget);
    expect(find.text('\$5,000.00'), findsOneWidget);
    expect(find.text('Student Loan'), findsOneWidget);
    expect(find.text('\$20,000.00'), findsOneWidget);
  });
  
  testWidgets('tap FAB navigates to add debt screen', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(DebtListScreen()));
    
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    
    expect(find.byType(AddDebtScreen), findsOneWidget);
  });
}
```

### Golden tests

```dart
testGoldens('MonthlyActionView renders correctly', (tester) async {
  await loadAppFonts();
  final widget = MonthlyActionView(
    month: DateTime(2026, 4),
    schedule: _fixtureSchedule(),
  );
  
  await tester.pumpWidgetBuilder(widget);
  await screenMatchesGolden(tester, 'monthly_action_view_default');
});
```

### Accessibility tests

```dart
testWidgets('all interactive elements have semantic labels', (tester) async {
  await tester.pumpWidget(_wrapWithProviders(DebtListScreen()));
  
  final SemanticsHandle handle = tester.ensureSemantics();
  expect(tester.getSemantics(find.byType(FloatingActionButton)),
         matchesSemantics(label: 'Thêm khoản nợ mới'));
  handle.dispose();
});
```

---

## 8. Layer 5 — End-to-end tests

### Scope

Full app flows through multiple screens, real Drift DB (ephemeral), mocked or emulated Firebase.

### Tech

- `integration_test` package (Flutter official)
- Firebase Emulator Suite for Firestore/Auth
- Runs on real devices or simulators

### Critical flows to cover

| # | Flow | Rationale |
|---|---|---|
| 1 | Onboarding: 0 → aha moment | Most critical: conversion funnel |
| 2 | Add 3 debts, select strategy, see timeline | Core value prop |
| 3 | Log 3 payments, see balance update | Living Plan principle |
| 4 | Edit debt APR, verify recast | Trust in math |
| 5 | Monthly check-off → creates payment | UI → DB flow |
| 6 | Export CSV → verify content | Trust layer |
| 7 | Enable backup (L0 → L1) with emulator | Sync integrity |
| 8 | Disable backup (L1 → L0) | Downgrade path |
| 9 | Invite partner (L1 → L2) with emulator | Sharing flow |
| 10 | Offline log payments → come online → sync | Resilience |

### Example

```dart
// integration_test/onboarding_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('complete onboarding in < 5 minutes', (tester) async {
    final stopwatch = Stopwatch()..start();
    
    app.main();
    await tester.pumpAndSettle();
    
    // Welcome screen
    expect(find.text('Thêm khoản nợ đầu tiên'), findsOneWidget);
    await tester.tap(find.text('Thêm khoản nợ đầu tiên'));
    await tester.pumpAndSettle();
    
    // Guided debt entry
    await tester.enterText(find.byKey(Key('debt_name')), 'Chase Sapphire');
    await tester.enterText(find.byKey(Key('debt_balance')), '5000');
    await tester.enterText(find.byKey(Key('debt_apr')), '19.99');
    await tester.enterText(find.byKey(Key('debt_min_payment')), '50');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    
    // Skip adding more
    await tester.tap(find.text('Xem plan trước'));
    await tester.pumpAndSettle();
    
    // Strategy selection
    expect(find.textContaining('Snowball'), findsOneWidget);
    expect(find.textContaining('Avalanche'), findsOneWidget);
    await tester.tap(find.text('Chọn Avalanche'));
    await tester.pumpAndSettle();
    
    // Extra amount
    await tester.enterText(find.byKey(Key('extra_amount')), '100');
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    
    // Aha moment: Monthly Action View
    expect(find.textContaining('Tháng này bạn cần trả'), findsOneWidget);
    expect(find.textContaining('hết nợ vào'), findsOneWidget);
    
    stopwatch.stop();
    expect(stopwatch.elapsed, lessThan(Duration(minutes: 5)));
  });
}
```

### Running E2E

```bash
# iOS
flutter test integration_test --device-id=<iOS_sim_id>

# Android
flutter test integration_test --device-id=<Android_emu_id>

# Web (for future)
flutter test integration_test -d chrome
```

---

## 9. Layer 6 — Manual QA & UAT

### Exploratory testing

Not all bugs can be automated. Manual testing finds:
- UX awkwardness
- Visual glitches across device sizes
- Copy errors
- Workflow friction

### Test charter template

```
Charter: Explore [area] with [resources] to discover [info]
Duration: 30 min
Tester: [name]

Notes:
- ...

Bugs found:
- ...

Questions raised:
- ...
```

### Devices to cover (pre-release)

| Platform | Devices minimum |
|---|---|
| iOS | iPhone SE (small), iPhone 15 (std), iPhone 15 Pro Max (large), iPad mini |
| Android | Pixel 6, Samsung A-series, Xiaomi entry, Fold |
| OS versions | iOS 16 + latest, Android 11 + latest |

### UAT (User Acceptance Testing)

Before public ship:
- 5-10 real users recruited (non-technical)
- Given device with app pre-installed
- Asked to accomplish:
  1. Complete onboarding
  2. Add 3 debts
  3. See debt-free date
  4. Log 2 payments
  5. Export PDF
- Observe without coaching; log where they get stuck

**Ship criteria:** > 80% complete all 5 tasks without help.

---

## 10. Specialty: Firestore rules tests

### Why dedicated

Security rules bugs are **critical** — data leak catastrophic.

### Tech

- `@firebase/rules-unit-testing` (Node.js)
- Firebase Emulator Suite

### Test structure

```javascript
// test/firestore-rules/debts.rules.test.js
const { initializeTestEnvironment, assertSucceeds, assertFails } 
  = require('@firebase/rules-unit-testing');

describe('Debt security rules', () => {
  let testEnv;
  
  beforeAll(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: 'debt-payoff-test',
      firestore: { rules: fs.readFileSync('firestore.rules', 'utf8') },
    });
  });
  
  afterAll(() => testEnv.cleanup());
  
  it('user can read own debts', async () => {
    const alice = testEnv.authenticatedContext('alice').firestore();
    await assertSucceeds(
      alice.doc('users/alice/debts/debt1').get()
    );
  });
  
  it('user cannot read other user debts', async () => {
    const alice = testEnv.authenticatedContext('alice').firestore();
    await assertFails(
      alice.doc('users/bob/debts/debt1').get()
    );
  });
  
  it('unauthenticated cannot read any debt', async () => {
    const anon = testEnv.unauthenticatedContext().firestore();
    await assertFails(
      anon.doc('users/alice/debts/debt1').get()
    );
  });
  
  it('rejects debt with negative balance', async () => {
    const alice = testEnv.authenticatedContext('alice').firestore();
    await assertFails(
      alice.doc('users/alice/debts/bad').set({
        id: 'bad',
        name: 'Bad Debt',
        type: 'creditCard',
        originalPrincipalCents: 1000,
        currentBalanceCents: -100,  // invalid
        apr: '0.19',
        status: 'active',
        createdAt: new Date(),
        updatedAt: new Date(),
      })
    );
  });
  
  it('partner with readonly cannot write', async () => {
    // Setup sharedPlans with alice as owner, bob as readonly partner
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc('sharedPlans/plan1').set({
        ownerUid: 'alice',
        partnerUids: ['bob'],
        mode: 'readonly',
      });
      await ctx.firestore().doc('users/alice/debts/debt1').set({
        scenarioId: 'plan1',
        // ... valid debt fields
      });
    });
    
    const bob = testEnv.authenticatedContext('bob').firestore();
    await assertSucceeds(
      bob.doc('users/alice/debts/debt1').get()  // read OK
    );
    await assertFails(
      bob.doc('users/alice/debts/debt1').update({ name: 'Changed' })  // write denied
    );
  });
});
```

### Coverage requirement

Every rule branch + every collection + every action (read/create/update/delete) tested.

---

## 11. Specialty: Migration tests

### Why

Drift schema migrations can corrupt user data if incorrect. Migration bugs are unrecoverable for affected users.

### Approach (ADR-016)

- Commit schema snapshot after each release: `drift_schemas/v1/`, `drift_schemas/v2/`, ...
- CI job tests migration path `vN → vN+1` with seeded data

### Example

```dart
// test/data/migration/v1_to_v2_test.dart
void main() {
  late SchemaVerifier verifier;
  
  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });
  
  test('migrate v1 → v2 preserves debt data', () async {
    // Setup v1 DB with known data
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    
    await db.into(db.debts).insert(DebtsCompanion.insert(
      name: 'Chase',
      // ... v1 fields
    ));
    await db.close();
    
    // Migrate to v2
    final migratedConnection = await verifier.migrateAndValidate(
      AppDatabase(connection),
      2,
    );
    
    // Verify data preserved
    final migratedDb = AppDatabase(migratedConnection);
    final debts = await migratedDb.select(migratedDb.debts).get();
    expect(debts, hasLength(1));
    expect(debts.first.name, 'Chase');
    
    // Verify new v2 fields have sensible defaults
    expect(debts.first.pauseReason, isNull);  // hypothetical v2 field
  });
}
```

### Migration checklist (per release with schema change)

- [ ] Dump new schema snapshot: `dart run drift_dev schema dump`
- [ ] Write migration test `vN_to_vN+1_test.dart`
- [ ] Seed with realistic data (not just empty tables)
- [ ] Verify all invariants hold post-migration
- [ ] Run migration test in CI
- [ ] Document migration in release notes

---

## 12. Specialty: Performance tests

### Budgets (must hold)

| Operation | Target P95 |
|---|---|
| App cold start | < 2s |
| Screen transition | < 100ms |
| Simulate 10 debts × 60 months | < 50ms |
| Simulate 20 debts × 600 months (mortgage) | < 500ms |
| Debt insert + recast trigger | < 500ms |
| Payment log + balance update + recast | < 500ms |
| DB query: active debts list | < 20ms |
| Initial Firestore pull (100 docs) | < 3s |

### Measurement

```dart
// test/perf/engine_perf_test.dart
void main() {
  test('simulate 20 debts × 600 months', () {
    final debts = List.generate(20, (i) => _buildDebt(...));
    final plan = _buildPlan();
    
    final stopwatch = Stopwatch()..start();
    TimelineSimulator.simulate(debts: debts, plan: plan);
    stopwatch.stop();
    
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
  });
  
  test('DB query active debts stays fast with 1000 debts', () async {
    final db = AppDatabase.inMemory();
    final repo = DebtRepository(db);
    
    for (int i = 0; i < 1000; i++) {
      await repo.addDebt(_buildDebt(name: 'Debt $i'));
    }
    
    final stopwatch = Stopwatch()..start();
    await repo.watchActiveDebts().first;
    stopwatch.stop();
    
    expect(stopwatch.elapsedMilliseconds, lessThan(20));
  });
}
```

### Profiling

- `flutter run --profile` + DevTools Performance tab
- Measure cold start frame rasterization
- Memory profiler for leaks
- Run on **low-end device** (Pixel 3a or equivalent) as baseline

### CI integration

- Nightly performance test suite
- Track regressions over time (store metrics in time-series DB or simple CSV)
- Alert if P95 exceeds budget by > 20%

---

## 13. Coverage targets

### Target by layer

| Layer | Coverage target | Rationale |
|---|---|---|
| `lib/domain/engine/` | **100%** (line + branch) | Financial correctness non-negotiable |
| `lib/data/repositories/` | **≥ 90%** | Data integrity |
| `lib/data/` (tables, converters) | ≥ 80% | Framework-generated, less critical |
| `lib/sync/` | **≥ 90%** | Critical for multi-device users |
| `lib/ui/` (widgets) | ≥ 60% | Visual, partly covered by widget + e2e |
| `lib/ui/` (state management) | ≥ 80% | Logic around UI state |
| Overall | ≥ 80% | |

### Measurement tool

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Enforcement

- PR check: coverage may not decrease
- PR check: `lib/domain/engine/` must be 100%
- Quarterly review: identify untested critical paths

### What NOT to chase

- Generated code (Drift companions, `.g.dart` files)
- Trivial getters/setters
- Main.dart bootstrap

---

## 14. CI pipeline

### Pipeline stages

```
┌─────────────┐
│   Push / PR  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Lint &    │  < 30s
│   Format    │
└──────┬──────┘
       │
       ▼
┌───────────────────────┐
│  Unit + Engine tests  │  < 60s
│  (parallel shard 1)   │
└──────┬────────────────┘
       │
       ▼
┌───────────────────────┐
│  Integration tests    │  < 3min
│  (parallel shard 2)   │
│  + Firestore rules    │
└──────┬────────────────┘
       │
       ▼
┌───────────────────────┐
│  Widget tests         │  < 60s
│  (parallel shard 3)   │
└──────┬────────────────┘
       │
       ▼
┌───────────────────────┐
│  Coverage report      │  < 30s
│  + thresholds check   │
└──────┬────────────────┘
       │
       ▼
┌───────────────────────┐
│  Build iOS + Android  │  < 5min
│  (no sign for PR)     │
└──────┬────────────────┘
       │
       ▼
     GREEN → mergeable
```

### Nightly additions

- E2E tests (full suite)
- Performance tests
- Dependency audit
- Migration tests with synthetic aged data

### Pre-release

- Manual smoke test checklist
- UAT session
- Crashlytics review from beta

### Tools

- **GitHub Actions** (or equivalent): workflow
- **Codecov** or **Coveralls**: coverage tracking
- **Danger**: automated PR review (enforce test presence for new code)

### PR requirements

- [ ] CI green
- [ ] Coverage not decreased
- [ ] 2 approvers
- [ ] No new `@skip` or `@ignore` without justification
- [ ] Link to test(s) for new feature / fixed bug

---

## 15. Regression prevention

### Protocol for every bug

1. **Reproduce** bug in test first (failing test)
2. **Fix** code
3. **Verify** test now passes
4. **Commit** test + fix together
5. **Never** delete regression test (even if "too specific")

### Mutation testing (advanced)

Run periodically (not every commit — expensive):
```bash
dart run mutation_test
```

Introduces small code mutations (e.g., `>` → `>=`) and checks if tests catch them. Reveals weak tests.

### Code review checklist (for test coverage)

- [ ] New function has unit test?
- [ ] Edge cases covered? (null, empty, boundary, large)
- [ ] Error paths tested?
- [ ] Async timing covered?
- [ ] Integration with collaborators mocked or stubbed appropriately?

---

## 16. Bug handling protocol

### Severity levels

| Severity | Definition | Response time | Example |
|---|---|---|---|
| **P0 — Critical** | Data loss, money math wrong, sync breaks | < 4 hours | Debt-free date off by > 1 month due to engine bug |
| **P1 — High** | Core feature broken for many users | < 24 hours | Can't add debt on Android 14 |
| **P2 — Medium** | Feature degraded or broken for subset | < 1 week | Specific bank's min payment type calc wrong |
| **P3 — Low** | Cosmetic, inconvenience | Next sprint | Button alignment off |

### Bug → Fix cycle

```
1. User reports (or test catches)
2. Reproduce in test
3. Triage severity
4. Fix on branch
5. PR with test + fix
6. Code review
7. Merge
8. Deploy (hotfix if P0/P1)
9. Monitor (Crashlytics, user feedback)
10. Post-mortem if P0
```

### Post-mortem template (P0 only)

```markdown
# Post-mortem: [Bug title]
Date: YYYY-MM-DD
Severity: P0

## Impact
Users affected: X
Duration: X hours/days
Data affected: ...

## Timeline
- HH:MM — Reported by [source]
- HH:MM — Confirmed
- HH:MM — Fix merged
- HH:MM — Deployed

## Root cause
...

## What went well
...

## What went wrong
...

## Action items
- [ ] Add regression test (owner, due date)
- [ ] Improve alerting (owner, due date)
- [ ] Update process (owner, due date)
```

---

## Appendix A: Test file organization

```
test/
├── domain/
│   ├── models/
│   │   ├── money_test.dart
│   │   ├── debt_test.dart
│   │   └── ...
│   ├── engine/
│   │   ├── amortization_test.dart
│   │   ├── strategy_test.dart
│   │   ├── timeline_simulator_test.dart
│   │   ├── properties_test.dart    ← property-based
│   │   └── golden_vectors_test.dart ← test vectors
│   └── validators/
│       └── debt_validator_test.dart
├── data/
│   ├── converters/
│   │   └── decimal_converter_test.dart
│   ├── repositories/
│   │   ├── debt_repository_test.dart
│   │   └── ...
│   └── migration/
│       └── v1_to_v2_test.dart
├── sync/
│   ├── sync_engine_test.dart
│   ├── conflict_resolver_test.dart
│   └── push_queue_test.dart
├── ui/
│   ├── screens/
│   │   ├── debts/
│   │   │   └── debt_list_screen_test.dart
│   │   └── ...
│   └── widgets/
│       └── ...
├── perf/
│   ├── engine_perf_test.dart
│   └── db_perf_test.dart
├── fixtures/
│   ├── debt_fixtures.dart
│   └── plan_fixtures.dart
└── helpers/
    ├── test_db.dart
    └── widget_wrappers.dart

integration_test/
├── onboarding_flow_test.dart
├── debt_management_flow_test.dart
├── sync_flow_test.dart
└── sharing_flow_test.dart

test/firestore-rules/     ← JavaScript, separate
├── debts.rules.test.js
├── payments.rules.test.js
└── shared_plans.rules.test.js
```

---

## Appendix B: Gate-to-ship checklist

Before every public ship (v1.0, v1.1, ...):

### Automated
- [ ] All CI green on main
- [ ] Coverage ≥ 80% overall, 100% engine
- [ ] All property-based tests passed 1000+ iterations
- [ ] All migration tests passed
- [ ] Performance tests within budget
- [ ] E2E suite green on iOS + Android
- [ ] Firestore rules tests green

### Manual
- [ ] QA smoke test checklist completed
- [ ] UAT with ≥ 5 users, ≥ 80% success
- [ ] Crashlytics review of beta cohort (no new critical)
- [ ] Privacy audit: no PII in logs, analytics sanitized
- [ ] Accessibility audit: contrast, touch targets, screen reader
- [ ] Localization: no untranslated strings
- [ ] Release notes written

### Meta
- [ ] ADRs updated if new decisions made
- [ ] Test strategy doc updated if new patterns introduced
- [ ] Post-mortems completed for any P0 in previous cycle

---

> **Lời khuyên cho team:**
> - Viết test song song với code, không sau. Sau = never.
> - Test name là doc — đọc tên test phải hiểu được behavior
> - Khi test flaky, root-cause. Đừng retry hide bug.
> - Engine correctness > UI polish. Khi phải trade, hold engine line.
> - Property-based tests catch bugs example-based không catch được. Đầu tư.
