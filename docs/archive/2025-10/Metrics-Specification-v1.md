# MAGUS Milestone 2 - Goal Fitness Metrics Specification v1.0

**Version:** 1.0
**Date:** October 2025
**Owner:** Neoterics / MAGUS team
**Status:** Completed

## 1. Overview

This document provides the formal mathematical definitions and implementation specifications for the two core goal fitness metrics used in MAGUS: **Measurability** and **Correlation**. These metrics enable the system to evaluate which signals and subgoals are worth tracking and promoting within the goal hierarchy.

## 2. Measurability Metric

### 2.1 Definition

**Measurability** quantifies how reliably and clearly a goal's satisfaction level can be measured. It combines two orthogonal factors:

```
Measurability(G) = Confidence_in_Measurement(G) × Metric_Clarity(G)
```

Where:
- **Confidence_in_Measurement**: How confident we are that our measurement reflects reality (0.0 - 1.0)
- **Metric_Clarity**: How clearly defined and unambiguous the measurement is (0.0 - 1.0)

### 2.2 Mathematical Formulation

#### Confidence_in_Measurement(G)

Confidence assesses the quality and reliability of available measurement mechanisms:

```
Confidence(G) = f(DataQuality, SampleFrequency, Objectivity, Noise)
```

**Factors:**
- **Data Quality**: Reliability and accuracy of measurement sources (0.0 - 1.0)
- **Sample Frequency**: How often measurements can be taken (0.0 - 1.0)
- **Objectivity**: Degree to which measurement is observer-independent (0.0 - 1.0)
- **Noise**: Inverse of measurement variance/uncertainty (0.0 - 1.0)

#### Metric_Clarity(G)

Clarity assesses how well-defined the goal's measurement criteria are:

```
Clarity(G) = f(DefinitionPrecision, ThresholdClarity, Quantifiability)
```

**Factors:**
- **Definition Precision**: How precisely the goal state is defined (0.0 - 1.0)
- **Threshold Clarity**: How clear the success/failure boundaries are (0.0 - 1.0)
- **Quantifiability**: Degree to which goal can be expressed numerically (0.0 - 1.0)

### 2.3 Reference Implementation

File: `Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.metta`

**Core Functions:**
```metta
;; Calculate measurability for a goal
(= (get-measurability $goal)
   (calculate-measurability $goal))

(= (calculate-measurability $goal)
   (let $confidence (calculate-confidence $goal)
   (let $clarity (calculate-clarity $goal)
        (* $confidence $clarity))))
```

### 2.4 Validated Reference Values

Based on analysis of three test goals (Energy, Exploration, Affinity):

| Goal | Confidence | Clarity | **Measurability** |
|------|-----------|---------|------------------|
| Energy | 0.8 | 0.9 | **0.72** |
| Exploration | 0.7 | 0.8 | **0.56** |
| Affinity | 0.5 | 0.4 | **0.20** |

**Rationale:**
- **Energy**: High measurability due to objective sensors (battery level, sleep tracking)
- **Exploration**: Moderate measurability with location tracking and activity logs
- **Affinity**: Low measurability due to subjective social relationship metrics

### 2.5 Usage in Goal Promotion/Demotion

**Promotion Threshold:** 0.7 (with hysteresis factor -0.1)
- Signals with measurability ≥ 0.6 (accounting for hysteresis) are candidates for promotion to subgoals

**Demotion Threshold:** 0.3 (with hysteresis factor +0.1)
- Goals with measurability ≤ 0.4 over time window are candidates for demotion or removal

## 3. Correlation Metric

### 3.1 Definition

**Correlation** quantifies the statistical dependence between two goals' satisfaction levels over time. It uses the **Maximum Information Coefficient (MIC)** to capture both linear and non-linear relationships.

```
Correlation(G₁, G₂) = MIC(SatisfactionHistory(G₁), SatisfactionHistory(G₂))
```

### 3.2 Mathematical Formulation

#### Maximum Information Coefficient (MIC)

MIC is based on mutual information with optimal binning:

