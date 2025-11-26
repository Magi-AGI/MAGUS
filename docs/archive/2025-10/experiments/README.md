# Archived Experiment Files

These files contain experimental self-modification and dynamic goal adjustment code.

## Files Archived

### anna-demands-test.metta
**Purpose**: Test case for Anna agent's demand system

**Content**:
- Dynamic demand values (energy, affinity, exploration)
- Demand-driven goal weight updates
- Test scenario: Anna starts tired (low energy demand)

**Status**: Experimental - demonstrates goal weight modification based on agent state

### self-modifying-demo.metta
**Purpose**: Demonstration of self-modifying agent behavior

**Content**:
- Goal weights that change based on performance
- Feedback loop between results and priorities
- Example: If actions fail, increase weight of alternative goals

**Status**: Proof-of-concept for adaptive goal prioritization

### simple-self-modify.metta
**Purpose**: Simplified self-modification example

**Content**:
- Basic demand-driven goal updates
- Cleaner example for understanding the concept
- Minimal dependencies

**Status**: Teaching example

### working-self-modify.metta
**Purpose**: Working implementation of self-modifying goals

**Content**:
- `addDemand` function for dynamic demand updates
- `addGoalMetric` for goal performance tracking
- Fitness-based goal weight adjustment
- Example: Energy demand changes from 0.2 → 0.8

**Key Code**:
```metta
!(addDemand &demands energy 0.2)   ; Low energy need
; ... later ...
!(addDemand &demands energy 0.8)   ; High energy need after depletion
```

**Status**: Functional but not integrated into current milestone workflow

## Why Archived

**Archive Date**: October 2025

**Reason**: These experiments explore self-modification and adaptive goal weighting, which are **future work** beyond M4 scope.

**Current System**: Uses fixed goal weights in test scenarios:
```python
('goal', 'energy', 0.9, 0.8),      # Priority, Weight fixed
('goal', 'exploration', 0.6, 0.5),
('goal', 'affinity', 0.3, 0.2),
```

## Future Integration

When implementing adaptive goal systems (M5+), these experiments provide:
1. **Demand-driven weighting** - Goals prioritized by current demands
2. **Performance feedback** - Failed goals get deprioritized
3. **Dynamic adjustment** - Weights update during runtime

## If You Want to Use Them

These files still run:
```bash
metta self-modifying-demo.metta
```

But they're not integrated with:
- M2 measurability/correlation
- M3 scoring-v2 pipeline
- M4 scenario framework

**Related Concepts**:
- OpenPsi's demand-driven goal activation
- AIRIS's goal discovery mechanisms
- Adaptive utility functions

**Related Documents**:
- KNOWN-LIMITATIONS.md - Notes future adaptive goal work
- Milestone_3/integration/integration-airis.metta - AIRIS integration points
