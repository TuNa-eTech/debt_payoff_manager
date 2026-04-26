# Debt Payoff Manager — Development Guide

> **A living plan for debt freedom.** Cross-platform Flutter app for tracking and strategizing debt payoff with mathematical precision.

**Current Status (April 26, 2026):** Phases 0–6 complete (MVP shipped), Phase 7 (Cloud Sync) coded but not enabled in app layer, Phase 10 (Reports & Reminders) in progress. 225+ tests passing.

---

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run codegen (Drift, Freezed)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on device
flutter run

# Run all tests
flutter test

# Analyze code
flutter analyze
```

### With FVM (Recommended)

```bash
fvm install && fvm use
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter run
```

---

## Architecture Overview

### 6-Layer Structure

```
lib/
├── core/               # Cross-cutting: DI, routing, theme, i18n, shared services
├── domain/             # Pure Dart: entities, enums, repository interfaces (contracts)
├── data/               # Implementation: Drift DB, repositories, mappers, converters
├── engine/             # Pure Dart financial calculations (no side effects)
├── features/           # Feature-first modules: UI + BLoC/Cubit + services
└── sync/               # Cloud sync: Firestore adapters, push/pull, conflict resolution
```

### Key Architectural Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Framework** | Flutter 3.38 + Dart 3.9 | Cross-platform iOS/Android, native-grade UI |
| **Local DB** | Drift (SQLite) | Type-safe, reactive streams, migration support |
| **State Management** | BLoC/Cubit | Predictable, testable, separation of concerns |
| **DI** | Manual `get_it` (not injectable codegen) | Avoids codegen complexity, explicit wiring |
| **Money** | Integer cents + `Decimal` | **Never** `double` for financial calculations |
| **Primary Keys** | UUID v4 | Offline-safe, sync-ready |
| **Cloud Sync** | Local-first Firestore (optional) | Progressive trust: Level 0 (local) → Level 1 (backup) → Level 2 (sharing) |
| **Conflict Resolution** | Last-Write-Wins | Simple, correct for 99%+ usage |

---

## Financial Engine

**Pure Dart** calculation engine with zero side effects. All formulas documented in [`docs/financial-engine-spec.md`](docs/financial-engine-spec.md).

### Core Modules

| Module | Purpose |
|--------|---------|
| `amortization.dart` | Standard fixed-payment, simple monthly, daily compounding |
| `interest_calculator.dart` | Simple monthly, compound daily, compound monthly |
| `min_payment_calculator.dart` | Fixed, percent-of-balance, interest-plus-percent (with floor) |
| `payment_allocator.dart` | Extra payment distribution with **intra-month rollover** |
| `strategy_sorter.dart` | Snowball (smallest balance), Avalanche (highest APR), Custom |
| `timeline_simulator.dart` | Month-by-month projection with debt-free date |
| `validators.dart` | Input validation, sanity checks |

### Precision Guarantees

- Money stored as **integer cents** — never floating point
- Interest rates stored as **`Decimal`** (arbitrary precision)
- **Banker's rounding** (round-half-to-even) for interest calculations
- Every function must reference its spec section in doc comments

---

## Development Conventions

### Code Style

- **Lint rules:** [`analysis_options.yaml`](analysis_options.yaml) (extends `flutter_lints`)
- **Commit messages:** [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`)
- **Financial code:** Every function must reference its spec section
  ```dart
  /// Computes simple monthly interest per financial-engine-spec.md §5.2
  /// interest = balance × (APR / 12), banker's rounding to 2 decimals
  Decimal computeMonthlyInterest(Decimal balance, Decimal apr) { ... }
  ```
- **Shell commands:** Use `rtk` prefix for token-efficient output (saves 60-90% tokens)
  ```bash
  rtk git status
  rtk flutter analyze
  rtk flutter test
  rtk find "*.dart" lib/
  ```

### Testing Strategy (6-Layer Pyramid)

1. **Unit tests** — Engine functions, pure Dart (fastest, no mocks)
2. **Repository tests** — In-memory Drift, CRUD operations
3. **BLoC/Cubit tests** — State transitions with `bloc_test`
4. **Widget tests** — Component rendering, golden tests
5. **Integration tests** — End-to-end flows with `integration_test`
6. **Property-based tests** — Financial invariants with `glados`

