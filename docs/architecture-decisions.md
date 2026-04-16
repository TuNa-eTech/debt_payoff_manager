# Architecture Decision Records

> Ghi lại các quyết định kiến trúc quan trọng của Debt Payoff Manager, với context và hệ quả.
> Mỗi ADR có status (Accepted / Superseded / Deprecated) và date.
> **Khi override: không xóa ADR cũ, thêm ADR mới với "Supersedes: ADR-XXX".**

---

## ADR-001: Flutter + Dart là framework chính

- **Status:** Accepted
- **Date:** 2026-04-15
- **Context:** Cần mobile app cross-platform iOS + Android, có thể mở rộng web/desktop sau
- **Decision:** Flutter 3.10+ với Dart 3
- **Consequences:**
  - (+) Single codebase cho iOS/Android
  - (+) UI performance native-grade
  - (+) Ecosystem mạnh cho financial tooling (drift, decimal, firebase)
  - (−) Team phải biết Dart (learning curve nếu đến từ JS/Swift)

---

## ADR-002: Drift làm local database

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** Cần local DB cho Living Plan (Nguyên tắc 1) + Local-first (Nguyên tắc 2). Đã so sánh Drift / Isar / Hive / sqflite / ObjectBox.
- **Decision:** Drift (SQLite + type-safe Dart layer)
- **Rationale:**
  - Data model relational (Debt ↔ Payment ↔ InterestRateHistory) — SQL fit
  - Complex aggregation queries (total interest, monthly sums) — SQL native
  - Reactive streams built-in (`.watch()`) cho Living Plan
  - Migration framework + verification tool cho schema evolution
  - Active maintenance (vs Isar/Hive đang unmaintained)
  - SQL + `updatedAt` column → delta sync với Firestore dễ
- **Consequences:**
  - (+) Type-safe, testable, in-memory DB cho unit test
  - (+) Transactions + nested savepoints cho atomic recast
  - (−) Boilerplate table definitions nhiều hơn NoSQL
  - (−) Codegen step (build_runner) trong dev loop

---

## ADR-003: Firestore là optional sync layer, không phải source of truth

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** App cần backup cross-device + partner sharing (Tier 2 feature 2.4), nhưng phải giữ Local-first trust (Nguyên tắc 2).
- **Decision:** Progressive Trust Model 3 levels (xem feature-spec §1.6)
  - Level 0: Drift only, no account
  - Level 1: Drift + Firestore backup (opt-in)
  - Level 2: Drift + Firestore + sharing
- **Rationale:** Drift vẫn là source of truth, Firestore là "sync channel". App offline 100% vẫn full functional.
- **Consequences:**
  - (+) User kiểm soát trust leveling, có thể downgrade bất kỳ lúc nào
  - (+) Không vendor lock-in ở data layer
  - (−) Sync logic phức tạp hơn "Firestore as primary" (nhưng đáng)
  - (−) Cần conflict resolution strategy (xem ADR-012)

---

## ADR-004: Money lưu dạng integer cents, không bao giờ double

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** Binary floating-point không biểu diễn được `0.1`, `0.01` chính xác. Sai số tích lũy qua hàng trăm phép tính = mất trust.
- **Decision:**
  - **Storage:** `INTEGER` cents trong Drift (VD $1,234.56 → `123456`)
  - **Runtime:** `Decimal` từ package `decimal` cho phép tính (interest, rate)
  - **Display:** format qua `intl` chỉ ở presentation layer
  - **NEVER:** `double`, `REAL`, `float` cho money
- **Consequences:**
  - (+) Exact arithmetic, không sai số
  - (+) Integer cents dễ SUM trong SQL
  - (−) Conversion boundary giữa DB ↔ Dart ↔ UI cần convention rõ
  - (−) Developer phải nhớ: không phép tính trên raw int cents, phải convert sang Decimal

---

## ADR-005: Primary key dùng UUID v4 (text), không auto-increment

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** Sync với Firestore yêu cầu ID không đụng độ giữa devices. Auto-increment int sẽ đụng nếu 2 device tạo entity offline cùng lúc.
- **Decision:** UUID v4 string làm primary key cho mọi entity
- **Rationale:**
  - Firestore document ID = UUID v4 by convention
  - Drift column: `TextColumn` với default generate từ `uuid` package
  - Không collision risk ngay cả ở multi-device offline scenario
- **Consequences:**
  - (+) Sync-ready từ đầu, không migrate PK sau
  - (+) Foreign key bằng UUID string, dễ debug trong logs
  - (−) Index UUID text chậm hơn int nhẹ (negligible ở scale app này)
  - (−) String dài hơn int trong storage (~36 bytes vs 4-8) — không đáng kể

---

