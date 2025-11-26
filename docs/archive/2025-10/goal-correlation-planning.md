# Goal Correlation Planning - MIC Implementation

## What I'm Trying to Do
STEP 1
I want to implement **Maximum Information Coefficient (MIC)** to measure how goals correlate with each other in the MAGUS system. This is for understanding goal relationships - when Energy is low, does Exploration tend to be low too? How predictable are goal patterns?

**Core idea**: If I know Goal A's satisfaction level, how much does that tell me about Goal B's satisfaction level?

## My Current Thinking

### Goal Relationships examples:
- **Energy ↔ Exploration**: +0.7 (need energy to explore)
- **Energy ↔ Affinity**: +0.5 (need energy to socialize)  
- **Exploration ↔ Affinity**: +0.3 (exploring can be social)


**Potential deciding factors for correlations between goal?**:
- Modulators? (as currently used in openpsi icog)
    1. arousal - emotional/motivational intensity
    2. positive-valence - emotional positivity
    3. selection-threshold - decision-making threshold
    4. securing-threshold - Controls environmental monitoring - how often to check for changes
    5. goal-directedness - focus on goals (proxy for dominance)
    6. resolution-level - problem-solving detail level
          Modulators create implicit goal correlations:
        - Goals that co-activate under similar modulator states become correlated
         - Example: High arousal + low securing-threshold might activate both Energy and Exploration together
         - This creates statistical dependencies between goals over time

- character? such as MBTI (eg extraversion will increase exploration + affinity correlation)

*To decide LATER*

## Two-Phase Approach

### Phase 1: Predefined Rules (Start Here)
- Use my expected correlation values as starting point
- MIC validates if reality matches expectations
- Clear, interpretable, immedi33ate results
- Good for testing and validation

### Phase 2: Self-Modifying (After Sufficient Data)
- Collect actual goal satisfaction data: `[(energy=0.2, exploration=0.1), ...]`
- MIC discovers patterns from real behavior
- System adapts correlation rules based on evidence
- More dynamic but requires sufficient observations

**Threshold for switching**: **50 observation points** per goal pair
- Rationale: Need enough data for statistical significance
- This means 50 decision cycles where we track Energy+Exploration satisfaction levels
- Can be adjusted based on testing

## Questions I Need to Resolve

### 1. Technical Questions
- How many bins for MIC calculation? (Start with 3: low/medium/high)
- What satisfaction value ranges define the bins?
  - Low: 0.0-0.33
  - Medium: 0.34-0.66  
  - High: 0.67-1.0
- How often do we recalculate MIC? (After every decision? Overgoal is meant to be Ongoing in the background) 
- use more complex formula?
(Correlation Score via MIC):**
```
CS(g) = (∏ᵢ MIC(g, gᵢ))^(1/n) / ∏ₐ MIC(g, aₐ)
```

Where MIC is the Maximal Information Coefficient:
```
MIC(X,Y) = max_{x,y<B(n)} I(X;Y) / log(min(x,y))
```

With B(n) = n^0.6 as the maximal grid dimension.

### 2. Context Factor Questions
- Which deciding factors should I implement first?


### 3. Data Collection Questions
- What format to store goal satisfaction history?
- Should we weight recent observations more heavily?

### 4. Integration Questions
- When MIC shows unexpected correlations, what should system do?
- How to balance predefined rules vs discovered patterns?
- Do we count correlations just between 2 goals, then continue with pairs, or use more complicated formula?
- how do we calculate all correlations together? simple average? geometic mean?4
11

## Implementation Plan

### Step 1: Basic MIC Implementation
- Start with 2 goals (Energy ↔ Exploration); then energy-affinity; then affinity-exploration
- Use predefined correlations
- Simple 3-bin discretization
- Both MeTTa and Python versions

### Step 2: then move to measurability score

### step 3: Overgoal calculation1


---

*This is a working document - will be updated as decisions are made and questions resolved*