<claude-mem-context>
# Memory Context

# [Debt-Payoff-Manager] recent context, 2026-04-30 11:57pm GMT+7

Legend: 🎯session 🔴bugfix 🟣feature 🔄refactor ✅change 🔵discovery ⚖️decision 🚨security_alert 🔐security_note
Format: ID TIME TYPE TITLE
Fetch details: get_observations([IDs]) | Search: mem-search skill

Stats: 50 obs (20,010t read) | 690,519t work | 97% savings

### Apr 25, 2026
S19 Phase 7 Cloud Sync (Firestore) — Audit actual implementation status vs documentation claims (Apr 25 at 8:32 PM)
S16 Debt-Payoff-Manager Apr 25 Phase Status: Phase 7 In Progress, Phases 0–6 + 10 Complete (Apr 25 at 8:32 PM)
S21 Debt-Payoff-Manager Phase 7 Sync — Push pipeline dirty-tracking coverage audit (user asked: "Tiến độ công việc tới đâu, và tiếp theo cần làm gì?") (Apr 25 at 8:34 PM)
S38 Audit and disable unused skills in Debt-Payoff-Manager's .claude/skills directory (Apr 25 at 8:37 PM)
93 8:41p 🔵 MilestoneRepository Interface Has markSeen() Write Method Not Covered in Plan
94 8:42p 🟣 DeviceIdService Implemented: Persistent UUID-Based Device ID via SharedPreferences
95 8:43p 🟣 TrackedSettingsRepository and TrackedMilestoneRepository Implemented
96 " ✅ DI Wiring Complete: DeviceIdService, DataManagementService, and SyncPushQueue Updated in injection.dart
97 11:14p ✅ DI Wiring Complete: All 5 Phase 7 Sync Bug Fixes Wired in injection.dart
98 11:15p 🔵 Existing DriftSyncPushQueue Tests Use Hardcoded deviceId Strings — Need Update for DeviceIdService
99 11:18p 🔴 drift_sync_adapters_test.dart — DeviceIdService import added as first step of API migration
100 " 🔴 drift_sync_adapters_test.dart — DriftSyncPushQueue API migration to DeviceIdService stub
101 " 🟣 New unit tests for DeviceIdService, TrackedSettingsRepository, and TrackedMilestoneRepository
102 11:20p 🔵 Test run reveals 3 remaining failures after Phase 7 sync migration
103 11:21p 🔴 cloud_backup_service_test.dart — SyncPushQueue mock classes updated with watchPendingWrites stream
104 " 🔴 tracked_settings_repository_test.dart — watchSettings stream test fixed with skip(1) operator
105 " 🔵 Test run after Phase 7 fixes reveals remaining issues: 68 passed, 2 failed
106 11:22p 🔴 drift_sync_adapters_test.dart — Second DriftSyncPushQueue compile error fixed
108 11:23p 🔴 Phase 7 sync test suite fully green — all 73 tests pass after migration
109 11:24p 🔵 Full test suite reveals 7 pre-existing failures in UI feature tests — not caused by Phase 7 changes
110 11:27p 🔵 Full test suite 7 failures traced to CloudBackupService mock classes missing new interface methods
111 11:28p 🔵 _FakeCloudBackupService implementation audit — all visible methods present, new interface method not yet identified
### Apr 26, 2026
112 10:13a 🔵 Debt-Payoff-Manager Project Skills Inventory
113 10:14a 🔵 Debt-Payoff-Manager Project Permissions Configuration
S39 Audit and disable unused skills in Debt-Payoff-Manager's .claude/skills — completed successfully (Apr 26 at 10:14 AM)
114 10:15a ✅ Disabled 9 Business/Strategy Skills in Debt-Payoff-Manager
115 3:45p 🔵 Phase 8 Power Features — Progress Status as of 2026-04-26
116 " 🔵 Phase 8 Git Diff — 22 Files Changed, 1,459 Insertions Confirmed
S40 Phase 8 progress check — what has been done and what remains for Debt-Payoff-Manager v1.2 (Apr 26 at 3:46 PM)
117 3:46p 🔵 InterestRateHistory Feature Scope — 19 Files Touch Rate History
118 " 🔵 InterestRateHistoryRepositoryImpl Write Methods Are Runtime Stubs, Not Compile Errors
119 3:47p 🔵 InterestRateHistoryTableCompanion Structure Confirmed — Fix Path Identified
120 " 🔵 Mapper Pattern for toCompanion() — InterestRateHistory Needs lib/data/mappers/ File
121 " 🔵 PlanTimelineCubit Has No scenarioId Parameter — Task 5 Gap Confirmed
122 " 🔵 CompareScenariosPage Already 592 Lines With Snapshot Logic — Chart Enhancement Is the Only Gap
123 3:48p ⚖️ Phase 8 Next Action: Fix Task 2 Interest Rate History Repository Write Methods
124 " ⚖️ Phase 8 Session Work Plan — Three Tasks Queued in Priority Order
125 " 🔵 Pre-existing CloudBackupService Mock Failures Known in Test Suite
126 " 🔵 InterestRateHistory Entity Structure — Missing createdAt/updatedAt for Companion Mapping
127 " 🔵 rate_history_page.dart and Repository Impl Compile Clean — No Errors
128 3:52p 🟣 InterestRateHistory Repository Write Methods Implemented — Task 2 Complete
129 " 🔵 Payment and Plan Entity Structures — Key Fields for MonthlySummaryService
130 3:54p 🔵 PaymentType Enum Uses "charge" Not "newCharge" — Progress Report Name Was Misleading
131 3:55p 🔵 DI Registration Pattern for MonthlySummaryService — Follows MonthlyActionService Template
132 " 🔵 AppFormatters Has formatMonthYear and formatMonthsDuration — Ready for MonthlySummaryPage
133 " 🟣 MonthlySummaryService Created — Task 4 Service Layer Complete
134 " 🔵 app_en.arb Is 2554 Lines — Monthly Summary L10n Strings Must Be Appended After scenariosCopyDebtsSuccess
### Apr 30, 2026
135 6:50p 🔵 Phase 7 Cloud Sync — Implementation Complete, Awaiting Real-Device QA
136 6:51p 🔵 Phase 7 Sync Layer — Detailed Implementation Architecture Confirmed
137 " 🔵 No Mobile Devices Available — Real-Device QA Blocked at Start
138 " 🔵 DI Wiring Complete — All 8 Tracked Repositories and Full Sync Stack in GetIt
139 " 🔵 Sync Unit Tests Pass; Firestore Rules Tests Fail — Emulator Not Running
140 6:52p 🔵 Firestore Rules Tests Commented Out in CI — Emulator Exec Approach Used for QA
141 " 🔵 Firebase Emulator Requires Java 21+ — Workaround Using Zulu 25 JDK
142 " 🔵 All 12 Firestore Rules Tests PASSED — Phase 7 Security Rules Verified
143 6:53p 🔵 Five Code Review Findings in Debt-Payoff-Manager Phase 8

