# What-if Scenarios Lab Plan

**Status:** First implementation slice complete; lump sum and deeper compare
actions remain deferred

**Target release:** v1.5 Premium polish, after StoreKit code gate

**Owner area:** Phase 8 Power Features, Premium value upgrade

## Summary

The current Scenarios implementation is technically usable: it has scenario
records, scenario-specific debts and plans, active scenario propagation, payment
isolation, recast, and a comparison page. The user experience is still too thin
for a Premium power feature because "create scenario" mostly creates a named
container and expects the user to know what to edit next.

This plan upgrades Scenarios into a **What-if Lab**: a guided workflow where the
user chooses a real-world assumption, sees the payoff impact immediately, and
can save, compare, or apply the scenario without mutating their real payment
history.

The product promise:

> Try a change before committing to it. See how many months and how much
> interest the change saves.

## Current Baseline

Already implemented:

- `Scenario` entity and `ScenarioRepository`.
- Scenario management UI: create, duplicate, delete, activate.
- `copyDebtsToScenario()`.
- Scenario-aware paths for timeline, debt list/add debt, progress, reminders,
  settings plan summary, monthly actions, and monthly summary.
- Payment logging guard so payments are not logged against a debt outside the
  active scenario.
- Compare page with two selectors, side-by-side metrics, winner badges, and
  delta banner.
- Premium gates at settings entry points, direct routes, and key scenario
  actions.

Main gap:

- There is no persisted model for "what changed in this scenario".
- Create flow does not ask for an assumption such as extra monthly payment,
  bonus, lower APR, or strategy change.
- Compare page shows outcomes but not the assumptions that caused the outcomes.
- A user can create a blank scenario that has no clear value.

## Product Goals

1. Let the user create a useful what-if scenario in under 60 seconds.
2. Default to cloning the current plan, not creating an empty scenario.
3. Show impact before saving:
   - debt-free date
   - months saved or delayed
   - interest saved or added
   - monthly commitment
   - first debt to attack
4. Preserve local-first trust:
   - no bank linking
   - no mutation of real payments
   - no hidden data overwrite
5. Make each saved scenario explain itself with a human-readable assumption
   summary.
6. Keep the feature valuable with three focused templates before expanding to
   more edge cases.

## Non-goals

- Do not implement budgeting or income planning.
- Do not create fake `Payment` rows for simulated future payments.
- Do not make a scenario active automatically after creation.
- Do not require cloud sync or account login.
- Do not block existing basic payoff planning for Free users.
- Do not ship every possible edge case before the first useful lab release.

## UX Model

### Entry points

- Settings plan section: rename "What-If Scenarios" entry to **What-if Lab**.
- Timeline page: add a secondary action **Try What-if** near extra monthly
  amount or projected payoff metrics.
- Compare page: add **Create What-if** when fewer than two useful scenarios
  exist.

### Main flow

1. User taps **Try What-if**.
2. App shows template picker:
   - Pay extra monthly
   - One-time bonus
   - Change strategy
3. User enters the template input.
4. App previews the result against the current active plan.
5. User chooses:
   - **Save scenario**
   - **Compare**
   - **Make active plan**
   - **Discard**

### Saved scenario detail

Each scenario card should show:

- name
- active badge
- created-from summary
- assumptions summary
- debt-free date
- interest saved vs current plan
- monthly commitment

Example copy:

```text
Extra $100/month
Pays off 8 months earlier
Saves $1,420 in projected interest
Commitment: $740/month
```

### Compare page upgrades

The compare page should always be able to compare against the current active
plan. It should add:

- Current plan baseline card.
- Assumptions changed section.
- Monthly commitment row.
- First target debt row.
- Clear neutral state when both scenarios are equivalent.
- CTA: **Make winner active** when the selected winner is not active.

## Template Scope

### Template 1: Pay extra monthly

User input:

- extra amount per month, in current currency
- optional scenario name

Behavior:

- Clone active scenario.
- Increase cloned plan `extraMonthlyAmount` by the entered amount.
- Recast the cloned scenario.
- Save a `ScenarioAssumption` of type `extraMonthly`.

Value:

- Highest clarity and lowest implementation risk.
- Directly answers: "What if I can pay $50, $100, or $200 more every month?"

### Template 2: One-time bonus

User input:

- one-time amount
- apply month
- optional target mode:
  - automatic by current strategy
  - choose a specific debt

Behavior:

- Clone active scenario.
- Store the lump sum as a simulation assumption, not as a real `Payment`.
- Recast with a projection overlay that applies the lump sum in the selected
  month.

Value:

- Covers tax refund, bonus, family support, sale proceeds, or any one-off cash
  event.

Implementation note:

