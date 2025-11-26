# MAGUS Prototypes Archive

**Historical prototype implementations - October 2025**

These files represent early experimental designs that were superseded by the current M2/M3/M4 implementation.

---

## Files

### Action Evaluation Prototype V1

**Files**:
- `magus-action-evaluation-prototype-v1.metta`
- `magus-action-evaluation-prototype-v1.py`

**Purpose**: Early action evaluation system exploring:
- Dynamic goal weight calculation
- Action scoring with considerations/discouragements
- Integration with goal weighting system

**Status**: Superseded by M3 `scoring-v2.metta` which provides:
- Integrated metagoal/anti-goal/overgoal system
- Bach's 6-modulator framework
- M2 data integration

**Why Archived**:
- Not imported by current codebase
- Functionality absorbed into M3 scoring pipeline
- Preserved for historical reference

---

### Goal Weighting V1

**Files**:
- `magus-goal-weighting-v1.metta`
- `magus-goal-weighting-v1.py`

**Purpose**: Original goal weighting approach:
- Static weight assignment
- Basic priority calculations
- Weight lookup functions

**Status**: Superseded by M2/M3 integration which provides:
- Dynamic measurability-based evaluation
- Correlation-weighted scoring
- Metagoal adjustments

**Why Archived**:
- Not imported by current codebase
- Replaced by M2 measurability framework
- Preserved for design evolution reference

---

## Current Implementation

**Active Code** (replaces prototypes):

**Goal Evaluation**:
- `Milestone_2/goal-fitness-metrics/measurability/` - Measurability framework
- `Milestone_2/goal-fitness-metrics/correlation/` - MIC correlations

**Action/Goal Scoring**:
- `Milestone_3/core/scoring-v2.metta` - Integrated scoring pipeline
- `Milestone_3/core/metagoals.metta` - Strategic adjustments
- `Milestone_3/core/antigoals.metta` - Constraints
- `Milestone_3/core/overgoal.metta` - Goal set coherence

---

## Design Evolution

**Prototype V1 → Current System**:

1. **Static Weights** → **Dynamic Measurability**
   - V1: Hard-coded goal weights
   - Current: Confidence × Clarity calculation

2. **Simple Scoring** → **Multi-layer Pipeline**
   - V1: Base score only
   - Current: Base + Metagoal + Overgoal + Modulators + Anti-goals

3. **Isolated Goals** → **Correlated System**
   - V1: Independent goal evaluation
   - Current: MIC correlations, weighted by measurability

4. **Fixed Context** → **Rich Scoring Context**
   - V1: Minimal context
   - Current: Goals, modulators, resources, history

---

## Learning Points

**What Worked**:
- Consideration/discouragement pattern (kept in scoring-v2)
- Python/MeTTa parallel implementation (expanded in M2/M3)
- Modular function design (influenced current architecture)

**What Changed**:
- Added data-driven metrics (M2)
- Integrated higher-order objectives (M3 metagoals)
- Added ethical constraints (M4 scenarios)
- Connected all layers (M2→M3→M4)

---

## References

**Knowledge Repository**:
- Core Framework Design Document - Full architecture evolution
- MAGUS Best Practices - Lessons from prototypes
- MeTTa Lessons Learned - Implementation insights

**Current Documentation**:
- PROJECT-OVERVIEW.md - Current system overview
- MILESTONE-2-SUMMARY.md - Measurability framework
- MILESTONE-3-SUMMARY.md - Scoring pipeline

---

**Archived**: October 2025
**Reason**: Superseded by M2/M3 implementation
**Status**: Preserved for historical reference
