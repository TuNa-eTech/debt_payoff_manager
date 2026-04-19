<claude-mem-context>
# Memory Context

# [Debt-Payoff-Manager] recent context, 2026-04-19 11:36am GMT+7

Legend: 🎯session 🔴bugfix 🟣feature 🔄refactor ✅change 🔵discovery ⚖️decision
Format: ID TIME TYPE TITLE
Fetch details: get_observations([IDs]) | Search: mem-search skill

Stats: 22 obs (8,641t read) | 1,118,057t work | 99% savings

### Apr 18, 2026
1 10:33a 🔵 Debt-Payoff-Manager Project Documentation Structure
2 10:34a 🔵 Debt-Payoff-Manager: Full Product Vision and Architecture
3 " 🔵 Financial Engine Specification: Precision Rules and Test Vectors
4 " 🔵 Firestore Sync Architecture: Local-First with Progressive Trust Levels
9 10:35a 🔵 Drift Database Schema: Complete Table Definitions and Type Conventions
10 " 🔵 Test Strategy: 6-Layer Pyramid with Financial Correctness as Non-Negotiable
11 " 🔵 Project Phase Gates and Detailed Delivery Milestones (Phases 4–10)
16 10:55a 🔵 Debt-Payoff-Manager Codebase Directory Structure Confirmed
17 " 🔵 pubspec.yaml Confirms Full Dependency Stack is Configured
18 " 🔵 Git Status Reveals Active Phase 2 Schema Expansion In Progress
19 10:56a 🔵 Complete File Inventory: 110+ Files Covering All Planned Features
20 " 🔵 GoRouter: Full 5-Tab Shell + Onboarding Flow Fully Wired
21 " 🔵 DI Manually Written (Not injectable Codegen) — 5 Repositories Registered
22 " 🔵 All 5 Repository Implementations Complete with Soft Delete, Streaming, and Validation
23 " 🔵 Full Engine Layer Implemented: TimelineSimulator Uses 4-Step Monthly Algorithm
24 " 🔵 Phase Assessment: UI Complete as Static Mockup, Data-UI Wiring is the Missing Link
25 " 🔵 All Onboarding UI Pages Fully Implemented with Navigation Wired
26 " 🔵 SyncBackupPage Implements Trust Level 1 Upgrade Flow (UI Only)
41 11:03a 🔵 Full Test Suite Status: 44/45 Tests Pass, 1 Widget Test Fails
42 " 🔵 Flutter Analyzer: 51 Issues — 4 Recursive Getters (Errors), 46 Deprecation Warnings, 1 Unused Import
43 " 🔵 Phase 3 Wiring Gap: All UI Forms Save Without Persisting, All Feature Fields Ignored
44 " 🔵 DebtRepositoryImpl Full CRUD + Streams Confirmed Working with 9 Tests

Access 1118k tokens of past work via get_observations([IDs]) or mem-search skill.
</claude-mem-context>

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **Debt-Payoff-Manager** (715 symbols, 708 relationships, 0 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> If any GitNexus tool warns the index is stale, run `npx gitnexus analyze` in terminal first.

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `gitnexus_impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `gitnexus_detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `gitnexus_query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `gitnexus_context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `gitnexus_impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `gitnexus_rename` which understands the call graph.
- NEVER commit changes without running `gitnexus_detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/Debt-Payoff-Manager/context` | Codebase overview, check index freshness |
| `gitnexus://repo/Debt-Payoff-Manager/clusters` | All functional areas |
| `gitnexus://repo/Debt-Payoff-Manager/processes` | All execution flows |
| `gitnexus://repo/Debt-Payoff-Manager/process/{name}` | Step-by-step execution trace |

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
