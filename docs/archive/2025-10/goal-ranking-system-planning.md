# Goal Ranking System - Dynamic Prioritization Planning

## Overview

This document outlines the goal ranking system for MAGUS virtual agents, designed to dynamically prioritize goals based on current satisfaction levels and importance weights. The system produces a ranked list of goals that adapts to changing conditions.
The agent's activity is essentially an attempt to maintain homeostasis for these goals. 

## Goal Structure

### Main Goals (3 Categories)

#### 1. Energy Goal
**Subgoals:**
- **Rest**: Recovery, sleep, relaxation
- **Eat**: Nutrition, resource consumption
- **Shelter**: Safety, environmental protection

#### 2. Cognitive Goal  
**Subgoals:**
- **Discover**: Exploring new areas, finding new objects/locations
- **Learn**: Skill acquisition, knowledge building
- **Certainty**: Reducing uncertainty, confirming predictions

#### 3. Social Goal
**Subgoals:**
- **Talk**: Communication, conversation with other agents
- **Help**: Assisting others, cooperative behavior
- **Legitimacy**: Gaining social status, respect, acceptance

## Satisfaction Acquisition

### Internal State Tracking

Each goal maintains a satisfaction level (0.0 to 1.0) through internal state monitoring:

#### Energy Satisfaction
- **Rest**: Tracked via sleep cycles, fatigue levels
- **Eat**: Monitored through hunger/nutrition state
- **Shelter**: Assessed via safety/environmental comfort

#### Cognitive Satisfaction  
- **Discover**: Measured by exploration progress, new discoveries
- **Learn**: Tracked through skill progression, knowledge gains
- **Certainty**: Evaluated via prediction accuracy, information completeness

#### Social Satisfaction
- **Talk**: Monitored through recent social interactions
- **Help**: Tracked via cooperative actions performed
- **Legitimacy**: Assessed through social recognition received

**Note**: For prototype implementation, satisfaction values will be simulated/assigned manually to test the ranking system.
??? does each goal value consist of its subgoals product values? Basically, how do we calculate each?
??? do we need to have thresholds for each?


## Calculation System

### Core Formula
```
Goal Priority = Urgency × Importance
```

### Urgency Calculation
```
Urgency = 1.0 - current_satisfaction
```
- Higher urgency when satisfaction is low
- Lower urgency when satisfaction is high
- Inversely proportional to satisfaction level

### Importance Values (Fixed - Prototype, but otherwise determined by the Overgoal)
```
Energy Importance: 0.8     (placeholder - high priority for survival)
Cognitive Importance: 0.6  (placeholder - moderate priority for growth)  
Social Importance: 0.7     (placeholder - high priority for cooperation)
```
**Note**: These are placeholder values for testing. Future versions will use dynamic importance calculation.

### Example Calculation
```
Energy: satisfaction = 0.3
- Urgency = 1.0 - 0.3 = 0.7
- Priority = 0.7 × 0.8 = 0.56

Cognitive: satisfaction = 0.8  
- Urgency = 1.0 - 0.8 = 0.2
- Priority = 0.2 × 0.6 = 0.12

Social: satisfaction = 0.5
- Urgency = 1.0 - 0.5 = 0.5  
- Priority = 0.5 × 0.7 = 0.35
```

**Result**: Ranked Goal List = [Energy (0.56), Social (0.35), Cognitive (0.12)]

## Test Scenarios

### Scenario 1: Energy Crisis
**Setup**:
- Energy satisfaction: 0.1 (very low)
- Cognitive satisfaction: 0.7 (high)
- Social satisfaction: 0.6 (moderate)

**Expected Result**: Energy becomes primary goal
- Energy Priority: (1.0 - 0.1) × 0.8 = 0.72
- Social Priority: (1.0 - 0.6) × 0.7 = 0.28  
- Cognitive Priority: (1.0 - 0.7) × 0.6 = 0.18
- **Ranking**: [Energy, Social, Cognitive]

### Scenario 2: Social Isolation
**Setup**:
- Energy satisfaction: 0.8 (high)
- Cognitive satisfaction: 0.7 (high)
- Social satisfaction: 0.2 (very low)

**Expected Result**: Social becomes primary goal
- Social Priority: (1.0 - 0.2) × 0.7 = 0.56
- Energy Priority: (1.0 - 0.8) × 0.8 = 0.16
- Cognitive Priority: (1.0 - 0.7) × 0.6 = 0.18
- **Ranking**: [Social, Cognitive, Energy]

### Scenario 3: Knowledge Gap
**Setup**:
- Energy satisfaction: 0.7 (moderate-high)
- Cognitive satisfaction: 0.1 (very low)
- Social satisfaction: 0.7 (moderate-high)

**Expected Result**: Cognitive becomes primary goal
- Cognitive Priority: (1.0 - 0.1) × 0.6 = 0.54
- Social Priority: (1.0 - 0.7) × 0.7 = 0.21
- Energy Priority: (1.0 - 0.7) × 0.8 = 0.24
- **Ranking**: [Cognitive, Energy, Social]

### Scenario 4: Balanced State
**Setup**:
- Energy satisfaction: 0.5 (moderate)
- Cognitive satisfaction: 0.5 (moderate)
- Social satisfaction: 0.5 (moderate)

**Expected Result**: Goals ranked by importance values
- Energy Priority: 0.5 × 0.8 = 0.40
- Social Priority: 0.5 × 0.7 = 0.35
- Cognitive Priority: 0.5 × 0.6 = 0.30
- **Ranking**: [Energy, Social, Cognitive]

## Success Criteria

### Dynamic Adaptation Evidence
-  **Goal priorities shift** based on satisfaction changes
-  **Different scenarios produce different primary goals**
-  **Urgency calculation responds inversely** to satisfaction levels
-  **Ranking system produces consistent, predictable results**

### System Behavior Validation
-  **Low satisfaction goals rise to top priority**
-  **High satisfaction goals drop in priority**
-  **Importance values influence final ranking**
-  **System handles extreme satisfaction values gracefully**

### Implementation Readiness
-  **Clear mathematical formulation**
- **Testable scenarios defined**
-  **Integration points identified for subgoal selection**
-  **Foundation prepared for dynamic importance calculation**

---

**Next Steps**: 
1. Implement ranking calculation in MeTTa
2. Create test harness for scenarios  
3. Validate dynamic goal switching
4. Integrate with subgoal selection system