# Financial Engine — Technical Reference

> Tài liệu chuyên ngành về data model và công thức tính toán tài chính cho Debt Payoff Manager.
> Đây là **nguồn chân lý duy nhất** cho mọi phép tính liên quan đến tiền, lãi suất, timeline.
> **Nguyên tắc tối thượng: sai 1 công thức = mất trust toàn bộ app. Mọi output số phải có formula reference đến doc này.**

---

## Mục lục

1. [Nguyên tắc nền tảng](#1-nguyên-tắc-nền-tảng)
2. [Precision & Money Representation](#2-precision--money-representation)
3. [Data Model](#3-data-model)
4. [Lãi suất — các khái niệm bắt buộc phải phân biệt](#4-lãi-suất--các-khái-niệm-bắt-buộc-phải-phân-biệt)
5. [Core formulas — Amortization](#5-core-formulas--amortization)
6. [Credit Card specifics](#6-credit-card-specifics)
7. [Payoff Strategy Algorithms](#7-payoff-strategy-algorithms)
8. [Extra Payment Allocation & Rollover](#8-extra-payment-allocation--rollover)
9. [Timeline Simulation Engine](#9-timeline-simulation-engine)
10. [Edge Cases](#10-edge-cases)
11. [Validation & Sanity Checks](#11-validation--sanity-checks)
12. [Test Vectors](#12-test-vectors)

---

## 1. Nguyên tắc nền tảng

| # | Nguyên tắc | Lý do |
|---|---|---|
| 1 | **Không dùng `double`/`float` cho tiền** | Binary floating-point không biểu diễn chính xác `0.1`, `0.01`. Cộng 100 lần `0.01` ra `1.0000000000000007` — không acceptable cho finance |
| 2 | **Tiền lưu ở đơn vị nhỏ nhất (cents/minor units) dạng integer** | $12.34 → lưu `1234` (cents). Hoặc dùng `Decimal` với scale cố định |
| 3 | **Lãi suất lưu dưới dạng decimal, không phải percent** | 18.99% → lưu `0.1899` (Decimal, không phải double) |
| 4 | **Rounding rule nhất quán** | Dùng **banker's rounding (round-half-to-even)** cho interest calc, **round-half-up** cho payment amount |
| 5 | **Mọi phép tính ra output phải có explanation trace** | User hỏi "sao tháng này interest $42.18?" → phải trả lời được: "balance × daily_rate × days" |
| 6 | **Idempotent calculation** | Cùng input → cùng output, luôn luôn. Không phụ thuộc thời gian gọi, thứ tự log. |
| 7 | **Never trust user-entered APR blindly** | Validate range: 0% ≤ APR ≤ 100%. APR > 36% cảnh báo (usury). APR = 0% cho phép (promo rate) |

---

## 2. Precision & Money Representation

### Thư viện đề xuất (Dart)

- **`decimal`** ([pub.dev/packages/decimal](https://pub.dev/packages/decimal)) — arbitrary precision decimal, built on top of `rational`
- **`intl`** — chỉ dùng cho format/display, **KHÔNG** dùng cho tính toán

### Convention

```dart
// ❌ SAI
double balance = 1234.56;
double interest = balance * 0.1899 / 12; // floating point error

// ✅ ĐÚNG
Decimal balance = Decimal.parse('1234.56');
Decimal apr = Decimal.parse('0.1899');
Decimal monthlyRate = apr / Decimal.fromInt(12);
Decimal interest = (balance * monthlyRate).round(scale: 2);
```

### Quy tắc scale

| Loại giá trị | Scale (số chữ số sau dấu phẩy) | Rounding |
|---|---|---|
| Money amount (balance, payment) | 2 | Banker's rounding khi tính, half-up khi display |
| Interest rate (APR, monthly rate) | 10 (internal), 4 (display) | Truncate |
| Percentage progress | 4 (internal), 1 (display) | Half-up |
| Day count | 0 (integer) | N/A |

### Storage

Trong SQLite/Firestore, lưu money dưới dạng:

- **SQLite**: `INTEGER` cents (VD: `123456` = $1,234.56) — nhanh, exact, dễ sum
- **Firestore**: `number` cents hoặc `string` decimal — Firestore không có Decimal type native, dùng integer cents an toàn nhất

**KHÔNG** bao giờ lưu money dưới dạng `REAL`/`DOUBLE`.

---

## 3. Data Model

### 3.1 Entity: `Debt`

```
Debt {
  id: UUID
  name: String (non-empty, max 60 chars)
  type: DebtType enum
    { creditCard, studentLoan, carLoan, mortgage, personal, medical, other }
  
  // Money (stored as integer cents)
  originalPrincipal: Int (cents, > 0)      // số tiền gốc khi bắt đầu
  currentBalance: Int (cents, >= 0)         // số dư hiện tại
  
  // Interest
  apr: Decimal (0 <= apr <= 1, scale 10)    // 0.1899 = 18.99%
  interestMethod: InterestMethod enum
    { simpleMonthly, compoundDaily, compoundMonthly }
  
  // Payment schedule
  minimumPayment: Int (cents, >= 0)
  minimumPaymentType: MinPaymentType enum
    { fixed, percentOfBalance, interestPlusPercent }
  minimumPaymentPercent: Decimal? (nullable, for percentOfBalance/interestPlusPercent)
  minimumPaymentFloor: Int? (cents, VD credit card min = $25)
  
  paymentCadence: Cadence enum
    { monthly, biweekly, weekly, semimonthly }
  dueDayOfMonth: Int (1-31, for monthly)
  firstDueDate: Date
  
  // Lifecycle
  status: DebtStatus enum
    { active, paidOff, archived, paused }
  pausedUntil: Date? (for forbearance)
  
  // Strategy metadata
  priority: Int? (manual override for user-defined ordering)
  excludeFromStrategy: Bool (default false)
  
  // Timestamps
  createdAt: Timestamp
  updatedAt: Timestamp
  paidOffAt: Timestamp?
}
```

### 3.2 Entity: `Payment`

```
Payment {
  id: UUID
  debtId: UUID (FK to Debt)
  
  // Money
  amount: Int (cents, > 0)
  principalPortion: Int (cents)      // computed
  interestPortion: Int (cents)       // computed
  feePortion: Int (cents, default 0) // late fee, etc.
  
  // Meta
  date: Date (date payment applied — important for interest calc)
  type: PaymentType enum
    { minimum, extra, lumpSum, fee, refund, charge }
  source: PaymentSource enum
    { scheduled, manual, windfall, checkOff, import }
  note: String? (user note, max 200 chars)
  
  // State
  status: PaymentStatus enum
    { planned, completed, missed }
  
  // Traceability
  appliedBalanceBefore: Int (cents) // snapshot for audit
  appliedBalanceAfter: Int (cents)
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

**Invariant:** `amount == principalPortion + interestPortion + feePortion` (luôn luôn).

### 3.3 Entity: `Plan`

```
Plan {
  id: UUID (singleton per user, or 1 plan per scenario)
  strategy: Strategy enum { snowball, avalanche, custom }
  extraMonthlyAmount: Int (cents, >= 0)
  extraPaymentCadence: Cadence (thường giống income cadence)
  
  // Optional overrides
  customOrder: [DebtId]? (only if strategy == custom)
  
  // Computed & cached
  lastRecastAt: Timestamp
  projectedDebtFreeDate: Date (computed)
  totalInterestProjected: Int (cents, computed)
  totalInterestSavedVsMinimumOnly: Int (cents, computed)
}
```

### 3.4 Entity: `InterestRateHistory` (cho edge case 2.2)

```
InterestRateHistory {
  id: UUID
  debtId: UUID
  apr: Decimal
  effectiveFrom: Date
  effectiveTo: Date? (null = hiện tại)
  reason: String? (VD "promo expired", "refinance")
}
```

Khi tính timeline, dùng APR có `effectiveFrom <= month <= effectiveTo`.

### 3.5 Entity: `TimelineProjection` (cache, không phải source of truth)

```
TimelineProjection {
  planId: UUID
  generatedAt: Timestamp
  months: [MonthProjection]
}

MonthProjection {
  monthIndex: Int (0 = hiện tại)
  yearMonth: String ("2026-04")
  entries: [DebtMonthEntry]
  totalPaymentThisMonth: Int (cents)
  totalInterestThisMonth: Int (cents)
  totalBalanceEndOfMonth: Int (cents)
}

DebtMonthEntry {
  debtId: UUID
  startingBalance: Int
  interestAccrued: Int
  paymentApplied: Int
  principalPortion: Int
  interestPortion: Int
  endingBalance: Int
  isPaidOffThisMonth: Bool
}
```

---

## 4. Lãi suất — các khái niệm bắt buộc phải phân biệt

App này sẽ bị sai nếu developer nhầm lẫn các khái niệm sau. Cần enforce qua type system.

### 4.1 APR vs APY

- **APR (Annual Percentage Rate)** — lãi suất danh nghĩa hàng năm, **không tính compounding**. Đây là gì user thấy trên statement.
- **APY (Annual Percentage Yield)** — lãi suất hiệu dụng hàng năm, **có tính compounding**.

Quan hệ:
```
APY = (1 + APR/n)^n - 1
  với n = số kỳ compound/năm
```

**User nhập APR.** App hiển thị APR. Internal tính toán convert sang periodic rate.

### 4.2 Periodic rate

```
Monthly periodic rate = APR / 12
Daily periodic rate   = APR / 365  (một số issuer dùng 360, xem note)
Biweekly rate         = APR / 26
```

**Note:** Một số US credit card issuer dùng 360-day year (bank method). Một số dùng 365. **Default của app: 365 (actual/365).** Cho phép override per debt nếu user biết.

### 4.3 Daily periodic rate vs Monthly periodic rate

Đây là điểm **hầu hết competitor app sai**:

- **Credit card**: lãi tính **daily**, compound daily. Nếu app tính monthly chỉ → off bởi vài %.
- **Student loan / mortgage**: thường tính monthly (simple monthly interest trên unpaid balance).
- **Car loan**: thường simple interest, tính daily.

Vì vậy `Debt.interestMethod` là **bắt buộc**, không default blind.

---

## 5. Core formulas — Amortization

### 5.1 Standard amortization (fixed payment, compound monthly)

Dùng cho: mortgage, student loan (cố định), personal loan.

**Monthly payment** (fixed payment amortization):
```
      P × r × (1 + r)^n
PMT = ─────────────────
        (1 + r)^n - 1

  P = principal
  r = monthly periodic rate = APR / 12
  n = số tháng
```

**Split principal/interest của tháng k:**
```
Interest_k  = Balance_{k-1} × r
Principal_k = PMT - Interest_k
Balance_k   = Balance_{k-1} - Principal_k
```

**Số tháng còn lại** (nếu biết PMT, P, r):
```
n = -log(1 - P × r / PMT) / log(1 + r)
```
→ làm tròn lên số tháng nguyên, tháng cuối payment sẽ < PMT.

### 5.2 Simple monthly interest (credit card, revolving)

Khi user tự chọn payment amount (không fixed):

```
Interest_this_month  = Balance_start × (APR / 12)
Principal_this_month = Payment_this_month - Interest_this_month
Balance_end          = Balance_start - Principal_this_month
```

Nếu `Payment < Interest` → **balance tăng** (negative amortization). App phải cảnh báo.

### 5.3 Daily compounding (credit card chính xác)

```
For each day d in month:
  daily_interest = Balance_d × (APR / 365)
  Balance_{d+1} = Balance_d + daily_interest - payment_on_day_d + charges_on_day_d
```

Đơn giản hóa khi không có charge mid-month:
```
Balance_end = Balance_start × (1 + APR/365)^days_in_month - payment_midcycle_adjusted
```

Trong MVP, approximation chấp nhận được:
```
effective_monthly_rate = (1 + APR/365)^30.4167 - 1
```
với 30.4167 = 365/12. **Ghi rõ đây là approximation trong UI trace.**

### 5.4 Average Daily Balance (ADB) — credit card thực tế

Issuer tính lãi trên ADB:
```
              Σ (Balance_d) for d in billing_cycle
ADB = ─────────────────────────────────────────────
               days_in_billing_cycle

Interest_cycle = ADB × (APR / 365) × days_in_cycle
```

Trong MVP, có thể approximate bằng balance giữa tháng. Trong v2 hỗ trợ chính xác khi user log charge và payment với date cụ thể.

---

## 6. Credit Card specifics

### 6.1 Minimum payment calculation

Mỗi issuer khác nhau. App hỗ trợ 3 method qua `minimumPaymentType`:

**A. Fixed amount**
```
min_payment = fixed_value
```

**B. Percent of balance**
```
min_payment = max(balance × percent, floor)
  percent thường 1%–3%
  floor thường $25–$35
```

**C. Interest + percent of principal** (phổ biến ở US)
```
min_payment = max(
  interest_this_month + balance × percent_of_principal,
  floor
)
  percent_of_principal thường 1%
  floor thường $25
```

### 6.2 Minimum payment trap

Nếu user chỉ trả minimum, credit card có thể mất **20+ năm** để trả hết, với tổng interest > gấp đôi principal. App phải hiển thị cảnh báo này rõ ràng:

```
"Chỉ trả minimum: hết nợ vào 2046 (20 năm), tổng lãi $18,420
Trả thêm $100/tháng: hết nợ vào 2029 (3 năm), tổng lãi $2,840
Tiết kiệm: $15,580 và 17 năm"
```

Đây là **một trong những 'aha moment' quan trọng nhất** của app.

### 6.3 Promo rate / intro APR

- Balance transfer thường có promo 0% trong 12–18 tháng
- Sau promo → rate nhảy lên APR thông thường (thường > 20%)

Mô hình hóa qua `InterestRateHistory`:
```
{ apr: 0.00, effectiveFrom: 2026-01-01, effectiveTo: 2027-01-01, reason: "intro 0%" }
{ apr: 0.2499, effectiveFrom: 2027-01-01, effectiveTo: null, reason: "post-intro" }
```

Timeline engine phải pick rate đúng theo month.

---

## 7. Payoff Strategy Algorithms

### 7.1 Snowball (smallest balance first)

```
sort debts by currentBalance ASC
priority_debt = debts[0]
```

Tiebreak: APR cao hơn trước (nếu cùng balance, trả APR cao trước).

### 7.2 Avalanche (highest APR first)

```
sort debts by apr DESC
priority_debt = debts[0]
```

Tiebreak: balance thấp hơn trước.

### 7.3 Custom

Dùng `Plan.customOrder: [DebtId]`.

### 7.4 So sánh Snowball vs Avalanche — math

Cho cùng bộ nợ + extra payment:
```
total_interest_avalanche <= total_interest_snowball  (luôn đúng về toán)
debt_free_date_avalanche <= debt_free_date_snowball  (luôn đúng về toán)
```

Vậy **tại sao Snowball tồn tại?** → Psychological: trả xong debt đầu nhanh → motivation boost. Research (Kellogg, 2016) cho thấy snowball users hoàn thành payoff journey tỷ lệ cao hơn.

App phải trình bày **cả hai số liệu thật + psychological benefit** cho user tự quyết, không lecture.

---

## 8. Extra Payment Allocation & Rollover

### 8.1 Monthly allocation rule

Cho mỗi tháng:
```
1. Với mỗi active debt d:
     pay_minimum(d)  // trả minimum cho tất cả
     
2. remaining_extra = plan.extraMonthlyAmount
   
3. Sort active debts theo strategy → priority_debt
   
4. Áp dụng extra vào priority_debt:
     extra_applied = min(remaining_extra, priority_debt.balance)
     pay(priority_debt, extra_applied)
     remaining_extra -= extra_applied
   
5. Nếu priority_debt paid off và remaining_extra > 0:
     priority_debt = next in sorted order
     goto 4 (rollover immediately)
```

**Key insight (Nguyên tắc 1 — Living Plan):** khi 1 debt trả xong giữa tháng, minimum + extra của nó **rollover sang debt tiếp theo cùng tháng đó**. Nhiều competitor app chỉ rollover tháng sau → sai số tích lũy.

### 8.2 Rollover formula

Khi debt A trả xong tại tháng k:
```
available_from_A = A.minimumPayment + (extra đã dành cho A trước đó)
new_priority = next debt in sort order

payment_to_new_priority = new_priority.minimumPayment + available_from_A
```

Rollover **cumulative**: khi A, B lần lượt xong, toàn bộ min(A) + min(B) + extra chảy vào C.

Đây là nguồn sức mạnh toán học của Snowball/Avalanche — và là tính năng **5/6 competitor làm sai hoặc làm thiếu**.

### 8.3 Lump-sum / windfall handling

One-time payment không thuộc recurring:
```
windfall_applied = min(windfall_amount, priority_debt.balance)
  → trả thẳng vào principal của priority_debt
  → nếu còn dư, rollover sang next priority
```

Windfall **không thay đổi** `extraMonthlyAmount` ổn định. Timeline recast ngay.

---

## 9. Timeline Simulation Engine

### 9.1 Algorithm (month-by-month simulation)

```python
def simulate(debts, plan, max_months=600):
    month = 0
    projections = []
    active = [d for d in debts if d.status == 'active']
    
    while active and month < max_months:
        month_projection = MonthProjection(month)
        
        # Step 1: accrue interest on all active
        for d in active:
            interest = compute_interest(d, month)
            d.balance += interest
            month_projection.add_interest(d, interest)
        
        # Step 2: pay minimum on all active (respecting pause)
        for d in active:
            if d.is_paused(month):
                continue
            min_pay = compute_min_payment(d)
            actual = min(min_pay, d.balance)
            apply_payment(d, actual, month_projection)
        
        # Step 3: apply extra + rollover (recursive)
        extra_pool = plan.extra_monthly_amount
        sorted_debts = sort_by_strategy(active, plan.strategy)
        
        for d in sorted_debts:
            if d.is_paused(month): continue
            if extra_pool <= 0: break
            applied = min(extra_pool, d.balance)
            apply_payment(d, applied, month_projection)
            extra_pool -= applied
        
        # Step 4: remove paid-off
        newly_paid = [d for d in active if d.balance == 0]
        for d in newly_paid:
            d.paid_off_at = month
            active.remove(d)
        
        projections.append(month_projection)
        month += 1
    
    return projections
```

### 9.2 Debt-free date

```
debt_free_month_index = max(month for month, proj in enumerate(projections)
                             if any debt paid off that month)
debt_free_date = start_date + debt_free_month_index months
```

### 9.3 Total interest projection

```
total_interest_projected = Σ interest_accrued across all months, all debts
```

### 9.4 Interest saved vs minimum-only

Chạy simulation thứ 2 với `extra_monthly_amount = 0`:
```
interest_saved = total_interest_minimum_only - total_interest_projected
time_saved = debt_free_date_minimum_only - debt_free_date_projected
```

### 9.5 Performance

Với 10 debts, 60 months → 600 debt-month calcs, trivial (<10ms). Với 20 debts, 600 months (mortgage) → 12k calcs, vẫn <100ms. **Không cần background thread cho MVP**, nhưng dùng `compute()` nếu > 50ms trên low-end device.

### 9.6 Incremental recast

Khi user log payment hoặc edit debt:
```
1. Update debt source of truth
2. Invalidate TimelineProjection cache
3. Re-simulate (full)
4. Diff old vs new debt_free_date → surface delta trong UI:
   "Debt-free date: July 2028 → May 2028 (↓ 2 months)"
```

**Không incremental partial update** — full resimulate là đơn giản, đúng, và đủ nhanh.

---

## 10. Edge Cases

### 10.1 Forbearance / Pause

Debt với `status == paused`:
- **Không tính interest** nếu là subsidized (government student loan) → `interestMethod` đã reflect
- **Vẫn tính interest** nếu unsubsidized → balance tăng trong thời gian pause
- Không trả minimum, không nhận extra payment

Khi hết pause (`month > pausedUntil`), tự động chuyển lại `active`.

### 10.2 Interest rate change

Query rate qua `InterestRateHistory`:
```dart
Decimal rateForMonth(Debt debt, Date month) {
  return InterestRateHistory.where(debtId == debt.id)
    .where(effectiveFrom <= month)
    .where(effectiveTo == null OR effectiveTo > month)
    .single.apr;
}
```

### 10.3 New charge added to balance (credit card)

Log như 1 payment với `type = charge` (negative principal portion):
```
balance_new = balance_old + charge_amount
```

Timeline recast → debt-free date dời lùi. UI hiển thị:
```
"Bạn thêm $280 charge. Debt-free date: May 2028 → June 2028 (+1 tháng)"
```

### 10.4 Missed payment

Nếu user không log minimum trong tháng k:
- **Option 1 (strict)**: balance tiếp tục tích interest bình thường, next month phải trả 2 × minimum
- **Option 2 (realistic)**: thêm late fee + penalty APR (không mô hình trong MVP)

MVP: Option 1. V2: cho user nhập late fee thủ công.

### 10.5 Overpayment

Nếu `payment > balance + interest_this_month`:
```
actual_applied = balance + interest_this_month
excess = payment - actual_applied
→ excess rollover sang next priority debt (như extra payment)
```

### 10.6 Zero-interest debt

`APR == 0` là hợp lệ (medical debt thường 0%, promo credit card 0%):
```
interest_this_month = 0
min_payment method = fixed (vì formula %-based không áp dụng)
```

### 10.7 Variable rate (ARM, HELOC)

**Không support trong MVP.** V2: cho user nhập rate change event thủ công. V3: pull benchmark rate (SOFR, Prime) tự động.

### 10.8 Bi-weekly payment cadence

```
biweekly_payment = monthly_payment / 2
payments_per_year = 26  (so với 24 nếu semimonthly)
=> 1 payment thêm mỗi năm so với monthly
```

Simulation: convert sang monthly-equivalent khi simulate, hoặc simulate theo day granularity (phức tạp hơn). **MVP**: convert thành `monthly_equivalent = biweekly × 26 / 12` để đơn giản, note rõ approximation.

### 10.9 Leap year / day count convention

Default: actual/365 (đếm ngày thật trong năm, chia 365). Một số mortgage dùng 30/360 (mọi tháng 30 ngày, năm 360 ngày). User-configurable per debt, default actual/365.

---

## 11. Validation & Sanity Checks

Mỗi phép tính phải pass sanity check trước khi hiển thị.

### 11.1 Invariants

```
∀ debt, ∀ month:
  balance >= 0
  balance <= originalPrincipal × 1.5  (không tăng quá 50% — trừ forbearance dài)
  
∀ payment:
  amount > 0
  principalPortion + interestPortion + feePortion == amount
  
∀ plan:
  debt_free_date >= today
  total_interest_projected >= 0
  total_interest_projected <= Σ originalPrincipal × 2  (soft limit, cảnh báo nếu vượt)
```

### 11.2 User-facing sanity warnings

- Balance > original principal → "Số dư lớn hơn nợ gốc — có thể bạn đang trả không đủ interest hàng tháng"
- APR > 36% → "Lãi suất cao bất thường, kiểm tra lại"
- Min payment < monthly interest → "Minimum payment không đủ bù lãi — nợ sẽ tăng"
- Debt-free date > 30 năm → "Với mức extra hiện tại, cần > 30 năm. Thử tăng extra?"
- Extra monthly > monthly income proxy (user-settable) → "Số tiền extra có vẻ cao so với income. Chắc chắn?"

### 11.3 Property-based test invariants (cho test suite)

```
Property 1: Monotonicity
  Với cùng debts + APR, tăng extra_monthly → debt_free_date không bao giờ trễ hơn
  
Property 2: Conservation
  Σ principal_paid across all months + final_total_balance == Σ initial_balance + Σ new_charges
  
Property 3: Avalanche optimality
  total_interest(avalanche) <= total_interest(snowball) <= total_interest(minimum_only)
  
Property 4: Rollover correctness
  Sau khi debt A paid off, payment của A phải xuất hiện trong payment của next priority
  ngay tháng đó (không phải tháng sau)
```

---

## 12. Test Vectors

Mỗi công thức phải có test vector với expected output cố định. Đây là hàng rào cuối chống regression.

### TV-1: Standard amortization

```
Input:
  Principal = $10,000
  APR = 6%
  Term = 60 months
  
Expected:
  Monthly payment = $193.33  (round banker's)
  Total interest = $1,599.68
  Total paid = $11,599.68
  
Formula: PMT = 10000 × 0.005 × 1.005^60 / (1.005^60 - 1)
```

### TV-2: Credit card minimum payment trap

```
Input:
  Balance = $5,000
  APR = 19.99%
  Min payment = interest + 1% principal, floor $25
  User pays minimum only
  
Expected:
  Payoff duration = ~272 months (~22.7 years)
  Total interest ≈ $6,923
  Total paid ≈ $11,923
```

### TV-3: Snowball vs Avalanche

```
Input:
  Debt A: $500 balance, 22% APR, min $25
  Debt B: $3,000 balance, 8% APR, min $60
  Debt C: $1,200 balance, 15% APR, min $35
  Extra: $100/month
  
Expected Snowball order: A → C → B
  Debt-free: ~29 months
  Total interest: $672.xx

Expected Avalanche order: A → C → B  (A first because 22% highest)
  wait, Avalanche sorts by APR desc:
  A (22%) → C (15%) → B (8%)
  Same order in this case!
  
Use different test vector where order diverges:
  Debt A: $500, 10% APR
  Debt B: $200, 8% APR  
  Debt C: $1500, 20% APR
  
Snowball:  B → A → C
Avalanche: C → A → B
→ total interest differs, verify avalanche < snowball
```

### TV-4: Rollover within month

```
Input:
  Debt A: balance $50, min $25, 20% APR
  Debt B: balance $1000, min $30, 15% APR
  Extra: $100/month (Snowball)
  
Month 1:
  Interest A: 50 × 20%/12 = $0.83
  Interest B: 1000 × 15%/12 = $12.50
  
  Pay min A: $25 → A balance = $25.83
  Pay min B: $30 → B balance = $982.50
  
  Extra to A: min($100, $25.83) = $25.83 → A paid off!
  Remaining extra: $100 - $25.83 = $74.17
  
  Rollover to B: $74.17 → B balance = $908.33
  
  (A's $25 min also rollovers starting month 2)

Expected end month 1:
  A: $0 (paid off)
  B: $908.33
  Total paid month 1: $25 + $30 + $25.83 + $74.17 = $155
```

### TV-5: Rate change mid-term (deferred from E1)

> Ghi chú Phase 1: vector này được giữ lại như tài liệu future scope, nhưng **không** thuộc acceptance set của E1 cho tới khi simulator support `InterestRateHistory` runtime đầy đủ.

```
Input:
  Debt: $2000 balance, 0% APR for 12 months, then 24.99% APR
  Min payment: fixed $50
  No extra
  
Month 1-12: 
  Interest = 0
  Principal = 50
  Balance after 12 months: 2000 - 12×50 = 1400

Month 13 onwards:
  Interest = 1400 × 24.99%/12 = $29.16
  Principal = 50 - 29.16 = $20.84
  ... continues with compound

Expected debt-free: ~month 77 (6.4 years)
Expected total interest: ~$1,842
```

---

## Appendix A: Rounding policy cụ thể

```
compute_interest(balance, rate):
  raw = balance * rate
  return round(raw, scale=2, mode=HALF_EVEN)

compute_payment_split(payment, interest):
  interest_portion = min(interest, payment)
  principal_portion = payment - interest_portion
  return (principal_portion, interest_portion)

display_amount(cents):
  return format as "$X,XXX.XX" (2 decimals, always shown)
```

**Banker's rounding chi tiết:**
- `round(0.125, 2)` = `0.12` (round down because 2 is even)
- `round(0.135, 2)` = `0.14` (round up because 4 is... wait, look at preceding digit 3, odd → round up)
- Quy tắc: khi exactly .x5, round về digit chẵn

Dart: `Decimal` package hỗ trợ `ScaleMode.roundHalfEven`.

---

## Appendix B: Formulas cheat sheet

| Cần tính | Công thức | Section |
|---|---|---|
| Monthly interest (simple) | `balance × APR / 12` | 5.2 |
| Daily interest | `balance × APR / 365` | 5.3 |
| Fixed payment amount | `P×r×(1+r)^n / ((1+r)^n - 1)` | 5.1 |
| Months to payoff | `-log(1 - P×r/PMT) / log(1+r)` | 5.1 |
| Credit card ADB | `Σ daily_balance / days_in_cycle` | 5.4 |
| Effective monthly (from daily compound) | `(1+APR/365)^30.4167 - 1` | 5.3 |
| APY from APR | `(1+APR/n)^n - 1` | 4.1 |

---

## Appendix C: Khái niệm chuyên ngành bắt buộc hiểu

- **Principal** — số tiền gốc chưa trả
- **Interest** — tiền lãi
- **APR** — lãi suất danh nghĩa năm
- **APY / EAR** — lãi suất hiệu dụng năm (có compound)
- **Amortization** — quá trình giảm dần balance qua payment cố định
- **Compounding** — lãi trên lãi
- **Periodic rate** — lãi mỗi kỳ (monthly/daily)
- **Negative amortization** — balance tăng vì payment < interest
- **Rollover** — chuyển payment của debt đã trả xong sang debt khác
- **Forbearance** — tạm dừng payment (interest có thể vẫn tích)
- **Deferment** — tạm dừng payment (interest thường không tích)
- **Subsidized/Unsubsidized** — government trả hoặc không trả interest trong deferment
- **Promo APR / Intro APR** — lãi suất khuyến mãi thời hạn
- **Balance transfer** — chuyển nợ từ card này sang card khác
- **Minimum payment** — số tiền tối thiểu tránh default/late fee
- **Billing cycle** — chu kỳ tính lãi (thường ~30 ngày)
- **Grace period** — thời gian không tính lãi nếu trả full balance
- **Day count convention** — quy tắc đếm ngày (actual/365, 30/360, actual/360)

---

> **Khi implement: mỗi function tính toán phải có comment reference về section trong doc này. VD:**
> ```dart
> /// Computes simple monthly interest per §5.2
> /// interest = balance × (APR / 12), banker's rounding to 2 decimals
> Decimal computeMonthlyInterest(Decimal balance, Decimal apr) { ... }
> ```
