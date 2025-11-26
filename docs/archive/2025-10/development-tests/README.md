# Archived Development & Diagnostic Tests

These test files were used during development but are not part of the official 24/24 test suite or milestone smoke test requirements.

## Archive Date

October 2025

## Files Archived

### Python Integration Tests (4 files)

#### test-anna-e2e-progression.py
**Purpose**: End-to-end progression test with Anna agent and Bach's 6 modulators

**Why Archived**:
- Not in 24/24 test suite (run_all_tests_wsl.sh)
- Not required by any milestone README
- Functionality covered by:
  - M4 pipeline tests (modulators in scoring context)
  - test-scoring-overgoal.py (integration validation)

**Historical Value**: Demonstrated full E2E flow with all 6 modulators (pleasure, arousal, dominance, focus, resolution, exteroception)

**Status**: Functional but superseded

---

#### test-overgoal-simple.py
**Purpose**: Simple diagnostic test for overgoal calculation

**Why Archived**:
- Not in 24/24 test suite
- Diagnostic/debugging only
- Functionality covered by:
  - test-scoring-overgoal.py (comprehensive overgoal validation)
  - M2 correlation tests (weighted correlation logic)

**Historical Value**: Quick smoke test during M3 development

**Status**: Superseded by test-scoring-overgoal.py

---

#### test-math-grounded.py
**Purpose**: Unit test for Python→MeTTa math bridge (sqrt, pow, etc.)

**Why Archived**:
- Not in 24/24 test suite
- Math functions implicitly tested by:
  - M2 measurability tests (geometric mean uses sqrt)
  - M2 correlation tests (calculations use math functions)
  - All scoring tests rely on math-grounded.metta working

**Could Be Restored**: If explicit unit tests for math_ext.py are desired, add to test suite

**Status**: Functionality validated indirectly by integration tests

---

#### test-modulator-simple.py
**Purpose**: Simple test for Bach's modulator system

**Why Archived**:
- Not in 24/24 test suite
- Modulator functionality validated by:
  - M4 pipeline tests (uses modulators in scoring context)
  - Integration tests (test-scoring-overgoal.py includes modulators)

**Historical Value**: Demonstrated modulator adjustment ranges

**Status**: Superseded by integration tests

---

### MeTTa Test Files (3 files)

#### test-m2-fixed.metta
**Purpose**: MeTTa-native test for M2 measurability and correlation

**Why Archived**:
- Superseded by Python test suite:
  - `Milestone_2/goal-fitness-metrics/measurability/test_measurability.py` (12 tests)
  - `Milestone_2/goal-fitness-metrics/correlation/test_correlations.py` (7 tests)
- run_all_tests_wsl.sh notes: "MeTTa test files... subject to known Hyperon 0.2.1 evaluation limitations. Python test coverage validates equivalent functionality."

**Status**: Superseded by Python equivalents

---

#### test-m3-integration.metta
**Purpose**: MeTTa-native test for M2→M3 integration

**Why Archived**:
- Superseded by `test-m2-m3-integration.py` (Python equivalent)
- MeTTa tests have Hyperon 0.2.1 evaluation limitations
- Python version is M3 smoke test requirement

**Status**: Superseded by test-m2-m3-integration.py

---

#### test-overgoal-integration.metta
**Purpose**: MeTTa-native test for overgoal calculation

**Why Archived**:
- Superseded by `test-scoring-overgoal.py` (Python equivalent)
- MeTTa tests have Hyperon 0.2.1 evaluation limitations
- Python version is M3 smoke test requirement

**Status**: Superseded by test-scoring-overgoal.py

---

## What's NOT Archived (Still Active)

### Essential Infrastructure
- `types.metta` - Core type definitions
- `math-grounded.metta` - Grounded math functions
- `math_ext.py` - Python math bridge
- `magus_init.py` - MAGUS initialization
- `test_fixtures.py` - Shared test infrastructure

### Official 24/24 Test Suite
- `Milestone_2/goal-fitness-metrics/measurability/test_measurability.py` (12 tests)
- `Milestone_2/goal-fitness-metrics/correlation/test_correlations.py` (7 tests)
- `Milestone_4/tests/test_m4_pipeline.py` (5 tests)

### Milestone Smoke Tests
- `test-m2-m3-integration.py` - M3 README requirement
- `test-scoring-overgoal.py` - M3 README requirement

---

## Running Archived Tests

These files still work if you need them:

```bash
# Python tests
python docs/archive/2025-10/development-tests/test-anna-e2e-progression.py
python docs/archive/2025-10/development-tests/test-overgoal-simple.py
python docs/archive/2025-10/development-tests/test-math-grounded.py
python docs/archive/2025-10/development-tests/test-modulator-simple.py

# MeTTa tests (may have evaluation issues in Hyperon 0.2.1)
metta docs/archive/2025-10/development-tests/test-m2-fixed.metta
metta docs/archive/2025-10/development-tests/test-m3-integration.metta
metta docs/archive/2025-10/development-tests/test-overgoal-integration.metta
```

But the canonical approach is:

```bash
# Run official test suite
./run_all_tests_wsl.sh  # 24/24 tests

# Run M3 smoke tests
python test-m2-m3-integration.py
python test-scoring-overgoal.py
```

---

## Restoration Criteria

These files could be restored if:

1. **Unit tests become policy**: Add test-math-grounded.py and test-modulator-simple.py to test suite
2. **E2E regression testing**: Add test-anna-e2e-progression.py to nightly CI
3. **MeTTa testing improves**: If Hyperon fixes evaluation issues, restore .metta tests

But for M4 milestone completion, they are not required.

---

**Related Documents**:
- ROOT-FILES-ANALYSIS.md - Analysis leading to this archival
- TECHNICAL-DEBT-ANALYSIS.md - Initial technical debt assessment
- REFACTORING-COMPLETE.md - Codex's refactoring (kept 4 integration tests)
- run_all_tests_wsl.sh - Official 24/24 test suite
- Milestone_3/README.md - M3 smoke test requirements