## ADR-006: Mọi table có `updatedAt` + `deletedAt` (soft delete)

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** Delta sync với Firestore cần biết rows nào changed since `lastSyncTime`. Hard delete làm mất khả năng sync "X đã bị xóa" sang device khác.
- **Decision:**
  - Mọi table có `createdAt`, `updatedAt` (TEXT ISO-8601 UTC)
  - Mọi table có `deletedAt` nullable — NULL = active, non-NULL = soft deleted
  - Query mặc định filter `WHERE deletedAt IS NULL`
  - Hard cleanup job chạy sau 90 ngày soft delete
- **Consequences:**
  - (+) Delta sync đơn giản: `WHERE updatedAt > lastSyncTime`
  - (+) Tombstone sync cho delete events
  - (+) User có thể recover accidentally deleted debt trong 90 ngày
  - (−) Phải nhớ filter `deletedAt IS NULL` ở mọi query (giải quyết bằng repository pattern)

---

## ADR-007: Enum lưu dạng string, không int

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** Enum có thể là int (ordinal) hoặc string (name). Int nhỏ hơn nhưng fragile khi reorder.
- **Decision:** String name (VD `"creditCard"`, `"snowball"`)
- **Rationale:**
  - Debug readable (SQL query ra `'creditCard'` dễ hiểu hơn `0`)
  - Firestore-friendly (Firestore không có enum type, dùng string)
  - Reorder enum trong Dart không break DB data
  - Thêm enum value mới không cần migration
- **Consequences:**
  - (+) Safer refactoring
  - (−) Slightly bigger storage (negligible)
  - (−) Cần validation khi parse string → enum (dùng Drift `TypeConverter`)

---

## ADR-008: Timestamp UTC; Date (due day) theo local

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** App có thể chạy ở nhiều timezone (user di chuyển, travel). Timestamp bản chất point-in-time → UTC. Date (như "due day 15 of month") bản chất là local calendar concept.
- **Decision:**
  - **Timestamps** (`createdAt`, `updatedAt`, `paidOffAt`, payment `date`): ISO-8601 UTC, stored TEXT
  - **Local dates** (`dueDayOfMonth` = 1-31, `firstDueDate`): stored theo timezone user
  - **Display:** convert UTC → device local timezone ở UI layer
- **Consequences:**
  - (+) Timestamp consistent qua timezone changes
  - (+) Due day không shift khi user travel
  - (−) Developer phải phân biệt 2 loại — document clearly trong schema

---

## ADR-009: Conflict resolution = Last-Write-Wins theo server timestamp

- **Status:** Accepted (MVP)
- **Date:** 2026-04-16
- **Context:** Khi user có 2 device cùng edit 1 row offline, sync lên thì resolve thế nào?
- **Decision:** **Last-Write-Wins (LWW)** theo Firestore `serverTimestamp()`
  - Mỗi row có `updatedAt` = server timestamp khi write
  - Conflict: keep row có `updatedAt` lớn hơn
  - Client cũng có `localUpdatedAt` — chỉ dùng local, không sync
- **Rationale:**
  - Đơn giản, đúng > 99% use case (user rarely edit cùng debt từ 2 device trong vài giây)
  - Per-field merge phức tạp, defer sang v2 nếu có user complaint
- **Consequences:**
  - (+) Implementation đơn giản
  - (−) Edge case hiếm: device A edit field X, device B edit field Y cùng row cùng lúc → device sau overwrite device trước toàn bộ row
  - **Mitigation:** UI show "synced X seconds ago" cho user biết state

---

## ADR-010: Sync trigger = on-write + foreground + manual

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** Khi nào push local changes lên Firestore?
- **Decision:** Combo 3 trigger:
  1. **On local write** (real-time, debounced 2s) — responsive
  2. **On app foreground** — catch offline changes
  3. **"Sync now" button** trong Settings — user control
- **Rationale:**
  - On-write giúp sharing (Level 2) real-time giữa owner và partner
  - Foreground trigger bắt missed syncs
  - Manual trigger cho power user debugging
- **Consequences:**
  - (+) Near-real-time sharing experience
  - (−) Firestore write count tăng — mitigate bằng debounce 2s và batch writes

---

## ADR-011: Sync scope = Debt + Payment + Plan + InterestRateHistory

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** TimelineProjection là cache compute từ 3 entity trên. Sync TimelineProjection = tốn Firestore cost mà recompute được.
- **Decision:** 
  - **Sync**: `Debt`, `Payment`, `Plan`, `InterestRateHistory`, `UserSettings`
  - **Không sync**: `TimelineProjection` (recompute on-device sau sync xong)
- **Consequences:**
  - (+) Giảm Firestore writes/reads ~70%
  - (+) TimelineProjection luôn fresh (recompute sau mỗi sync)
  - (−) First launch sau install cần recompute timeline — chấp nhận được (< 100ms)

---

