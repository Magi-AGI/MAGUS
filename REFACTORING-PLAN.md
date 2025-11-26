# MAGUS Refactoring Plan

**Based on Codex Code Review - October 2025**

This document outlines technical debt and refactoring opportunities identified after documentation consolidation. All items are **non-blocking** - the codebase is functional and all tests pass. These are improvements for maintainability and clarity.

---

## Summary

**Status**: All 24/24 tests passing, no infinite loops, clean execution in WSL

**Key Targets**:
1. Remove hard-coded metagoal stubs
2. Consolidate scenario runner logic
3. Centralize weighted-correlation calculations
4. Archive/remove unused prototypes
5. Clean up TODOs
6. Consolidate redundant integration tests
7. Ensure knowledge-base sync

**Priority**: Post-milestone cleanup (M5 or maintenance phase)

---

## 1. Metagoal Placeholders (Hard-coded Stubs)

### Issue

**File**: `Milestone_3/core/metagoals.metta`

**Current Behavior**:
```metta
; Always returns 0.5 instead of using M2 data
(= (calculate-correlation $goal1 $goal2)
  0.5)  ; TODO: Use M2's get-correlation

; Always returns True
(= (goals-coherent $goals)
  True)
```

**Impact**: Metagoal scoring doesn't use actual M2 correlation data

### Refactor Plan

**Option A - Import M2 Functions** (Recommended):
```metta
; Import M2 correlation functions
!(import! &self Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.metta)

; Use real correlation data
(= (calculate-correlation $goal1 $goal2)
  (get-correlation (goal-type $goal1) (goal-type $goal2)))

; Implement real coherence check
(= (goals-coherent $goals)
  (let $weighted-corrs (map-weighted-correlations $goals)
    (all-above-threshold $weighted-corrs 0.3)))  ; Positive correlation threshold
```

**Option B - Pass Context** (Alternative):
```metta
; Add correlation data to ScoringContext
(= (calculate-correlation $goal1 $goal2 $context)
  (lookup-correlation $goal1 $goal2 (get-correlations $context)))
```

**Benefits**:
- Removes last dummy behavior from scoring loop
- Connects metagoals to actual M2 data
- Makes coherence calculation meaningful

**Effort**: Medium (2-3 hours)
- Update metagoal functions
- Update test expectations
- Verify scoring pipeline still works

---

## 2. Scenario Runner Logic Duplication

### Issue

**File**: `Milestone_4/ethical/scenario-runner.metta`

**Duplicated/TODO Logic**:
```metta
; TODO: Extract penalty from anti-goal result
(= (get-candidate-penalty $candidate)
  0.0)  ; Placeholder

; TODO: Get actual timestamp
(= (get-timestamp-ms)
  0)  ; Placeholder

; TODO: Export to JSON
(= (export-ethical-log $log $filepath)
  ())  ; Stub
```

**Impact**: Scenario runner can't extract full penalty details or export logs

### Refactor Plan

**Step 1 - Expose Helpers from scoring-v2.metta**:
```metta
; In scoring-v2.metta, add public extractors
(: extract-antigoal-penalty (-> DecisionScore Number))
(= (extract-antigoal-penalty (decision-score $base $meta $overgoal $anti $final))
  $anti)

; Import in scenario-runner.metta
(= (get-candidate-penalty $candidate)
  (let $score (score-decision-v2 $candidate ...)
    (extract-antigoal-penalty $score)))
```

**Step 2 - Connect to Python for Timestamp/Export**:
```python
# In magus_init.py or new magus_logging.py
import time
import json

def get_timestamp_ms():
    return int(time.time() * 1000)

def export_ethical_log(log_data, filepath):
    with open(filepath, 'w') as f:
        json.dump(log_data, f, indent=2)

# Register with MeTTa
metta.register_atom('get-timestamp-ms', OperationAtom('get-timestamp-ms', get_timestamp_ms))
metta.register_atom('export-ethical-log', OperationAtom('export-ethical-log', export_ethical_log))
```