```
MIC(X,Y) = max_{bins} I(X_binned, Y_binned) / log₂(min(bins_x, bins_y))
```

Where:
- **I(X,Y)**: Mutual information between discretized variables
- **bins**: Discretization granularity (optimized for maximum information capture)

For MAGUS M2 implementation, we use **3-bin discretization**:
- **Low**: [0.0 - 0.33]
- **Mid**: [0.34 - 0.66]
- **High**: [0.67 - 1.0]

#### Mutual Information Calculation

```
I(X,Y) = ΣΣ P(x,y) × log₂(P(x,y) / (P(x) × P(y)))
```

Where:
- **P(x,y)**: Joint probability of X in bin x and Y in bin y
- **P(x), P(y)**: Marginal probabilities

### 3.3 Reference Implementation

File: `Milestone_2/goal-fitness-metrics/correlation/initial_correlation_calculation.metta`

**Core Functions:**
```metta
;; Get correlation between two goals
(= (get-correlation $goal1 $goal2)
   (calculate-mic $goal1 $goal2))

;; Discretize continuous satisfaction values into bins
(= (discretize-value $value)
   (if (<= $value 0.33)
       0
       (if (<= $value 0.66)
           1
           2)))
```

### 3.4 Validated Reference Values

Based on synthetic goal satisfaction data designed to match realistic correlation patterns:

| Goal Pair | **Correlation (MIC)** | Interpretation |
|-----------|----------------------|----------------|
| Energy ↔ Exploration | **0.70** | Strong positive: more energy enables more exploration |
| Energy ↔ Affinity | **0.50** | Moderate positive: social interaction has energy cost |
| Exploration ↔ Affinity | **0.30** | Weak positive: some social exploration overlap |

**Data Design:**
- Energy-Exploration: Diagonal dominance in 3×3 bin matrix (strong correlation)
- Energy-Affinity: Moderate cross-bin scatter
- Exploration-Affinity: Significant cross-bin scatter (weak correlation)

### 3.5 Usage in Goal Promotion/Demotion

**Promotion Threshold:** 0.8 (with hysteresis factor -0.1)
- Signals with correlation ≥ 0.7 to parent goal are candidates for promotion

**Correlation Integration:**
- Used with measurability: `promote if measurability ≥ 0.6 AND correlation ≥ 0.7`
- Weighted by measurability: `effective_correlation = correlation × √(measurability(G₁) × measurability(G₂))`

## 4. Integration Between Metrics

### 4.1 Combined Promotion Criteria

A signal S is promoted to subgoal of parent goal P when:

```
promote(S, P) ⟺
    get-rolling-measurability(S) ≥ (0.7 - 0.1) AND
    get-rolling-correlation(S, P) ≥ (0.8 - 0.1)
```

The 0.1 hysteresis factor prevents oscillation.

### 4.2 Measurability-Weighted Correlation

When comparing correlations between goals with different measurability:

```
WeightedCorrelation(G₁, G₂) =
    Correlation(G₁, G₂) × √(Measurability(G₁) × Measurability(G₂))
```

**Rationale for Geometric Mean**: The geometric mean ensures that **both** goals must have reasonable measurability for the correlation to be trusted. If either goal has very low measurability, the geometric mean will be low, appropriately reducing confidence in the correlation.

**Comparison with Arithmetic Mean**:
- Arithmetic mean `(m₁ + m₂)/2` is biased toward the higher value
- Geometric mean `√(m₁ × m₂)` penalizes when either value is low
- Example: If m₁=0.9 and m₂=0.1:
  - Arithmetic: (0.9 + 0.1)/2 = 0.5 (seems high despite one very low value)
  - Geometric: √(0.9 × 0.1) = 0.3 (more conservative, appropriate for synergy)

This ensures we don't over-trust correlations between poorly measurable goals.

### 4.3 Windowed Metric Calculation

Both metrics operate over rolling time windows:

```metta
(= (create-window $duration $current-time)
   (metric-window (- $current-time $duration) $current-time))

(= (get-rolling-measurability $goal $metrics $window)
   (let* (($filtered (filter-metrics $metrics $window))
          ($count (count-goal-metrics $goal $filtered))
          ($duration (window-duration $window)))
     (if (> $duration 0)
         (/ $count $duration)
         0)))
```

