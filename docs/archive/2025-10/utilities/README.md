# Archived Utilities

This directory contains utility scripts that have been replaced by more robust testing infrastructure.

## test-runner.py

**Original Purpose**: Manual test runner for M2 measurability and correlation tests

**Why Archived**: Replaced by pytest-based test suite (24/24 tests in `Milestone_4/reproducibility-archive/tests/`)

**Archive Date**: October 2025

**Historical Context**:
- Created during early M2 development
- Used to manually run MeTTa expressions and verify output
- Created 3 separate MeTTa instances inefficiently
- Pytest approach provides:
  - Better error reporting
  - Shared fixtures via `test_fixtures.py`
  - Automated test discovery
  - CI/CD integration capability

**If You Need It**:
The script still works and can be run with:
```bash
python docs/archive/2025-10/utilities/test-runner.py
```

But the canonical test approach is:
```bash
cd Milestone_4/reproducibility-archive/tests
./run_all_tests_wsl.sh
```

**Related Files**:
- `test_fixtures.py` - Shared test infrastructure
- `test-scoring-overgoal.py` - Example of modern test approach
- `Milestone_4/reproducibility-archive/tests/` - Full test suite
