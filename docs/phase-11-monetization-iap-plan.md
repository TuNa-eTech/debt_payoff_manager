# Phase 11 Monetization & IAP Plan

**Status:** Code/server gate verified; iOS sandbox/TestFlight QA pending

**Target release:** v1.5 Premium Tier

**Release posture:** iOS-first; Android billing prep is allowed but not required for closeout

## Summary

Phase 11 replaces the Free vs Premium stub with real subscription purchasing and entitlement enforcement. The phase must preserve the app's local-first trust posture: basic payoff planning, CSV export, local backup/restore, and basic cloud sync remain Free. Premium unlocks power-user features that create clear extra value.

Accepted product decisions:

- **Tier policy:** Power-only Premium.
- **Validation:** Firebase server validation is the source of truth.
- **Platform scope:** iOS-first release gate.

## Implementation Audit — May 3, 2026

Repo/server implementation is complete enough for iOS sandbox QA:

- `in_app_purchase` is wired through `PurchaseService` / `InAppPurchaseService`.
- `EntitlementService` subscribes to purchase updates during app startup, validates purchases through Firebase Functions, completes store purchases, refreshes entitlement, and caches entitlement locally in `UserSettings`.
- `PricingPage` now loads App Store products, supports monthly/yearly selection, purchase, restore, continue-free, loading, unavailable-store, missing-product, active-premium, and trust states.
- Premium Settings entry points, direct premium routes, and key premium actions are gated for scenarios, compare scenarios, reports, and partner sharing.
- Firebase callable functions `verifyPurchase` and `refreshEntitlement` are deployed to `debt-payoff-manager-e6283`.
- `verifyPurchase` is bound to `APP_STORE_SHARED_SECRET`, rejects Android for the iOS-first release, verifies Apple receipts, and writes `users/{uid}/entitlements/premium`.
- Firestore rules are deployed and keep entitlement docs server-owned while blocking client-side promotion through synced settings.
- Local secret handling was corrected so `APP_STORE_SHARED_SECRET` lives in Secret Manager and local `.secret.local`, not in deploy-loaded `.env`.

Verification evidence from this audit:

- `fvm flutter analyze`: pass, no issues found.
- `fvm flutter test`: pass, 321/321 tests.
- `functions` TypeScript build: pass.
- Firebase MCP `firebase_validate_security_rules`: pass.
- Firestore rules emulator suite: pass, 18/18 tests.
- Firebase deployed functions list includes `verifyPurchase` and `refreshEntitlement` as callable Node.js 22 functions in `us-central1`.

Remaining release blockers are outside the current repo/server code gate:

- Real App Store product metadata must be visible to sandbox/TestFlight for `premium_monthly` and `premium_yearly`.
- iOS sandbox/TestFlight purchase, restore, cancel/expiry, interrupted/pending flow, and downgrade must be manually verified.
- No real Apple sandbox receipt has been exercised against `verifyPurchase` yet.
- Android billing closeout remains deferred.

## Entry Criteria

- Phase 10 is closed with accepted scope adjustments.
- Phase 8 power features and Phase 9 partner sharing are stable enough to gate.
- App Store product setup can be completed for `premium_monthly` and `premium_yearly`.
- Firebase Functions and Firestore rules are available for entitlement validation and protection.

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

- Add `in_app_purchase`.
- Subscribe to `InAppPurchase.instance.purchaseStream` early in app startup and keep one active listener.
- Query store products for:
  - `premium_monthly`
  - `premium_yearly`
- Handle store unavailable, product not found, pending purchase, purchase error, purchased, restored, and pending completion states.
- Always call `completePurchase` when `pendingCompletePurchase` is true after local processing has finished.

### App services

- Add `PurchaseService` for store availability, product lookup, start purchase, restore purchases, and purchase stream translation into app states.
- Add `EntitlementService` for entitlement refresh, validation calls, local cache updates, expiry checks, and downgrade handling.
- Add `PremiumFeature` enum for gateable features:
  - `scenarios`
  - `compareScenarios`
  - `advancedReports`
  - `partnerSharing`
  - `customMilestones`
- Keep `UserSettings.isPremium` and `UserSettings.premiumExpiresAt` as local cache fields only; they are not the authority.

### Firebase backend

