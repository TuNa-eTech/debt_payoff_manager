# Phase 11 Monetization & IAP Plan

**Status:** Code gate verified; iOS sandbox/TestFlight QA pending

**Target release:** v1.5 Premium Tier

**Release posture:** iOS-first; Android billing prep is allowed but not required for closeout

## Summary

Phase 11 replaces the Free vs Premium stub with real subscription purchasing and entitlement enforcement. The phase must preserve the app's local-first trust posture: basic payoff planning, CSV export, local backup/restore, and basic cloud sync remain Free. Premium unlocks power-user features that create clear extra value.

Accepted product decisions:

- **Tier policy:** Power-only Premium.
- **Validation:** StoreKit 2 local entitlement validation is the source of truth for the iOS-first release.
- **Platform scope:** iOS-first release gate.
- **Backend scope:** Firebase IAP receipt validation is removed from the active flow; server-side subscription lifecycle monitoring is deferred.

## Implementation Audit — May 3, 2026

Repo implementation is complete enough for iOS sandbox QA:

- `in_app_purchase` and `in_app_purchase_storekit` are wired through `PurchaseService` / `InAppPurchaseService`.
- `EntitlementService` now uses StoreKit 2 transactions/JWS payloads locally, subscribes to purchase updates during app startup, completes store purchases, refreshes entitlement from transaction history, and caches entitlement locally in `UserSettings`.
- `PricingPage` now loads App Store products, supports monthly/yearly selection, purchase, restore, continue-free, loading, unavailable-store, missing-product, active-premium, debug subscription management, debug local premium clear, trust states, and a success dialog after Premium activation.
- Premium Settings entry points, direct premium routes, and key premium actions are gated for scenarios, compare scenarios, reports, and partner sharing.
- Settings has a Premium row so users can find the current subscription status and restore/manage their purchase path.
- The debug iOS flow includes an App Store subscription management button backed by native StoreKit `AppStore.showManageSubscriptions(in:)`; `in_app_purchase` does not expose that sheet directly.
- Firebase callable functions for IAP are no longer part of the active architecture. The deployed Functions code now only contains Partner Sharing callables.

Verification evidence from this audit:

- `rtk fvm flutter test test/features/pricing/cubit/pricing_cubit_test.dart test/features/pricing/presentation/pricing_page_test.dart`: pass.
- `rtk fvm flutter test test/features/pricing/cubit/pricing_cubit_test.dart test/features/pricing/presentation/pricing_page_test.dart test/features/pricing/data/storekit_entitlement_service_test.dart test/features/settings/presentation/settings_page_test.dart`: pass.
- `rtk fvm flutter analyze lib/features/pricing test/features/pricing`: pass, no issues found.
- `rtk fvm flutter analyze lib/features/pricing lib/features/settings lib/core/constants/app_test_keys.dart test/features/pricing test/features/settings/presentation/settings_page_test.dart test/helpers/test_app_harness.dart`: pass, no issues found.
- `rtk git diff --check`: pass.

Remaining release blockers are outside the current repo code gate:

- Real App Store product metadata must be visible to sandbox/TestFlight for `premium_monthly` and `premium_yearly`.
- iOS sandbox/TestFlight purchase, restore, cancel/expiry, interrupted/pending flow, and downgrade must be manually verified.
- Native iOS StoreKit subscription-management bridge must be verified on simulator/device build and real sandbox account.
- Android billing closeout remains deferred.

## Entry Criteria

- Phase 10 is closed with accepted scope adjustments.
- Phase 8 power features and Phase 9 partner sharing are stable enough to gate.
- App Store product setup can be completed for `premium_monthly` and `premium_yearly`.
- StoreKit 2 transaction history is available on iOS; Firebase Functions remain available for Partner Sharing only.

## Tier Policy

### Free

- Local-first debt tracking, payoff plan, timeline, progress basics, and reminders.
- CSV export, local backup ZIP, local restore ZIP, and clear-all data controls.
- Basic cloud sync / backup as a trust feature.
- Pricing screen can be opened without forcing purchase.

