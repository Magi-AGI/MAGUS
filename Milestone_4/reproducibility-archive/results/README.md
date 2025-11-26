# MAGUS Baseline Results

This directory contains reference results from the original MAGUS research implementation.

## Files

### baseline/m2_metrics.json
**M2 Goal Fitness Metrics baseline**

Contains:
- Measurability values for 3 goals (Energy, Exploration, Affinity)
- Correlation matrix (3×3, symmetric)
- Test results summary (19/19 tests passing)
- Metadata (Hyperon version, Python version, date, tolerance)

**Key Values**:
- Energy measurability: 0.72
- Exploration measurability: 0.56
- Affinity measurability: 0.20
- Energy-Exploration correlation: 0.70
- Energy-Affinity correlation: 0.50
- Exploration-Affinity correlation: 0.30

### baseline/m3_integration.json
**M3 Integration with M2 baseline**

Contains:
- M2→M3 data flow examples (novelty score, uncertainty boost, coherence)
- Integration verification results
- Test status

**Key Examples**:
- Novelty score calculation using M2 measurability
- Uncertainty boost for poorly-measured goals
- Coherence adjustment from M2 correlations

### baseline/m4_scenarios.json
**M4 Ethical Scenarios baseline**

Contains:
- 10 canonical scenario definitions
- Ethical constraints for each scenario
- Test implementation status
- Pipeline test results

**Scenarios**:
1. Resource allocation fairness
2. Privacy vs security trade-off
3. Autonomy preservation
4. Deception prohibition
5. Harm prevention
6. Fairness in decision-making
7. Transparency requirements
8. Consistency and alignment
9. Cultural sensitivity
10. Long-term consequence evaluation

## Usage

### Compare Your Results

Run the validation script to compare your test outputs to these baselines:

```bash
cd ../scripts
python validate_results.py
```

### Tolerance

All numeric comparisons use a tolerance of ±0.01 for floating-point values.

This accounts for:
- Floating-point rounding differences
- Platform-specific computation variations
- Python version differences

### Expected Deviations

**Acceptable**:
- Floating-point differences < 0.001
- Log message formatting variations
- Timestamp differences in metadata

**Not Acceptable**:
- Metric values differing by > 0.01
- Test pass/fail status changes
- Missing or extra tests

## Regenerating Baselines

If you need to regenerate baseline results (e.g., after code changes):

1. Run all tests with known-good code
2. Capture outputs
3. Update JSON files in this directory
4. Document changes in CHANGELOG.md

**Warning**: Only regenerate baselines if the original results are incorrect or the implementation has intentionally changed.

## Verification

To verify baseline integrity:

```bash
python validate_results.py
```

Expected output:
```
=== MAGUS Results Validation ===
✓ M2 metrics validated
✓ M3 integration validated
✓ M4 scenarios validated
=== Validation Summary ===
✓ All validations passed
```

---

**Baseline Version**: 1.0
**Date Generated**: October 2025
**Corresponds to**: MAGUS paper Section 4 (Results)
