# Milestone 3 Redundancy Audit

## Files in Milestone_3

### Core Implementation (KEEP - Active)
1. ✅ `core/antigoal-costs.metta` (Oct 5)
2. ✅ `core/antigoals.metta` (Oct 9 - latest with magic number fixes)
3. ✅ `core/hermes-refs.metta` (Oct 5)
4. ✅ `core/integration-airis.metta` (Oct 5)
5. ✅ `core/metagoals.metta` (Oct 9)
6. ✅ `core/overgoal.metta` (Oct 9)
7. ✅ `core/planner-bt.metta` (Oct 5)
8. ✅ `core/scoring-v2.metta` (Oct 8)
9. ✅ `README.md`

**Status**: Active, used by M4 tests, core implementation

---

### Test Files in Milestone_3/tests/ (REDUNDANT - Duplicate)

10. ❌ `tests/test-airis-integration.metta`
11. ❌ `tests/test-antigoal-costs.metta`
12. ❌ `tests/test-antigoals.metta`
13. ❌ `tests/test-end-to-end-scenarios.metta`
14. ❌ `tests/test-metagoals.metta`
15. ❌ `tests/test-planner.metta`
16. ❌ `tests/test-scoring-v2.metta`

**What they are**:
- MeTTa test files for M3 functionality
- Use relative imports: `!(import! &self ../core/metagoals.metta)`
- Date: Oct 5-6

**Why redundant**:
- **EXACT DUPLICATES** of files in `tests/m3_tests/`
- Only difference: import paths
  - Milestone_3/tests: `!(import! &self ../core/metagoals.metta)`
  - tests/m3_tests: `!(load ../../Milestone_3/core/metagoals.metta)`
- Organized test suite already exists in tests/m3_tests/

**Used by**: Nothing (redundant with tests/m3_tests/)

**Recommendation**: Archive to `docs/archive/2025-10/m3-duplicate-tests/`

---

### Debug Files (Archive - Development Artifacts)

17. ❌ `tests/debug.metta` (Oct 6, 263 bytes)
18. ❌ `tests/debug2.metta` (Oct 6, 198 bytes)
19. ❌ `tests/debug3.metta` (Oct 6, 165 bytes)
20. ❌ `tests/debug4.metta` (Oct 6, 137 bytes)

**What they are**:
- Debug scripts from development
- Oct 6 (during M3 development)
- Small files (137-263 bytes)

**Why redundant**:
- Development/diagnostic only
- Not referenced anywhere
- Functionality covered by comprehensive test suite

**Recommendation**: Archive to `docs/archive/2025-10/m3-debug/`

---

## Duplicate Test Analysis

### Files in tests/m3_tests/ (KEEP - Organized Test Suite)
- ✅ `test-airis-integration.metta`
- ✅ `test-antigoals.metta`
- ✅ `test-end-to-end-scenarios.metta`
- ✅ `test-metagoals.metta`
- ✅ `test-planner.metta`
- ✅ `test-scoring-v2.metta`

**Why keep these**:
- Centralized test organization (all tests in tests/ directory)
- Proper absolute paths from project root
- Referenced in run_all_tests_wsl.sh note
- Part of organized test structure

### Import Path Comparison

**Milestone_3/tests/ version**:
```metta
!(import! &self ../core/metagoals.metta)
```
- Relative path from Milestone_3/tests/
- Works only from within Milestone_3/

**tests/m3_tests/ version**:
```metta
!(load ../../Milestone_3/core/metagoals.metta)
```
- Absolute path from project root
- Works from centralized test directory

---

## Summary

### Files to Keep (9 active + 6 centralized tests = 15 files)
- ✅ 8 core implementation files
- ✅ 1 README.md
- ✅ 6 MeTTa test files in tests/m3_tests/ (centralized)

### Files to Archive (11 files)

**M3 Duplicate Tests** (7 files):
- Milestone_3/tests/test-airis-integration.metta
- Milestone_3/tests/test-antigoal-costs.metta
- Milestone_3/tests/test-antigoals.metta
- Milestone_3/tests/test-end-to-end-scenarios.metta
- Milestone_3/tests/test-metagoals.metta
- Milestone_3/tests/test-planner.metta
- Milestone_3/tests/test-scoring-v2.metta

**M3 Debug Files** (4 files):
- Milestone_3/tests/debug.metta
- Milestone_3/tests/debug2.metta
- Milestone_3/tests/debug3.metta
- Milestone_3/tests/debug4.metta

---

## Rationale

### Duplicate Tests
- Exact duplicates with different import paths
- Centralized tests/ directory is standard organization
- Milestone_3/tests/ creates confusing redundancy
- Keep centralized version (tests/m3_tests/)

### Debug Files
- Development artifacts from Oct 6
- Not referenced anywhere
- Small diagnostic scripts

---

## Action Plan

1. **Create archive directories**:
   - `docs/archive/2025-10/m3-duplicate-tests/`
   - `docs/archive/2025-10/m3-debug/`

2. **Archive files** (11 files):
   - Move 7 duplicate test files
   - Move 4 debug files

3. **Create README** documenting:
   - Why duplicate tests existed (import path experimentation)
   - Difference between import! &self and load paths
   - Why centralized tests/m3_tests/ is canonical

4. **Result**:
   - Milestone_3: 20 files → 9 files (55% reduction)
   - All core implementation retained
   - Centralized test organization maintained

---

## Post-Archive Structure

```
Milestone_3/
├── README.md
└── core/
    ├── antigoal-costs.metta
    ├── antigoals.metta
    ├── hermes-refs.metta
    ├── integration-airis.metta
    ├── metagoals.metta
    ├── overgoal.metta
    ├── planner-bt.metta
    └── scoring-v2.metta

tests/m3_tests/  (centralized test directory)
├── test-airis-integration.metta
├── test-antigoals.metta
├── test-end-to-end-scenarios.metta
├── test-metagoals.metta
├── test-planner.metta
└── test-scoring-v2.metta
```

Clean structure: core implementation in Milestone_3/, tests centralized in tests/.

---

## Note on MeTTa Test Files

As documented in run_all_tests_wsl.sh:
> "MeTTa test files in tests/m3_tests/ and Milestone_4/tests/m4_tests/
> are subject to known Hyperon 0.2.1 evaluation limitations.
> Python test coverage validates equivalent functionality."

These MeTTa tests are:
- ✅ Kept for reference and documentation
- ✅ Subject to known Hyperon limitations
- ✅ Superseded by Python test suite (25/25 tests)
- ✅ Valuable for understanding MeTTa implementation
