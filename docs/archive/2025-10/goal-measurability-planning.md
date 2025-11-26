# Goal Measurability Planning - Confidence × Clarity

## What Is Measurability?

Measurability determines how reliably we can assess goal satisfaction. Since the **Overgoal = Measurability × Correlation**, we need robust measurability scores to make good decisions about which goals to prioritize.

**Core Formula**: 
```
Measurability = Confidence_in_Measurement × Metric_Clarity
```

## The Two Components

### 1. Confidence_in_Measurement (0.0 - 1.0)
How confident are we that our goal satisfaction measurement reflects reality?

**Factors affecting confidence**:
- **Sample size**: More observations = higher confidence - this is probably the most important
- **Measurement frequency**: Regular tracking vs. sporadic checks?


**Examples**:
- Energy goal with "battery" + rest tracking = 1 confidence
- Affinity goal based only self-report + amount of interactions  = 0.4 confidence
- Exploration goal with activity logs = 0.8 confidence

*** in future we use pattern miner

### 2. Metric_Clarity (0.0 - 1.0)
How clearly defined and unambiguous is our goal measurement?

**Factors affecting clarity**:
- **Measurement objectivity**: Noise vs. quantifiable metrics
- **Boundary clarity**: Clear thresholds vs. fuzzy boundaries
- **Interpretability**: Easy to understand vs. complex composite scores
- **Occam's Razor**: simplicity algorythm 

**Examples**:
- Energy: "Battery percentage from 0-100%" = 1 clarity
- Affinity: "Quality of social connections" = 0.3 clarity (too vague)
   - but would that mean that Affinity is always vague..? Because of theory of mind
- Exploration: "New locations visited per day" = 0.9 clarity

## Implementation Strategy

### Phase 1: Static Measurability (Start Here)
Begin with predefined measurability scores based on goal type and available sensors/data:

```
Energy: 
- Confidence: 0.8 (good data available)
- Clarity: 0.9 (well-defined energy metrics)
- Measurability: 0.8 × 0.9 = 0.72

Exploration:
- Confidence: 0.7 ( activity tracking)
- Clarity: 0.8 (clear location/activity metrics)
- Measurability: 0.7 × 0.8 = 0.56

Affinity:
- Confidence: 0.5 (limited social interaction data)
- Clarity: 0.4 (subjective relationship quality)
- Measurability: 0.5 × 0.4 = 0.20
```

### Phase 2: Adaptive Measurability (Future)
Dynamically adjust measurability based on:
- Actual measurement variance over time
- Prediction accuracy (how well our measurements predict outcomes)
- Cross-validation with other data sources

## Technical Considerations

### Data Requirements
- **Measurement history**: Track goal satisfaction values over time
- **Measurement metadata**: Source, timestamp
- **Variance analysis**: Standard deviation, outlier detection
- **Validation data**: Cross-references, ground truth comparisons

### Calculation Approach
1. **Confidence calculation**:
   - Base confidence from data source quality
   - Adjust for sample size (more data = higher confidence)
   - Boost for recent validation

2. **Clarity calculation**:
   - Base clarity from goal definition specificity
   - Adjust for simplicity using occam's razor 
   - Consider threshold/boundary precision

### Integration with Correlation
```
Overgoal = Σ(Measurability_i × Correlation_ij) for all goal pairs (i,j)
```

Goals with higher measurability get weighted more heavily in decision-making, ensuring we prioritize goals we can actually track and optimize effectively.

## Implementation Questions

### Technical
- Should measurability be calculated per goal globally, or per goal-pair for correlations?
   per measure per goal satisfaction
- How often to recalculate measurability scores?
- What's the minimum measurability threshold for including a goal in decisions?

### Data Collection
- How to systematically assess measurement confidence?
- Should we track measurability changes over time?
- How to handle goals with temporarily unavailable measurements?

### Integration
- How does low measurability affect correlation calculations?
- Should goals with very low measurability be excluded from Overgoal calculation?
- How to balance measurable but less important goals vs. important but hard-to-measure goals?

## Next Steps

1. **Implement basic measurability calculation** with static confidence/clarity values
2. **Test integration** with existing correlation system  
3. **Calculate combined Overgoal** = Measurability × Correlation
4. **Validate results** make sense for sample goal scenarios
5. **Design adaptive measurability** system for Phase 2

---

*This planning document will be updated as implementation progresses and questions are resolved.*