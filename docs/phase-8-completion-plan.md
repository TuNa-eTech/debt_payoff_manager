# Phase 8 Completion Plan — Power Features

**Goal:** Hoàn thiện Phase 8 (Power Features) để ship v1.2

**Timeline:** 4-5 tuần  
**Status:** 85% complete → 100%

---

## Summary

| Feature | Status | Effort | Notes |
|---------|--------|--------|-------|
| §2.1 What-If Scenarios | 🟡 80% | 1 day | Task 5 — fl_chart + scenario-aware cubit |
| §2.2 Forbearance/Pause | ✅ 100% | — | Task 1 — Done |
| §2.2 Interest Rate Change | 🟡 50% | deferred | Engine done; UI deferred to v1.3 |
| §2.2 New Charge (balance increase) | ✅ 100% | — | Task 3 — Done |
| §2.3 Monthly Summary | ✅ 100% | — | Task 4 — Pre-existing, verified |
| Property-based tests | 🔴 0% | 1 day | Task 6 — next |
| Full test suite | ✅ 100% | — | Task 7 — 276/276 green |
| **Total** | **85%** | **~2 days** | |

> **Note:** IAP gating moved to Phase 11 — Phase 8 sẽ ship toàn bộ power features free để đo adoption trước khi monetize.

---

## §2.1 What-If Scenarios (80% → 100%)

### ✅ Already Complete
- [x] `Scenario` entity + `ScenarioRepository`
- [x] `ScenariosCubit` + `ScenariosPage` (create, duplicate, delete, activate)
- [x] `CompareScenariosPage` (side-by-side comparison)
- [x] `copyDebtsToScenario()` method
- [x] DI wiring + tests

### 🔧 Remaining (2 days)

#### 1. Scenario-aware timeline computation (1 day)
**File:** `lib/features/plan/cubit/plan_timeline_cubit.dart`

**Current gap:** Timeline cubit chỉ compute cho active scenario, không có parameter để chọn scenario khác.

**Fix:**
```dart
// Add scenarioId parameter
class PlanTimelineCubit {
  Future<void> loadTimeline({String? scenarioId}) async {
    final targetScenarioId = scenarioId ?? state.activeScenarioId;
    final debts = await _debtRepository
        .getActiveDebts(scenarioId: targetScenarioId);
    // ... rest of compute
  }
}
```

**Test:** Widget test cho `TimelinePage` với scenario selector.

#### 2. Scenario comparison enhancements (1 day)
**File:** `lib/features/scenarios/presentation/pages/compare_scenarios_page.dart`

**Current gap:** So sánh chỉ hiển thị debt-free date và total interest, thiếu:
- Timeline chart visual (2 đường timeline song song)
- Monthly breakdown comparison
- "Difference" highlight (tiết kiệm bao nhiêu interest)

**Enhancement:**
```dart
// Add chart visualization
import 'package:fl_chart/fl_chart.dart';

LineChart(
  LineChartData(
    titlesData: FlTitlesData(show: true),
    lineBarsData: [
      LineChartBarData(
        spots: scenarioASpots, // (monthIndex, remainingBalance)
        color: AppColors.mdPrimary,
      ),
      LineChartBarData(
        spots: scenarioBSpots,
        color: AppColors.mdSecondary,
      ),
    ],
  ),
)
```

**Acceptance:**
- [ ] User có thể chọn 2 scenarios bất kỳ để so sánh
- [ ] Timeline chart hiển thị 2 đường với màu khác nhau
- [ ] Hiển thị delta: "Scenario B giúp hết nợ sớm hơn 3 tháng, tiết kiệm $1,234 interest"

---

## §2.2 Forbearance/Pause (50% → 100%)

### ✅ Already Complete
- [x] `DebtStatus.paused` enum
- [x] `pausedUntil` field trong `Debt` entity + DB table
- [x] `Debt.isPaused()` helper method
- [x] `DebtFormCubit` có `pausedUntil` state
- [x] `DebtFormFields` widget có pause date picker UI
- [x] `TimelineSimulator` skip paused debts trong simulation

