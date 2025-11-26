# Anna's E2E Test Coverage Analysis

## What Anna's E2E Test Validates

The `test-anna-e2e-progression.py` test validates **Anna's complete architectural vision**:

### Components Tested:
1. ✅ **All 6 Modulators** (PAD + Attentional)
   - Arousal, Pleasure, Dominance (PAD framework)
   - Focus, Resolution, Exteroception (Attentional)
   - Tests that each modulator produces an effect (not 1.0)

2. ✅ **Full E2E Flow**
   - Context → Measurabilities → Correlations → Weighted Correlations → Modulators → Ranking

3. ✅ **Integration Path**
   - M2 measurabilities (energy, exploration, affinity)
   - M2 correlations (3 pairs)
   - M3 overgoal (weighted correlations)
   - M3 scoring with all 6 modulators

4. ✅ **Overgoal Calculation**
   - Weighted correlation formula: `base_corr × gmean(meas1, meas2)`
   - Goal set coherence

5. ✅ **Assertions** (12 total)
   - 3 measurability assertions
   - 3 correlation assertions
   - 6 modulator effect assertions

---

## What the 24/24 Test Suite Covers

### M2 Measurability Tests (12 tests)
- ✅ Individual measurability calculations
- ✅ Component validation (confidence, clarity)
- ✅ Average measurability
- ✅ Weighted correlation integration

### M2 Correlation Tests (7 tests)
- ✅ Individual correlations
- ✅ Symmetry
- ✅ Total score calculation
- ✅ Data availability validation

### M4 Pipeline Tests (5 tests)
- ✅ Scenario schema
- ✅ Ethical logging
- ✅ Metrics collection
- ✅ Ablation framework
- ✅ Integration modules (AIRIS, HERMES)

---

## Gap Analysis

### ❌ NOT Covered by 24/24 Suite:

1. **All 6 Modulators Individually Tested**
   - 24/24 suite uses modulators in context but doesn't assert each one works
   - Anna's test has 6 explicit assertions: one per modulator

2. **Full E2E Flow Validation**
   - 24/24 suite tests components in isolation
   - Anna's test validates the complete architectural flow

3. **Overgoal with Modulators**
   - M2 tests validate weighted correlations
   - But don't test the full scoring pipeline with all 6 modulators applied

4. **Ranking Logic**
   - Anna's test documents expected ranking based on measurabilities
   - 24/24 suite doesn't test goal ranking

### ✅ Covered by 24/24 Suite (Redundant):

1. **Measurability Calculations** (3 assertions in Anna, 12 tests in suite)
2. **Correlation Calculations** (3 assertions in Anna, 7 tests in suite)

---

## Recommendation

### Should We Restore Anna's E2E Test?

**YES** - Here's why:

1. **Unique Coverage**: Tests all 6 modulators individually (not in 24/24)
2. **Architectural Validation**: Validates Anna's vision of the complete flow
3. **Integration Confidence**: Proves M2→M3 integration with modulators works
4. **Regression Protection**: Would catch if a modulator breaks

### Where Should It Go?

**Option A - Add to 24/24 Suite** (Recommended):
```bash
# Add to run_all_tests_wsl.sh
echo "========================================================================"
echo "  E2E: Anna's Architectural Flow (12 assertions)"
echo "========================================================================"
python test-anna-e2e-progression.py || {
    echo "FAILED: Anna's E2E test"
    exit 1
}
```
- New total: 36/36 tests (24 + 12)

**Option B - Keep as Separate Smoke Test**:
- Add to Milestone_3/README.md alongside other smoke tests
- Document as "architectural validation"

**Option C - Restore to Root** (Current State):
- Keep in `docs/archive/2025-10/development-tests/`
- Run manually for validation

---

## Comparison with Other Root Tests

| Test | Unique Coverage | In 24/24? | Keep? |
|------|----------------|-----------|-------|
| **test-anna-e2e-progression.py** | 6 modulator assertions, E2E flow | ❌ NO | ✅ **RESTORE** |
| test-m2-m3-integration.py | M2→M3 data flow | ❌ NO | ✅ YES (M3 smoke test) |
| test-scoring-overgoal.py | Overgoal integration | ❌ NO | ✅ YES (M3 smoke test) |
| test-overgoal-simple.py | Nothing unique | ❌ NO | ❌ Archive OK |
| test-math-grounded.py | Math bridge unit test | ❌ NO | ⚠️ Could add |
| test-modulator-simple.py | Simple modulator test | ❌ NO | ❌ Superseded by Anna |

---

## Proposed Action

### Restore Anna's E2E Test

1. **Move back to root**:
   ```bash
   mv docs/archive/2025-10/development-tests/test-anna-e2e-progression.py ./
   ```

2. **Add to test suite** (Option A):
   - Edit `run_all_tests_wsl.sh`
   - Add Anna's test after M4 pipeline tests
   - Update total: 24/24 → 36/36 tests

3. **Update README.md**:
   - Document as architectural validation test
   - Reference Anna's vision

4. **Benefits**:
   - Comprehensive modulator testing
   - E2E flow validation
   - Protection against architectural regression
   - Documents Anna's original vision

---

## Test Coverage Summary

**Current (24/24)**:
- M2 component tests: ✅ Excellent
- M4 pipeline tests: ✅ Good
- Modulator coverage: ⚠️ Contextual only
- E2E flow: ⚠️ Not validated

**With Anna's Test (36/36)**:
- M2 component tests: ✅ Excellent
- M4 pipeline tests: ✅ Good
- Modulator coverage: ✅ **All 6 tested individually**
- E2E flow: ✅ **Complete validation**

---

## Conclusion

Anna's E2E test provides **unique and valuable coverage** that the 24/24 suite lacks. It validates:
1. All 6 modulators work individually
2. The complete architectural flow
3. M2→M3 integration with modulators
4. Anna's vision is implemented correctly

**Recommendation**: **Restore to root and add to test suite** → 36/36 tests total.

This gives us comprehensive coverage of both components (M2/M4 tests) and architecture (Anna's E2E flow).
