# Phase 9 Partner Sharing Deploy Checklist

Status as of 2026-05-01: implementation is complete in the repo and automated
UAT/rules checks are the accepted QA gate for this pass. Real-device QA is
waived by product decision.

## Firebase project

- Active project: `debt-payoff-manager-e6283`
- Functions source: `functions/`
- Firestore rules file: `firestore.rules`
- Invite base URL: `https://debtpayoff.app/invite`

Before deploying Functions, create `functions/.env` from
`functions/.env.example`:

```sh
INVITE_BASE_URL=https://debtpayoff.app/invite
```

## Deploy commands

Use targeted deploys:

```sh
firebase deploy --only firestore:rules -P debt-payoff-manager-e6283
firebase deploy --only functions -P debt-payoff-manager-e6283
```

The app-link files live in the landing page public directory and deploy with
the landing site:

```sh
cd landing-page
yarn deploy:hosting
```

Do not deploy root Firebase Hosting from the app root unless the root
`firebase.json` is intentionally expanded for hosting. The landing page already
owns Hosting deploy output.

## App Links / Universal Links

Android:

- Intent filter is configured in `android/app/src/main/AndroidManifest.xml`.
- Flutter default deeplinking is disabled so `app_links` owns routing.
- Current `assetlinks.json` includes the local debug SHA-256 fingerprint:
  `4D:3B:15:F9:E1:67:62:76:47:C6:52:32:3A:4C:76:75:76:F0:CB:8C:0F:D3:3A:92:94:02:AA:E9:7C:C7:FA:D8`.
- Add the production release signing SHA-256 before public release.

iOS:

- Associated domain is configured in `ios/Runner/Runner.entitlements`.
- AASA file is hosted from
  `landing-page/public/.well-known/apple-app-site-association`.
- App ID used by AASA: `WG7WMAD5MS.com.anhtu.debtPayoffManager`.

## Automated UAT gate

Required local checks:

```sh
fvm flutter analyze
fvm flutter test
npm run build --prefix functions
firebase emulators:exec --only firestore "npm test --prefix test/firestore-rules"
```

Firebase MCP validation should also report:

```text
firebase_validate_security_rules firestore.rules -> OK: No errors detected.
```