### 🔧 Remaining (3 days)

#### 1. Pause debt action trong Debt Detail (1 day)
**File:** `lib/features/debts/presentation/pages/debt_detail_page.dart`

**Current gap:** Không có cách nào để pause debt từ UI ngoài edit form.

**Implementation:**
```dart
// Add "Pause payments" option trong DebtOptionsSheet
if (debt.status == DebtStatus.active) {
  _showPauseDialog(context);
} else if (debt.status == DebtStatus.paused) {
  _showResumeDialog(context);
}

void _showPauseDialog(BuildContext context) {
  showDialog(
    builder: (ctx) => AlertDialog(
      title: Text('Tạm dừng khoản nợ'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Chọn thời gian tạm dừng:'),
          DropdownButton<DateTime>(
            items: [
              DropdownMenuItem(value: DateTime.now().add(Duration(days: 30)), child: Text('1 tháng')),
              DropdownMenuItem(value: DateTime.now().add(Duration(days: 60)), child: Text('2 tháng')),
              DropdownMenuItem(value: DateTime.now().add(Duration(days: 90)), child: Text('3 tháng')),
            ],
            onChanged: (value) => _pauseDebt(value!),
          ),
        ],
      ),
    ),
  );
}
```

**Test:** Widget test cho pause dialog + integration test verify DB state.

#### 2. Resume from pause flow (1 day)
**File:** `lib/features/debts/presentation/pages/debts_list_page.dart`

**Current gap:** Không có indicator hoặc action để resume paused debts.

**Implementation:**
```dart
// Add "Paused" section trong DebtsListPage
final pausedDebts = debts.where((d) => d.status == DebtStatus.paused).toList();

if (pausedDebts.isNotEmpty) ...[
  _SectionHeader(title: 'Tạm dừng (${pausedDebts.length})'),
  ...pausedDebts.map((debt) => _PausedDebtCard(debt: debt)),
]

// _PausedDebtCard có "Resume" button
class _PausedDebtCard extends StatelessWidget {
  Widget build(BuildContext context) {
    final daysUntilResume = debt.pausedUntil!.difference(DateTime.now()).inDays;
    return AppCard(
      child: Row(
        children: [
          Icon(LucideIcons.pauseCircle, color: AppColors.mdOutline),
          Expanded(
            child: Column(
              children: [
                Text(debt.name),
                Text('Tự động resume vào ${formatDate(debt.pausedUntil!)}'),
                if (daysUntilResume <= 7)
                  Text('Sắp resume!', style: TextStyle(color: AppColors.mdError)),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () => _resumeDebt(context, debt),
            child: Text('Resume ngay'),
          ),
        ],
      ),
    );
  }
}
```

**Test:** Integration test: pause → resume → timeline recast.

#### 3. Engine: Handle paused debts trong Monthly Action (1 day)
**File:** `lib/core/services/monthly_action_service.dart`

**Current gap:** Monthly Action không hiển thị paused debts.

**Fix:**
```dart
// Add paused debts với different UI
final pausedItems = activeDebts
    .where((debt) => debt.isPaused(DateTime.now()))
    .map((debt) => MonthlyActionItem(
          debt: debt,
          type: MonthlyActionType.paused,
          subtitle: 'Tự động resume ${formatDate(debt.pausedUntil!)}',
        ))
    .toList();
```

**Acceptance:**
- [ ] Pause debt từ detail page → status chuyển sang Paused
- [ ] Paused debt xuất hiện trong "Tạm dừng" section ở Debts List
- [ ] Monthly Action không yêu cầu payment cho paused debts
- [ ] Resume debt → status về Active, xuất hiện lại trong Monthly Action

---

## §2.2 Interest Rate Change (20% → 100%)

