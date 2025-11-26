# Urgency × Importance Integration Proposal

## Anna's Original Concept (Currently in Testing_scenario/)

**Formula**: `Priority = Urgency × Importance`
- **Urgency**: `1.0 - satisfaction` (how much the goal needs attention NOW)
- **Importance**: Fixed weight per goal (intrinsic significance)
- **Result**: Short-term prioritization based on current deficits

**Example** (from tests):
```
Energy Crisis scenario:
- Energy satisfaction: 0.1 → urgency: 0.9 → priority: 0.9 × 0.8 = 0.72
- Social satisfaction: 0.6 → urgency: 0.4 → priority: 0.4 × 0.7 = 0.28

Result: Focus on Energy (highest urgency × importance)
```

---

## Current M2/M3 System

**M2 - Goal Fitness Metrics**:
- **Measurability**: How well we can assess goal state (confidence × clarity)
- **Correlation**: How goals influence each other (MIC correlation)
- **Result**: Long-term strategic value of goals

**M3 - Integration**:
- **Metagoals**: Higher-order objectives (coherence, learning, efficiency)
- **Overgoal**: Goal set synergy via weighted correlations
- **Modulators**: Emotional/attentional state adjustments

---

## The Key Insight: Two Different Timescales

### Short-Term (Urgency × Importance)
**What it captures**: Immediate needs based on current state
- "I'm low on energy RIGHT NOW"
- "My social needs are critically unmet"
- Reactive, deficit-driven
- **Timescale**: Minutes to hours

### Long-Term (Measurability × Correlation)
**What it captures**: Strategic goal value over time
- "Energy is highly measurable and correlates with other goals"
- "This goal synergizes well with my active goal set"
- Proactive, synergy-driven
- **Timescale**: Hours to days

---

## Integration Approaches

### Option 1: Dual-Layer Priority System

**Layer 1 - Tactical (Urgency × Importance)**:
```
tactical_priority = (1.0 - satisfaction) × importance
```
- Answers: "What needs attention NOW?"
- Uses current satisfaction levels
- Reacts to deficits

**Layer 2 - Strategic (M2 × M3)**:
```
strategic_priority = measurability × correlation_weight × overgoal_bonus × modulators
```
- Answers: "What will serve me best long-term?"
- Uses goal fitness and synergy
- Plans for future states

**Combined Decision**:
```
final_priority = (α × tactical_priority) + (β × strategic_priority)
```
- α: weight for short-term urgency (default: 0.6)
- β: weight for long-term strategy (default: 0.4)
- Adjustable based on context/modulators

**Example**:
```
Energy goal:
- Tactical: 0.72 (low satisfaction, high importance)
- Strategic: 0.85 (high measurability, good correlations)
- Final: 0.6×0.72 + 0.4×0.85 = 0.432 + 0.34 = 0.772

Social goal:
- Tactical: 0.28 (moderate satisfaction, moderate importance)
- Strategic: 0.45 (lower measurability, fewer correlations)
- Final: 0.6×0.28 + 0.4×0.45 = 0.168 + 0.18 = 0.348
```

---

### Option 2: Modulated Urgency (Simpler Integration)

**Replace static importance with M2 measurability**:
```
priority = urgency × measurability × correlation_factor
```

