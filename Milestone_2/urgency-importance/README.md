# Urgency × Importance: Anna's Original Concept

## Overview

This directory contains Anna's original goal prioritization system using the formula:

```
Priority = Urgency × Importance
```

Where:
- **Urgency** = `1.0 - satisfaction` (how much a goal needs attention NOW)
- **Importance** = Fixed weight per goal (intrinsic significance)

## Files

1. **goal_ranking_test.py** - Python implementation with test scenarios
2. **goal-ranking-test.metta** - MeTTa implementation

## Concept

Anna's formula captures **short-term, reactive prioritization** based on current deficits:

- **Timescale**: Minutes to hours
- **Approach**: Reactive, deficit-driven
- **Question**: "What needs attention RIGHT NOW?"

### Example from Tests

```python
Energy Crisis Scenario:
- Energy satisfaction: 0.1 → urgency: 0.9 → priority: 0.9 × 0.8 = 0.72
- Social satisfaction: 0.6 → urgency: 0.4 → priority: 0.4 × 0.7 = 0.28

Result: Focus on Energy (highest urgency × importance)
```

## Relationship to M2 Metrics

This concept is **complementary** to M2's measurability/correlation metrics, not competing:

### Urgency × Importance (Short-Term)
- Reactive to current state
- Deficit-driven
- Timescale: Minutes to hours
- "I'm low on energy RIGHT NOW"

### Measurability × Correlation (Long-Term)
- Proactive strategic planning
- Synergy-driven
- Timescale: Hours to days
- "Energy synergizes well with my goal set"

## Integration Plan

See **URGENCY-IMPORTANCE-INTEGRATION-PROPOSAL.md** in the root directory for:

1. **Option 1: Dual-Layer Priority System** (Recommended)
   - Separate tactical and strategic priorities
   - Combine with configurable weights: `α × tactical + β × strategic`
   - Default: 60% tactical, 40% strategic

2. **Option 2: Modulated Urgency**
   - Replace static importance with M2 measurability
   - Single unified formula

3. **Option 3: Urgency as Meta-Modulator**
   - Treat urgency like arousal/pleasure modulators
   - Non-invasive addition to existing system

## Test Scenarios

The Python implementation includes four test scenarios:

1. **Energy Crisis**: Energy satisfaction = 0.1 (highest priority)
2. **Social Isolation**: Social satisfaction = 0.2 (medium priority)
3. **Knowledge Gap**: Cognitive satisfaction = 0.1 (medium-low priority due to lower importance)
4. **Balanced State**: All satisfaction = 0.5 (all goals equal priority)

## Status

- **Date Created**: September 1, 2025 (Anna's early exploration)
- **Current Status**: Preserved for future integration
- **Integration Target**: Milestone 3 (dual-layer priority system)
- **Test Coverage**: Not currently in official test suite (to be added during integration)

## Why Preserved

Originally identified during redundancy audit as potentially obsolete. Upon analysis, recognized as capturing a fundamentally different dimension than M2 metrics:

- M2 answers: "Which goals are most valuable strategically?"
- Urgency×Importance answers: "Which goals need immediate attention?"

Both questions are valid and important for a complete goal-based system.

## Future Work

When integrating into Milestone 3:

1. Create `Milestone_3/core/urgency.metta` with dual-layer functions
2. Add tests for tactical + strategic priority combination
3. Implement configurable α/β weighting
4. Document use cases for different weight configurations
5. Add to official test suite (currently 25/25 → 27/27+)

## References

- **Integration Proposal**: `URGENCY-IMPORTANCE-INTEGRATION-PROPOSAL.md`
- **M2 Audit**: `MILESTONE-2-REDUNDANCY-AUDIT.md`
- **Complete Summary**: `MILESTONE-REDUNDANCY-SUMMARY.md`

---

**Note**: This concept demonstrates the value of preserving early explorations even when they don't immediately fit the current architecture. Different perspectives on prioritization can coexist and complement each other.