### ✅ Already Complete
- [x] `InterestRateHistory` entity
- [x] `InterestRateHistoryTable` trong Drift
- [x] `InterestRateHistoryRepository` interface + implementation
- [x] Firestore sync serializer (`FirestoreInterestRateHistorySerializer`)

### 🔧 Remaining (4 days)

#### 1. Engine: Use rate history trong timeline simulation (2 days)
**File:** `lib/engine/timeline_simulator.dart`

**Current gap:** Simulator chỉ dùng `debt.apr` cố định, không check `InterestRateHistory`.

**Implementation:**
```dart
Decimal _getAprForMonth(Debt debt, DateTime monthDate, List<InterestRateHistory> rateHistory) {
  // Tìm rate active tại tháng này
  final activeRate = rateHistory
      .where((r) => r.debtId == debt.id)
      .firstWhere(
        (r) => r.isActiveAt(monthDate),
        orElse: () => InterestRateHistory(
          id: 'default',
          debtId: debt.id,
          apr: debt.apr, // fallback to current APR
          effectiveFrom: DateTime(2000),
        ),
      );
  
  return activeRate.apr;
}

// Trong simulateMonth():
for (final debt in activeDebts) {
  final rates = await _rateHistoryRepository.getByDebtId(debt.id);
  final currentApr = _getAprForMonth(debt, currentDate, rates);
  
  final interest = computeInterest(
    balance: debt.currentBalance,
    apr: currentApr,
    method: debt.interestMethod,
  );
  // ... rest of calculation
}
```

**Test:** Test vector TV-5 (rate change mid-term) từ spec.

#### 2. Add/Edit rate history UI (1.5 days)
**File:** `lib/features/debts/presentation/pages/debt_detail_page.dart`

**Implementation:**
```dart
// Add "Interest Rate History" section trong DebtDetailPage
Section(
  title: 'Lãi suất',
  children: [
    _RateHistoryTile(
      currentApr: debt.apr,
      onTap: () => _navigateToRateHistory(context, debt.id),
    ),
  ],
)

// Navigation
void _navigateToRateHistory(BuildContext context, String debtId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RateHistoryPage(debtId: debtId),
    ),
  );
}
```

**File:** `lib/features/debts/presentation/pages/rate_history_page.dart` (new)

```dart
class RateHistoryPage extends StatelessWidget {
  final String debtId;
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lịch sử lãi suất')),
      body: StreamBuilder<List<InterestRateHistory>>(
        stream: _repository.watchByDebtId(debtId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          final rates = snapshot.data!;
          
          return ListView.separated(
            itemCount: rates.length,
            itemBuilder: (_, i) => _RateHistoryRow(rates[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRateDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

**Test:** Widget test cho rate history list + add rate dialog.

#### 3. Add rate change validation (0.5 day)
**File:** `lib/data/repositories/interest_rate_history_repository_impl.dart`

**Validation rules:**
```dart
@override
Future<void> addRateHistory(InterestRateHistory rate) async {
  // Validate: effectiveFrom < effectiveTo (if set)
  if (rate.effectiveTo != null && !rate.effectiveFrom.isBefore(rate.effectiveTo!)) {
    throw ArgumentError('effectiveFrom must be before effectiveTo');
  }
  
  // Validate: no overlap với existing rates
  final existing = await getByDebtId(rate.debtId);
  final hasOverlap = existing.any((r) => 
    r.effectiveFrom.isBefore(rate.effectiveTo ?? DateTime(9999)) &&
    (r.effectiveTo ?? DateTime(9999)).isAfter(rate.effectiveFrom)
  );
  
  if (hasOverlap) {
    throw ArgumentError('Rate period overlaps with existing rate');
  }
  
  await _db.into(_db.interestRateHistoryTable).insert(rate.toCompanion());
}
```

**Acceptance:**
- [ ] User có thể xem lịch sử lãi suất trong Debt Detail
- [ ] Add rate change với validation: không overlap, effectiveFrom < effectiveTo
- [ ] Timeline simulation sử dụng đúng APR theo từng thời điểm
- [ ] Test vector TV-5 pass

---

## §2.2 New Charge / Balance Increase (0% → 100%)

### 🔧 Implementation (2 days)

**Use case:** Credit card có new charge (quẹt thẻ, phí chuyển khoản, v.v.) làm tăng balance.

#### 1. Payment type: "New Charge" (1 day)
**File:** `lib/domain/entities/payment.dart`

**Add new payment type:**
```dart
enum PaymentType {
  payment('Payment'),
  fee('Fee'),
  interest('Interest'),
  newCharge('New Charge'); // ← Add this
  
