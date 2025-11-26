# Milestone 2 Redundancy Audit

## Files in Milestone_2

### Core Implementation (KEEP - Active)
1. ✅ `goal-fitness-metrics/measurability/initial_measurability_calculation.metta`
2. ✅ `goal-fitness-metrics/measurability/initial_measurability_calculation.py`
3. ✅ `goal-fitness-metrics/correlation/initial_correlation_calculation.metta`
4. ✅ `goal-fitness-metrics/correlation/initial_correlation_calculation.py`
5. ✅ `README.md`

**Status**: Active, used by M3/M4, in test suite

---

### Test Files (Official 25/25 Suite)
6. ✅ `goal-fitness-metrics/measurability/test_measurability.py` (12 tests)
7. ✅ `goal-fitness-metrics/correlation/test_correlations.py` (7 tests)

**Status**: Part of official test suite

---

### Redundant MeTTa Test Files (Archive)
8. ❌ `goal-fitness-metrics/measurability/test-measurability.metta`
9. ❌ `goal-fitness-metrics/correlation/test-correlations.metta`

**What they are**:
- MeTTa-native versions of the Python tests
- Created during development before Python test suite

**Why redundant**:
- Superseded by Python tests (more robust)
- Subject to Hyperon 0.2.1 evaluation limitations
- Not in official test suite
- Python tests cover same functionality

**Used by**: Nothing (not referenced in any scripts or docs)

**Recommendation**: Archive to `docs/archive/2025-10/m2-development-tests/`

---

### Debug/Diagnostic Files (Archive)
10. ❌ `goal-fitness-metrics/debuging/debug-measurability.metta`
11. ❌ `goal-fitness-metrics/debuging/manual-test.metta`

**What they are**:
- Debug scripts from development
- Manual testing utilities
- Date: Sep 1 (old)

**Purpose**:
- `debug-measurability.metta`: Isolated parameter error debugging
- `manual-test.metta`: Manual function testing

**Why redundant**:
- Development/diagnostic only
- Functionality fully covered by Python test suite
- Not referenced anywhere

**Recommendation**: Archive to `docs/archive/2025-10/m2-development-tests/`

---

### Simple Test File (Archive)
12. ❌ `test-m2-simple.metta`

**What it is**:
- Simple runnable M2 test
- Tests measurability calculations
- Date: Oct 5 (newer than debug files)

**Why redundant**:
- Superseded by comprehensive Python test suite (12 tests)
- Not in official test suite
- Not referenced in any docs or scripts

**Recommendation**: Archive to `docs/archive/2025-10/m2-development-tests/`

---

### Testing Scenario (KEEP - Complementary System)
13. ✅ `Testing_scenario/goal_ranking_test.py`
14. ✅ `Testing_scenario/goal-ranking-test.metta`

**What they are**:
- Goal ranking system using urgency × importance
- Uses different goals: Energy, Cognitive, Social
- Priority = Urgency × Importance
- Date: Sep 1 (Anna's original concept)

**Why KEEP**:
- **Complementary system** capturing different timescale than M2
- Urgency×Importance: Short-term, reactive, deficit-driven (minutes to hours)
- M2 Measurability/Correlation: Long-term, strategic, synergy-driven (hours to days)
- Valuable concept for integration with current architecture
- See: URGENCY-IMPORTANCE-INTEGRATION-PROPOSAL.md

**Used by**: Not yet integrated (planned for M3)

**Recommendation**: Move to organized location: `Milestone_2/urgency-importance/`

**Note**: This captures a fundamentally different dimension than M2 metrics and should be preserved for integration

---

## Summary

### Files to Keep (5 active + 2 tests + 2 urgency = 9 files)
- ✅ 4 core implementation files (.metta + .py for each metric)
- ✅ 2 Python test files (in official suite)
- ✅ 1 README.md
- ✅ 2 urgency×importance files (Anna's concept - to be integrated)

### Files to Archive (5 files)

**M2 Development Tests** (4 files):
- test-measurability.metta
- test-correlations.metta
- debuging/debug-measurability.metta
- debuging/manual-test.metta

**M2 Simple Tests** (1 file):
- test-m2-simple.metta

---

## Rationale

### MeTTa Test Files
- Superseded by Python equivalents
- Python tests more robust (Hyperon limitations)
- 19 Python tests vs 2 MeTTa test files
- No unique coverage

### Debug Files
- Development artifacts
- Not referenced anywhere
- Functionality covered by test suite

### Urgency×Importance (Anna's Concept)
- Complementary to M2 measurability/correlation
- Captures different timescale (short-term vs long-term)
- Different concepts serve different purposes:
  - Urgency: Reactive, deficit-driven (minutes to hours)
  - Measurability/Correlation: Strategic, synergy-driven (hours to days)
- To be integrated into M3 as dual-layer priority system

---

## Action Plan

1. **Create archive directory**:
   - `docs/archive/2025-10/m2-development-tests/`

2. **Archive files** (5 files):
   - Move 4 dev/debug test files
   - Move 1 simple test file

3. **Reorganize Anna's urgency×importance**:
   - Move Testing_scenario/ to Milestone_2/urgency-importance/
   - Add README explaining concept and integration plan
   - Reference URGENCY-IMPORTANCE-INTEGRATION-PROPOSAL.md

4. **Create README** for archived files documenting:
   - What each file was for
   - Why superseded by Python tests
   - How to use if needed

5. **Result**:
   - Milestone_2: 14 files → 9 files (36% reduction)
   - All active code retained
   - All test coverage maintained
   - Anna's urgency concept preserved for integration

---

## Post-Archive Structure

```
Milestone_2/
├── README.md
├── goal-fitness-metrics/
│   ├── measurability/
│   │   ├── initial_measurability_calculation.metta
│   │   ├── initial_measurability_calculation.py
│   │   └── test_measurability.py
│   └── correlation/
│       ├── initial_correlation_calculation.metta
│       ├── initial_correlation_calculation.py
│       └── test_correlations.py
└── urgency-importance/
    ├── README.md (explains concept and integration plan)
    ├── goal_ranking_test.py (Anna's Python implementation)
    └── goal-ranking-test.metta (Anna's MeTTa implementation)
```

Clean structure: active M2 metrics + Anna's urgency concept preserved for M3 integration.