## ADR-012: Firestore data shape = mirror Drift 1-1, per-user subcollection

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** Có thể denormalize cho query hiệu quả, hoặc mirror exact Drift structure.
- **Decision:** Mirror 1-1, scope per-user:
  ```
  users/{uid}/debts/{debtId}
  users/{uid}/payments/{paymentId}
  users/{uid}/plans/{planId}
  users/{uid}/interestRateHistory/{id}
  users/{uid}/settings/{doc}
  
  sharedPlans/{planId}  // Level 2, denormalize owner + partner UIDs
  ```
- **Rationale:**
  - Mirror giúp sync code đơn giản (không transform)
  - Per-user subcollection: security rules đơn giản (`request.auth.uid == resource.uid`)
  - SharedPlans tách riêng vì có list of partner UIDs
- **Consequences:**
  - (+) Security rules dễ viết và test
  - (+) Không double-write khi share (Level 2) vì owner data vẫn ở `users/{owner}`, partner access qua rule
  - (−) Query cross-debt của partner cần 2 round-trip (lấy sharedPlan → lấy owner's debts) — acceptable

---

## ADR-013: Anonymous → Email upgrade qua Firebase Auth linking

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** User ở Level 1 có thể là anonymous (auto-created UID) hoặc email. Khi upgrade anonymous → email, UID có đổi không?
- **Decision:** Dùng Firebase `linkWithCredential()` — giữ nguyên UID
- **Rationale:**
  - Không cần migrate data (`users/{uid}/...` giữ nguyên)
  - Không mất history khi user "sign up" sau đã dùng anonymous
- **Consequences:**
  - (+) Seamless upgrade path
  - (−) Edge case: nếu email đã có account khác → conflict, user phải chọn (handle trong UI)

---

## ADR-014: Multi-scenario support — `scenarioId` column từ v1

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** Tier 2 feature 2.1 (What-If Scenario) cần nhiều plan song song. Thêm cột ngay v1 tránh migrate sau.
- **Decision:**
  - `Debt`, `Plan`, `Payment` có `scenarioId` column, default `"main"`
  - Main scenario là source of truth, các scenario khác chỉ dùng để so sánh
  - Payments **chỉ log vào main scenario** — what-if không có real payments
- **Consequences:**
  - (+) v1 schema đã ready cho Tier 2, không migration breaking
  - (+) Clear separation: "real" vs "hypothetical"
  - (−) Extra column + index trong v1 (nhỏ, không impact)

---

## ADR-015: Testing — Drift in-memory + property-based cho Engine

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** Financial engine cần test kỹ vì sai 1 công thức = mất trust. Property-based test bắt bug subtle mà example test không bắt được.
- **Decision:**
  - **Unit test** repositories: Drift `NativeDatabase.memory()`
  - **Property-based test** FinancialEngine: package `glados`
    - Monotonicity: tăng extra → debt-free date không trễ hơn
    - Avalanche optimality: total_interest(avalanche) ≤ total_interest(snowball)
    - Rollover conservation: Σ principal paid = Σ balance reduction
  - **Golden test** cho test vectors trong financial-engine-spec §12
  - **Integration test** cho sync flow với Firebase emulator
- **Consequences:**
  - (+) Hàng rào toàn diện chống regression
  - (−) Test suite chạy lâu hơn (chấp nhận được: < 30s local, < 2min CI)

---

## ADR-016: Migration strategy = Drift schema versioning + verification

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** Khi thêm column (VD forbearance fields Tier 2), phải migrate mà không mất data.
- **Decision:**
  - Dùng Drift `schemaVersion` + `MigrationStrategy`
  - Chạy `drift_dev schema dump` sau mỗi release → commit schema snapshot
  - CI step verify migration từ mỗi version cũ → version mới không crash
  - Mỗi migration chạy trong transaction (rollback nếu fail)
- **Consequences:**
  - (+) Migration safe, có thể rollback
  - (+) Schema history tracked trong git
  - (−) Release process có thêm step verify

---

## ADR-017: Encryption at rest — defer đến Premium

- **Status:** Accepted (deferred)
- **Date:** 2026-04-16
- **Context:** SQLCipher cho encryption at rest tăng bundle ~3MB và complexity (key management).
- **Decision:**
  - **MVP:** không encrypt (rely on OS-level sandboxing của iOS/Android)
  - **Premium:** bật SQLCipher với key derived từ user password hoặc biometric
- **Rationale:** Data tài chính cá nhân không phải top-secret; OS sandboxing đủ cho 95% threat model. Premium users cần cao hơn → có.
- **Consequences:**
  - (+) MVP nhẹ, fast iteration
  - (−) Cần migration path từ non-encrypted → encrypted khi user upgrade Premium

---

## ADR-018: Repository pattern — không expose Drift types ra domain/UI

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** Nếu UI watch trực tiếp Drift row class, khi đổi DB schema → UI break khắp nơi.
- **Decision:** 3 layer strict:
  - **Data layer** (Drift): tables, generated companion classes
  - **Repository layer**: expose `Stream<Debt>` với `Debt` là domain model (plain Dart class)
  - **UI layer**: consume streams từ repository
  - Conversion Drift row ↔ Domain model ở repository boundary
- **Consequences:**
  - (+) UI không biết DB structure → refactor DB dễ
  - (+) Domain model có thể có logic (VD `debt.isPastDue`) không pollute DB layer
  - (−) Boilerplate mapper functions — giải quyết bằng extension method hoặc code gen

---

## ADR-019: Firestore cost optimization — batch writes + debounce

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** Free tier 20k writes/ngày. User log 5 payments nhanh → 5 writes riêng = lãng phí.
- **Decision:**
  - Debounce local changes 2s trước khi push
  - Batch writes theo entity type (tối đa 500 ops/batch)
  - Không push `localUpdatedAt`-only changes (chỉ push business fields)
- **Consequences:**
  - (+) Free tier support ~500-1000 active users
  - (−) Sync delay 2s — acceptable, user không perceive

---

## ADR-020: Observability — log structured, không PII

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** Cần debug production issue mà không leak tài chính cá nhân.
- **Decision:**
  - Structured log (JSON) với fields: `event`, `debtId` (UUID, không phải name), `amountBucket` (range, không phải exact)
  - **Không log:** debt names, exact amounts, APR, user email
  - Crash reporting (Firebase Crashlytics) với sanitized stack trace
- **Consequences:**
  - (+) Debug được mà không vi phạm privacy
  - (−) Đôi khi khó reproduce bug khi không có exact amount

---

## ADR-021: Monthly Action View — computed on-the-fly, không pre-generate

- **Status:** Accepted
- **Date:** 2026-04-16
- **Context:** Monthly Action View (Feature §1.5) cần danh sách "tháng này phải trả gì" cho mỗi active debt. Có 2 approach: (A) Pre-generate planned payment records vào DB đầu mỗi tháng, (B) Compute on-the-fly từ active debts + plan.
- **Decision:** **Option B — Compute on-the-fly**
  - Monthly Action View gọi `compute_monthly_schedule(active_debts, plan)` mỗi khi render
  - Khi user check off → tạo `Payment` record mới với `source = checkOff`, `status = completed`
  - Không auto-create `missed` records — app chỉ cảnh báo
- **Rationale:**
  - Đúng nguyên tắc Living Plan (Nguyên tắc 1): recompute, không freeze static data
  - Không cần batch job đầu tháng → đơn giản hơn
  - Khi edit debt/plan → monthly view tự cập nhật, không cần cleanup planned records cũ
  - Idempotent: mở view 10 lần không tạo duplicate planned payments
- **Consequences:**
  - (+) Đơn giản, UI luôn reflect current plan state
  - (+) Không có orphaned planned records khi plan changes
  - (−) Cần recompute mỗi khi mở view (trivial perf, < 1ms cho 20 debts)
  - (−) "Planned" payments không visible trong payment history cho đến khi user check off

---

## Summary — Quick reference

| ADR | Quyết định | Impact |
|---|---|---|
| 001 | Flutter + Dart | Tech foundation |
| 002 | Drift local DB | Data layer core |
| 003 | Firestore optional sync | Trust architecture |
| 004 | Integer cents + Decimal | Precision guarantee |
| 005 | UUID v4 PK | Sync-ready IDs |
| 006 | updatedAt + deletedAt mọi table | Delta sync enabler |
| 007 | Enum as string | Migration safety |
| 008 | UTC timestamp, local Date | Timezone correctness |
| 009 | LWW conflict resolution | Sync simplicity |
| 010 | Sync on write + foreground + manual | UX responsiveness |
| 011 | Sync scope excludes TimelineProjection | Cost optimization |
| 012 | Firestore 1-1 mirror, per-user | Security simplicity |
| 013 | Firebase Auth linking | Anon → email path |
| 014 | scenarioId từ v1 | Tier 2 readiness |
| 015 | In-memory + property-based tests | Engine trust |
| 016 | Drift schema versioning | Migration safety |
| 017 | Encryption deferred to Premium | MVP scope |
| 018 | Repository pattern | Layer isolation |
| 019 | Batch + debounce sync | Firestore cost |
| 020 | Sanitized logging | Privacy |
| 021 | Monthly Action View on-the-fly | Living Plan simplicity |

---

> **Override protocol:** Nếu cần thay đổi ADR đã Accepted, tạo ADR mới với "Supersedes: ADR-XXX" và mark ADR cũ thành "Superseded by ADR-YYY". Giữ history để audit.