```bash
# All tests
flutter test

# Engine tests only (financial calculations)
flutter test test/engine/

# With coverage
flutter test --coverage
```

### Architecture Rules

- **Engine is pure** — no DB, no UI, no side effects. Input → output.
- **Repository pattern** — Drift types never leak outside `data/` layer.
- **Feature-first** — each feature in its own directory under `features/`.
- **No `double` for money** — enforced in code review.

---

## GitNexus Code Intelligence

This project is indexed by GitNexus. **MUST use GitNexus tools** for safe code changes:

### Before Editing

```bash
# Run impact analysis for any symbol you modify
gitnexus_impact({target: "symbolName", direction: "upstream"})
```

### Before Committing

```bash
# Verify changes match expected scope
gitnexus_detect_changes({scope: "staged"})
```

### Refactoring

```bash
# Safe rename (understands call graph)
gitnexus_rename({symbol_name: "old", new_name: "new", dry_run: true})
```

> ⚠️ **Never** edit a function/class without running `gitnexus_impact` first.  
> ⚠️ **Never** ignore HIGH/CRITICAL risk warnings.  
> ⚠️ Index becomes stale after commits — run `npx gitnexus analyze` to refresh.

See full workflow in [AGENTS.md](AGENTS.md) or [CLAUDE.md](CLAUDE.md).

---

## Key Files & Directories

| Path | Purpose |
|------|---------|
| [`pubspec.yaml`](pubspec.yaml) | Dependencies, Flutter config |
| [`lib/main.dart`](lib/main.dart) | App entry point, Firebase/Crashlytics setup |
| [`lib/app.dart`](lib/app.dart) | Root widget, BLoC providers, router |
| [`lib/core/di/injection.dart`](lib/core/di/injection.dart) | Manual DI wiring (get_it) |
| [`lib/core/router/app_router.dart`](lib/core/router/app_router.dart) | GoRouter config, 5-tab shell + onboarding |
| [`lib/data/local/database.dart`](lib/data/local/database.dart) | Drift database definition |
| [`docs/financial-engine-spec.md`](docs/financial-engine-spec.md) | **Source of truth** for all financial calculations |
| [`docs/architecture-decisions.md`](docs/architecture-decisions.md) | 21 ADRs with rationale |
| [`docs/project-phases.md`](docs/project-phases.md) | Phase roadmap with entry/exit criteria |
| [`test/`](test/) | 6-layer test suite (225+ tests) |

---

## Environment Setup

### Firebase Configuration

Firebase is used for Crashlytics, Analytics, and (optionally) Cloud Sync.

```bash
# Copy env template
cp .env.example .env

# Required (gitignored) Firebase config files:
# - android/app/google-services.json
# - ios/Runner/GoogleService-Info.plist
# Download from Firebase Console → Project Settings
```

### Feature Flags

Control features via `.env`:

```env
FEATURE_CLOUD_SYNC=true
FEATURE_PARTNER_SHARING=false
FEATURE_PREMIUM=false
ANALYTICS_ENABLED=false    # Disable in dev
CRASHLYTICS_ENABLED=false  # Disable in dev
```

---

## Design System

**"Material Structure, Notion Soul"** — MD3 components with Notion-inspired aesthetics.

### Color Palette

| Token | Value | Usage |
|-------|-------|-------|
| `$md-primary` | `#1B6B4A` (Forest Green) | Primary brand color |
| `$md-surface` | `#FFFFFF` | Cards, main backgrounds |
| `$md-surface-container-low` | `#F6F5F4` (Warm White) | Gentle rhythm, alternating sections |
| `$md-on-surface` | `#000000F2` (Notion Black) | Primary text |
| `$md-outline-variant` | `rgba(0,0,0,0.1)` | Whisper borders |

### Typography (Roboto)

| Role | Size | Weight | Letter Spacing |
|------|------|--------|----------------|
| Display Large | 64px | 700 | -2.125px |
| Headline Large | 40px | 700 | -1.0px |
| Title Large | 22px | 700 | -0.25px |
| Body Large | 16px | 400 | 0px |
| Label Small | 12px | 600 | +0.125px |

See [`DESIGN.md`](DESIGN.md) for full spec.

---

## Project Phases

