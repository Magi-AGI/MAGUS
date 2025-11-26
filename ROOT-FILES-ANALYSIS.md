# Root-Level Files Analysis

## Current Root-Level Files (14 total)

### ✅ ESSENTIAL - Core Infrastructure (5 files)

| File | Purpose | Used By | Keep? |
|------|---------|---------|-------|
| `types.metta` | Type definitions for all MAGUS modules | All Milestone modules | ✅ YES |
| `math-grounded.metta` | Grounded math functions (sqrt, pow, etc.) | M2, M3 calculations | ✅ YES |
| `math_ext.py` | Python→MeTTa math bridge | magus_init.py | ✅ YES |
| `magus_init.py` | MAGUS initialization (registers math) | All Python tests | ✅ YES |
| `test_fixtures.py` | Shared test infrastructure | Integration tests | ✅ YES |

**Rationale**: These are foundational - loaded by multiple modules across milestones.

---

### ✅ INTEGRATION TESTS - Active & Documented (4 files)

| File | Purpose | Why Separate | Keep? |
|------|---------|--------------|-------|
| `test-scoring-overgoal.py` | Overgoal pipeline integration | Refactored with test_fixtures | ✅ YES |
| `test-anna-e2e-progression.py` | Full E2E with modulators | Bach's 6 modulators validation | ✅ YES |
| `test-m2-m3-integration.py` | M2→M3 flow validation | Data flow verification | ✅ YES |
| `test-overgoal-simple.py` | Diagnostic/debugging | Quick smoke test | ⚠️ MAYBE |

**Source**: REFACTORING-COMPLETE.md line 116-120 explicitly kept these separate.

**Rationale**: Each serves distinct testing purpose not covered by 24/24 test suite.

---

### ⚠️ POSSIBLY REDUNDANT - Need Verification (5 files)

| File | Type | Last Used | Superseded By? | Keep? |
|------|------|-----------|----------------|-------|
| `test-m2-fixed.metta` | MeTTa | Oct 5 | Python test suite? | ❓ CHECK |
| `test-m3-integration.metta` | MeTTa | Oct 6 | test-m2-m3-integration.py? | ❓ CHECK |
| `test-overgoal-integration.metta` | MeTTa | Oct 8 | test-scoring-overgoal.py? | ❓ CHECK |
| `test-math-grounded.py` | Python | Oct 8 | Used by CI? | ❓ CHECK |
| `test-modulator-simple.py` | Python | Oct 8 | Part of M3 tests? | ❓ CHECK |

**Issue**: Not in 24/24 test suite, not in run_all_tests_wsl.sh, but relatively recent dates.

**Question**: Are these developmental/diagnostic tests that can be archived?

---

## Analysis

### The 24/24 Test Suite Only Runs:
1. `Milestone_2/goal-fitness-metrics/measurability/test_measurability.py` (12 tests)
2. `Milestone_2/goal-fitness-metrics/correlation/test_correlations.py` (7 tests)
3. `Milestone_4/tests/test_m4_pipeline.py` (5 tests)

### Root-Level Python Tests NOT in Suite:
- `test-anna-e2e-progression.py` - Manual E2E validation
- `test-m2-m3-integration.py` - Manual M2→M3 validation
- `test-scoring-overgoal.py` - Manual overgoal validation
- `test-overgoal-simple.py` - Diagnostic
- `test-math-grounded.py` - Math bridge unit test
- `test-modulator-simple.py` - Modulator unit test

### Root-Level MeTTa Tests:
- `test-m2-fixed.metta` - MeTTa test file
- `test-m3-integration.metta` - MeTTa test file
- `test-overgoal-integration.metta` - MeTTa test file

**Note**: Line 92-94 of run_all_tests_wsl.sh says:
> "MeTTa test files in tests/m3_tests/ and Milestone_4/tests/m4_tests/ are subject to known Hyperon 0.2.1 evaluation limitations. Python test coverage validates equivalent functionality."

This suggests MeTTa tests are supplementary, not required.

---

## Recommendations

### Keep (9 files):
1-5. Essential infrastructure (types.metta, math-grounded.metta, math_ext.py, magus_init.py, test_fixtures.py)
6-8. Documented integration tests (test-scoring-overgoal.py, test-anna-e2e-progression.py, test-m2-m3-integration.py)
9. **MAYBE** test-overgoal-simple.py (diagnostic value)

### Consider Archiving (5 files):
1. `test-m2-fixed.metta` → archive (superseded by Python tests)
2. `test-m3-integration.metta` → archive (superseded by test-m2-m3-integration.py)
3. `test-overgoal-integration.metta` → archive (superseded by test-scoring-overgoal.py)
4. `test-math-grounded.py` → archive OR add to test suite if unit test needed
5. `test-modulator-simple.py` → archive OR add to test suite if unit test needed

### Action Plan:

**Option A - Conservative**: Archive only the 3 MeTTa test files (redundant with Python tests)
- Reduces root files: 14 → 11

**Option B - Aggressive**: Archive 3 MeTTa + 2 simple Python tests + test-overgoal-simple.py
- Reduces root files: 14 → 8 (only essential + 3 documented integration tests)

---

## Questions for User:

1. Are `test-math-grounded.py` and `test-modulator-simple.py` still useful as unit tests?
   - If yes: Add to test suite
   - If no: Archive

2. Is `test-overgoal-simple.py` still needed for debugging?
   - If yes: Keep
   - If no: Archive (covered by test-scoring-overgoal.py)

3. Are the 3 `.metta` test files still used for anything?
   - Likely no (superseded by Python equivalents)
   - Recommendation: Archive with README

---

**Current State**: 14 root files
**Minimal Target**: 8-9 root files (essential + documented integration tests)
**Status**: Awaiting decision on redundant tests