### Premium

- What-if scenarios and scenario comparison.
- Advanced PDF reports and premium report polish.
- Partner sharing.
- Custom milestones and similar power-user planning tools.
- Future power features that create optional convenience or collaboration value.

Downgrade rule: expired users move back to Free without deleting data. Premium-only creation/actions are blocked, but existing user data should remain readable where practical.

## Architecture

### Flutter IAP layer

- Add `in_app_purchase` and `in_app_purchase_storekit`.
- Subscribe to `InAppPurchase.instance.purchaseStream` early in app startup and keep one active listener.
- Query store products for:
  - `premium_monthly`
  - `premium_yearly`
- Handle store unavailable, product not found, pending purchase, purchase error, purchased, restored, and pending completion states.
- Read current StoreKit 2 transactions with `SK2Transaction.transactions()` for entitlement refresh and restore reconciliation.
- Decode StoreKit 2 local transaction JSON/JWS payloads to validate product ID, expiration, and revocation locally.
- Always call `completePurchase` when `pendingCompletePurchase` is true after local processing has finished.
- Use a small native iOS MethodChannel only for the debug subscription-management sheet because the Flutter IAP plugin does not expose `AppStore.showManageSubscriptions(in:)`.

### App services

- Add `PurchaseService` for store availability, product lookup, start purchase, restore purchases, and purchase stream translation into app states.
- Add `EntitlementService` for StoreKit 2 entitlement refresh, local validation, local cache updates, expiry checks, and downgrade handling.
- Add `PremiumFeature` enum for gateable features:
  - `scenarios`
  - `compareScenarios`
  - `advancedReports`
  - `partnerSharing`
  - `customMilestones`
- Keep `UserSettings.isPremium` and `UserSettings.premiumExpiresAt` as local cache fields only; StoreKit 2 transactions are the authority.

### Firebase backend

- No Firebase callable is required for the active iOS-first IAP flow.
- Existing Cloud Functions remain for Partner Sharing only.
- Do not reintroduce `APP_STORE_SHARED_SECRET` or receipt-validation Functions unless the product explicitly decides to support server-authoritative cross-device subscription lifecycle monitoring.
- Firestore remains relevant for sync and partner sharing, but Premium entitlement is local StoreKit 2 state for this release.

## Implementation Milestones

### Milestone 1 — Foundation

- [x] Add IAP dependency and product constants.
- [x] Add purchase and entitlement domain models.
- [x] Register services in DI with test fakes.
- [x] Add app startup purchase-stream listener.
- [x] Add initial unit tests for purchase states and entitlement states.

### Milestone 2 — Pricing and Purchase Flow

- [x] Replace `PricingPage` stub with real subscription UI.
- [x] Show monthly/yearly products from store metadata.
- [x] Add purchase, restore, continue-free, loading, error, and product-not-found states.
- [x] Preserve trust copy: no bank linking, local export stays available, no aggressive paywall.
- [x] Add upgrade success and restore success feedback.
- [x] Add Settings Premium entry point.
- [x] Add debug-only iOS subscription-management button.
- [x] Add debug-only local Premium cache clear button for downgrade UI testing.

### Milestone 3 — StoreKit 2 Entitlement

- [x] Implement StoreKit 2 transaction-history refresh.
- [x] Validate product ID, expiration, and revocation locally from StoreKit 2 transaction payloads.
- [x] Gracefully fall back to cached local entitlement if StoreKit transaction refresh fails.
- [x] Remove obsolete Firebase entitlement service from Flutter.
- [x] Remove obsolete IAP receipt-validation backend from active Functions code.

### Milestone 4 — Premium Gating

- [x] Gate Settings entry points for scenarios, reports, and partner sharing.
- [x] Gate direct routes so deep links cannot bypass the paywall.
- [x] Gate premium actions, not just screens, for scenario creation/copy/duplicate, report export, and partner invite creation.
- [x] Keep basic cloud sync accessible for Free users.

### Milestone 5 — Downgrade and Restore