  const PaymentType(this.label);
  final String label;
}
```

**File:** `lib/core/services/payment_logging_service.dart`

```dart
Future<Debt> logNewCharge({
  required Debt debt,
  required int amountCents,
  required String note,
}) async {
  if (amountCents <= 0) {
    throw ArgumentError('New charge amount must be positive');
  }
  
  final newBalance = debt.currentBalance + amountCents;
  final now = DateTime.now().toUtc();
  
  final charge = Payment(
    id: const Uuid().v4(),
    debtId: debt.id,
    amountCents: -amountCents, // Negative to indicate balance increase
    type: PaymentType.newCharge,
    date: now,
    note: note,
    createdAt: now,
  );
  
  await _db.transaction(() async {
    await _db.into(_db.paymentsTable).insert(charge.toCompanion());
    await _db.update(_db.debtsTable).write(
      debt.copyWith(
        currentBalance: newBalance,
        updatedAt: now,
      ).toCompanion(),
    );
    await _markDirty(debt.id);
  });
  
  return debt.copyWith(currentBalance: newBalance);
}
```

#### 2. UI: Add new charge flow (1 day)
**File:** `lib/features/debts/presentation/pages/debt_detail_page.dart`

```dart
// Add "Add new charge" button trong Debt Actions
if (debt.type == DebtType.creditCard) {
  ListTile(
    leading: Icon(LucideIcons.creditCard),
    title: Text('Thêm giao dịch mới'),
    subtitle: Text('Tăng dư nợ (quẹt thẻ, phí, v.v.)'),
    onTap: () => _showNewChargeDialog(context, debt),
  );
}

void _showNewChargeDialog(BuildContext context, Debt debt) {
  showDialog(
    builder: (ctx) => _NewChargeDialog(debt: debt),
  );
}

class _NewChargeDialog extends StatefulWidget {
  final Debt debt;
  
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Thêm giao dịch mới'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Số tiền',
              prefixText: '\$ ',
            ),
            keyboardType: TextInputType.number,
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'Ghi chú',
              hintText: 'Mua sắm tại Amazon, phí chuyển khoản, v.v.',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        FilledButton(
          onPressed: () => _confirmNewCharge(),
          child: Text('Thêm'),
        ),
      ],
    );
  }
}
```

**Acceptance:**
- [ ] Credit card debts có "Add new charge" button
- [ ] New charge làm tăng currentBalance
- [ ] Payment history hiển thị new charge với màu đỏ (tiêu cực)
- [ ] Timeline recast sau khi add new charge

---

## §2.3 Monthly Summary (0% → 100%)

### 🔧 Implementation (3 days)

**Goal:** Màn hình tổng kết tháng — user đã trả bao nhiêu, còn bao nhiêu, progress so với plan.

#### 1. Monthly Summary Screen (2 days)
**File:** `lib/features/progress/presentation/pages/monthly_summary_page.dart` (new)

```dart
class MonthlySummaryPage extends StatelessWidget {
  final DateTime month; // e.g., DateTime(2026, 4) for April 2026
  