| Phase | Status | Description |
|-------|--------|-------------|
| **Phase 0** | ✅ Complete | Foundation + setup |
| **Phase 1** | ✅ Complete | Core data + engine |
| **Phase 2** | ✅ Complete | Core UX design |
| **Phase 3** | ✅ Complete | Debt management MVP |
| **Phase 4** | ✅ Complete | Living plan (timeline, payments) |
| **Phase 5** | ✅ Complete | Onboarding + trust layer |
| **Phase 6** | ✅ Complete | MVP polish + ship (v1.0) |
| **Phase 7** | 🟡 In Progress | Cloud sync (Firestore) — coded, not enabled |
| **Phase 8** | 🟡 Partial | Power features (what-if scenarios) |
| **Phase 9** | ⏳ Planned | Partner sharing |
| **Phase 10** | ✅ Complete | Reports + reminders (v1.4 scope) |

See [`docs/project-phases.md`](docs/project-phases.md) for detailed entry/exit criteria.

---

## Contributing

### Good First Issues

- Engine edge cases — add test vectors for new scenarios
- Accessibility improvements — screen reader labels, contrast fixes
- Localization — translate strings to your language
- Test coverage — widget/integration tests for existing features

### Workflow

1. **Fork** and create branch from `main` (`feat/`, `fix:`, `docs/`)
2. **Write tests first** for engine changes (property-based preferred)
3. **Run full suite** before submitting:
   ```bash
   flutter analyze
   flutter test
   ```
4. **Open PR** with clear description of what and why

### Before Committing

```bash
# 1. Run impact analysis for modified symbols
gitnexus_impact({target: "YourClass", direction: "upstream"})

# 2. Verify changes match expected scope
gitnexus_detect_changes({scope: "staged"})

# 3. Run tests
flutter test

# 4. Analyze
flutter analyze
```

---

## Tech Stack

| Category | Package | Purpose |
|----------|---------|---------|
| **State** | `flutter_bloc` / `bloc` | BLoC/Cubit state management |
| **DI** | `get_it` / `injectable` | Manual dependency injection |
| **Navigation** | `go_router` | Declarative routing |
| **Database** | `drift` / `sqlite3_flutter_libs` | Local-first SQLite |
| **Precision** | `decimal` | Arbitrary precision arithmetic |
| **Charts** | `fl_chart` | Financial visualizations |
| **Formatting** | `intl` | Currency & date formatting |
| **Notifications** | `flutter_local_notifications` | Due dates, reminders, milestones |
| **Firebase** | `firebase_core` / `firebase_auth` / `cloud_firestore` | Crashlytics, analytics, sync |
| **Testing** | `mocktail` / `bloc_test` / `glados` | Mocking, BLoC testing, property-based |

---

## Documentation

| Document | Purpose |
|----------|---------|
| [`README.md`](README.md) | Project overview, features, roadmap |
| [`docs/feature-spec.md`](docs/feature-spec.md) | Product requirements, JTBD, pain points |
| [`docs/financial-engine-spec.md`](docs/financial-engine-spec.md) | **Authoritative** formulas and data model |
| [`docs/data-schema.md`](docs/data-schema.md) | Drift tables, indexes, migrations |
| [`docs/architecture-decisions.md`](docs/architecture-decisions.md) | 21 ADRs with rationale |
| [`docs/project-phases.md`](docs/project-phases.md) | Phase roadmap with gates |
| [`docs/sync-strategy.md`](docs/sync-strategy.md) | Firestore sync architecture |
| [`docs/test-strategy.md`](docs/test-strategy.md) | 6-layer test pyramid |

---

## Known Issues

| Issue | Status | Notes |
|-------|--------|-------|
| LogPaymentPage keyboard hides Save button | 🔴 Bug | Fix planned — CTA button needs keyboard visibility handling |
| Cloud sync dirty-tracking for Settings/Milestones | 🔴 Gap | Phase 7 fix roadmap in memory context |
| Test mock classes missing new `CloudBackupService` methods | 🔴 7 failures | Pre-existing, not caused by Phase 7 changes |

---

<p align="center">
  <strong>Built with 🧮 precision and ❤️ trust.</strong><br>
  <em>Because getting out of debt shouldn't require trusting another app with your money.</em>
</p>