- Add callable `verifyPurchase`.
  - Requires Firebase Auth.
  - Accepts platform, product ID, purchase/transaction ID, and server verification data.
  - Verifies with the relevant store backend.
  - Writes server entitlement through Admin SDK.
- Add callable `refreshEntitlement`.
  - Requires Firebase Auth.
  - Returns the current entitlement status for the signed-in user.
- Store entitlement in a server-owned document or protected fields that normal clients cannot promote.
- Update Firestore rules so clients cannot directly grant Premium by writing `isPremium` or `premiumExpiresAt`.

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

### Milestone 3 — Server Validation

- [x] Implement Firebase Functions callable contracts.
- [x] Add protected entitlement storage.
- [x] Add Firestore rules tests for client-side premium spoofing.
- [ ] Add Functions tests for unauthenticated, invalid product, invalid platform, invalid receipt, valid purchase, restore/refresh, and expiry.

### Milestone 4 — Premium Gating

- [x] Gate Settings entry points for scenarios, reports, and partner sharing.
- [x] Gate direct routes so deep links cannot bypass the paywall.
- [x] Gate premium actions, not just screens, for scenario creation/copy/duplicate, report export, and partner invite creation.
- [x] Keep basic cloud sync accessible for Free users.

### Milestone 5 — Downgrade and Restore

- [x] Refresh entitlement on app start, pricing screen entry, and restore completion.
- [x] Expired entitlement switches to Free gracefully.
- [x] Existing Premium-created data remains available in read-only or limited mode where practical.
- [x] Restore purchases validates through the same server path as a new purchase.

### Milestone 6 — iOS Release Readiness

- [ ] Configure App Store subscriptions and sandbox users.
- [ ] Test monthly/yearly purchase, cancel, restore after reinstall, pending/interrupted flow, renewal/expiry sandbox behavior, and downgrade.
- [x] Prepare Android product IDs and billing notes, but keep Android closeout deferred until the current Gradle/Kotlin release blocker is resolved.

## App Store / Firebase Setup Required

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
7. Enable Firebase Auth Anonymous provider for purchase validation sessions.
8. Configure Firebase Functions secret/env:
   - `APP_STORE_SHARED_SECRET`
9. Deploy Functions and Firestore rules before sandbox QA:
   - `verifyPurchase`
   - `refreshEntitlement`
   - protected `users/{uid}/entitlements/premium`

## Test Matrix

### Flutter unit tests

- Store unavailable disables purchase CTA and explains the issue.
- Product not found shows a recoverable error.
- Pending purchase shows pending state without unlocking Premium.
- Purchased/restored purchase calls server validation.
- Invalid validation does not unlock Premium.
- Active entitlement unlocks Premium features.
- Expired entitlement downgrades to Free without deleting data.

### Widget tests

- Pricing page renders Free/Premium tiers and store-loaded prices.
- Monthly/yearly purchase buttons call the purchase service.
- Restore button calls restore flow and handles restored purchases through validation.
- Free users see locked premium entry points.
- Premium users enter gated screens normally.

### Firebase tests

- Firestore rules block direct client writes that promote Premium.
- Firestore rules allow normal settings writes that do not alter protected entitlement state.
- `verifyPurchase` rejects unauthenticated and malformed requests.
- `refreshEntitlement` returns the correct active/expired state.

### Manual QA

- iOS sandbox purchase monthly and yearly.
- iOS restore after reinstall/sign-in.
- iOS cancellation/expiry in sandbox.
- Regression pass: onboarding, cloud backup, scenario list, report preview/export, partner sharing, and settings data controls.

## Exit Gate

- Real IAP purchase and restore flow tested on iOS sandbox/TestFlight.
- Firebase server validation is the entitlement authority.
- Premium gates work at UI entry points and direct route/action level.
- Free users retain local-first core value and basic cloud sync.
- Downgrade does not delete user data.
- `fvm flutter analyze` passes.
- `fvm flutter test` passes.
- Firestore rules tests pass.
- Functions build/tests pass.
- **v1.5 Premium Tier is ready for iOS-first release.**

## Deferred Backlog

- Android production billing closeout after Gradle/Kotlin release blocker is resolved.
- Deeper Premium PDF visual polish if not required for first v1.5 acceptance.
- Dedicated email-share flow from Phase 10 backlog.
- Advanced server-side subscription lifecycle monitoring beyond the initial validation/refresh path.