- [x] Refresh entitlement on app start, pricing screen entry, and restore completion.
- [x] Expired entitlement switches to Free gracefully.
- [x] Existing Premium-created data remains available in read-only or limited mode where practical.
- [x] Restore purchases validates through the same StoreKit 2 local entitlement path as a new purchase.

### Milestone 6 — iOS Release Readiness

- [x] Configure App Store IAP key reference for setup notes.
- [ ] Confirm App Store subscriptions are visible to sandbox/TestFlight users.
- [ ] Test monthly/yearly purchase, cancel, restore after reinstall, pending/interrupted flow, renewal/expiry sandbox behavior, and downgrade.
- [x] Prepare Android product IDs and billing notes, but keep Android closeout deferred until the current Gradle/Kotlin release blocker is resolved.

## App Store Setup Required

These are outside the repo and must be completed before real iOS sandbox/TestFlight validation:

1. In App Store Connect, create one auto-renewable subscription group:
   - Reference name: `Debt Payoff X Premium`
   - Display name: `Debt Payoff X Premium`
2. Add two subscription products in that group:
   - `premium_monthly`
     - Duration: 1 month
     - Price: USD 4.99
     - Introductory offer: none
   - `premium_yearly`
     - Duration: 1 year
     - Price: USD 39.99
     - Introductory offer: none
3. Put both products at the same subscription level because they unlock the same Premium tier.
4. Add product localizations for English and Vietnamese.
5. Add review notes and a screenshot of the pricing page for each subscription.
6. Create at least two Sandbox Apple Accounts:
   - one clean purchase tester
   - one interrupted/expiry tester
7. Keep Firebase Functions focused on Partner Sharing for the active release.
8. Do not deploy or depend on IAP receipt-validation Functions for StoreKit 2 sandbox QA.

## Test Matrix

### Flutter unit tests

- Store unavailable disables purchase CTA and explains the issue.
- Product not found shows a recoverable error.
- Pending purchase shows pending state without unlocking Premium.
- Purchased/restored purchase updates entitlement through StoreKit 2 local validation.
- Invalid/malformed local transaction payload does not unlock Premium.
- Active entitlement unlocks Premium features.
- Expired entitlement downgrades to Free without deleting data.

### Widget tests

- Pricing page renders Free/Premium tiers and store-loaded prices.
- Monthly/yearly purchase buttons call the purchase service.
- Restore button calls restore flow and handles restored purchases through validation.
- Free users see locked premium entry points.
- Premium users enter gated screens normally.
- Successful Premium activation shows a confirmation dialog.
- Settings exposes Premium status and the subscription entry point.

### Firebase tests

- Partner Sharing Functions and Firestore rules remain covered by the Phase 9 validation path.
- There is no active IAP Firebase callable to test after the StoreKit 2 migration.

### Manual QA

- iOS sandbox purchase monthly and yearly.
- iOS restore after reinstall/sign-in.
- iOS cancellation/expiry in sandbox.
- iOS App Store subscription management sheet opens from debug flow.
- Regression pass: onboarding, cloud backup, scenario list, report preview/export, partner sharing, and settings data controls.

## Exit Gate

- Real IAP purchase and restore flow tested on iOS sandbox/TestFlight.
- StoreKit 2 local entitlement validation is the iOS-first authority.
- Premium gates work at UI entry points and direct route/action level.
- Free users retain local-first core value and basic cloud sync.
- Downgrade does not delete user data.
- `fvm flutter analyze` passes.
- `fvm flutter test` passes.
- Firestore rules tests pass.
- Functions build/tests pass for non-IAP callable scope when Functions code changes.
- **v1.5 Premium Tier is ready for iOS-first release.**

## Deferred Backlog

- Android production billing closeout after Gradle/Kotlin release blocker is resolved.
- Deeper Premium PDF visual polish if not required for first v1.5 acceptance.
- Dedicated email-share flow from Phase 10 backlog.
- Advanced server-side subscription lifecycle monitoring, if later needed for cross-device entitlement authority or analytics.
