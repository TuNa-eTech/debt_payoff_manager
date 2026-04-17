# Project Structure

## Top-Level

```
lib/
├── core/         # Shared infrastructure (DI, routing, theme, utils, widgets)
├── data/         # Data layer (Drift tables, repositories, mappers)
├── domain/       # Pure Dart domain models, enums, repository interfaces
├── engine/       # Financial calculation engine (pure Dart, no Flutter)
├── features/     # Feature-first UI modules
├── app.dart      # App widget + router setup
└── main.dart     # Entry point, DI initialization
```

## Layer Details

### `core/`
- `di/` — Injectable setup (`injection.dart`, generated `injection.config.dart`)
- `router/` — go_router route definitions
- `theme/` — colors, text styles, dimensions, app theme
- `constants/` — app-wide and financial constants
- `errors/` — exception and failure types
- `extensions/` — Dart extension methods (Decimal, DateTime, BuildContext)
- `utils/` — formatters, validators
- `widgets/` — shared reusable widgets

### `domain/`
- `entities/` — pure Dart classes (Equatable, no DB/Flutter imports)
- `enums/` — domain enums (DebtType, Strategy, PaymentStatus, etc.)
- `repositories/` — abstract repository interfaces (contracts only)

### `data/`
- `local/tables/` — Drift table definitions
- `local/daos/` — Drift DAO classes
- `local/database.dart` — AppDatabase
- `mappers/` — bidirectional DB ↔ domain model mappers
- `repositories/` — concrete repository implementations

### `engine/`
Pure Dart financial calculation engine. No DB, no Flutter, no side effects.
- `amortization.dart`
- `interest_calculator.dart`
- `min_payment_calculator.dart`
- `payment_allocator.dart`
- `strategy_sorter.dart`
- `timeline_simulator.dart`
- `validators.dart`

### `features/`
Each feature follows this structure:
```
features/{feature_name}/
├── cubit/
│   ├── {feature}_cubit.dart
│   └── {feature}_state.dart
└── presentation/
    ├── pages/
    └── widgets/
```

Current features: `debts`, `monthly_action`, `onboarding`, `payments`, `settings`, `strategy`, `timeline`

## Tests

```
test/
├── engine/       # Unit + property-based tests for financial engine
└── widget_test.dart
```

## Architecture Rules

- **Engine is pure** — no DB, no UI, no side effects. Input → output only.
- **Repository pattern** — Drift types never leak outside `data/`. Domain layer only sees interfaces.
- **Feature-first** — all UI code lives under `features/{name}/`.
- **Domain entities** — no Flutter or Drift imports. Use `Equatable` for value equality.
- **Money** — stored as `int` cents in DB and domain. Use `Decimal` for calculations. Never `double`.
- **APR** — stored as `Decimal` (e.g. `0.1899` = 18.99%). Never as a raw percentage.
- **IDs** — UUID v4 strings everywhere. No auto-increment integers.
- **Engine doc comments** — every engine function must reference its spec section:
  ```dart
  /// Per financial-engine-spec.md §5.2: Interest = Balance × (APR / 12)
  ```
- **Firestore** is optional sync only — Drift/SQLite is always the source of truth.
