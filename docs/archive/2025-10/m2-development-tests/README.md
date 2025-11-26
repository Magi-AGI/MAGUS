# M2 Development Tests Archive

## Overview

This directory contains development and diagnostic test files from Milestone 2 that have been superseded by the official Python test suite.

**Archive Date**: October 10, 2025
**Reason**: Redundant with comprehensive Python test coverage

---

## Archived Files

### 1. test-measurability.metta
**Purpose**: MeTTa-native tests for measurability calculations
**Date**: September 1, 2025
**Superseded By**: `Milestone_2/goal-fitness-metrics/measurability/test_measurability.py` (12 tests)

**Why Archived**:
- MeTTa test subject to Hyperon 0.2.1 evaluation limitations
- Python version more robust and reliable
- Functionality fully covered by Python test suite

### 2. test-correlations.metta
**Purpose**: MeTTa-native tests for correlation calculations
**Date**: September 1, 2025
**Superseded By**: `Milestone_2/goal-fitness-metrics/correlation/test_correlations.py` (7 tests)

**Why Archived**:
- MeTTa test subject to Hyperon 0.2.1 evaluation limitations
- Python version more robust and reliable
- Functionality fully covered by Python test suite

### 3. debug-measurability.metta
**Purpose**: Isolated parameter error debugging
**Date**: September 1, 2025
**Type**: Development diagnostic

**Why Archived**:
- Development/diagnostic only
- Not referenced in any scripts or documentation
- Issue resolved during development

### 4. manual-test.metta
**Purpose**: Manual function testing utility
**Date**: September 1, 2025
**Type**: Development diagnostic

**Why Archived**:
- Manual testing only
- Superseded by automated test suite
- Not referenced anywhere

### 5. test-m2-simple.metta
**Purpose**: Simple runnable M2 test for measurability
**Date**: October 5, 2025
**Superseded By**: Comprehensive Python test suite (12 measurability tests)

**Why Archived**:
- Simple smoke test only
- Comprehensive tests provide better coverage
- Not in official test suite

---

## Current Test Coverage

### Official M2 Test Suite (19 tests)

**Measurability Tests** (12 tests in test_measurability.py):
1. Basic measurability calculation
2. High confidence/clarity test
3. Low confidence/clarity test
4. Zero confidence test
5. Zero clarity test
6. Boundary value tests (0.0, 1.0)
7. Mid-range values
8. Geometric mean calculation
9. Multiple goals integration
10. Weighted correlation with measurability
11. Edge cases
12. Integration with M3

**Correlation Tests** (7 tests in test_correlations.py):
1. Perfect positive correlation (1.0)
2. Perfect negative correlation (-1.0)
3. No correlation (0.0)
4. Moderate positive correlation
5. Moderate negative correlation
6. Weighted correlation calculation
7. Integration with measurability

---

## How to Use Archived Files

If you need to reference the original MeTTa implementations:

### 1. MeTTa Test Files
```bash
# View test structure
cat test-measurability.metta
cat test-correlations.metta

# Run (subject to Hyperon limitations)
metta test-measurability.metta
```

### 2. Debug Files
```bash
# Reference for understanding past issues
cat debug-measurability.metta
cat manual-test.metta
```

### 3. Simple Test
```bash
# Basic M2 functionality check
metta test-m2-simple.metta
```

**Note**: These files are archived for historical reference. Use the official Python test suite for actual testing.

---

## Hyperon 0.2.1 Limitations

The MeTTa test files were subject to known limitations in Hyperon 0.2.1:

1. **Evaluation Issues**: `let*` expressions sometimes fail to evaluate correctly
2. **Pattern Matching**: Complex patterns may not match as expected
3. **Numeric Precision**: Floating-point comparisons inconsistent

These limitations led to the decision to use Python tests as the official test suite, with MeTTa implementations serving as reference.

---

## References

- **Official Tests**: `Milestone_2/goal-fitness-metrics/measurability/test_measurability.py`
- **Official Tests**: `Milestone_2/goal-fitness-metrics/correlation/test_correlations.py`
- **Test Runner**: `run_all_tests_wsl.sh`
- **Audit Report**: `MILESTONE-2-REDUNDANCY-AUDIT.md`
- **Summary**: `MILESTONE-REDUNDANCY-SUMMARY.md`

---

## Test Coverage Status

✅ **100% Coverage Maintained**

All functionality tested by these archived files is covered by the official Python test suite:
- 12 measurability tests
- 7 correlation tests
- 19/25 total official tests are M2-related

**Conclusion**: These files served their purpose during development and are now preserved for historical reference.
