# M3 Duplicate Tests Archive

## Overview

This directory contains duplicate test files from `Milestone_3/tests/` that were exact copies of the centralized tests in `tests/m3_tests/`, differing only in import paths.

**Archive Date**: October 10, 2025
**Reason**: Redundant with centralized test directory

---

## Archived Files (7 files)

All files are duplicates of corresponding files in `tests/m3_tests/`:

1. **test-airis-integration.metta**
2. **test-antigoal-costs.metta**
3. **test-antigoals.metta**
4. **test-end-to-end-scenarios.metta**
5. **test-metagoals.metta**
6. **test-planner.metta**
7. **test-scoring-v2.metta**

---

## Why Duplicate Tests Existed

### Import Path Experimentation

During M3 development, tests were created in two locations with different import strategies:

#### Milestone_3/tests/ (ARCHIVED)
```metta
;; Relative import from within Milestone_3
!(import! &self ../core/metagoals.metta)
```

- **Approach**: Relative paths from milestone directory
- **Pro**: Shorter paths, self-contained within milestone
- **Con**: Only works when running from Milestone_3/tests/
- **Con**: Doesn't integrate with centralized test organization

#### tests/m3_tests/ (KEPT)
```metta
;; Absolute path from project root
!(load ../../Milestone_3/core/metagoals.metta)
```

- **Approach**: Absolute paths from project root
- **Pro**: Works from centralized test directory
- **Pro**: Consistent with overall project structure
- **Con**: Longer paths

**Decision**: Keep centralized tests/ directory for consistency with overall project organization.

---

## Import Statement Comparison

### Example: test-metagoals.metta

**Milestone_3/tests/ version (archived)**:
```metta
;; Test Suite for Metagoals Module
;; Tests metrics windowing, promotion/demotion, and metagoal adjustments
;; Based on Milestone-3-Spec.md Test Requirements

!(import! &self ../core/metagoals.metta)

;; ... rest of test identical ...
```

**tests/m3_tests/ version (kept)**:
```metta
;; Test Suite for Metagoals Module
;; Tests metrics windowing, promotion/demotion, and metagoal adjustments
;; Based on Milestone-3-Spec.md Test Requirements

!(load ../../Milestone_3/core/metagoals.metta)

;; ... rest of test identical ...
```

**Difference**: Only the import statement (line 5) differs. All test logic is identical.

---

## Canonical Test Location

The official M3 tests are located in:
```
tests/m3_tests/
├── test-airis-integration.metta
├── test-antigoals.metta
├── test-end-to-end-scenarios.metta
├── test-metagoals.metta
├── test-planner.metta
└── test-scoring-v2.metta
```

**Note**: `test-antigoal-costs.metta` exists in archive but not in tests/m3_tests/ (likely early version before consolidation into test-antigoals.metta).

---

## Test Status

### MeTTa Tests (Reference)
All M3 MeTTa tests serve as reference implementations but are subject to known Hyperon 0.2.1 limitations:
- Evaluation issues with complex expressions
- Pattern matching inconsistencies
- Not in official test suite

### Python Tests (Official)
M3 functionality validated by:
- M4 pipeline integration tests (test_m4_pipeline.py)
- Anna's E2E modulator tests (validates all 6 Bach modulators)
- M2/M3 integration tests

**Official Test Suite**: 25/25 tests (100% pass rate)

---

## How to Use Archived Files

If you need to reference the milestone-relative import approach:

```bash
# View archived test with relative imports
cat test-metagoals.metta

# Compare with canonical version
diff test-metagoals.metta ../../tests/m3_tests/test-metagoals.metta

# Expected output: Only line 5 differs (import statement)
```

**For actual testing**: Use the canonical tests in `tests/m3_tests/` or the official Python test suite.

---

## Lessons Learned

### What Worked
- ✅ Centralized test organization (tests/ directory)
- ✅ Absolute paths from project root
- ✅ Consistent structure across milestones

### What to Avoid
- ❌ Creating tests in multiple locations
- ❌ Relative imports that only work from specific directories
- ❌ Duplicating test logic in different files

### Best Practices for Future Milestones
1. **Single test location**: Use centralized tests/ directory
2. **Absolute paths**: Import from project root
3. **Clean as you go**: Remove experimental duplicates before completion
4. **M4 as template**: Milestone 4 has optimal organization

---

## Project Organization

### Current Structure (Post-Archive)
```
Milestone_3/
├── README.md
└── core/              # Implementation only
    ├── antigoal-costs.metta
    ├── antigoals.metta
    ├── hermes-refs.metta
    ├── integration-airis.metta
    ├── metagoals.metta
    ├── overgoal.metta
    ├── planner-bt.metta
    └── scoring-v2.metta

tests/m3_tests/        # Centralized tests
├── test-airis-integration.metta
├── test-antigoals.metta
├── test-end-to-end-scenarios.metta
├── test-metagoals.metta
├── test-planner.metta
└── test-scoring-v2.metta
```

**Clean separation**: Implementation in Milestone_3/, tests in centralized tests/.

---

## References

- **Canonical Tests**: `tests/m3_tests/`
- **Official Test Suite**: `run_all_tests_wsl.sh`
- **Audit Report**: `MILESTONE-3-REDUNDANCY-AUDIT.md`
- **Summary**: `MILESTONE-REDUNDANCY-SUMMARY.md`

---

## Conclusion

These duplicate files served a purpose during import path experimentation but created confusing redundancy. The centralized test organization in `tests/m3_tests/` provides:
- Consistent project structure
- Clear test location
- Integration with test runner

**Status**: Duplicates archived, canonical tests remain in tests/m3_tests/.
