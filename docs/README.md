# Documentation Index

## Current status snapshot

As of **May 3, 2026**, the repository reflects this project status:

- `Phase 0-6` MVP scope is complete in the codebase.
- `Phase 10` Reports & Reminders is closed with accepted scope adjustments.
- `Phase 7` Cloud Sync engineering is functionally complete and accepted with a QA waiver. Real-device cross-sync QA and cost monitoring remain v1.1 release gates.
- `Phase 8` Power Features is a release candidate with bi-weekly/weekly cadence explicitly deferred from v1.2 scope.
- `Phase 9` Partner Sharing is engineering complete with automated UAT/rules validation and production Firebase Hosting/App Links assets verified for the iOS-first release target. Android release is deferred because the Gradle/Kotlin build currently stalls and production release SHA-256 is still needed for Android App Links.
- `Phase 11` Monetization & IAP is StoreKit 2 code gate verified for an iOS-first Premium Tier; real App Store sandbox/TestFlight QA remains the release blocker.

## Recommended reading order

- [Project Phases](project-phases.md): master progress tracker and gate status
- [Phase 11 Monetization & IAP Plan](phase-11-monetization-iap-plan.md): detailed v1.5 Premium implementation plan
- [Release Notes v1.4](release-notes/v1.4.md): latest shipped post-MVP scope
- [Release Notes v1.0](release-notes/v1.0.md): original MVP launch snapshot
- [Feature Spec](feature-spec.md): product scope and feature tiers
- [Architecture Decisions](architecture-decisions.md): ADRs and implementation rationale
- [Financial Engine Spec](financial-engine-spec.md): calculation rules and acceptance vectors
- [Data Schema](data-schema.md): Drift schema, invariants, and migration notes
- [Sync Strategy](sync-strategy.md): cloud sync and partner-sharing design/implementation notes
- [Partner Sharing Deploy](partner-sharing-deploy.md): Phase 9 deploy, app-link, and automated UAT checklist
- [Test Strategy](test-strategy.md): automated coverage expectations

## Note on historical docs

Some documents intentionally capture a point-in-time state, especially:

- App Store submission notes for the MVP build
- release notes tied to a specific version

Use [Project Phases](project-phases.md) and [Release Notes v1.4](release-notes/v1.4.md) as the source of truth for the current repository progress.