  Widget build(BuildContext context) {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Tổng kết ${formatMonth(month)}'),
        actions: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () => _navigateToMonth(month.subtract(Duration(days: 30))),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () => _navigateToMonth(month.add(Duration(days: 30))),
          ),
        ],
      ),
      body: FutureBuilder<MonthlySummaryData>(
        future: _loadSummary(monthStart, monthEnd),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          final data = snapshot.data!;
          
          return ListView(
            padding: AppDimensions.pagePadding,
            children: [
              _SummaryCard(
                title: 'Đã trả tháng này',
                amount: data.totalPaid,
                subtitle: 'So với plan: ${data.planVariance}',
              ),
              _SummaryCard(
                title: 'Dư nợ còn lại',
                amount: data.remainingBalance,
                delta: data.balanceDelta, // so với đầu tháng
              ),
              _ProgressSection(
                title: 'Progress theo khoản nợ',
                debts: data.perDebtProgress,
              ),
              _MilestonesSection(
                title: 'Cột mốc đạt được',
                milestones: data.milestonesThisMonth,
              ),
            ],
          );
        },
      ),
    );
  }
}
```

#### 2. Monthly Summary Service (1 day)
**File:** `lib/core/services/monthly_summary_service.dart` (new)

```dart
class MonthlySummaryData {
  final int totalPaid; // principal + interest
  final int principalPaid;
  final int interestPaid;
  final int planVariance; // positive = paid more than plan
  final int remainingBalance;
  final int balanceDelta; // negative = giảm
  final List<DebtProgress> perDebtProgress;
  final List<Milestone> milestonesThisMonth;
}

class MonthlySummaryService {
  Future<MonthlySummaryData> getSummary({
    required DateTime monthStart,
    required DateTime monthEnd,
  }) async {
    final payments = await _paymentRepository
        .getPaymentsInRange(monthStart, monthEnd);
    
    int totalPaid = 0;
    int principalPaid = 0;
    int interestPaid = 0;
    
    for (final payment in payments) {
      if (payment.type == PaymentType.payment) {
        totalPaid += payment.amountCents.abs();
        // Split principal/interest based on audit snapshot
        principalPaid += payment.appliedPrincipalCents;
        interestPaid += payment.appliedInterestCents;
      }
    }
    
    final planSummary = await _planRepository.getSummaryForMonth(monthStart);
    final variance = totalPaid - planSummary.plannedPayment;
    
    final debts = await _debtRepository.getAllDebts();
    final remainingBalance = debts.fold<int>(
      0,
      (sum, d) => sum + d.currentBalance,
    );
    
    final startBalance = await _getBalanceAtDate(monthStart);
    final balanceDelta = remainingBalance - startBalance;
    
    return MonthlySummaryData(
      totalPaid: totalPaid,
      principalPaid: principalPaid,
      interestPaid: interestPaid,
      planVariance: variance,
      remainingBalance: remainingBalance,
      balanceDelta: balanceDelta,
      perDebtProgress: await _getPerDebtProgress(monthStart, monthEnd),
      milestonesThisMonth: await _milestoneRepository.getMilestonesInRange(
        monthStart,
        monthEnd,
      ),
    );
  }
}
```

**Acceptance:**
- [ ] Monthly summary screen hiển thị total paid, remaining balance
- [ ] So sánh với plan: "Bạn trả nhiều hơn plan $234"
- [ ] Per-debt progress: mỗi debt giảm bao nhiêu trong tháng
- [ ] Milestones đạt được trong tháng

---

## Property-Based Tests (0% → 100%)

### 🔧 Implementation (2 days)

**File:** `test/engine/edge_case_property_test.dart`

```dart
import 'package:glados/glados.dart';
import 'package:test/test.dart';

