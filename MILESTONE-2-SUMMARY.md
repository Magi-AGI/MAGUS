# Milestone 2 Summary: Goal Fitness Metrics

**Focus**: Measurability framework and MIC (Maximal Information Coefficient) correlations for goal evaluation.

---

## Overview

M2 provides quantitative metrics for evaluating goal fitness based on:
1. **Measurability**: How well we can observe/measure goal state
2. **Correlations**: Relationships between goals (synergies/conflicts)

These metrics feed into M3's scoring pipeline to influence goal selection.

---

## Measurability Framework

### Definition
```
Measurability = Confidence × Clarity
```

**Components**:
- **Confidence**: Belief in measurement accuracy [0-1]
- **Clarity**: Precision of goal state definition [0-1]

### Key Values
| Goal        | Confidence | Clarity | Measurability |
|-------------|------------|---------|---------------|
| Energy      | 0.80       | 0.90    | 0.72          |
| Exploration | 0.70       | 0.80    | 0.56          |
| Affinity    | 0.50       | 0.40    | 0.20          |

**Range**: [0-1] where higher values indicate better observability

---

## MIC Correlations

### Base Correlations
Measure relationship strength between goals:
- **Energy ↔ Exploration**: 0.70 (strong synergy)
- **Energy ↔ Affinity**: 0.50 (moderate synergy)
- **Exploration ↔ Affinity**: 0.30 (weak synergy)

### Weighted Correlations
Correlations are weighted by measurability using **geometric mean**:

```python
geometric_mean = sqrt(measurability1 × measurability2)
weighted_correlation = base_correlation × geometric_mean
```

**Why Geometric Mean?**
- Better represents mutual synergy than arithmetic mean
- Penalizes asymmetric measurability
- Example: `sqrt(0.72 × 0.56) = 0.635` vs `(0.72 + 0.56)/2 = 0.64`

### Weighted Results
- **Energy-Exploration**: 0.70 × 0.635 = 0.4445
- **Energy-Affinity**: 0.50 × 0.380 = 0.1897
- **Exploration-Affinity**: 0.30 × 0.335 = 0.1004

---

## Implementation

### Python Module
**Location**: `Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.py`

**Key Functions**:
```python
def calculate_measurability(confidence: float, clarity: float) -> float:
    """Returns confidence × clarity"""

def calculate_weighted_correlation(
    base_correlation: float,
    measurability1: float,
    measurability2: float
) -> float:
    """Returns base_correlation × sqrt(m1 × m2)"""
```

### MeTTa Module
**Location**: `Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.metta`

**Key Functions**:
```metta
(: get-measurability (-> GoalType Number))
(: get-correlation (-> GoalType GoalType Number))
(: calculate-weighted-correlation (-> GoalType GoalType Number))
```

**Initialization Required**:
```python
from magus_init import initialize_magus
metta = initialize_magus()  # Registers sqrt, pow, etc.
```

---

## Testing

### Test Suite
**Location**: `Milestone_2/goal-fitness-metrics/measurability/test_measurability.py`

**Tests**: 19 total (12 measurability + 7 correlation)

**Measurability Tests (12)**:
- Component range validation (confidence, clarity in [0,1])
- Individual measurability calculations
- Expected vs calculated validation
- Measurability component breakdown
- Average measurability calculation
- All measurabilities function
- Approximate equality function
- Integration with M3 metagoals
- Novelty score calculation
- Weighted correlation integration

**Correlation Tests (7)**:
- Individual correlation calculations
- Symmetric correlations (A↔B == B↔A)
- Total score calculation
- Data availability validation
- Discretization function
- All correlations function
- Comprehensive system test

### Running Tests
```bash
cd Milestone_2/goal-fitness-metrics/measurability
python test_measurability.py
```

**Expected**: 19/19 tests PASSED

### Validation Criteria
- All measurabilities in [0,1]
- Weighted correlations match expected ±0.01
- Symmetric correlation property holds
- Geometric mean formula verified

---

## Integration with M3

M2 metrics flow into M3 scoring:

1. **Overgoal Calculation**:
   ```python
   overgoal_score = average(weighted_correlations)
   overgoal_bonus = 0.3 × overgoal_score
   ```

2. **Goal Scoring**:
   - Weighted correlations influence goal attractiveness
   - Higher measurability increases goal selection confidence
   - Correlations identify synergistic goal combinations

3. **Data Flow**:
   ```
   M2 Measurability → Weighted Correlations → M3 Overgoal → Final Score
   ```

---

## Key Lessons

### 1. Geometric Mean Superiority
**Issue**: Initially used arithmetic mean for weighting
**Resolution**: Switched to geometric mean
**Impact**: Better penalty for asymmetric measurability

### 2. Grounded Math Functions
**Issue**: MeTTa math operations failed with "unbound symbol"
**Resolution**: `magus_init.py` registers Python math functions
**Impact**: All calculations now work reliably

### 3. Test-Driven Validation
**Issue**: Floating-point comparison challenges
**Resolution**: Tolerance-based assertions (±0.01)
**Impact**: Robust validation across platforms

### 4. Python-MeTTa Consistency
**Issue**: Easy for implementations to drift
**Resolution**: Parallel test suites with shared expected values
**Impact**: Both implementations guaranteed consistent

---

## Files & Locations

**Core Implementation**:
- `Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.py`
- `Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.metta`

**Testing**:
- `Milestone_2/goal-fitness-metrics/measurability/test_measurability.py`
- `Milestone_2/Testing_scenario/Test-Results.md`

**Documentation**:
- `Milestone_2/goal-fitness-metrics/measurability/README.md`

---

## Known Limitations

**None for M2 core functionality**. All metrics validated and integrated successfully.

Minor notes:
- Measurability values are currently static (not dynamically updated)
- Correlation discovery mechanism not implemented (values are predefined)

**Status**: Acceptable - static values sufficient for milestone validation

---

**Version**: 1.0
**Last Updated**: October 2025
**Tests**: 19/19 passing (100%)
