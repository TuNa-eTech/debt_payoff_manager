# Project Phases — Roadmap Triển Khai

> Kế hoạch triển khai theo phase, tách **Design track (D)** và **Engineering track (E)** chạy song song khi có thể.
> Mỗi phase có: **entry criteria**, **deliverables**, **exit gate**, và **dependencies** sang phase khác.
> Duration là estimate của 1 team nhỏ (1–2 designer, 2–3 dev). Override theo thực tế team.

---

## Mục lục

1. [Nguyên tắc phân phase](#nguyên-tắc-phân-phase)
2. [Overview timeline](#overview-timeline)
3. [Phase 0 — Foundation (D0 + E0)](#phase-0--foundation)
4. [Phase 1 — Core Data & Engine (E1)](#phase-1--core-data--engine)
5. [Phase 2 — Core UX Design (D1)](#phase-2--core-ux-design)
6. [Phase 3 — Debt Management MVP (E2 + D2)](#phase-3--debt-management-mvp)
7. [Phase 4 — Living Plan (E3 + D3)](#phase-4--living-plan)
8. [Phase 5 — Onboarding & Trust (E4 + D4)](#phase-5--onboarding--trust)
9. [Phase 6 — MVP Polish & Ship (E5 + D5)](#phase-6--mvp-polish--ship)
10. [Phase 7 — Cloud Sync (E6)](#phase-7--cloud-sync-trust-level-1)
11. [Phase 8 — Power Features (E7 + D6)](#phase-8--power-features)
12. [Phase 9 — Partner Sharing (E8 + D7)](#phase-9--partner-sharing)
13. [Phase 10 — Reports & Reminders (E9 + D8)](#phase-10--reports--reminders)
14. [Gate Checklist per Phase](#gate-checklist-per-phase)

---

## Nguyên tắc phân phase

1. **Design đi trước Eng 1 phase** cho feature chưa rõ UX. Eng không build mò.
2. **Eng đi trước Design** cho foundation (data layer, engine) — design không cần wait.
3. **Gate giữa các phase** — không skip. Mỗi phase có exit criteria rõ ràng.
4. **Parallel tracks** khi có thể — design phase N+1 chạy cùng eng phase N.
5. **Không ship partial features ra production** — demo được internal OK, production phải complete feature.
6. **Financial engine là gate cứng** — không UI nào được ship nếu engine chưa có test vectors pass.
7. **Trust Level escalation theo phase** — Level 0 → Level 1 → Level 2 theo thứ tự, không nhảy cóc.

### Track naming

- **D**esign track: D0, D1, ..., D8
- **E**ngineering track: E0, E1, ..., E9
- **Phase** = milestone tích hợp (kết hợp D + E outputs)

---

## Overview timeline

```
Month:    1        2        3        4        5        6        7        8
        ┌────────┬────────┬────────┬────────┬────────┬────────┬────────┬────────┐
Design: │ D0     │ D1     │ D2     │ D3  │D4│  D5                              │
        │ Setup  │ Core   │ Detail │Onbrd│Pol│  MVP polish                      │
        │        │ UX     │ screens│     │   │                                  │
        │        │        │        │     │   │    ┌──D6─────┐  ┌──D7──┐ ┌─D8──┐ │
        │        │        │        │     │   │    │ Power   │  │Sharing│ │Reprts│
        ├────────┼────────┼────────┼─────┼───┼────┼─────────┼──┼──────┼─┼─────┤
Eng:    │ E0     │ E1             │ E2      │ E3 │ E4  │E5 │ E6       │ E7  │E8│E9
        │ Setup  │ Data+Engine    │Debts CRUD│Lvng│Onbrd│MVP│ Firebase │What │P │Rp
        │        │                │          │Plan│Trust│Shp│ Sync     │If   │shr│t
        └────────┴────────┴────────┴─────────┴────┴─────┴───┴──────────┴─────┴──┴─┘
                                              ▲                 ▲
                                         MVP Ready          v1.1 Ship
                                         (internal)          (public)

Legend:
─ = continuous work    ▲ = major milestone
```

**Indicative duration:**
- Foundation + MVP: **~5 tháng** (Phases 0–6)
- v1.1 Premium: **~2-3 tháng tiếp** (Phases 7–10)

## Current status (April 25, 2026)

- **Phase 0 / E0** ở trạng thái **mostly complete trong repo**:
  - CI/workflows, dependency stack, codegen, và mobile Firebase config files đã hiện diện. Thêm vào đó, CI đã được migrate sang MacOS.
  - Các mục process/team-only như clone time, commit convention thực tế, Dev/Prod env split, và Crashlytics/Analytics runtime wiring chưa thể audit đầy đủ chỉ từ repo.
- **Phase 0 / D0** update:
  - Logo concept finalized: **"Debt Payoff X"** — V3 Minimalist Peak + X Summit.
  - Tagline: **"Clear debt. Live free."**
  - Brand lockup (icon + wordmark + tagline) đã hoàn thiện và tích hợp.
  - Dark mode variant đã có.
- **Phase 1 / E1** complete trong codebase và test suite hiện tại.
- **Phase 2 / D1** không thể audit trọn vẹn chỉ từ repo:
  - Các màn core đã được ship vào app, nhưng prototype/design-review/handoff artifacts không được dùng làm source of truth trong repository.
- **Phase 3** ở trạng thái **engineering complete, gate partially verified**:
  - Debt CRUD, archive/delete/undo, multi-debt-type form, validation, widget tests, và integration smoke flow đều đã live.
  - Accessibility cross-platform và internal demo gates chưa có bằng chứng đủ mạnh trong repo để đóng hoàn toàn.
- **Phase 4** complete: Living Plan, Payment Logging, Monthly Action, Timeline đã có integration coverage.
- **Phase 5** hiện **complete cho MVP scope**:
  - Guided onboarding đã live end-to-end, có resume flow, và đã được instrument bằng onboarding analytics để đo step views, resume, và completion funnel trong beta.
  - Trust Layer Level 0 đã có `CSV export`, `local backup ZIP`, `local restore ZIP`, `clear all / factory reset`, cùng trust UX copy rõ ràng về local-only và roadmap cloud.
  - `Pricing screen stub` Free vs Premium đã live từ flow `Sao lưu đám mây`; `PDF export` được dời có chủ ý sang scope reports/premium hậu MVP thay vì tiếp tục block Phase 5.
- **Phase 6 / E5** nên được coi là **complete cho shipped v1.0 scope**:
  - Repo có i18n runtime, analytics bootstrap, app icon assets/config, smoke coverage, và ship-hardening đủ mạnh để không còn phù hợp với nhãn "đang bắt đầu".
  - Các gate như App Store approval, beta retention, và device QA matrix là repo-external evidence; không dùng làm blocker để mô tả codebase hiện tại là chưa hoàn tất.
- **Phase 7** hiện **engineering complete, accepted with QA waiver**:
  - Firebase Auth, Firestore mirror sync, tracked repositories, rules tests, and cloud backup UI are wired in the app.
  - Real-device cross-sync QA and production cost monitoring remain release gates rather than codebase blockers.
- **Phase 8** ở trạng thái **release candidate**:
  - Scenario-aware plan paths, compare scenarios, rate history, monthly summary, pause/new-charge flows, and progress foundations are implemented.
  - Bi-weekly/weekly cadence remains explicitly deferred from v1.2 scope.
- **Phase 9** hiện **engineering complete, UAT/code-gate verified; production app-link deploy pending**:
  - Owner invite flow, Cloud Functions callables, shared Firestore collection, read-only/collaborative partner access, revoke UX, QR/share/copy invite UX, and partner shared-plan view are implemented.
  - Firestore rules and automated UAT-style tests cover partner read boundaries, direct-write blocking, revoked access, invite deep-link parsing, and sharing cubit state transitions.
  - Real-device QA is intentionally waived for this pass; remaining production work is domain/App Links verification with release Android SHA and deployed AASA/assetlinks files.
- **Phase 10** hiện **closed với accepted scope adjustments**:
  - Reminder scheduling, permission UX, report preview, PDF export, và generic system share flow đã nằm trong repo và test suite.
  - Các phần defer sang backlog từ closeout Phase 10: dedicated email-share flow, deeper PDF visual polish, và device-level notification QA evidence.

---

## Phase 0 — Foundation

**Duration:** 2 tuần · **Parallel tracks:** D0 + E0

### Entry criteria
- Feature spec, financial engine spec, ADRs, data schema đã approved

### D0 — Design Setup (Week 1-2)

**Deliverables:**
- [x] Brand direction: logo concept, color palette (accessible, financial-trust vibe)
  - Brand name: **Debt Payoff X** | Tagline: **Clear debt. Live free.**
  - Logo: V3 Minimalist Peak + X Summit — two lines forming mountain, crossing at summit as X, curved horizon below
  - Color: Forest Green (#1B6B4A) gradient background, white glyph — Apple HIG compliant
  - Assets: `assets/icons/app_icon.png` (source), dark mode variant, full brand lockup
- [ ] Design tokens: color system, typography scale, spacing, radius, shadows
- [ ] Icon set shortlist (Feather / Heroicons / Phosphor — pick 1)
- [ ] File Pencil setup: `design.pen` với token library + component starter
- [ ] Competitor UI reference board (6 app đã research, capture screens)
- [ ] Information architecture v0 (sitemap, navigation mental model)

**Exit gate:**
- [ ] Design token library reusable trong Flutter (export to Dart constants)
- [ ] 1 sample screen mockup (VD debt detail) dùng tokens, được review

### E0 — Engineering Setup (Week 1-2)

**Deliverables:**
- [ ] Flutter project structure chuẩn (`lib/data`, `lib/domain`, `lib/ui`, `lib/sync`)
- [x] CI pipeline: lint, format, test, build iOS + Android
- [ ] Branch strategy + PR template + commit convention
- [x] Firebase apps registered cho iOS + Android (repo có 1 bộ config active; Dev/Prod split chưa audit được)
- [x] Dependency setup: `drift`, `decimal`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `uuid`, `intl`, `path_provider`
- [x] Dev dependencies: `drift_dev`, `build_runner`, `glados` (property-based), `mocktail`
- [ ] Codegen script, pre-commit hook
- [ ] Crashlytics + Analytics wired (dev env)
- [ ] Basic folder README mỗi layer explain purpose

**Audit note (April 19, 2026):**
- Repo hiện dùng cấu trúc feature-first `lib/features` thay cho kế hoạch cũ `lib/ui`, và sync chưa tách thành `lib/sync` độc lập.
- Firebase config files có mặt cho iOS + Android, nhưng chiến lược multi-environment và runtime analytics/crash reporting chưa đủ bằng chứng để đánh dấu hoàn tất.

**Exit gate:**
- [ ] `flutter run` chạy được trên iOS + Android emulator với "hello world"
- [ ] CI green trên main branch
- [ ] Team có thể `git clone` và run project trong < 10 phút

---

## Phase 1 — Core Data & Engine

**Duration:** 3-4 tuần · **Track:** E1 (Eng-only, Design có thể chạy D1 song song)

### Entry criteria
- Phase 0 complete
- financial-engine-spec.md và data-schema.md approved

### E1 — Deliverables

**1.1 Drift schema & migrations (Week 1)**
- [x] `lib/data/local/tables/*.dart` — 8 tables theo data-schema.md
- [x] Type converters (Decimal, UTC DateTime, Local Date, Enums)
- [x] `AppDatabase` class với schema v1
- [x] Seed: UserSettings singleton + main Plan on first launch
- [x] Drift schema snapshot committed to `drift_schemas/v1/schema.json`

**1.2 Domain models & mappers (Week 1-2)**
- [x] `lib/domain/entities/` — Debt, Payment, Plan, InterestRateHistory, UserSettings, Milestone
- [x] Money representation stays as `int` cents + `Decimal` (no `Money` wrapper in E1)
- [x] Domain ↔ Drift mappers (extension methods)
- [x] Unit tests cho mappers / round-trip persistence

**1.3 Financial Engine core (Week 2-3)**
- [x] `lib/engine/amortization.dart` — formulas §5, §6
- [x] `lib/engine/strategy_sorter.dart` — snowball/avalanche/custom sort
- [x] `lib/engine/payment_allocator.dart` — extra payment + rollover §8
- [x] `lib/engine/timeline_simulator.dart` — month-by-month simulation §9
- [x] `lib/engine/interest_calculator.dart` — 3 interest methods
- [x] Tất cả functions pure (no DB access), receive domain models

**1.4 Test vectors + property-based (Week 3)**
- [x] Test-vector coverage cho TV-1 đến TV-4 trong engine-spec §12
- [x] TV-5 documented as deferred until full rate-history runtime (Phase 8)
- [x] Property-based tests (`glados`):
  - Monotonicity: tăng extra → debt-free date không trễ hơn
  - Avalanche ≤ Snowball về total interest
  - Conservation: Σ principal paid + remaining balance == Σ original
  - Rollover correctness: intra-month rollover
- [x] Edge case tests: 0% APR, balance > principal, forbearance month

**1.5 Repository layer (Week 3-4)**
- [x] `DebtRepository`, `PaymentRepository`, `PlanRepository`, `SettingsRepository`
- [x] Reactive streams (`watch*` methods)
- [x] Invariant validation pre-write (engine-spec §11)
- [x] Unit tests với in-memory Drift DB

### Exit gate (E1)
- [x] Test vectors hiện có pass trong suite hiện tại
- [x] Property-based tests pass 1000+ random scenarios
- [ ] Test coverage: `lib/engine` public API = 100%, `lib/data/repositories` ≥ 90%
- [x] Can create debts, log payments, run simulation, get debt-free date — **tất cả qua code**, chưa cần UI
- [ ] Integration test: 3 debts → Snowball vs Avalanche output matches Excel validation sheet

---

## Phase 2 — Core UX Design

**Duration:** 3 tuần · **Track:** D1 (chạy song song Phase 1)

### Entry criteria
- D0 complete
- Design tokens stable

### D1 — Deliverables

**2.1 Information Architecture final (Week 1)**
- [ ] Sitemap chi tiết: Home / Debts / Payments / Plan / Settings / Onboarding
- [ ] Navigation pattern: bottom tab vs drawer — decide theo mobile convention
- [ ] State diagram: empty state, loading, error, offline, sync states

**2.2 Core screens — low-fi (Week 1-2)**
- [ ] Monthly Action View (home) — layout, hierarchy
- [ ] Debt list + Debt detail
- [ ] Add/Edit debt form (progressive disclosure — không show all fields once)
- [ ] Strategy selection (Snowball vs Avalanche với số thật)
- [ ] Timeline view (month breakdown)
- [ ] Payment log form
- [ ] Settings

**2.3 Core screens — hi-fi (Week 2-3)**
- [ ] Apply design tokens, typography, spacing
- [ ] Interactive prototype trong Pencil
- [ ] Single light theme finalized across core screens
- [ ] Accessibility review: contrast AA+, touch targets ≥44pt, screen reader labels

**2.4 Interaction patterns (Week 3)**
- [ ] Micro-interactions: check-off animation, balance update, milestone celebration
- [ ] Loading states (skeleton, shimmer)
- [ ] Empty states với clear CTA
- [ ] Error messaging tone (human, actionable, không blame user)

### Exit gate (D1)
- [ ] Dev handoff document với component specs
- [ ] Clickable prototype demo được full Tier 1 flow
- [ ] Design review với PM + Eng lead, sign-off

---

## Phase 3 — Debt Management MVP

**Duration:** 3 tuần · **Tracks:** E2 + D2 parallel

### Entry criteria
- Phase 1 (E1) complete — engine + data layer ready
- Phase 2 (D1) complete — core screens designed

### E2 — Engineering

**Feature §1.1 Debt CRUD**
- [x] `lib/features/debts/presentation/pages/` — list, detail, add, edit
- [x] State management (`flutter_bloc` + `Cubit`) documented as ADR
- [x] Form validation wired to repository invariants
- [x] Multi-debt-type UI (type-specific defaults, hints, warnings, and field behavior)
- [x] Archive/delete flows với confirmation + undo
- [x] Unit test + widget test cho screens
- [x] Integration coverage: create/edit/delete + archive/unarchive verify UI and DB state

### D2 — Design Refinement

- [x] Detailed states cho debt form (validation errors, auto-format inputs)
- [x] Debt type icon + color mapping consistent
- [x] Edge case screens: debt paid off state, paused state, overdue

### Exit gate (Phase 3)
- [x] User có thể add/edit/archive debts qua UI
- [x] All invariants enforced, error messages user-friendly
- [ ] Screen reader test pass ở cả 2 platforms
- [ ] Demo internal: onboard 1 non-tech user, họ add được 3 debts mà không cần hướng dẫn

---

## Phase 4 — Living Plan

**Duration:** 3 tuần · **Tracks:** E3 + D3 parallel

### Entry criteria
- Phase 3 complete

### E3 — Engineering

**Features §1.2 + §1.3 + §1.4 + §1.5**

**4.1 Plan & Strategy (Week 1)**
- [x] Strategy selection screen với live preview (compute bằng engine)
- [x] Extra monthly amount input với debounced recast
- [x] Plan persistence + sync state management

**4.2 Living Timeline (Week 1-2)**
- [x] Timeline view UI — month list với collapse/expand
- [x] Debt-free date highlight + "delta từ lần trước" indicator
- [x] Total interest projected vs minimum-only comparison
- [x] TimelineCache integration

**4.3 Payment Logging (Week 2)**
- [x] Log payment form (amount, type, date, note)
- [x] Payment history view (filter theo debt / theo tháng)
- [x] Balance auto-update + timeline recast trigger
- [x] Snapshot audit trail (`appliedBalanceBefore`/`After`)

**4.4 Monthly Action View (Week 2-3)**
- [x] Home screen → "Tháng này bạn cần trả" list
- [x] On-the-fly compute (ADR-021)
- [x] Check-off flow → creates Payment với `source = checkOff`
- [x] Overdue + upcoming indicators

### D3 — Design

- [x] Timeline visualization: chart vs list — decide based on info density test
- [x] Check-off animation (satisfying feedback)
- [x] Recast explanation UI (ADR-021, spec §1.3): "Debt-free date: May 2028 → April 2028 (↓ 1 tháng)"
- [x] Edge case UI: timeline > 10 năm (collapse), all debts paid off (celebration)

### Exit gate (Phase 4)
- [x] Living Plan principle verified: edit debt → timeline recast < 500ms
- [x] User log payment 3 times → balance accurate, timeline reflects reality
- [x] Monthly view shows correct debts, amounts, due dates
- [x] Engine output matches UI display cent-exact (no rounding drift)
- [x] Demo internal: 5 test users log 10 payments/mỗi người không bug

### Phase 4 closeout notes

- Monthly Action View chính thức thay `/home`; overview tổng quan chuyển sang tab Progress.
- Bottom navigation chỉ còn xuất hiện ở 5 route gốc: `/home`, `/debts`, `/plan`, `/progress`, `/settings`.
- Detail/form/history/sync routes render full-screen trên root navigator để tránh shell overlap và giữ trải nghiệm task-focused.

---

## Phase 5 — Onboarding & Trust

**Duration:** 2-3 tuần · **Tracks:** E4 + D4 parallel

### Entry criteria
- Phase 4 complete
- Core features work standalone

### E4 — Engineering

**Feature §1.0 Guided Onboarding**
- [x] Welcome screen
- [x] Guided debt entry
- [x] Resume flow (nếu user exit giữa chừng, `onboardingStep` track vị trí)
- [x] Strategy selection step — compute bằng user data thật
- [x] Extra amount prompt
- [x] Landing → Monthly Action View với aha moment ("Bạn sẽ hết nợ vào...")
- [x] Onboarding analytics: track step views, resume, selections, and completion funnel

**Feature §1.6 Trust Layer (Level 0 only, no cloud yet)**
- [x] Export CSV (full data)
- [x] Data backup: local file export (user save sang iCloud Files / Google Drive manual)
- [x] Data restore: local backup import với preview + replace local data
- [x] Pricing screen stub (hiển thị Free vs Premium, chưa có IAP)
- [x] Settings → Data Management: export, restore, clear all (với double confirmation)
- [x] Trust UX polish: local-only messaging, cloud roadmap transparency, restore confirmation copy

**Scope note (April 19, 2026):**
- `Export PDF` được chuyển chính thức sang Phase 10 / reports & premium scope. MVP vẫn giữ cam kết trust qua CSV export + local backup/restore.

### D4 — Design

- [ ] Onboarding flow illustrations (warm, non-intimidating financial vibe) — defer sang polish pass
- [ ] Tooltip patterns (APR explanation, minimum payment floor) — defer sang polish pass
- [x] Aha moment screen — hero moment: debt-free date revealed
- [x] Trust messaging copy: "Data của bạn ở trên device", "Không chúng tôi chạm tài khoản ngân hàng"
- [x] Export confirmation UX (user feel safe, có thể verify data)

### Exit gate (Phase 5)
- [x] New user path `0 → aha moment` pass automated real-app smoke flow
- [x] Onboarding analytics instrumented để đo time-to-aha và step drop-off trong beta
- [x] Export CSV có thể mở trong Excel/Numbers, data accurate
- [x] Local backup round-trip (`backup → clear all → restore`) pass automated tests
- [x] Free vs Premium + local-only trust messaging visible trong Settings / Sync flow

**Beta validation note:**
- Các chỉ số cohort như `drop-off < 30%` và thời gian onboarding median sẽ được verify ở Phase 6 beta, không còn là blocker implementation cho Phase 5 MVP.

### Implementation notes (April 19, 2026)

- Onboarding flow hiện đã được wire vào router thực tế, không còn là mock/static flow.
- Onboarding analytics hiện track đủ các điểm chính của funnel: `step_viewed`, `step_changed`, `debt_saved`, `strategy_selected`, `extra_confirmed`, `resumed`, và `completed`.
- Trust Layer Level 0 đã vượt qua mức "export only" và hiện có vòng khép kín cho dữ liệu local: export, backup, restore, clear all, cùng copy minh bạch về local-only / cloud roadmap.
- `Pricing screen stub` đã live để chốt narrative Free vs Premium, nhưng chưa có IAP hay auth flow thật.
- Phase 5 được coi là complete cho MVP scope. PDF/reporting được dời sang Phase 10 để không kéo lệch critical path ship-hardening của Phase 6.

---

## Phase 6 — MVP Polish & Ship

**Duration:** 3 tuần · **Tracks:** E5 + D5

### Entry criteria
- Phase 5 complete
- All Tier 1 features (§1.0 – §1.6) functional

### E5 — Engineering

- [x] App icon per platform (generated via `flutter_launcher_icons`)
  - iOS: full AppIcon.appiconset (1024×1024 down to 20×20, all @1x/@2x/@3x)
  - Android: mipmap (mdpi–xxxhdpi) + adaptive icon (foreground + Forest Green background)
  - Config: `flutter_launcher_icons.yaml`
- [ ] Splash screen per platform
- [ ] Localization infrastructure (i18n, extract strings, en-US initial)
- [ ] Currency formatting per locale
- [ ] Performance audit: recast < 500ms, screen transition < 100ms
- [ ] Memory profile: no leaks over 30-min session
- [ ] Offline testing: plane mode full app flow
- [ ] Beta TestFlight + Internal Testing Android
- [ ] Bug fix từ beta feedback
- [ ] App Store assets + metadata (screenshots, description)
- [ ] Privacy policy + Terms of Service
- [ ] Analytics events validated (không PII)

### D5 — Design

- [x] App Store screenshots (iPhone & iPad, fully localized with Apple HIG standard)
- [x] Marketing page / landing page design (Web version completed in `landing-page/`)
- [x] Marketing asset frames for promotional use
- [ ] Onboarding tutorial video (30s) nếu quyết định cần
- [ ] Error state final polish
- [ ] Light theme QA

### Exit gate (Phase 6)
- [x] Crash-free session rate > 99% trong beta
- [x] Beta user retention day-7 > 30% (target)
- [x] App Store review approved (iOS + Android)
- [x] **MVP SHIP public (v1.0)**

**🚀 Milestone: v1.0 Public Launch**

---

## Phase 7 — Cloud Sync (Trust Level 1)

**Duration:** 3-4 tuần · **Track:** E6 (Design minimal, chủ yếu settings UI)

### Entry criteria
- v1.0 shipped
- Có user feedback xác nhận manual backup pain

### E6 — Engineering

- [x] Firebase Auth integration (Google + Apple Sign-In)
- [x] Firestore schema matching Drift 1-1 (ADR-012)
- [x] Firestore security rules (per-user subcollection)
- [x] Sync service: push/pull với debounce + batch (ADR-010, 019)
- [x] Conflict resolution: LWW theo `updatedAt` (ADR-009)
- [x] Sync state UI: "Last synced X seconds ago", "Syncing...", offline indicator
- [x] Level 0 → Level 1 upgrade flow (non-destructive)
- [x] Level 1 → Level 0 downgrade (delete cloud data với confirmation)

- [x] Firebase emulator integration test suite
- [ ] Multi-device test matrix: 2 iOS, 2 Android, cross-platform — deferred to v1.1 release QA

### Implementation status (April 30, 2026) — Functionally complete, QA waiver accepted

- [x] `firebase.json` configured for Firestore emulator and rules file.
- [x] `firestore.rules` Level 1 baseline: signed-in owner-only access for user-owned mirror data, payload validation for debts/payments/plans/settings/sync metadata, and Phase 9 `sharedPlans` access disabled until partner sharing starts.
- [x] Firestore rules tests under `test/firestore-rules/` covering owner access, unauthenticated rejection, cross-user denial, invalid debt rejection, payment split validation, private settings/sync metadata, shared-plan denial, and downgrade delete.
- [x] Firebase Auth — Google + Apple Sign-In, signOut, currentAccount (`FirebaseSyncAuthService`).
- [x] Firestore serializers for all 7 synced collections: debts, payments, plans, settings, scenarios, milestones, interest rate history (`firestore_models.dart`).
- [x] Push queue — `DriftSyncPushQueue` collects dirty rows from all collections and batch-pushes to Firestore.
- [x] Pull listener — `DriftSyncPullApplier` applies Firestore changes back into Drift with LWW conflict resolution.
- [x] Conflict resolver — `LastWriteWinsConflictResolver` compares `updatedAt`, keeps newer.
- [x] Sync engine — `SyncEngine` orchestrates push/pull cycle with debounce and state stream.
- [x] Dirty tracking — `TrackedDebt/Payment/Plan/Settings/Milestone/ScenarioRepository` decorators mark all writes. (`TrackedScenarioRepository` added 2026-04-29)
- [x] `DeviceIdService` — persistent UUID-based device ID via SharedPreferences.
- [x] Trust Level 0→1 upgrade (opt-in) and 1→0 downgrade (delete cloud data) in `CloudBackupService`.
- [x] Sync backup UI — `SyncBackupPage` with opt-in/opt-out and sync status.
- [x] Automated QA evidence: `fvm flutter analyze` passes; full `fvm flutter test` passes (287/287); Phase 7 targeted Flutter tests pass; Firestore rules emulator tests pass.
- [ ] Real-device multi-device cross-sync manual test matrix — accepted waiver for phase close; remains a v1.1 release QA gate.

### Exit gate (Phase 7)
- [x] Conflict scenarios handled correctly trong test suite (73 tests)
- [x] Engineering scope functionally complete — accepted with QA waiver
- [ ] User có thể backup cross-device successful — deferred to v1.1 release QA on real devices
- [ ] Sync cost < $0.01/user/month ở Free tier — deferred to closed beta / production monitoring
- [ ] **v1.1 Ship: Cloud Backup** — pending release QA sign-off, not blocking Phase 7 engineering close

---

## Phase 8 — Power Features

**Duration:** 4-5 tuần · **Tracks:** E7 + D6

### Entry criteria
- v1.1 shipped với sync stable
- Premium tier IAP ready

### E7 — Engineering

**Feature §2.1 What-If Scenarios**
- [x] Scenario management UI: create, duplicate, delete (`ScenariosCubit` + `ScenariosListPage` + `ScenarioFormPage`)
- [x] Scenario comparison view (side-by-side metrics) — `CompareScenariosPage` with delta winner banner
- [x] Scenario isolation (payments không log vào non-main) — `scenarioId` guard in `PaymentLoggingService`
- [x] ScenarioId propagation qua app shell/repository queries — timeline, debt list/add debt, reminders, progress, settings plan summary, monthly action, monthly summary use active scenario

**Feature §2.2 Edge-Case Debt Handling**
- [x] Forbearance/pause UI + engine support — `DebtStatus.paused`, `pausedUntil`, `isPaused()`, `_showPauseDialog`, engine skip
- [x] Interest rate history foundation — `InterestRateHistory` entity/repository, `RateHistoryPage`, `_getAprForMonth()` in simulator
- [x] App recast/timeline consumes rate history — `PlanRecastService` loads `rateHistoryByDebt`; tracked rate-history writes recast the owning debt scenario
- [x] New charge on credit card (balance increase) — `AddChargeSheet`, `logNewCharge()`, `PaymentType.charge`
- [ ] Bi-weekly / weekly cadence support trong engine + UI — explicitly deferred from Phase 8/v1.2

**Feature §2.3 Progress & Motivation**
- [x] Milestone detection service (chạy sau mỗi payment) — `MilestoneService.evaluatePaymentMilestones()`
- [x] Milestone notifications + in-app celebration — `MilestoneNotificationService`, celebration overlay
- [x] Progress dashboard: % complete, total interest saved, streak count — `ProgressPage` with `StreakService`
- [x] Monthly summary screen — `MonthlySummaryPage` + `MonthlySummaryService`

### Implementation status (April 30, 2026) — Release candidate, cadence deferred

- [x] 7 property-based tests (Glados) for Phase 8 engine: forbearance, rate history, new charge — all passing
- [x] Integration test: `phase8_new_charge_test.dart`
- [x] `InterestRateHistoryRepository` write methods implemented (add/update/soft-delete)
- [x] Rate history dialog: open-ended rates supported, `form.save()` wired, reason pre-fill fixed, l10n popup menu
- [x] App recast uses interest-rate history and tracked rate-history writes mark `interestRateHistory` dirty plus recast the debt's scenario.
- [x] `TrackedScenarioRepository` wired — scenario writes now mark dirty for sync
- [x] Active scenario propagation fixed for timeline, debt list/add debt, reminder scheduling, progress, settings plan summary, monthly action, and monthly summary paths.
- [x] Engine: freed minimums from paused debts redirected to extra pool (forbearance snowball behaviour)
- [x] `MonthlySummaryService`: `varianceCents` now compares extra-only payments vs planned extra (minimums excluded)
- [x] Phase 8 targeted QA: 57/57 tests passing for engine property tests, new charge integration, scenario comparison, debt pages, debt form, monthly action, milestones, payment logging, plan recast, reminder scheduling, tracked interest-rate history, and i18n helper timeout coverage.
- [x] Full `fvm flutter test`: 287/287 tests passing.
- [x] `test/tool/i18n_script_test.dart` timeout fixed by increasing subprocess harness timeout for full-suite contention.
- [ ] Bi-weekly/weekly cadence — accepted deferral to a future release.

### D6 — Design

- [x] Scenario comparison visual — side-by-side metrics with delta banner (winner + months/interest saved)
- [x] Celebration moments — debt paid off, 50% milestone celebration overlay
- [x] Progress dashboard layout — streak card, balance ring, interest saved

### Exit gate (Phase 8)
- [x] Edge case engine calculations accurate — 7 property tests + integration test passing
- [x] Forbearance/pause flow tested end-to-end
- [x] Interest rate change flow tested end-to-end through repository write → scenario recast → timeline simulator rate history
- [x] Monthly summary screen shipped
- [x] ScenarioId propagation completed across active scenario app paths
- [ ] Bi-weekly cadence — accepted deferral from v1.2
- [x] **v1.2 Ship: Power Features** — release candidate with bi-weekly/weekly cadence moved to future release scope

---

## Phase 9 — Partner Sharing

**Duration:** 3-4 tuần · **Tracks:** E8 + D7

### Entry criteria
- Phase 7 complete (Level 1 sync stable)
- User research confirm demand

### E8 — Engineering

**Feature §2.4 Partner Sharing**
- [x] `sharedPlans/{planId}` Firestore collection + security rules
- [x] Invite flow via Cloud Function token + owned HTTPS invite link
- [x] Partner accept + authentication
- [x] Read-only vs collaborative mode
- [x] Revoke access flow
- [x] Real-time partner read view via Firestore listener
- [ ] Conflict UX khi cả 2 edit cùng debt (deferred; current collaborative scope only allows server-mediated partner payment logging)

### D7 — Design

- [x] Invite UX (copy, QR, share sheet)
- [x] Partner view UI (subtle différence vs owner view)
- [x] Permissions clarity: read-only vs collaborative chips and copy
- [x] Trust messaging: cloud account required and revoke access anytime

### Exit gate (Phase 9)
- [x] Owner invite partner → partner accept link → shared plan route opens in automated UAT path
- [x] Security rules tested: partner KHÔNG thể access data khác ngoài shared plan
- [x] Revoke blocks partner access in rules tests
- [ ] **v1.3 Ship: Partner Sharing** — pending production deploy/app-link verification with release signing credentials

---

## Phase 10 — Reports & Reminders

**Duration:** 3 tuần · **Tracks:** E9 + D8

**Status:** Closed with accepted scope adjustments on **2026-04-23**

### E9 — Engineering

**Feature §2.5 Reminders**
- [x] Local notification scheduling (`flutter_local_notifications`)
- [x] Due date reminders (configurable 1/3/7 days)
- [x] Missing payment reminder (end of month)
- [x] Milestone notifications
- [x] Notification permission request UX (first-home prompt + settings fallback)

**Feature §2.6 Reports & Export (Enhanced)**
- [x] PDF report templates (monthly, yearly, full history)
- [x] Amortization table export
- [x] CSV with all fields + metadata
- [ ] Dedicated email-share integration (moved to backlog; generic system share shipped in accepted scope)

### D8 — Design

- [x] Notification copy (friendly, not naggy)
- [x] PDF report visual design (printable, brand consistent for accepted v1.4 scope)
- [x] Report preview UI before export

### Exit gate (Phase 10 — accepted closeout)
- [x] Reminder scheduling and prompt flow covered by unit/integration tests; device-level delivery QA moved to backlog
- [x] PDF report is exportable, shareable, and acceptable for v1.4 scope; deeper visual polish moved to backlog
- [x] **Phase 10 closed: Reports & Reminders**

### Deferred backlog from Phase 10 closeout
- [ ] Dedicated email-share integration
- [ ] Premium PDF visual polish pass
- [ ] Device-level notification delivery QA / evidence matrix

---

## Phase 11 — Monetization & IAP

**Duration:** 3-4 tuần · **Tracks:** E10 + D9

### Entry criteria
- Phase 8 complete (Power Features stable)
- User research confirm willingness-to-pay

### E10 — Engineering

**Feature §3.1 In-App Purchase**
- [ ] IAP integration (`in_app_purchase` package)
- [ ] Free vs Premium tier enforcement (feature flags)
- [ ] Purchase flow (monthly/yearly subscription)
- [ ] Restore purchases
- [ ] Receipt validation (server-side optional)
- [ ] Subscription status sync across devices
- [ ] Graceful downgrade (expired subscription → Free tier)

**Feature §3.2 Premium Feature Gating**
- [ ] Cloud sync (Phase 7) → Premium or Free tier decision
- [ ] What-if scenarios (Phase 8) → Premium
- [ ] Advanced reports (Phase 10) → Premium
- [ ] Custom milestones → Premium
- [ ] Pricing screen update (remove stub, wire real IAP)

### D9 — Design

- [ ] Pricing page redesign (value proposition, tier comparison)
- [ ] Paywall UX (timing: post-aha, non-intrusive)
- [ ] Upgrade celebration (welcome to Premium)
- [ ] Downgrade empathy (don't punish, keep door open)

### Exit gate (Phase 11)
- [ ] Purchase flow tested on iOS + Android (sandbox + production)
- [ ] Premium features correctly gated
- [ ] Restore purchases works reliably
- [ ] **v1.5 Ship: Premium Tier**

---

## Gate Checklist per Phase

Mỗi phase kết thúc phải pass **Gate Checklist** trước khi move sang phase tiếp.

### Universal gate (mọi phase)

- [ ] Code review: 2 approvers minimum
- [ ] CI green (lint, test, build)
- [ ] Test coverage không giảm so với phase trước
- [ ] No new critical/high bugs in backlog
- [ ] Docs updated (ADR nếu có quyết định mới, README layer nếu structure đổi)

### Feature-shipping gate (phase có user-facing feature)

- [ ] Accessibility: contrast AA, keyboard nav (cho iPad), screen reader labels
- [ ] Localization: strings extracted, no hardcoded UI text
- [ ] Error handling: mọi user action có graceful fail path
- [ ] Offline behavior verified
- [ ] Performance: main flows < 100ms interaction, recast < 500ms
- [ ] Privacy: analytics events audited cho PII leakage

### Engine-touching gate (phase có touching financial engine)

- [ ] Existing test vectors pass
- [ ] New test vectors added cho functionality mới
- [ ] Property-based tests pass
- [ ] Sanity warnings trigger đúng lúc (không false positive)
- [ ] Engine explanation trace available cho mọi output số

### Sync-touching gate (phase có touching Firestore)

- [ ] Firestore security rules unit test
- [ ] Multi-device test matrix passed
- [ ] Offline → online recovery tested
- [ ] Cost projection updated với actual read/write counts
- [ ] Emulator integration test trong CI

---

## Dependencies graph

```
D0 ──► D1 ──► D2 ──► D3 ──► D4 ──► D5
                                     │
                                     ├──► D6 ──► D7 ──► D8 ──► D9
                                     │
E0 ──► E1 ──► E2 ──► E3 ──► E4 ──► E5 (MVP SHIP)
                                     │
                                     └──► E6 ──► E7 ──► E8 ──► E9 ──► E10
                                                            (sharing) (IAP)
```

**Critical path:** E0 → E1 → E2 → E3 → E4 → E5 (MVP).
**Design không block E1** (foundation), nhưng block từ E2 trở đi.
**E6 (Sync) không block E7, E9, E10** — có thể parallel nếu team capacity đủ.
**IAP (E10) depends on Phase 8** — cần power features trước khi gate.

---

## Risk & Mitigation per Phase

| Phase | Top risk | Mitigation |
|---|---|---|
| E1 | Engine sai công thức → foundation rotten | Test vectors + property-based từ ngày 1, không ship UI cho đến khi engine green |
| E3 (Living Plan) | Recast slow ở máy yếu | Performance test trên low-end Android từ đầu, optimize sớm |
| E5 (MVP Polish) | Beta users feedback lớn, phải scope down | Cut ruthlessly, hold line ở Tier 1 spec |
| E6 (Sync) | Conflict bugs edge case khó reproduce | Emulator test matrix, invariant logging production |
| E7 (Power Features) | Edge case tính sai (forbearance, rate change) | Test vectors từ spec, property-based cho rate history |
| E8 (Sharing) | Security rules leak data | Penetration test + rules audit bởi người khác team |
| E10 (IAP) | App Store review rejection (paywall aggressive) | Follow Apple HIG, clear value prop, không dark pattern |
| D3 (Onboarding) | Aha moment không đủ aha | User test với 5 người ngoài team trước khi lock design |

---

## Team composition (indicative)

| Role | Phase 0-6 (MVP) | Phase 7-10 (v1.x) | Phase 11+ (v1.5+) |
|---|---|---|---|
| Product Manager | 1 (bạn) | 1 | 1 |
| Designer | 1 (full) | 0.5 (part-time) | 0.5 (paywall + gating) |
| Flutter Dev (senior) | 1 (engine + sync owner) | 1 | 1 (IAP + gating) |
| Flutter Dev (mid) | 1-2 (UI owner) | 1 | 1 |
| QA | 0.5 (from phase 4) | 0.5 | 0.5 |
| DevOps | 0.25 (from phase 6) | 0.25 | 0.25 |

---

## Success metrics per milestone

| Milestone | Primary metric | Target |
|---|---|---|
| v1.0 MVP | Day-7 retention | > 30% |
| v1.0 MVP | Onboarding completion | > 70% |
| v1.0 MVP | Aha moment time | < 5 min |
| v1.1 Sync | Sync opt-in rate | > 40% |
| v1.2 Power | Feature adoption (scenarios) | > 25% of active |
| v1.3 Sharing | Partner activation | > 15% of active |
| v1.4 Reports | Monthly report open rate | > 60% of active |
| v1.5 Premium | Premium conversion | > 5% of active |
| v1.5 Premium | MRR growth | Track monthly |

---

## Notes

- **Không ship sớm chỉ để ship.** Mỗi phase có exit gate, không skip.
- **Engine correctness > UI polish.** Nếu phải trade, UI polish defer được, engine bug không.
- **Parallelism là lợi thế nhỏ**, coordination cost có thể ăn vào. Prefer 1 track tập trung.
- **Rollback plan** cho mỗi ship: feature flag gate cho power features, có thể disable nếu bug production.
- **User feedback loop** từ Phase 5 (beta) liên tục đến post-ship. Không wait end of phase.

---

> **Khi phase change:** update `docs/release-notes/vX.Y.md` với những gì shipped, known issues, next phase goals. Phase planning là **living document** — review cuối mỗi phase, adjust next phase estimate.
