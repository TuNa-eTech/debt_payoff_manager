# Tech Stack

## Framework & Language

- **Flutter 3.38+ / Dart 3.9+** — cross-platform iOS & Android
- **FVM** — Flutter version pinned in `.fvmrc` (use `fvm flutter` prefix for all commands)

## Key Libraries

| Category | Package |
|---|---|
| State Management | `flutter_bloc` / `bloc` (BLoC/Cubit pattern) |
| Dependency Injection | `get_it` + `injectable` (code-generated) |
| Navigation | `go_router` |
| Local Database | `drift` + `sqlite3_flutter_libs` (SQLite, reactive streams) |
| Financial Precision | `decimal` (arbitrary precision — never `double` for money) |
| Cloud Sync | `firebase_core`, `firebase_auth`, `cloud_firestore` (optional) |
| Models | `freezed` + `equatable` (immutable, value equality) |
| Serialization | `json_serializable` |
| Charts | `fl_chart` |
| Formatting | `intl` (display only, not calculations) |
| Logging | `logger` (sanitized — no PII) |
| IDs | `uuid` v4 |
| Testing | `mocktail`, `bloc_test`, `glados` (PBT), `fake_cloud_firestore` |

## Code Generation

Several packages require `build_runner`. Run after modifying Drift tables, Freezed models, or Injectable registrations:

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

## Common Commands

```bash
# Install dependencies
fvm flutter pub get

# Run code generation
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Run app
fvm flutter run

# Analyze (lint + type check)
fvm flutter analyze

# Run all tests
fvm flutter test

# Run engine tests only
fvm flutter test test/engine/

# Run with coverage
fvm flutter test --coverage
```

## Linting

- `flutter_lints` via `analysis_options.yaml`
- Run `fvm flutter analyze` before committing

## Commit Convention

Conventional Commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`
