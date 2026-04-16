# Summary

<!-- 1-3 sentences. Why this change, what does it do? -->

## Type of change

- [ ] New feature (Tier 1 / Tier 2 — specify which spec §)
- [ ] Bug fix
- [ ] Refactoring (no behavior change)
- [ ] Engine / math change (requires additional scrutiny)
- [ ] Sync / Firestore change (requires rules test update)
- [ ] Docs / ADR
- [ ] Chore / infra

## Checklist

### Mandatory

- [ ] CI green
- [ ] Tests added/updated for the change
- [ ] Coverage not decreased
- [ ] No new `// ignore:` or `@skip` without justification
- [ ] No PII in logs / analytics

### If touching engine (`lib/engine/`)

- [ ] Test vectors still pass (see `financial-engine-spec.md §12`)
- [ ] Property-based tests pass 1000+ iterations
- [ ] New formula has source/reference in code comment
- [ ] Sanity warnings updated if invariants changed

### If touching data layer (`lib/data/`)

- [ ] Migration test added for schema changes
- [ ] `drift_schemas/vN/` snapshot updated
- [ ] Repository invariants documented

### If touching sync (`lib/sync/` or `firestore.rules`)

- [ ] Firestore rules unit tests updated
- [ ] Multi-device scenario tested (or emulator test added)
- [ ] Cost impact considered (writes, reads per user)

### If touching UI (`lib/features/`)

- [ ] Widget test added
- [ ] Screen reader labels (accessibility)
- [ ] Dark mode verified
- [ ] No hardcoded strings (i18n-ready)

## Screenshots / Video

<!-- Required for UI changes. GIF or video preferred. -->

## References

- Spec: [feature-spec §X.Y](../docs/feature-spec.md)
- ADR: [ADR-XXX](../docs/architecture-decisions.md#adr-xxx)
- Issue: Fixes #...

## Post-merge tasks

- [ ] Update release notes
- [ ] Notify team in #product if user-facing
