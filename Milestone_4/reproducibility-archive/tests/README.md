# MAGUS Test Suite

This directory contains all tests for reproducing MAGUS experiments.

## Structure

```
tests/
├── m2_measurability/     # M2 measurability tests (12 tests)
├── m2_correlation/       # M2 correlation tests (7 tests)
├── m4_pipeline/          # M4 pipeline tests (5 tests)
├── run_all_tests_wsl.sh      # Master test runner script
└── expected_results.md   # Validation criteria and expected outputs
```

## Running Tests

### All Tests
```bash
./run_all_tests_wsl.sh
```

Expected: `24/24 Python tests PASSED`

### Individual Test Suites

```bash
# M2 measurability
python m2_measurability/test_measurability.py

# M2 correlation
python m2_correlation/test_correlations.py

# M4 pipeline
python m4_pipeline/test_m4_pipeline.py
```

## Test Content

### M2 Measurability Tests (12 tests)
- Component range validation (confidence, clarity in [0,1])
- Expected vs calculated validation
- Individual measurability calculations (Energy, Exploration, Affinity)
- Measurability component breakdown
- Average measurability calculation
- Weighted correlation integration
- All measurabilities function
- Approximate equality function
- Integration with M3 metagoals
- Novelty score calculation

### M2 Correlation Tests (7 tests)
- Individual correlation calculations (Energy-Exploration, Energy-Affinity, Exploration-Affinity)
- Symmetric correlation validation (A↔B == B↔A)
- Total score calculation
- Data availability validation
- Discretization function
- All correlations function
- Comprehensive system test

### M4 Pipeline Tests (5 tests)
- Scenario schema validation
- Ethical logging pipeline
- Metrics collection framework
- Ablation configuration
- Integration modules (AIRIS/HERMES stubs)

## Prerequisites

Before running tests:

1. **Virtual environment activated**:
   ```bash
   source ../environment/.venv/bin/activate
   ```

2. **Dependencies installed**:
   ```bash
   pip install -r ../environment/requirements.txt
   ```

3. **Source code copied**:
   See `../source/README.md` for instructions

## Expected Results

See `expected_results.md` for detailed validation criteria.

**Summary**:
- All 24 Python tests should pass
- Metric values should match expected within ±0.01 tolerance
- No Python exceptions or MeTTa parsing errors

## Troubleshooting

### Tests fail with "ModuleNotFoundError"
**Solution**: Activate virtual environment
```bash
source ../environment/.venv/bin/activate
```

### Tests fail with "No module named 'hyperon'"
**Solution**: Install dependencies
```bash
pip install -r ../environment/requirements.txt
```

### Tests fail with import errors
**Solution**: Verify source code is present
```bash
ls ../source/Milestone_2/
ls ../source/Milestone_3/
ls ../source/Milestone_4/
```

### Tests pass but values don't match expected
**Cause**: Possible platform/version differences
**Action**: Run validation script
```bash
cd ../scripts
python validate_results.py
```

## Validation

After running tests, validate results match baseline:

```bash
cd ../scripts
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

## Continuous Integration

To run tests in CI/CD pipeline:

```yaml
# Example .gitlab-ci.yml
test:
  script:
    - cd reproducibility-archive/environment
    - ./setup.sh
    - cd ../tests
    - ./run_all_tests_wsl.sh
```

---

**Test Suite Version**: 1.0
**Last Updated**: October 2025
**Total Tests**: 24 Python tests (12 M2 measurability + 7 M2 correlation + 5 M4 pipeline)