- This template needs engine/recast support for scheduled simulated principal
  reductions. Do not hack it by inserting future payments into `payments`.

### Template 3: Change strategy

User input:

- target strategy: snowball, avalanche, custom if supported later
- optional scenario name

Behavior:

- Clone active scenario.
- Change cloned plan `strategy`.
- Recast the cloned scenario.
- Save a `ScenarioAssumption` of type `strategyChange`.

Value:

- Gives a clean financial vs psychological comparison:
  - avalanche often wins by interest
  - snowball can win by early payoff wins

## Deferred Templates

These are valuable but should wait until the first lab release is stable:

- Lower APR / refinance.
- Pause payment for a date range.
- Add future charge.
- Increase minimum payment.
- Balance transfer promo APR.
- Side income starting in a future month.
- Emergency fund guardrail.

## Domain Model

### `ScenarioAssumption`

New domain entity:

```dart
class ScenarioAssumption {
  final String id;
  final String scenarioId;
  final ScenarioAssumptionType type;
  final String summary;
  final Map<String, Object?> params;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}
```

Enum:

```dart
enum ScenarioAssumptionType {
  extraMonthly,
  lumpSum,
  strategyChange,
  aprChange,
  pausePayment,
  futureCharge,
}
```

Storage:

- Drift table: `scenario_assumptions`.
- Firestore mirror collection: `scenarioAssumptions`.
- `scenario_id` required.
- `params_json` as JSON text for template-specific fields.
- `summary` as persisted text for stable display and auditability.

Why persist assumptions:

- Compare can explain the scenario.
- Sync can preserve what the user was testing.
- Future edits can be layered without guessing from changed plan/debt fields.
- The app can distinguish real payment history from simulated future changes.

### Assumption params

Extra monthly:

```json
{
  "deltaExtraMonthlyCents": 10000,
  "previousExtraMonthlyCents": 20000,
  "newExtraMonthlyCents": 30000
}
```

Lump sum:

```json
{
  "amountCents": 50000,
  "applyMonth": "2026-07",
  "targetMode": "strategy",
  "targetDebtId": null
}
```

Strategy change:

```json
{
  "previousStrategy": "snowball",
  "newStrategy": "avalanche"
}
```

## Architecture

Follow the existing project style:

- Domain models stay in `lib/domain/entities`.
- Repository interfaces stay in `lib/domain/repositories`.
- Drift table, mapper, repository implementation, and tracked wrapper stay in
  `lib/data`.
- UI and Cubit stay in `lib/features/scenarios`.
- Cross-feature orchestration can live in `lib/core/services` only if it needs
  shared repositories and engine access.

Recommended new files:

```text
lib/domain/entities/scenario_assumption.dart
lib/domain/enums/scenario_assumption_type.dart
lib/domain/repositories/scenario_assumption_repository.dart

lib/data/local/tables/scenario_assumptions_table.dart
lib/data/mappers/scenario_assumption_mapper.dart
lib/data/repositories/scenario_assumption_repository_impl.dart
lib/data/repositories/tracked_scenario_assumption_repository.dart

lib/core/services/scenario_lab_service.dart

lib/features/scenarios/cubit/scenario_lab_cubit.dart
lib/features/scenarios/cubit/scenario_lab_state.dart
lib/features/scenarios/presentation/pages/scenario_lab_page.dart
lib/features/scenarios/presentation/pages/create_what_if_page.dart
lib/features/scenarios/presentation/widgets/what_if_template_card.dart
lib/features/scenarios/presentation/widgets/what_if_preview_card.dart
lib/features/scenarios/presentation/widgets/scenario_assumptions_summary.dart
```

### `ScenarioLabService`

Responsibilities:

- Load active scenario and current plan.
- Clone active scenario into a draft scenario.
- Apply template-specific assumptions.
- Recast the cloned scenario.
- Build a preview result comparing current vs draft.
- Save or discard draft output.

The service should orchestrate repositories and engine services. It should not
format UI strings beyond stable assumption summaries.

Suggested API:

```dart
class ScenarioLabService {
  Future<ScenarioPreview> previewExtraMonthly({
    required int deltaExtraMonthlyCents,
    String? name,
  });

  Future<ScenarioPreview> previewStrategyChange({
    required Strategy strategy,
    String? name,
  });

  Future<ScenarioPreview> previewLumpSum({
    required int amountCents,
    required YearMonth applyMonth,
    String? targetDebtId,
    String? name,
  });

  Future<SavedScenarioResult> savePreview(String previewId);
  Future<void> discardPreview(String previewId);
}
```

Implementation choice:

- For the first implementation, previews may create a temporary saved scenario
  immediately and delete it on discard. That is simpler with the current Drift
  repository shape.