Where:
- `urgency = 1.0 - satisfaction` (Anna's concept)
- `measurability` (from M2)
- `correlation_factor` (weighted average of correlations)

**Benefits**:
- Keeps urgency concept
- Uses M2 metrics for "importance"
- Single unified formula
- Importance becomes dynamic (based on goal fitness)

**Example**:
```
Energy:
- Urgency: 0.9 (low satisfaction)
- Measurability: 0.72
- Correlation factor: 0.7 (avg correlation with other goals)
- Priority: 0.9 × 0.72 × 0.7 = 0.453

Social:
- Urgency: 0.4 (moderate satisfaction)
- Measurability: 0.20
- Correlation factor: 0.4
- Priority: 0.4 × 0.20 × 0.4 = 0.032
```

---

### Option 3: Urgency as Meta-Modulator

**Treat urgency as a dynamic modulator in scoring-v2**:

```
base_score = considerations × discouragements
metagoal_adjusted = base_score + metagoal_bonuses
urgency_boost = (1.0 - satisfaction) × urgency_weight
final_score = metagoal_adjusted × modulators × (1.0 + urgency_boost)
```

**Benefits**:
- Non-invasive (adds to existing system)
- Urgency acts like arousal modulator
- Can be enabled/disabled per scenario
- Preserves all M2/M3 architecture

---

## Recommended Approach: **Option 1 (Dual-Layer)**

### Why:
1. **Preserves both concepts** - Urgency and measurability serve different purposes
2. **Configurable** - Can adjust α/β based on context
3. **Testable** - Can validate tactical vs strategic separately
4. **Aligns with literature** - Dual-process models (System 1/System 2, reactive/deliberative)

### Implementation:

**Add to Milestone_3 as `urgency.metta`**:
```metta
;; Urgency-based tactical prioritization (Anna's original concept)
;; Complements strategic M2/M3 metrics

;; Calculate urgency: how much a goal needs attention now
(: calculate-urgency (-> Number Number))
(= (calculate-urgency $satisfaction)
   (- 1.0 $satisfaction))

;; Tactical priority: urgency × importance
;; Importance can be static or derived from measurability
(: tactical-priority (-> Symbol Number Number Number))
(= (tactical-priority $goal-name $satisfaction $importance)
   (* (calculate-urgency $satisfaction) $importance))

;; Strategic priority: uses M2/M3 metrics
(: strategic-priority (-> Goal Context Number))
(= (strategic-priority $goal $context)
   ;; Calculated by existing M3 scoring-v2.metta
   (score-goal-fitness $goal $context))

;; Combined priority with configurable weights
(: combined-priority (-> Symbol Number Number Number Number Number))
(= (combined-priority $goal-name $satisfaction $importance $strategic-score $tactical-weight $strategic-weight)
   (let* (($tactical (tactical-priority $goal-name $satisfaction $importance))
          ($combined (+ (* $tactical-weight $tactical)
                       (* $strategic-weight $strategic-score))))
     $combined))

;; Default weighting: 60% tactical (short-term), 40% strategic (long-term)
(: default-tactical-weight (-> Number))
(= (default-tactical-weight) 0.6)

(: default-strategic-weight (-> Number))
(= (default-strategic-weight) 0.4)
```

**Add test to validate**:
```python
def test_urgency_importance_integration():
    """Test Anna's urgency × importance with M2/M3 strategic metrics"""

    # Test tactical priority (Anna's formula)
    # Energy: satisfaction=0.1, importance=0.8
    urgency = 1.0 - 0.1  # 0.9
    tactical = urgency * 0.8  # 0.72

    # Strategic priority (from M2/M3)
    strategic = 0.85  # High measurability + good correlations

    # Combined (60% tactical, 40% strategic)
    combined = 0.6 * tactical + 0.4 * strategic
    # = 0.6 * 0.72 + 0.4 * 0.85 = 0.432 + 0.34 = 0.772

    assert abs(combined - 0.772) < 0.01
```

---

## Migration Path

### Phase 1: Keep Testing_scenario/ as Reference
- Don't archive (user request)
- Move to `Milestone_2/urgency-importance/` (organized)
- Add README explaining concept and integration plan

### Phase 2: Integrate into M3
- Create `Milestone_3/core/urgency.metta`
- Add tactical/strategic/combined priority functions
- Add tests to M4 pipeline

### Phase 3: Documentation
- Update MILESTONE-3-SUMMARY.md
- Document dual-layer decision model
- Reference Anna's original concept
- Show how it complements measurability/correlation

---

## Example Use Cases

### Crisis Response (High Tactical Weight)
```
Scenario: Energy critically low (0.1)
Weights: tactical=0.8, strategic=0.2
Result: Prioritize energy despite lower long-term strategic value
```

### Long-Term Planning (High Strategic Weight)
```
Scenario: All goals moderately satisfied (0.5-0.7)
Weights: tactical=0.2, strategic=0.8
Result: Prioritize goals with best measurability/correlation
```

### Balanced Decision-Making (Default)
```
Scenario: Mixed satisfaction levels
Weights: tactical=0.6, strategic=0.4
Result: Balance immediate needs with long-term value
```

---

## Conclusion

Anna's **urgency × importance** formula captures a **fundamentally different** dimension than M2/M3:
- **Urgency**: Reactive, deficit-driven, short-term
- **Measurability/Correlation**: Proactive, synergy-driven, long-term

**Recommendation**:
1. ✅ Keep Testing_scenario/ (don't archive)
2. ✅ Move to organized location: `Milestone_2/urgency-importance/`
3. ✅ Integrate into M3 as dual-layer priority system
4. ✅ Add tests for combined tactical/strategic prioritization

This preserves Anna's valuable work while integrating it with the current architecture.
