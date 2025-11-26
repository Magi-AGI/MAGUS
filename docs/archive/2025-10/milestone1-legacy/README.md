# Archived Milestone 1 Legacy Files

These files represent the original MAGUS M1 implementation, now superseded by M2/M3/M4.

## Files Archived

### magus.metta
**Original Purpose**: Milestone 1 decision-making system

**Key Features**:
- Geometric mean scoring
- Considerations and discouragements
- Action selection (Talk, Rest, Explore)
- Epsilon-based comparison

**Why Archived**: M1 was a proof-of-concept. The system now uses:
- M2: Goal fitness metrics (measurability, correlations)
- M3: Metagoals, anti-goals, overgoal, Bach modulators
- M4: Ethical scenarios and validation

**Historical Significance**: This was the foundational implementation that proved the utility function approach worked.

### notes.metta
**Original Purpose**: Development notes and experimental code during M1

**Content**:
- Commented-out test expressions
- Function prototypes
- Design notes

**Why Archived**: Superseded by structured documentation (PROJECT-OVERVIEW.md, milestone summaries)

## Archive Date

October 2025

## Evolution Path

```
M1 (magus.metta) → M2 (measurability + correlation) → M3 (metagoals + antigoals + scoring-v2) → M4 (scenarios + validation)
```

## If You Need Historical Reference

These files document the original design:

**M1 Formula**:
```
decision_score = gmean(considerations) × product(discouragements)
```

**M3 Formula** (current):
```
final_score = base_score × metagoal_bonuses × antigoal_penalties × modulator_adjustments
```

**Related Documents**:
- `docs/archive/2025-10/prototypes/` - Early M2 prototypes
- `PROJECT-OVERVIEW.md` - Current architecture
- `MILESTONE-2-SUMMARY.md` - M2 design and formulas