- If temporary saved rows become noisy for sync, add an `isDraft` column or keep
  preview state in memory until save. Do not overbuild this in the first pass.

## Engine and Recast Requirements

Extra monthly and strategy change can be implemented through existing plan
fields and `PlanRecastService`.

Lump sum needs a clean simulation overlay:

```dart
class TimelineAssumption {
  final TimelineAssumptionType type;
  final int amountCents;
  final DateTime effectiveMonth;
  final String? targetDebtId;
}
```

`TimelineSimulator.simulate()` should accept optional assumptions:

```dart
TimelineProjection simulate({
  required List<Debt> debts,
  required Plan plan,
  Map<String, List<InterestRateHistory>> rateHistoryByDebt = const {},
  List<TimelineAssumption> assumptions = const [],
})
```

Rules:

- Apply lump sum at the start of the selected month after interest is computed
  only if that matches the existing simulator ordering; otherwise document the
  ordering and test it.
- If target debt is null, allocate the lump sum to the strategy's current target.
- If amount exceeds target balance, roll remaining amount through the strategy
  order.
- Do not create `Payment` rows.
- Do not affect monthly summary, payment history, or audit trails.

## Data and Sync

Drift migration:

- Add `scenario_assumptions` table.
- Add indexes:
  - `(scenario_id)`
  - `(scenario_id, type)`
  - `(updated_at)`
- Include table in database schema and migration tests.

Firestore sync:

- Add serializer to `firestore_models.dart`.
- Add collection to push/pull adapters.
- Mark dirty on add/update/delete.
- Conflict resolver can remain last-write-wins.

Backup/restore:

- Include `scenarioAssumptions` in local backup bundle.
- Validate that each assumption references an existing scenario.
- Restore assumptions after scenarios and before recast.

## UI Detail

### Template picker

Use cards with short labels, not long explanatory paragraphs:

- Pay extra monthly
- One-time bonus
- Change strategy

Each card should show expected input:

- `+$100/mo`
- `$500 in July`
- `Snowball vs Avalanche`

### Input forms

Use existing app form patterns:

- `AppTextField` for money input.
- Segmented controls or choice chips for strategy.
- Date/month picker for lump sum month.
- Existing `AppButton` and `AppCard`.
- No nested cards.

### Preview screen

Preview should be dense and decision-oriented:

```text
Extra $100/month

Debt-free date      Oct 2027    8 months earlier
Projected interest  $3,140      Saves $1,420
Monthly commitment  $740/mo     Up $100/mo
First target        Visa        Highest APR
```

Primary action:

- Save scenario

Secondary actions:

- Compare
- Make active
- Discard

### Scenario list

Replace generic "Add" with **Create What-if**.

Keep advanced actions in overflow:

- Duplicate
- Copy debts
- Delete

Do not surface blank scenario creation as the primary path.

## Implementation Plan

### Milestone 1: Documentation and product baseline

- [x] Write this plan.
- [x] Update `docs/README.md` with this plan link.
- [x] Add a Phase 8 note that current Scenarios are a technical foundation and
  What-if Lab is the planned premium UX upgrade.

### Milestone 2: Assumption persistence

- [x] Add `ScenarioAssumption` entity and enum.
- [x] Add repository interface.
- [x] Add Drift table and migration.
- [x] Add mapper and repository implementation.
- [x] Add tracked repository wrapper.
- [x] Wire DI.
- [x] Add unit tests for repository CRUD and soft delete.

Exit criteria:

- Assumptions persist per scenario.
- Deleted assumptions do not appear in default queries.
- Dirty tracking marks `scenarioAssumptions`.

### Milestone 3: Extra monthly and strategy templates

- [x] Add `ScenarioLabService`.
- [x] Implement clone active scenario helper.
- [x] Implement extra monthly template.
- [x] Implement strategy change template.
- [x] Recast preview scenarios.
- [x] Persist assumptions and human summaries.
- [x] Add tests for preview/save.
- [ ] Add explicit discard path test.

Exit criteria:

- User can create a scenario that is immediately meaningful.
- Current active plan remains unchanged.
- Preview values match recast output.

### Milestone 4: Lab UI

- [x] Add `ScenarioLabCubit`.
- [x] Add template picker page.
- [x] Add extra monthly form.
- [x] Add strategy change form.
- [x] Add preview screen.
- [x] Replace primary Add Scenario action with Create What-if.
- [x] Keep duplicate paths available as advanced actions.
- [ ] Decide whether blank scenario creation should stay available as a
  secondary advanced action.

Exit criteria:

- User can create a guided what-if scenario in under 60 seconds.
- Empty scenario creation is no longer the primary flow.
- Premium action guard still works inside Cubit/service paths.

### Milestone 5: Compare page upgrade