**Benefits**:
- Removes code duplication
- Enables full ethical logging
- Connects to reproducibility scripts

**Effort**: Medium (3-4 hours)
- Create helper extractors
- Add Python logging functions
- Update scenario runner
- Add export tests

---

## 3. Weighted-Correlation Logic Centralization

### Issue

**Current State**: Same geometric mean calculation exists in **4 places**:

1. `Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.metta`
2. `Milestone_3/core/overgoal.metta`
3. Python: `Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.py`
4. Test scripts: `test_measurability.py`, `test-scoring-overgoal.py`

**Formula**:
```metta
; MeTTa version
(= (calculate-weighted-correlation $base $m1 $m2)
  (* $base (sqrt (* $m1 $m2))))

# Python version
def calculate_weighted_correlation(base, m1, m2):
    return base * (m1 * m2) ** 0.5
```

**Impact**: Changes require updates in 4 places, risk of drift

### Refactor Plan

**Option A - Single MeTTa Source** (Recommended):
```metta
; In Milestone_2/.../initial_measurability_calculation.metta
; (already exists, just make it the canonical version)
(: calculate-weighted-correlation (-> Number Number Number Number))
(= (calculate-weighted-correlation $base-correlation $measurability1 $measurability2)
  (let $geometric-mean (sqrt (* $measurability1 $measurability2))
    (* $base-correlation $geometric-mean)))

; In overgoal.metta - import instead of reimplementing
!(import! &self Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.metta)

; Use imported function
(= (calculate-overgoal-adjustment $goal $context)
  (let* (($energy-meas (get-measurability energy))
         ($exploration-meas (get-measurability exploration))
         ($energy-exploration-corr (get-correlation energy exploration))
         ($weighted (calculate-weighted-correlation
                      $energy-exploration-corr
                      $energy-meas
                      $exploration-meas)))
    (* 0.3 $weighted)))
```

**Option B - Python Calls MeTTa**:
```python
# In Python tests/helpers - call MeTTa instead of reimplementing
def calculate_weighted_correlation(metta, base, m1, m2):
    result = metta.run(f"!(calculate-weighted-correlation {base} {m1} {m2})")
    return float(result[0])
```

**Benefits**:
- Single source of truth
- Formula changes only need one update
- Consistency guaranteed

**Effort**: Low (1-2 hours)
- Update overgoal.metta imports
- Update Python test helpers
- Verify all tests still pass

---

## 4. Unused Prototypes and Legacy Code

### Issue

**Files to Consider Archiving/Removing**:

1. `magus-action-evaluation-prototype-v1.metta`
2. `magus-action-evaluation-prototype-v1.py`
3. `magus-goal-weighting-v1.metta` (if exists)
4. `test-runner.py` (if not used by main test suite)
5. Any other `-prototype-` or `-v1` files not imported by active code

**Impact**: Confuses which code is "live" vs historical

### Refactor Plan

**Step 1 - Identify Unused Files**:
```bash
# Search for imports/usage
grep -r "magus-action-evaluation-prototype" Milestone_*
grep -r "import.*prototype" **/*.metta
```

**Step 2 - Archive if Unused**:
```bash
# Move to archive with clear labeling
mkdir -p docs/archive/2025-10/prototypes
mv magus-*-prototype-*.* docs/archive/2025-10/prototypes/
mv magus-*-v1.* docs/archive/2025-10/prototypes/
```

**Step 3 - Update Archive README**:
```markdown
### prototypes/
Historical prototype implementations (October 2025)
- magus-action-evaluation-prototype-v1 - Early action evaluation design
- magus-goal-weighting-v1 - Original goal weighting approach
```

**Benefits**:
- Cleaner repository tree
- Clear separation of active vs historical code
- Easier onboarding for new developers

**Effort**: Low (30 minutes)
- Search for usage
- Move files to archive
- Update archive documentation

---

