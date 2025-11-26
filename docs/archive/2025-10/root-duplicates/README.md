# Archived Root-Level M3 Duplicates

These files are outdated duplicates of Milestone 3 modules. The canonical versions are in `Milestone_3/core/`.

## Files Archived

| File | Root Date | M3/core Date | Status |
|------|-----------|--------------|---------|
| antigoals.metta | Sep 23 | **Oct 9** | M3 version has new penalty factor constants |
| metagoals.metta | Sep 23 | **Oct 9** | M3 version has M2 integration clarifications |
| scoring-v2.metta | Sep 23 | **Oct 8** | M3 version is newer |
| planner-bt.metta | Sep 23 | **Oct 5** | M3 version is newer |
| hermes-refs.metta | Sep 23 | **Oct 5** | M3 version is newer |
| integration-airis.metta | Sep 23 | **Oct 5** | M3 version is newer |

## Why Archived

**Archive Date**: October 2025

**Reason**: These root-level files were outdated copies created during M3 development. All active tests and modules now correctly reference `Milestone_3/core/` paths.

**Evidence**:
- `test-scoring-overgoal.py` uses `base_dir / 'Milestone_3/core/antigoals.metta'`
- `test-anna-e2e-progression.py` uses `base_dir / 'Milestone_3/core/metagoals.metta'`
- No active code references root-level versions

## Key Differences

**antigoals.metta**:
- Root version: Magic numbers (0.5, 0.3, 0.7) hardcoded
- M3 version: Named constants (energy-penalty-factor, risk-penalty-factor, risky-goal-penalty)
- M3 version: Imports antigoal-costs.metta for data-driven costs

**metagoals.metta**:
- Root version: Commented-out M2 imports
- M3 version: Active M2 measurability/correlation imports
- M3 version: Added goal-name helper function
- M3 version: Clarifying comments showing real M2 data usage

## If You Need Them

These files still work but are superseded. Use the canonical versions:

```metta
;; DON'T use root versions (outdated)
!(load antigoals.metta)

;; DO use canonical M3 versions
!(load Milestone_3/core/antigoals.metta)
```

**Related Documents**:
- REFACTORING-COMPLETE.md - Refactoring that updated M3 versions
- TECHNICAL-DEBT-ANALYSIS.md - Analysis identifying these as vestigial
