# Debt Payoff Manager

> **A living plan for debt freedom.** Track, strategize, and conquer your debt with mathematically precise payoff plans that adapt to your real life.

[![Flutter](https://img.shields.io/badge/Flutter-3.38-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

---

## Why This App?

We analyzed 6 top debt payoff apps on the US App Store. Every single one fails users in at least one critical way: frozen plans that don't reflect reality, broken payment tracking, bait-and-switch pricing, or data loss. **Debt Payoff Manager** is built from the ground up to solve these problems.

### Design Principles

| # | Principle | Why |
|---|---|---|
| 1 | **Living Plan, not Static Calculator** | Plans adapt instantly when you log a payment, change strategy, or add new debt |
| 2 | **Trust is a Feature** | Local-first data, transparent pricing, no bank linking, your data stays yours |
| 3 | **Boring but Robust > Feature Breadth** | One job done right — debt payoff — not a budgeting suite |
| 4 | **Never Touch Your Money** | We help you plan and track. We never hold, move, or access your funds |

---

## Features

### 🎯 Tier 1 — Core (MVP)

- **Guided Onboarding** — Add your first debt and see your freedom date in < 5 minutes
- **Unlimited Debt Tracking** — Credit cards, student loans, car loans, mortgages, medical, personal — all free
- **Snowball & Avalanche Strategies** — Compare with your real numbers, not generic examples
- **Living Timeline** — Debt-free date updates instantly when anything changes
- **Payment Logging** — Log actual payments, track planned vs completed, full audit trail
- **Monthly Action View** — "This month you need to pay: ..." with one-tap check-off
- **Progressive Trust Model** — Start with zero account. Back up when ready. Share when you choose.

### ⚡ Tier 2 — Power Features (Post-MVP)

- What-If Scenario Comparison
- Forbearance, Rate Changes, New Charges
- Progress Milestones & Streak Tracking
- Partner / Household Sharing
- Payment Reminders & Notifications
- PDF Reports & CSV Export

See the full [Feature Spec →](docs/feature-spec.md)

---

## Architecture

```
lib/
├── core/               # Theme, DI, routing, extensions, shared widgets
├── data/               # Drift tables, type converters, repositories
│   ├── local/          # SQLite/Drift database
│   ├── mappers/        # Domain ↔ DB model mappers
│   └── repositories/   # Repository implementations
├── domain/             # Pure Dart domain models & enums
│   ├── entities/       # Debt, Payment, Plan, InterestRateHistory
│   ├── enums/          # DebtType, Strategy, PaymentStatus, etc.
│   └── repositories/   # Repository interfaces (contracts)
├── engine/             # Financial calculation engine (pure Dart, no DB)
│   ├── amortization.dart
│   ├── interest_calculator.dart
│   ├── min_payment_calculator.dart
│   ├── payment_allocator.dart
│   ├── strategy_sorter.dart
│   ├── timeline_simulator.dart
│   └── validators.dart
└── features/           # Feature-first UI modules
    ├── debts/          # Debt CRUD
    ├── monthly_action/ # Monthly Action View (home)
    ├── onboarding/     # Guided first-time setup
    ├── payments/       # Payment logging & history
    ├── settings/       # User preferences
    ├── strategy/       # Strategy selection & comparison
    └── timeline/       # Living payoff timeline
```

### Key Technical Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Framework | Flutter + Dart | Cross-platform iOS/Android, native-grade UI |
| Local DB | [Drift](https://drift.simonbinder.eu/) (SQLite) | Reactive streams, type-safe, in-memory testing |
| State Management | BLoC / Cubit | Predictable, testable, separation of concerns |
| Money | Integer cents + `Decimal` | **Never** `double` for financial calculations |
| Primary Keys | UUID v4 | Offline-safe, sync-ready from day one |
| Cloud Sync | Firestore (optional) | Progressive trust — local-first, cloud when chosen |
| Conflict Resolution | Last-Write-Wins | Simple, correct for 99%+ of real usage |

> 📖 Full details: [Architecture Decisions →](docs/architecture-decisions.md) (21 ADRs)

---

## Getting Started

### Prerequisites

- [Flutter 3.38+](https://docs.flutter.dev/get-started/install)
- [FVM](https://fvm.app/) (recommended) — version pinned in `.fvmrc`
- Xcode 16+ (iOS) / Android Studio (Android)

### Setup

```bash
# Clone
git clone https://github.com/TuNa-eTech/debt-payoff-manager.git
cd debt-payoff-manager

# Install Flutter version (if using FVM)
fvm install
fvm use

# Install dependencies
fvm flutter pub get

# Run code generation (Drift, Freezed, Injectable)
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Run on device/emulator
fvm flutter run
```

### Without FVM

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Running Tests

```bash
# All tests
fvm flutter test

# Engine tests only (financial calculations)
fvm flutter test test/engine/

# With coverage
fvm flutter test --coverage
```

---

## Financial Engine

The heart of the app. A **pure Dart** calculation engine with zero side effects — fully testable, fully deterministic.

### What It Does

- **Amortization** — Standard fixed-payment, simple monthly, daily compounding
- **Interest Calculation** — Simple monthly, compound daily, compound monthly
- **Minimum Payment** — Fixed, percent-of-balance, interest-plus-percent (with floor)
- **Strategy Sorting** — Snowball (smallest balance first), Avalanche (highest APR first), Custom
- **Payment Allocation** — Extra payment distribution with **intra-month rollover**
- **Timeline Simulation** — Month-by-month projection with debt-free date, total interest, savings

### Precision Guarantees

- Money stored as **integer cents** — never floating point
- Interest rates stored as **Decimal** (arbitrary precision)
- **Banker's rounding** (round-half-to-even) for interest calculations
- Every output traceable to a formula in the [Financial Engine Spec](docs/financial-engine-spec.md)

### Test Vectors

Phase 1 acceptance uses golden test vectors TV-1 through TV-4: standard amortization, credit card minimum trap, Snowball vs Avalanche comparison, and intra-month rollover. TV-5 (rate change mid-term) remains documented as a deferred scenario until full `InterestRateHistory` runtime support lands in a later phase. Property-based tests verify:

- **Monotonicity** — More extra payment → earlier (or same) debt-free date
- **Avalanche Optimality** — `interest(avalanche) ≤ interest(snowball)`
- **Conservation** — Total principal paid + remaining balance = total original balance
- **Rollover Correctness** — Freed-up payments cascade within the same month

---

## Documentation

| Document | Description |
|---|---|
| [Feature Spec](docs/feature-spec.md) | Product requirements, JTBD, pain points, feature tiers |
| [Financial Engine Spec](docs/financial-engine-spec.md) | Formulas, data model, test vectors, edge cases |
| [Data Schema](docs/data-schema.md) | Drift tables, indexes, invariants, migration strategy |
| [Architecture Decisions](docs/architecture-decisions.md) | 21 ADRs with context, rationale, and consequences |
| [Project Phases](docs/project-phases.md) | Phased roadmap with Design + Engineering tracks |

---

## Roadmap

```
Phase 0     ✅  Architecture + Spec Baseline
Phase 1     ✅  Foundation + Core Data & Engine
Phase 2-3  🔄  Core UX Design + Debt Management MVP
Phase 4       Living Plan (strategy, timeline, payments)
Phase 5       Onboarding & Trust Layer
Phase 6       MVP Polish & Ship (v1.0)
Phase 7       Cloud Sync — Trust Level 1 (v1.1)
Phase 8       Power Features — Scenarios, Milestones (v1.2)
Phase 9       Partner Sharing (v1.3)
Phase 10      Reports & Reminders (v1.4)
```

See the full [Project Phases →](docs/project-phases.md) for entry/exit criteria, deliverables, and dependencies.

---

## Contributing

Contributions are welcome! Here's how you can help:

### Good First Issues

- Engine edge cases — add test vectors for new scenarios
- Accessibility improvements — screen reader labels, contrast fixes
- Localization — translate strings to your language

### Development Workflow

1. **Fork** the repository
2. **Create a branch** from `main` — name it `feat/`, `fix/`, or `docs/`
3. **Write tests first** for engine changes (property-based preferred)
4. **Run the full suite** before submitting:
   ```bash
   fvm flutter analyze
   fvm flutter test
   ```
5. **Open a PR** with a clear description of what and why

### Code Conventions

- **Commit messages**: [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`)
- **Dart style**: enforced by `analysis_options.yaml`
- **Financial code**: every function must reference its spec section in a doc comment
  ```dart
  /// Computes simple monthly interest per financial-engine-spec.md §5.2
  /// interest = balance × (APR / 12), banker's rounding to 2 decimals
  Decimal computeMonthlyInterest(Decimal balance, Decimal apr) { ... }
  ```
- **No `double` for money** — this is enforced in code review

### Architecture Rules

- **Engine is pure** — no DB, no UI, no side effects. Input → output.
- **Repository pattern** — Drift types never leak outside the data layer.
- **Feature-first** — each feature lives in its own directory under `features/`.

---

## Tech Stack

| Category | Package | Purpose |
|---|---|---|
| **State** | `flutter_bloc` / `bloc` | BLoC / Cubit state management |
| **DI** | `get_it` / `injectable` | Dependency injection |
| **Navigation** | `go_router` | Declarative routing |
| **Database** | `drift` / `sqlite3_flutter_libs` | Local-first SQLite |
| **Precision** | `decimal` | Arbitrary precision arithmetic |
| **Charts** | `fl_chart` | Financial visualizations |
| **Formatting** | `intl` | Currency & date formatting |
| **Typography** | `google_fonts` | Premium typography |
| **Animations** | `flutter_animate` | Micro-interactions |
| **Icons** | `lucide_icons` | Consistent icon set |
| **IDs** | `uuid` | UUID v4 primary keys |
| **Models** | `freezed` / `equatable` | Immutable models |
| **Testing** | `mocktail` / `bloc_test` | Mocking & BLoC testing |
| **Codegen** | `build_runner` / `drift_dev` | Code generation |

---

## Project Status

> 🚧 **Active Development** — The financial engine and data layer are implemented. UI features are being built.

| Component | Status |
|---|---|
| Financial Engine | ✅ Implemented + Tested |
| Data Schema (Drift) | ✅ Designed |
| Core Architecture | ✅ Scaffolded |
| Feature UI | 🔄 In Progress |
| Cloud Sync | 📋 Planned |
| Premium / IAP | 📋 Planned |

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Acknowledgements

- Financial formulas based on US consumer lending standards (CFPB, Federal Reserve)
- Competitor research: Debt Payoff Box, Debt Snowball+, Debt Payoff Assistant, Debt Payoff Planner & Tracker, Goodbudget, Changed
- Strategy research: Kellogg School (2016) on snowball behavioral effectiveness

---

<p align="center">
  <strong>Built with 🧮 precision and ❤️ trust.</strong><br>
  <em>Because getting out of debt shouldn't require trusting another app with your money.</em>
</p>