Access 691k tokens of past work via get_observations([IDs]) or mem-search skill.
</claude-mem-context>

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **Debt-Payoff-Manager** (5542 symbols, 12140 relationships, 86 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> If any GitNexus tool warns the index is stale, run `npx gitnexus analyze` in terminal first.

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `gitnexus_impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `gitnexus_detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `gitnexus_query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `gitnexus_context({name: "symbolName"})`.

## When Debugging

1. `gitnexus_query({query: "<error or symptom>"})` — find execution flows related to the issue
2. `gitnexus_context({name: "<suspect function>"})` — see all callers, callees, and process participation
3. `READ gitnexus://repo/Debt-Payoff-Manager/process/{processName}` — trace the full execution flow step by step
4. For regressions: `gitnexus_detect_changes({scope: "compare", base_ref: "main"})` — see what your branch changed

## When Refactoring

- **Renaming**: MUST use `gitnexus_rename({symbol_name: "old", new_name: "new", dry_run: true})` first. Review the preview — graph edits are safe, text_search edits need manual review. Then run with `dry_run: false`.
- **Extracting/Splitting**: MUST run `gitnexus_context({name: "target"})` to see all incoming/outgoing refs, then `gitnexus_impact({target: "target", direction: "upstream"})` to find all external callers before moving code.
- After any refactor: run `gitnexus_detect_changes({scope: "all"})` to verify only expected files changed.

## Never Do

- NEVER edit a function, class, or method without first running `gitnexus_impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `gitnexus_rename` which understands the call graph.
- NEVER commit changes without running `gitnexus_detect_changes()` to check affected scope.

## Tools Quick Reference

| Tool | When to use | Command |
|------|-------------|---------|
| `query` | Find code by concept | `gitnexus_query({query: "auth validation"})` |
| `context` | 360-degree view of one symbol | `gitnexus_context({name: "validateUser"})` |
| `impact` | Blast radius before editing | `gitnexus_impact({target: "X", direction: "upstream"})` |
| `detect_changes` | Pre-commit scope check | `gitnexus_detect_changes({scope: "staged"})` |
| `rename` | Safe multi-file rename | `gitnexus_rename({symbol_name: "old", new_name: "new", dry_run: true})` |
| `cypher` | Custom graph queries | `gitnexus_cypher({query: "MATCH ..."})` |

## Impact Risk Levels

| Depth | Meaning | Action |
|-------|---------|--------|
| d=1 | WILL BREAK — direct callers/importers | MUST update these |
| d=2 | LIKELY AFFECTED — indirect deps | Should test |
| d=3 | MAY NEED TESTING — transitive | Test if critical path |

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/Debt-Payoff-Manager/context` | Codebase overview, check index freshness |
| `gitnexus://repo/Debt-Payoff-Manager/clusters` | All functional areas |
| `gitnexus://repo/Debt-Payoff-Manager/processes` | All execution flows |
| `gitnexus://repo/Debt-Payoff-Manager/process/{name}` | Step-by-step execution trace |

## Self-Check Before Finishing

Before completing any code modification task, verify:
1. `gitnexus_impact` was run for all modified symbols
2. No HIGH/CRITICAL risk warnings were ignored
3. `gitnexus_detect_changes()` confirms changes match expected scope
4. All d=1 (WILL BREAK) dependents were updated

## Keeping the Index Fresh

After committing code changes, the GitNexus index becomes stale. Re-run analyze to update it:

```bash
npx gitnexus analyze
```

If the index previously included embeddings, preserve them by adding `--embeddings`:

```bash
npx gitnexus analyze --embeddings
```

To check whether embeddings exist, inspect `.gitnexus/meta.json` — the `stats.embeddings` field shows the count (0 means no embeddings). **Running analyze without `--embeddings` will delete any previously generated embeddings.**

> Claude Code users: A PostToolUse hook handles this automatically after `git commit` and `git merge`.

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