## 5. TODO Cleanup

### Issue

**Remaining TODOs in Active Code**:

**File**: `Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.metta`
```metta
; TODO(human check): Verify these measurability values are reasonable
(= (get-measurability energy) 0.72)
(= (get-measurability exploration) 0.56)
(= (get-measurability affinity) 0.20)
```

**File**: `Milestone_4/ethical/scenario-runner.metta`
```metta
; TODO: Extract penalty from anti-goal result
; TODO: Get actual timestamp
; TODO: Export to JSON
```

**Impact**: Unclear if TODOs are done or need work

### Refactor Plan

**For M2 Measurability TODOs**:

**Option A - Convert to Assertions** (if verified):
```metta
; Verified measurability values (October 2025)
; Energy: High confidence (0.8) × high clarity (0.9) = 0.72
; Exploration: Moderate confidence (0.7) × moderate clarity (0.8) = 0.56
; Affinity: Low confidence (0.5) × low clarity (0.4) = 0.20
(= (get-measurability energy) 0.72)
(= (get-measurability exploration) 0.56)
(= (get-measurability affinity) 0.20)

; Add validation test
(= (test-measurability-ranges)
  (and (>= (get-measurability energy) 0.7)
       (<= (get-measurability energy) 0.8)))
```

**Option B - Keep TODO if Dynamic** (if values should be learned):
```metta
; TODO(future): Replace static values with learned measurability
; Current static values verified for milestone validation (October 2025)
(= (get-measurability energy) 0.72)
```

**For M4 Scenario Runner TODOs**:
- Address via Refactor #2 above
- Remove TODOs once implementations added

**Benefits**:
- Clear status of each TODO
- Prevents re-questioning resolved issues
- Documents future work properly

**Effort**: Low (1 hour)
- Review each TODO
- Convert to comment or test
- Update if resolved

---

## 6. Test Consolidation

### Issue

**Overlapping Integration Tests**:

1. `test-scoring-overgoal.py` - Overgoal integration verification
2. `test-overgoal-simple.py` - Simple overgoal calculation
3. `test-m2-m3-integration.py` - M2-M3 data flow
4. `test-anna-e2e-progression.py` - End-to-end progression test

**Overlap**: All validate overgoal behavior with slightly different setups

**Impact**: Maintenance burden, duplicated setup code

### Refactor Plan

**Option A - Single Integration Test** (Recommended):
```python
# test_m2_m3_m4_integration.py - Consolidated integration test

def test_m2_metrics_loaded():
    """Verify M2 measurability and correlation values"""
    # Energy, exploration, affinity measurability
    # Base correlations

def test_m3_weighted_correlations():
    """Verify geometric mean weighting"""
    # Weighted correlation calculations

def test_m3_overgoal_integration():
    """Verify overgoal calculation and integration"""
    # Overgoal bonus from weighted correlations
    # Integration into scoring pipeline

def test_e2e_progression():
    """End-to-end: goal selection with all components"""
    # Full progression through M2→M3→M4
    # Smoke test of complete pipeline
```

**Option B - Keep Separate, Reduce Duplication**:
```python
# shared_test_fixtures.py
def setup_magus_with_m2_m3():
    """Shared setup for integration tests"""
    metta = initialize_magus()
    # Load modules
    # Return metta + expected values
    return metta, expected_values

# Use in all integration tests
def test_overgoal():
    metta, expected = setup_magus_with_m2_m3()
    # Test specific aspect
```

**Benefits**:
- Reduced maintenance
- Single source of setup logic
- Faster test execution
- Clearer test purpose

**Effort**: Medium (2-3 hours)
- Identify unique assertions in each test
- Create consolidated test or shared fixtures
- Verify 24/24 tests still pass

---

## 7. Knowledge-Base Sync

### Issue

**Current State**: Docs trimmed in metta-magus repo, details in magi-knowledge-repo

**Need**: Ensure milestone READMEs link back to knowledge base