void main() {
  group('Forbearance properties', () {
    test('Paused debt không được trả trong simulation', () {
      glados(
        (g) {
          final debt = g.genDebt(isPaused: true);
          final payments = g.genPayments(debt.id);
          return (debt, payments);
        },
        (scenario) {
          final (debt, payments) = scenario;
          final result = simulateMonth(debt, payments);
          
          // Property: paused debt không có payment allocated
          expect(result.paymentToDebt(debt.id), equals(0));
        },
        maxTests: 100,
      );
    });
    
    test('Resume từ pause → timeline không sai', () {
      // Property: resume debt → debt-free date không trễ hơn so với không pause
      // (vì interest vẫn accrue trong pause period)
    });
  });
  
  group('Interest rate change properties', () {
    test('APR tăng → debt-free date trễ hơn hoặc bằng', () {
      glados(
        (g) {
          final debt = g.genDebt();
          final rateIncrease = g.genDecimal(min: 0.01, max: 0.10);
          return (debt, rateIncrease);
        },
        (scenario) {
          final (debt, rateIncrease) = scenario;
          
          final timeline1 = simulateTimeline(debt);
          final debtWithHigherRate = debt.copyWith(
            apr: debt.apr + rateIncrease,
          );
          final timeline2 = simulateTimeline(debtWithHigherRate);
          
          // Property: higher APR → debt-free date không sớm hơn
          expect(
            timeline2.debtFreeDate,
            inSameMonthOrAfter(timeline1.debtFreeDate),
          );
        },
        maxTests: 100,
      );
    });
    
    test('Rate change không làm total interest giảm vô lý', () {
      // Property: rate increase → total interest tăng hoặc bằng
    });
  });
  
  group('New charge properties', () {
    test('New charge → debt-free date trễ hơn hoặc bằng', () {
      glados(
        (g) {
          final debt = g.genDebt();
          final chargeAmount = g.genInt(min: 100, max: 50000); // $1 - $500
          return (debt, chargeAmount);
        },
        (scenario) {
          final (debt, chargeAmount) = scenario;
          
          final timeline1 = simulateTimeline(debt);
          final debtWithCharge = debt.copyWith(
            currentBalance: debt.currentBalance + chargeAmount,
          );
          final timeline2 = simulateTimeline(debtWithCharge);
          
          // Property: new charge → debt-free date không sớm hơn
          expect(
            timeline2.debtFreeDate,
            inSameMonthOrAfter(timeline1.debtFreeDate),
          );
        },
        maxTests: 100,
      );
    });
  });
}
```

**Acceptance:**
- [ ] 100+ property tests pass
- [ ] Edge cases: 0% APR, balance > principal, multiple rate changes

---

## Testing Strategy

| Layer | Tests | Owner |
|-------|-------|-------|
| Unit tests (engine) | 20 tests | You |
| Repository tests | 10 tests | You |
| Cubit tests | 8 tests | You |
| Widget tests | 15 tests | You |
| Integration tests | 5 flows | You |
| Property-based tests | 100+ scenarios | Glados |

**Total:** ~158 tests added

---

## Timeline

| Week | Focus | Deliverables |
|------|-------|--------------|
| 1 | Scenarios + Forbearance | Scenario comparison chart, Pause/Resume flow |
| 2 | Interest Rate Change | Rate history UI, Engine integration |
| 3 | New Charge + Monthly Summary | Balance increase flow, Summary screen |
| 4 | Tests + Polish | Property tests, integration tests, bug fixes |

---

## Exit Criteria (Phase 8)

- [ ] All 7 tasks complete
- [ ] 150+ new tests pass
- [ ] No critical/high bugs in backlog
- [ ] Performance: timeline recast < 500ms với rate history
- [ ] **v1.2 Ship: Power Features**

---

## Post-Phase 8: Phase 11 Prep (IAP)

Sau khi Phase 8 complete, chuẩn bị cho Phase 11:

1. **IAP package setup** (`in_app_purchase`)
2. **Define tiers:** Free vs Premium
   - Free: Local-only, basic features
   - Premium: Cloud sync, scenarios, advanced reports
3. **Pricing screen** (replace stub với real IAP)
4. **Feature flag infrastructure** (enable/disable premium features)

---

> **Note:** IAP moved to Phase 11 để đo adoption rate của power features trước khi gate. Data adoption > 25% → tự tin set premium tier.
