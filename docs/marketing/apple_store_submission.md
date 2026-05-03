# Apple Store Submission Content

Prepared on 2026-04-20 for the current MVP build.

## Recommended Positioning

- Target market: US English first
- Primary category: Finance
- Secondary category: Productivity
- Positioning: local-first debt payoff planner, not a budgeting suite

## Naming Status

Official app name for submission: `Debt Payoff X`

The repo is still inconsistent:

- `Debt Payoff X` appears in the Flutter app title.
- `Debt Payoff Manager` appears in iOS display name and product docs.

Recommendation: use `Debt Payoff X` consistently in App Store metadata, iOS display name, and marketing assets before submission.

## Metadata Package

### App Name

`Debt Payoff X`

Count: 13/30

### Subtitle

`Snowball & avalanche plans`

Count: 26/30

### Promotional Text

`See your debt-free date, compare snowball vs avalanche, log real payments, and keep full control with local backup and CSV export.`

Count: 130/170

### Description

```text
Debt Payoff X helps you build a real payoff plan for your debt and keep it accurate as life changes.

Add your debts, compare snowball and avalanche with your own numbers, see your projected debt-free date, and log the payments you actually make.

Built for clarity and trust:
- Guided setup that gets you to your first payoff plan fast
- Unlimited debt tracking for credit cards, loans, and other balances
- Living timeline that updates when you edit a debt or log a payment
- Monthly action view so you know what to pay this month
- Local-first experience with no bank linking required
- CSV export plus local backup and restore

We help you plan and track your debt payoff journey. We do not move money or connect to your bank accounts.
```

### Keywords

`snowball,avalanche,debt tracker,payoff planner,loan payoff,credit card debt,tracker`

Count: 83/100 bytes

### Support URL

Use a real page with contact details. Suggested path:

`https://yourdomain.com/support/debt-payoff-x`

Required content on that page:

- support email
- legal or business contact details
- issue reporting instructions
- privacy policy link

### Marketing URL

Optional but recommended:

`https://yourdomain.com/debt-payoff-x`

### Copyright

Use your legal entity, not the product name.

Suggested format:

`2026 <Your Legal Entity Name>`

### App Review Notes

```text
No login is required to use the submitted build.

This version is local-first. Cloud backup across devices, partner sharing, PDF reports, and in-app purchases are not part of the submitted MVP build.

The app does not link bank accounts, move money, or require financial account credentials.

Suggested review path:
1. Launch the app
2. Add the first debt in onboarding
3. Select Snowball or Avalanche
4. Review the debt-free date and monthly action view
5. Open Settings to test CSV export and local backup/restore flows
```

### What's New

For 1.0: not needed.

For the first update after launch, use something like:

```text
Improved payoff timeline accuracy, debt editing polish, and data management reliability.
```

## Screenshot Copy

Use these headlines on the current 5-screen flow:

1. `See your debt-free date`
2. `Know what to pay this month`
3. `Track every debt in one place`
4. `Compare snowball and avalanche`
5. `Log payments. Keep plans current`

## Submission Guardrails

These guardrails describe the original MVP submission posture. For the current
Phase 11/v1.5 work, use the project phase docs before publishing subscription
metadata.

Do not claim these as live features in App Store metadata for the MVP build:

- cloud backup across devices
- partner sharing
- PDF reports
- in-app purchases or subscriptions
- bank syncing

Safe claims for the current build:

- guided onboarding
- unlimited debt entry and editing
- snowball and avalanche comparison
- living payoff timeline
- payment logging
- monthly action view
- CSV export
- local backup and restore
- local-first, no bank linking

## Local Findings From The Repo

### Blockers

- Privacy policy page is still missing.
- Support page is still missing.
- The current app targets both iPhone and iPad, so App Store submission will need iPad screenshots unless iPad support is removed.
- The `*_V2.png` screenshot files are 1284 x 2779, which is off by 1 pixel from the standard 6.5-inch portrait size. Use the non-V2 assets or crop the V2 assets before upload.

### Product Truth For MVP Build

MVP messaging should stay aligned with these implemented capabilities:

- onboarding is live end-to-end
- living plan, payment logging, monthly action, and timeline are implemented
- Trust Layer Level 0 is implemented: CSV export, local backup ZIP, restore, clear all
- Free vs Premium was only a stub in the MVP build
- real IAP flow is Phase 11/v1.5 scope, not MVP scope
- no real cloud backup flow yet

## Suggested Next Docs To Prepare

1. Privacy Policy page
2. Support page
3. Terms of Service page
4. First-review screenshot set for iPhone
5. iPad screenshot set or iPad removal decision
