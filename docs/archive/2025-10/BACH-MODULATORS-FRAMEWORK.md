# Bach Modulators Framework in MAGUS

**Version**: 1.0
**Date**: 2025-10-08
**Status**: Active Implementation

---

## Overview

MAGUS uses **Bach's 6-modulator framework** for emotional and attentional regulation. This framework combines:

1. **PAD (Pleasure-Arousal-Dominance)** - Emotional dimensions
2. **Attentional Modulators** - Cognitive focus dimensions

This replaced the earlier Psi-Theory framework to provide more comprehensive cognitive and emotional modeling.

---

## The 6 Modulators

### PAD Modulators (Emotional)

#### 1. **Arousal** (Activation Level)
- **Range**: 0.0 (calm) to 1.0 (excited)
- **Effect on Score**: 0.8 to 1.2
- **Formula**: `effect = 0.8 + (0.4 × arousal)`
- **Behavior**:
  - High arousal (0.8-1.0): Promotes exploration, action-oriented goals
  - Low arousal (0.0-0.2): Promotes rest, conservative goals

#### 2. **Pleasure** (Valence)
- **Range**: 0.0 (negative) to 1.0 (positive)
- **Effect on Score**: 0.9 to 1.1
- **Formula**: `effect = 0.9 + (0.2 × pleasure)`
- **Behavior**:
  - High pleasure: Slight boost to all goals
  - Low pleasure: Slight dampening of goals

#### 3. **Dominance** (Control)
- **Range**: 0.0 (submissive) to 1.0 (dominant)
- **Effect on Score**: 0.85 to 1.15
- **Formula**: `effect = 0.85 + (0.3 × dominance)`
- **Behavior**:
  - High dominance: Promotes assertive, control-seeking goals
  - Low dominance: Promotes cooperative, adaptive goals

### Attentional Modulators (Cognitive)

#### 4. **Focus** (Concentration)
- **Range**: 0.0 (diffuse) to 1.0 (concentrated)
- **Effect on Score**: 0.7 to 1.3
- **Formula**: `effect = 0.7 + (0.6 × focus)`
- **Behavior**:
  - High focus: Strong boost to primary goals
  - Low focus: Allows exploration of multiple goals

#### 5. **Resolution** (Temporal Detail)
- **Range**: 0.0 (coarse) to 1.0 (fine)
- **Effect on Score**: 0.75 to 1.25
- **Formula**: `effect = 0.75 + (0.5 × resolution)`
- **Behavior**:
  - High resolution: Detailed, short-term goals favored
  - Low resolution: Abstract, long-term goals favored

#### 6. **Exteroception** (External Awareness)
- **Range**: 0.0 (internal) to 1.0 (external)
- **Effect on Score**: 0.8 to 1.2
- **Formula**: `effect = 0.8 + (0.4 × exteroception)`
- **Behavior**:
  - High exteroception: Environment-oriented goals boosted
  - Low exteroception: Introspective goals boosted

---

## Implementation

### MeTTa Type Definition

```metta
(: Modulator Type)
(: modulator (-> Symbol Number Modulator))
;; modulator name value
```

### Knowledge Base Approach

Modulators are stored in a knowledge base to avoid nondeterminism:

```metta
!(bind! &modulator-kb (new-space))

;; Store modulator parameters: (modulator-params name base multiplier)
!(add-atom &modulator-kb (modulator-params arousal 0.8 0.4))
!(add-atom &modulator-kb (modulator-params pleasure 0.9 0.2))
!(add-atom &modulator-kb (modulator-params dominance 0.85 0.3))
!(add-atom &modulator-kb (modulator-params focus 0.7 0.6))
!(add-atom &modulator-kb (modulator-params resolution 0.75 0.5))
!(add-atom &modulator-kb (modulator-params exteroception 0.8 0.4))
```

### Modulator Effect Calculation

```metta
(: modulator-effect (-> Symbol Number Number))
(= (modulator-effect $name $value)
   (let $params (match &modulator-kb (modulator-params $name $base $mult) ($base $mult))
     (if (== $params ())
         1.0  ;; Default for unknown modulators
         (let ($base $mult) $params
           (+ $base (* $mult $value))))))
```

### Integration into Scoring

```metta
;; Apply modulators to base score
(: apply-modulators (-> Number (List Modulator) Number))
(= (apply-modulators $score Nil) $score)
(= (apply-modulators $score (Cons (modulator $name $value) $tail))
   (let (($modulated (* $score (modulator-effect $name $value))))
     (apply-modulators $modulated $tail)))
```

---

## Usage Examples

### Example 1: High-Arousal, High-Focus State