### Refactor Plan

**Verify Links Exist**:

In `Milestone_2/README.md`, `Milestone_3/README.md`, `Milestone_4/README.md`:
```markdown
## Additional Documentation

**Knowledge Repository**:
- [Core Framework Design Document](../../../magi-knowledge-repo/docs/neoterics/MAGUS/Core Framework Design Document (AM).md)
- [MAGUS Best Practices](../../../magi-knowledge-repo/docs/neoterics/MAGUS/MAGUS-Best-Practices.md)
- [MeTTa Lessons Learned](../../../magi-knowledge-repo/docs/neoterics/MAGUS/MeTTa-Lessons-Learned.md)
```

**Add if Missing**:
- Check each milestone README
- Add knowledge-base section if not present
- Reference relevant deep-dive docs

**Benefits**:
- Clear path to detailed docs
- No information lost in consolidation
- Easy navigation between repos

**Effort**: Low (30 minutes)
- Check milestone READMEs
- Add missing links
- Verify paths work

---

## Implementation Priority

### High Priority (Do First)
1. **TODO Cleanup** - Clarifies current state
2. **Knowledge-Base Sync** - Ensures documentation complete
3. **Unused Prototypes** - Quick win, reduces confusion

### Medium Priority (Maintenance Phase)
4. **Weighted-Correlation Centralization** - Reduces future bugs
5. **Metagoal Placeholders** - Improves functionality
6. **Test Consolidation** - Reduces maintenance

### Lower Priority (Future Work)
7. **Scenario Runner Logic** - Enhancement, not blocker

---

## Testing Strategy

**After Each Refactor**:
```bash
# Run full test suite
cd Milestone_4/reproducibility-archive/tests
./run_all_tests_wsl.sh

# Expected: 24/24 tests passing

# Run integration tests specifically
python test-scoring-overgoal.py
python test-anna-e2e-progression.py
```

**Regression Prevention**:
- No refactor should change test expectations
- All 24 tests must still pass
- If behavior changes, update tests explicitly

---

## Non-Issues (Confirmed Fixed)

✅ **Infinite Loops**: Fixed by test-scoring-overgoal.py rewrite
✅ **WSL Execution**: All tests run cleanly in WSL
✅ **Documentation Redundancy**: Resolved via consolidation
✅ **Test Count Inconsistency**: All docs now show 24/24

---

## Refactoring Guidelines

**Before Starting Any Refactor**:
1. Create feature branch
2. Run baseline tests (24/24 passing)
3. Make changes incrementally
4. Test after each increment
5. Commit small, focused changes

**Rollback Strategy**:
- Each refactor should be in separate commit
- Easy to revert if issues found
- Keep main branch stable

**Code Review Checklist**:
- [ ] All 24 tests still pass
- [ ] No new TODOs introduced
- [ ] Documentation updated
- [ ] Knowledge-base updated if needed
- [ ] Commit message explains "why"

---

## Questions for Discussion

1. **Metagoal Implementation**: Should calculate-correlation use M2 data now, or wait for dynamic learning?
2. **Prototype Archival**: Archive or delete? (Recommend archive for historical context)
3. **Test Consolidation**: Single integration test or shared fixtures?
4. **Python vs MeTTa**: Should Python tests call MeTTa for calculations, or keep parallel implementations?

---

## Benefits of Completing This Plan

**Maintainability**:
- Single source of truth for calculations
- Clear separation of active vs historical code
- Reduced duplication

**Functionality**:
- Metagoals connected to real data
- Full ethical logging capability
- Better scenario validation

**Onboarding**:
- Clearer codebase structure
- Fewer "what does this do?" files
- Better documentation links

**Future Work**:
- Easier to add new metagoals
- Simpler to extend scenario framework
- Clear foundation for M5+

---

**Document Version**: 1.0
**Last Updated**: October 2025
**Status**: Planning - No Changes Made Yet
**Next Step**: Review and prioritize with team