**Default Window:** 1000 time units (configurable via `evaluation-window-duration`)

## 5. API Reference

### 5.1 Measurability Functions

```metta
;; Get measurability score for a goal (0.0 - 1.0)
(: get-measurability (-> Goal Number))

;; Get all measurability scores
(: get-all-measurabilities (-> (List (Goal Number))))

;; Get detailed breakdown (goal, confidence, clarity, measurability)
(: get-measurability-breakdown (-> (List (Goal Number Number Number))))

;; Calculate average measurability across all goals
(: calculate-average-measurability (-> Number))

;; Get measurability factor for external integration
(: get-goal-measurability-factor (-> Goal Number))
```

### 5.2 Correlation Functions

```metta
;; Get correlation between two goals (0.0 - 1.0)
(: get-correlation (-> Goal Goal Number))

;; Get all pairwise correlations
(: get-all-correlations (-> (List (Goal Goal Number))))

;; Calculate total correlation score (average of all pairs)
(: calculate-total-score (-> Number))

;; Weight correlation by measurability
(: get-weighted-correlation (-> Goal Goal Number Number))
```

### 5.3 Integration Functions (M3)

These functions are used by Milestone 3 metagoals module:

```metta
;; Calculate rolling measurability over time window
(: get-rolling-measurability (-> Goal (List MetricRecord) MetricWindow Number))

;; Calculate rolling correlation over time window
(: get-rolling-correlation (-> Goal Goal (List MetricRecord) MetricWindow Number))

;; Create time window for rolling calculations
(: create-window (-> Number Number MetricWindow))
```

## 6. Testing and Validation

### 6.1 Validation Tests

File: `Milestone_2/goal-fitness-metrics/measurability/test-measurability.metta`
File: `Milestone_2/goal-fitness-metrics/correlation/test-correlations.metta`

**Test Coverage:**
- ✅ Component range validation (all values in [0.0, 1.0])
- ✅ Expected vs calculated validation (within 0.01 tolerance)
- ✅ Individual metric calculations
- ✅ Integration function tests
- ✅ Data availability validation

### 6.2 Test Results Summary

```
Energy measurability: 0.72 ✓
Exploration measurability: 0.56 ✓
Affinity measurability: 0.20 ✓

Energy-Exploration correlation: 0.70 ✓
Energy-Affinity correlation: 0.50 ✓
Exploration-Affinity correlation: 0.30 ✓

Total correlation score: 0.50 ✓
Average measurability: 0.49 ✓
```

## 7. Future Enhancements

### 7.1 Adaptive Confidence Calculation

Current implementation uses static confidence values. Future versions should dynamically adjust confidence based on:
- Recent measurement variance
- Sensor health metrics
- Historical prediction accuracy

### 7.2 Dynamic Bin Optimization

Current MIC implementation uses fixed 3-bin discretization. Future versions should:
- Optimize bin count based on data volume
- Use adaptive bin boundaries based on distribution
- Implement full MIC maximization over bin configurations

### 7.3 Temporal Decay

Add time-decay weighting to correlation calculation:
```
WeightedMIC(G₁, G₂) = MIC with exponential decay on older samples
```

## 8. References

### 8.1 Internal Documentation

- `Milestone_2/goal-fitness-metrics/measurability/goal-measurability-planning.md`
- `Milestone_2/goal-fitness-metrics/correlation/goal-correlation-planning.md`
- `Milestone_2/goal-fitness-metrics/overgoal-planning.md`

### 8.2 External References

- Reshef et al. (2011): "Detecting Novel Associations in Large Data Sets" - MIC foundation
- Shannon, C. (1948): "A Mathematical Theory of Communication" - Mutual Information
- Goertzel, B. (2014): "OpenCog System Documentation" - Goal System Architecture

## 9. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Oct 2025 | Initial specification based on M2 implementation and testing |

---

**Document Status:** ✅ Complete and Validated
**Next Review:** After M3 integration testing