```metta
Context:
  Arousal: 0.9     → effect: 0.8 + (0.4 × 0.9) = 1.16
  Pleasure: 0.6    → effect: 0.9 + (0.2 × 0.6) = 1.02
  Dominance: 0.7   → effect: 0.85 + (0.3 × 0.7) = 1.06
  Focus: 0.9       → effect: 0.7 + (0.6 × 0.9) = 1.24
  Resolution: 0.8  → effect: 0.75 + (0.5 × 0.8) = 1.15
  Exteroception: 0.7 → effect: 0.8 + (0.4 × 0.7) = 1.08

Combined effect: 1.16 × 1.02 × 1.06 × 1.24 × 1.15 × 1.08 ≈ 1.95

Result: Goals receive nearly 2× boost - favors exploration and action
```

### Example 2: Low-Arousal, Low-Focus State

```metta
Context:
  Arousal: 0.2     → effect: 0.8 + (0.4 × 0.2) = 0.88
  Pleasure: 0.3    → effect: 0.9 + (0.2 × 0.3) = 0.96
  Dominance: 0.4   → effect: 0.85 + (0.3 × 0.4) = 0.97
  Focus: 0.4       → effect: 0.7 + (0.6 × 0.4) = 0.94
  Resolution: 0.3  → effect: 0.75 + (0.5 × 0.3) = 0.90
  Exteroception: 0.5 → effect: 0.8 + (0.4 × 0.5) = 1.00

Combined effect: 0.88 × 0.96 × 0.97 × 0.94 × 0.90 × 1.00 ≈ 0.68

Result: Goals receive ~68% of base score - favors rest and recovery
```

### Example 3: Balanced State

```metta
Context:
  All modulators: 0.5

Effects:
  Arousal: 1.0
  Pleasure: 1.0
  Dominance: 1.0
  Focus: 1.0
  Resolution: 1.0
  Exteroception: 1.0

Combined effect: 1.0 (neutral - no modification)
```

---

## Comparison with Psi-Theory

### Old Framework (Psi-Theory)
- **Single modulator**: Energy level
- **Simple effect**: Direct multiplication
- **Limited expressiveness**: Only activation level

### New Framework (Bach)
- **6 modulators**: PAD (3) + Attentional (3)
- **Rich expressiveness**: Emotional and cognitive dimensions
- **Complex interactions**: Combined effects create nuanced behavior
- **Theoretically grounded**: Based on Bach's MicroPsi architecture

---

## Migration Notes

### Deprecated Concepts

❌ **Energy Level** - Replaced by **Arousal** (similar but PAD-theoretically grounded)
❌ **Psi-Theory modulators** - Replaced by **Bach's 6-modulator framework**

### Updated Test Cases

Test cases using "Energy level: X" should be updated to use all 6 modulators:

**Before**:
```metta
Context:
  Energy level: 0.9
```

**After**:
```metta
Context:
  Arousal: 0.9
  Pleasure: 0.8
  Dominance: 0.7
  Focus: 0.9
  Resolution: 0.8
  Exteroception: 0.7
```

---

## Validation

### E2E Test Verification

The `test-anna-e2e-progression.py` test validates all 6 modulators:

```python
modulators = [
    ('arousal', 0.8, '0.8 to 1.2'),
    ('pleasure', 0.6, '0.9 to 1.1'),
    ('dominance', 0.7, '0.85 to 1.15'),
    ('focus', 0.9, '0.7 to 1.3'),
    ('resolution', 0.8, '0.75 to 1.25'),
    ('exteroception', 0.7, '0.8 to 1.2')
]

# All modulators verified to produce correct effects
```

### Test Results

```
✓ arousal(0.8): 1.120 [range: 0.8 to 1.2]
✓ pleasure(0.6): 1.020 [range: 0.9 to 1.1]
✓ dominance(0.7): 1.060 [range: 0.85 to 1.15]
✓ focus(0.9): 1.240 [range: 0.7 to 1.3]
✓ resolution(0.8): 1.150 [range: 0.75 to 1.25]
✓ exteroception(0.7): 1.080 [range: 0.8 to 1.2]

SUCCESS: All 6 modulators implemented and functional
```

---

## References

- **Bach, J.** (2009). *Principles of Synthetic Intelligence: Psi and MicroPsi*
- **Russell, J. A.** (1980). *A circumplex model of affect* (PAD model origin)
- **MAGUS Implementation**: `Milestone_3/core/scoring-v2.metta` lines 57-81

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-10-08 | Initial documentation of Bach framework implementation |

---

**Status**: ✅ Fully Implemented and Tested
