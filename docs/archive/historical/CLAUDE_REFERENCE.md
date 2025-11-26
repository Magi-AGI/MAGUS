# MAGUS Repo Review Notes (2025-10-07)

These notes summarize discrepancies between the MAGUS implementation in `neoterics/metta-magus` and the related documentation in `magi-knowledge-repo` for Claude to reference.

## Key Assets
- `neoterics/metta-magus/README.md` — milestone overview and links to the core MeTTa modules (M2 metrics, M3 decision pipeline, M4 ethical harness) plus the Python harnesses.
- `neoterics/metta-magus/Milestone_4/reproducibility-archive/` — packaging for D5 (environment setup, scripts, baseline results, expected outputs).
- Knowledge base docs under `magi-knowledge-repo/docs/neoterics/MAGUS/` — milestone specs, implementation plans, retrospectives, and the consolidated `MAGUS-Best-Practices.md` guidance.

## Contradictions and Blocking Issues
- **"31/31 tests passing" claims remain unverified.** Both the repo README (`README.md:12`, `README.md:180`) and `MAGUS-Best-Practices.md:5` assert clean test status, but several suites still break.
  - `Milestone_2/goal-fitness-metrics/correlation/test-correlations.metta:4` tries to `!(include "initial-correlation-calculation.metta")`; the real file is `initial_correlation_calculation.metta`, so the tests never load.
  - `Milestone_2/goal-fitness-metrics/measurability/test-measurability.metta` only prints results and never asserts, contradicting the documented `assertEqualToResult` outputs in `Milestone_2/Testing_scenario/Test-Results.md`.
  - `Milestone_4/ethical/scenario-runner.metta` loads `../Milestone_3/...` paths (`lines 7-10`), but from inside `Milestone_4/ethical/` that resolves to a non-existent `Milestone_4/Milestone_3` folder. When the MeTTa interpreter executes, imports fail before the pipeline starts.
  - The same runner calls `(and ...)` without defining an `and` helper (`line ~331`), so even with fixed paths it errors.
  - Legacy tests in `tests/m3_tests/` still rely on deprecated `!(import! ...)` statements and omit promised helper definitions (e.g., `tests/m3_tests/test-antigoals.metta:5`), contradicting `VERIFICATION_STATUS.md:51` which claims all imports were converted to `!(load ...)`.
  - M4 Python coverage (`Milestone_4/tests/test_m4_pipeline.py`) depends on the failing scenario runner; until the MeTTa module loads cleanly, this script cannot pass.
- **Docs record both failures and successes simultaneously.** `Lessons-Learned-M2-M3.md` (knowledge repo) documents that tests were never run and returned symbolic expressions, yet other docs continue to state the suite has already passed.
- **Deliverables report outdated blockers.** `DELIVERABLES-FINAL-STATUS.md` still flags a missing `requirements.txt`, but the archive now provides one at `Milestone_4/reproducibility-archive/environment/requirements.txt`.

## Recommended Remediations
1. **Unify the live test suite before re-running claims.**
   - Fix the M4 relative import paths and add explicit boolean helpers where `(and ...)` is used.
   - Align the correlation test include name with the actual file.
   - Update or retire the duplicate `tests/m3_tests/*` copies so there is a single authoritative set.
2. **Execute the full suite with Hyperon.**
   - Activate the WSL virtual environment (`.venv`) and run:
     ```bash
     python Milestone_2/goal-fitness-metrics/measurability/test_measurability.py
     python Milestone_2/goal-fitness-metrics/correlation/test_correlations.py
     python Milestone_4/tests/test_m4_pipeline.py
     metta tests/m4_tests/test-ethical-suite.metta
     ```
   - Replace placeholder results in README, best-practices, and deliverable summaries with the real outcomes.
3. **Sync documentation with reality.**
   - Update `README.md`, `MAGUS-Best-Practices.md`, and `DELIVERABLES-FINAL-STATUS.md` once the corrected runs succeed.
   - Keep the Lessons Learned document for historical context but note the precise run that closes the loop.

## Testing Environment Reminder
- Hyperon requires WSL; activate the project virtual environment (e.g., `source .venv/bin/activate`) before invoking the MeTTa interpreter or Python harnesses.
- The repo assumes Hyperon 0.2.1 (`Milestone_4/reproducibility-archive/environment/requirements.txt`).
