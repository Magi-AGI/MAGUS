# Expected Test Results

## M2 Measurability Tests (12 tests)

**File**: `m2_measurability/test_measurability.py`

**Expected Output**:
```
✓ Component range validation (confidence, clarity in [0,1])
✓ Expected vs calculated validation
✓ Energy measurability: 0.72 (confidence=0.80, clarity=0.90)
✓ Exploration measurability: 0.56 (confidence=0.70, clarity=0.80)
✓ Affinity measurability: 0.20 (confidence=0.50, clarity=0.40)
✓ Measurability component breakdown
✓ Average measurability calculation
✓ Weighted correlation integration
✓ All measurabilities function
✓ Approximate equality function
✓ Integration with M3 metagoals
✓ Novelty score calculation

12/12 tests PASSED
```

**Key Metrics**:
- Energy measurability: **0.72** (±0.01 tolerance)
- Exploration measurability: **0.56** (±0.01 tolerance)
- Affinity measurability: **0.20** (±0.01 tolerance)

## M2 Correlation Tests (7 tests)

**File**: `m2_correlation/test_correlations.py`

**Expected Output**:
```
✓ Energy ↔ Exploration correlation: 0.70
✓ Energy ↔ Affinity correlation: 0.50
✓ Exploration ↔ Affinity correlation: 0.30
✓ Symmetric correlations (A↔B == B↔A)
✓ Total score calculation
✓ Data availability validation
✓ Discretization function

7/7 tests PASSED
```

**Key Metrics**:
- Energy ↔ Exploration: **0.70** (±0.01 tolerance)
- Energy ↔ Affinity: **0.50** (±0.01 tolerance)
- Exploration ↔ Affinity: **0.30** (±0.01 tolerance)

## M4 Pipeline Tests (5 tests)

**File**: `m4_pipeline/test_m4_pipeline.py`

**Expected Output**:
```
✓ Scenario schema validation
✓ Ethical logging pipeline
✓ Metrics collection framework
✓ Ablation configuration
✓ Integration modules (AIRIS/HERMES stubs)

5/5 tests PASSED
```

## Validation Criteria

**Test run is successful if**:
- All M2 Python tests pass (19 tests: 12 measurability + 7 correlation)
- M4 pipeline tests pass (5 tests)
- M3 integration verified via code analysis
- Measurability values match expected ±0.01 tolerance
- Correlation values match expected ±0.01 tolerance
- No Python exceptions or MeTTa parsing errors

**Note**: Test execution requires `hyperon` Python library (`pip install hyperon`). Code analysis confirms M4-M3 integration is complete with genuine metagoal/anti-goal effects.

**Known Acceptable Variations**:
- Floating-point rounding differences (< 0.001)
- Log message formatting may vary by Python version
- Hyperon 0.2.1 may show symbolic forms for some outputs (documented in paper Section 4.7)

## Baseline Results

Reference JSON files in `results/baseline/` contain exact outputs from original research runs.

Use `scripts/validate_results.py` to compare your outputs to baseline:

```bash
python scripts/validate_results.py
```

Expected output:
```
=== MAGUS Results Validation ===

✓ M2 metrics validated
✓ M3 integration validated
✓ M4 scenarios validated

=== Validation Complete ===
All results match baseline within tolerance
```

## Troubleshooting Test Failures

### If M2 tests fail:

1. **Check virtual environment is activated**:
   ```bash
   source environment/.venv/bin/activate
   ```

2. **Verify hyperon installation**:
   ```bash
   python -c "from hyperon import MeTTa; print('OK')"
   ```

3. **Check test file paths are correct**:
   ```bash
   ls m2_measurability/test_measurability.py
   ```

### If M4 tests fail:

1. **Verify all dependencies loaded**:
   - M2 measurability module
   - M2 correlation module
   - M3 metagoals module

2. **Check for Hyperon evaluation issues** (known limitation):
   - Some complex patterns may return symbolic forms
   - This is documented in paper Section 5.3.3
   - Workaround: Use validation script

### If validation script reports mismatches:

1. **Check tolerance settings**:
   - Default: ±0.01 for floating-point values
   - May need adjustment for different Python versions

2. **Review baseline JSON files**:
   - Located in `results/baseline/`
   - Generated from original research runs

3. **Consult troubleshooting guide**:
   - See `docs/troubleshooting.md`

## Performance Expectations

**Test execution time**:
- M2 measurability: ~5-10 seconds
- M2 correlation: ~5-10 seconds
- M4 pipeline: ~10-15 seconds
- **Total**: ~20-35 seconds

If tests run significantly slower:
- Check system resources (CPU, RAM)
- Verify no background processes interfering
- See `docs/troubleshooting.md` for optimization tips

## Success Criteria

**✓ Tests are passing if**:
1. All 24 Python tests execute without Python exceptions (12 measurability + 7 correlation + 5 M4 pipeline)
2. All test assertions pass
3. Metric values match expected within tolerance
4. Validation script confirms baseline match

**✗ Tests are failing if**:
1. Any Python exceptions occur
2. Any test assertions fail
3. Metric values deviate by more than tolerance
4. Validation script reports mismatches

---

**Document Version**: 1.0
**Last Updated**: October 2025
**Corresponds to**: MAGUS paper Section 4 (Results)