- [x] Add assumptions summary to each selected scenario.
- [x] Add monthly commitment row.
- [ ] Add current active plan as an easy baseline.
- [x] Add first target debt row when projection data is available.
- [ ] Add Make active CTA for saved scenario.

Exit criteria:

- Compare explains both outcome and cause.
- User can decide which scenario to keep without leaving the page.

### Milestone 6: Lump sum simulation

- [ ] Add `TimelineAssumption` model.
- [ ] Extend `TimelineSimulator.simulate()` with optional assumptions.
- [ ] Add lump sum allocation rules.
- [ ] Extend `PlanRecastService` to load saved assumptions for scenario recast.
- [ ] Add one-time bonus template to Lab UI.
- [ ] Add engine property/unit tests.

Exit criteria:

- One-time bonus affects projection without creating `Payment` rows.
- Excess lump sum rolls through strategy order.
- Payment history and monthly summary remain based on real activity only.

### Milestone 7: Backup, sync, and release hardening

- [x] Add Firestore serializer and sync adapters for assumptions.
- [ ] Add backup/restore support.
- [x] Add Firestore rules coverage for assumptions.
- [x] Add i18n strings for English and Vietnamese.
- [ ] Add targeted widget tests.
- [x] Run targeted scenario suite.
- [x] Run targeted `fvm flutter analyze`.
- [x] Run full `fvm flutter test`.
- [x] Run Firestore rules tests with emulator.

Exit criteria:

- Lab data survives backup/restore.
- Cloud sync mirrors saved assumptions.
- Full code gate is green.

## Test Plan

Targeted tests:

- `test/data/repositories/scenario_assumption_repository_test.dart`
- `test/data/repositories/tracked_scenario_assumption_repository_test.dart`
- `test/core/services/scenario_lab_service_test.dart`
- `test/engine/timeline_simulator_assumptions_test.dart`
- `test/features/scenarios/cubit/scenario_lab_cubit_test.dart`
- `test/features/scenarios/presentation/pages/create_what_if_page_test.dart`
- `test/features/scenarios/presentation/pages/compare_scenarios_page_test.dart`
- `test/core/services/data_management_service_test.dart`
- `test/sync/firestore_models_test.dart`
- `test/sync/drift_sync_adapters_test.dart`

Critical cases:

- Extra monthly scenario changes only cloned plan.
- Strategy scenario changes only cloned plan.
- Lump sum does not create payments.
- Deleting scenario soft-deletes or hides assumptions.
- Restored backup preserves assumptions.
- Free user cannot create premium scenario via direct Cubit call.
- Existing Premium-created scenarios remain readable after downgrade.
- Compare page works with:
  - no assumptions
  - one assumption
  - multiple assumptions
  - stale plan requiring recast

## Release Acceptance Criteria

- User can create a useful scenario without manually editing debt details.
- Scenario cards explain their assumptions.
- Compare page explains why one scenario wins.
- Current plan is never mutated unless user chooses Make active.
- No fake future payments appear in payment history.
- Guided creation, compare, save, discard, and make-active paths are covered by
  automated tests.
- `fvm flutter analyze` passes.
- `fvm flutter test` passes.
- Manual QA confirms the flow on iOS simulator or device.

## Risks and Decisions

### Risk: temporary preview rows pollute sync

Decision:

- Start with saved draft rows only if it keeps implementation small.
- If noisy, add an `isDraft` column before enabling sync for drafts.

### Risk: lump sum ordering changes engine semantics

Decision:

- Document and test whether lump sum applies before or after monthly interest.
- Keep assumption behavior deterministic and visible in tests.

### Risk: feature becomes too broad

Decision:

- Ship extra monthly and strategy change first if lump sum engine work grows.
- Keep refinance, pause, future charge, and balance transfer deferred.

### Risk: user confuses scenario with real plan

Decision:

- Use labels such as "Simulation", "What-if", and "Not applied to your real
  plan yet".
- Require explicit confirmation for Make active.

## Handoff Checklist

Before coding:

- [ ] Confirm whether Milestone 6 lump sum is included in the first code slice
  or split into the second slice.
- [ ] Decide whether preview rows are persisted immediately or held in memory.
- [ ] Decide how Make active should behave:
  - switch active scenario only
  - or copy scenario back into `main`
- [ ] Confirm Premium gating copy for downgrade/read-only behavior.

Recommended first implementation slice:

1. Milestone 2 assumption persistence.
2. Milestone 3 extra monthly + strategy templates.
3. Milestone 4 Lab UI without lump sum.
4. Milestone 5 compare assumptions + monthly commitment.

This slice creates real user value while avoiding engine changes. Lump sum can
then be implemented as a focused engine/recast slice.
