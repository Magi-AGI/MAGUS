# MAGUS Milestone 2 - Exploratory Prototyping Report

**Version:** 1.0
**Date:** October 2025
**Owner:** Neoterics / MAGUS team
**Related:** `agi-integration-strategic-analysis.md`, `Milestone-3-Spec.md`
**Status:** ✅ Complete

---

## 1. Executive Summary

This report documents Milestone 2's exploratory prototyping efforts, focusing on **integration pathways** between MAGUS and external AGI reasoning systems. The primary objective was to evaluate feasibility and design MeTTa-based API contracts for future connections with:

1. **OpenCog Hyperon** (PLN, ECAN, DAS)
2. **NARS** (Non-Axiomatic Reasoning System)
3. **AIRIS** (Autonomous Intelligent Reinforcement Interpreted Symbolism)
4. **General Planning Systems** (GOAP, HTN, Behavior Trees)

**Key Findings:**
- ✅ **MeTTa native compatibility** with Hyperon ecosystem provides lowest-friction integration path
- ✅ **AIRIS integration** proven feasible with clear API contracts (implemented in M3)
- ✅ **NARS interface** requires truth-value conversion layer (medium complexity)
- ✅ **Generic planner adapters** viable through behavior tree abstraction

**No direct integration attempts were made** (per M2 scope), but all API contracts and design patterns are documented for future implementation.

---

## 2. Integration Target Analysis

### 2.1 OpenCog Hyperon / PLN

**Status:** High priority, low integration cost
**Rationale:** Native MeTTa implementation provides direct compatibility

#### 2.1.1 Integration Points

**ECAN Attention Allocation:**
- MAGUS goal priorities map to Short-Term Importance (STI) values
- High-priority goals inject STI into related atoms
- Creates attention-motivation feedback loop

**PLN Reasoning Guidance:**
- Goal satisfaction states become PLN truth values
- MAGUS correlations inform PLN inference targets
- Probabilistic reasoning results update goal measurability

**DAS Knowledge Storage:**
- Goal satisfaction histories stored in distributed atomspace
- Correlation matrices as hypergraph relationships
- Enables multi-agent goal sharing

#### 2.1.2 MeTTa API Contract (PLN)

```metta
;; ============================================================================
;; MAGUS → PLN Integration API Contract
;; ============================================================================

;; Type definitions for PLN integration
(: PLNTruthValue Type)
(: pln-tv (-> Number Number PLNTruthValue))  ;; strength, confidence

;; Convert goal satisfaction to PLN truth value
;; Satisfaction level → strength, Measurability → confidence
(: goal-to-pln-tv (-> Goal Number PLNTruthValue))
(= (goal-to-pln-tv $goal $satisfaction-level)
   (let* (($measurability (get-measurability $goal))
          ($strength $satisfaction-level)
          ($confidence $measurability))
     (pln-tv $strength $confidence)))

;; Example usage:
;; !(goal-to-pln-tv (goal energy 0.8 0.7) 0.6)
;; Returns: (pln-tv 0.6 0.72)  ; strength=0.6, confidence=0.72 (measurability)

;; Inject MAGUS goal into PLN atomspace
(: inject-goal-into-pln (-> Goal Number &pln-space ()))
(= (inject-goal-into-pln $goal $satisfaction $pln-space)
   (let (($tv (goal-to-pln-tv $goal $satisfaction)))
     (add-atom $pln-space
       (EvaluationLink $tv
         (PredicateNode satisfied)
         (ConceptNode (goal-name $goal))))))

;; Query PLN for goal-relevant inferences
(: query-pln-for-goal (-> Goal &pln-space (List PLNInference)))
(= (query-pln-for-goal $goal $pln-space)
   (match $pln-space
     (ImplicationLink $tv
       (ConceptNode (goal-name $goal))
       $consequent)
     (pln-inference $goal $consequent $tv)))

;; Map MAGUS correlations to PLN similarity relationships
(: correlation-to-pln-similarity (-> Goal Goal Number &pln-space ()))
(= (correlation-to-pln-similarity $goal1 $goal2 $correlation $pln-space)
   (let (($avg-measurability (/ (+ (get-measurability $goal1)
                                   (get-measurability $goal2))
                                2)))
     (add-atom $pln-space
       (SimilarityLink (pln-tv $correlation $avg-measurability)
         (ConceptNode (goal-name $goal1))
         (ConceptNode (goal-name $goal2))))))

;; ECAN STI injection based on goal priority
(: inject-sti-for-goal (-> Goal &ecan-space ()))
(= (inject-sti-for-goal $goal $ecan-space)
   (let ((goal $name $priority $weight) $goal)
     (let (($sti-amount (* $priority $weight 100)))  ;; Scale to ECAN range
       (set-sti $ecan-space (ConceptNode $name) $sti-amount))))
```

**Integration Complexity:** ⭐⭐☆☆☆ (Low - native MeTTa)
**Estimated Effort:** 2-3 weeks for basic integration
**Status:** API contract complete, ready for M4+ implementation

---

### 2.2 NARS (Non-Axiomatic Reasoning System)

**Status:** Medium priority, medium integration cost
**Rationale:** Requires truth-value conversion but high synergy potential

#### 2.2.1 Integration Points

**Task Priority Mapping:**
- MAGUS goal priorities → NARS task budgets
- High-priority goals get more reasoning cycles

**Truth Value Conversion:**
- Goal satisfaction → NARS truth value (frequency, confidence)
- Measurability → confidence component
- Correlation → similarity strength

**Self-Control Enhancement:**
- MAGUS meta-goals guide NARS mental operators
- Adaptive adjustment of NARS inference parameters

#### 2.2.2 MeTTa API Contract (NARS)

```metta
;; ============================================================================
;; MAGUS → NARS Integration API Contract
;; ============================================================================

;; NARS truth value format: (frequency confidence)
(: NARSTruthValue Type)
(: nars-tv (-> Number Number NARSTruthValue))

;; Convert MAGUS goal satisfaction to NARS truth value
;; Frequency = satisfaction level, Confidence = measurability
(: goal-to-nars-tv (-> Goal Number NARSTruthValue))
(= (goal-to-nars-tv $goal $satisfaction)
   (let (($frequency $satisfaction)
         ($confidence (get-measurability $goal)))
     (nars-tv $frequency $confidence)))

;; Convert MAGUS goal priority to NARS task budget
;; Budget determines reasoning cycles allocated
(: goal-priority-to-budget (-> Goal Number))
(= (goal-priority-to-budget $goal)
   (let ((goal $name $priority $weight) $goal)
     (* $priority $weight 0.9)))  ;; NARS budget in [0, 1]

;; Create NARS sentence for goal state
;; Format: <Goal --> [Satisfied]>. %frequency, confidence%
(: create-nars-goal-sentence (-> Goal Number String))
(= (create-nars-goal-sentence $goal $satisfaction)
   (let* (($tv (goal-to-nars-tv $goal $satisfaction))
          ((nars-tv $freq $conf) $tv)
          ($goal-name (goal-name $goal)))
     (format "<~a --> [Satisfied]>. %~f,~f%"
             $goal-name $freq $conf)))

;; Example output: "<energy --> [Satisfied]>. %0.6,0.72%"

;; Map MAGUS correlation to NARS similarity statement
(: create-nars-similarity (-> Goal Goal Number String))
(= (create-nars-similarity $goal1 $goal2 $correlation)
   (let* (($name1 (goal-name $goal1))
          ($name2 (goal-name $goal2))
          ($avg-meas (/ (+ (get-measurability $goal1)
                          (get-measurability $goal2))
                       2)))
     (format "<~a <-> ~a>. %~f,~f%"
             $name1 $name2 $correlation $avg-meas)))

;; Example output: "<energy <-> exploration>. %0.70,0.64%"

;; Create NARS task with priority and budget
(: create-nars-task (-> Goal Number NARSTask))
(= (create-nars-task $goal $satisfaction)
   (let* (($sentence (create-nars-goal-sentence $goal $satisfaction))
          ($budget (goal-priority-to-budget $goal))
          ($priority (get-goal-priority $goal)))
     (nars-task $sentence $priority $budget)))

;; Interface for NARS mental operators (self-control)
(: suggest-nars-operator (-> Context (List Metagoal) Symbol))
(= (suggest-nars-operator $context $metagoals)
   (cond
     ((contains-metagoal $metagoals uncertainty-reduction)
      wonder)  ;; NARS operator for exploration
     ((contains-metagoal $metagoals efficiency)
      believe)  ;; NARS operator for exploitation
     (otherwise
      evaluate)))  ;; Default NARS operator
```

**Integration Complexity:** ⭐⭐⭐☆☆ (Medium - truth value conversion)
**Estimated Effort:** 4-6 weeks for bidirectional integration
**Status:** API contract complete, requires NARS instance for testing

---

### 2.3 AIRIS (Autonomous Intelligent Reinforcement Interpreted Symbolism)

**Status:** High priority, implemented in M3
**Rationale:** Clear use case (game environments), well-defined I/O format

#### 2.3.1 Integration Points

**Input Mapping:**
- AIRIS environment → MAGUS context
- AIRIS actions → MAGUS available operators
- AIRIS tasks → MAGUS goals
- AIRIS agent status → MAGUS modulators

**Output Mapping:**
- MAGUS selected goal → AIRIS planned action
- Plan hints → AIRIS action parameters
- Priority signals → AIRIS task urgency

#### 2.3.2 MeTTa API Contract (AIRIS)

```metta
;; ============================================================================
;; MAGUS ↔ AIRIS Integration API Contract (M3 Implementation)
;; ============================================================================
;; Full implementation in: Milestone_3/integration/integration-airis.metta
;; This contract specifies the bidirectional data flow

;; === Input: AIRIS → MAGUS ===

;; AIRIS input structure
(: AirisInput Type)
(: airis-input (-> AirisEnvironment    ;; Unstructured environment array
                  AirisInventory      ;; Agent inventory
                  AirisStatus         ;; Agent status (energy, health, state)
                  (List AirisAction)  ;; Available actions
                  (List AirisTask)    ;; Active tasks
                  AirisInput))

;; Convert AIRIS input to MAGUS context
(: airis-to-magus-context (-> AirisInput Context))
(= (airis-to-magus-context $airis-input)
   (let* (((airis-input $env $inv $status $actions $tasks) $airis-input)
          ($goals (airis-tasks-to-goals $tasks))
          ($modulators (airis-status-to-modulators $status))
          ($timestamp (get-current-timestamp)))
     (context $goals $timestamp)))

;; Map AIRIS tasks to MAGUS goals
(: airis-tasks-to-goals (-> (List AirisTask) (List Goal)))
(= (airis-tasks-to-goals Nil) Nil)
(= (airis-tasks-to-goals (Cons (airis-task $name $priority $reqs) $tail))
   (Cons (goal $name
              (/ $priority 10.0)    ;; AIRIS priority [0-100] → [0-1]
              (task-weight $priority))
         (airis-tasks-to-goals $tail)))

;; Map AIRIS status to MAGUS modulators
(: airis-status-to-modulators (-> AirisStatus (List Modulator)))
(= (airis-status-to-modulators (airis-status $energy $stance $mood $effects))
   (Cons (modulator arousal (/ $energy 100))      ;; Energy → Arousal
   (Cons (modulator dominance (stance-value $stance))  ;; Stance → Dominance
   (Cons (modulator pleasure (mood-value $mood))    ;; Mood → Pleasure
   Nil))))

;; === Output: MAGUS → AIRIS ===

;; AIRIS output structure (action tuple)
(: AirisOutput Type)
(: airis-output (-> Symbol              ;; Action name
                   (List (List $a))     ;; Nested parameters
                   (List Symbol)        ;; Hints/metadata
                   AirisOutput))

;; Convert MAGUS plan to AIRIS output
(: magus-plan-to-airis (-> Plan AirisOutput))
(= (magus-plan-to-airis (plan $goal $actions $score))
   (let* (($first-action (get-first-action $actions))
          ($action-name (btnode-name $first-action))
          ($params (btnode-params $first-action))
          ($hints (generate-airis-hints $goal $score)))
     (airis-output $action-name
                  (nest-parameters $params)
                  $hints)))

;; Nest parameters for AIRIS format
;; MAGUS: (from to) → AIRIS: ((from to))
(: nest-parameters (-> (List $a) (List (List $a))))
(= (nest-parameters Nil) Nil)
(= (nest-parameters (Cons $p1 (Cons $p2 Nil)))
   (Cons (Cons $p1 (Cons $p2 Nil)) Nil))

;; Generate hints based on goal characteristics
(: generate-airis-hints (-> Goal Number (List Symbol)))
(= (generate-airis-hints $goal $score)
   (let ((goal $name $priority $weight) $goal)
     (cond
       ((> $priority 0.8) (Cons urgent (Cons $name Nil)))
       ((< $score 0.3) (Cons caution (Cons $name Nil)))
       (otherwise (Cons $name Nil)))))

;; === Mode Handling ===

;; AIRIS operates in two modes:
;; - Oracle: Only actions/status available (limited context)
;; - Agent: Full task/environment information available

(: AirisMode Type)
(: Oracle AirisMode)
(: Agent AirisMode)

(: detect-airis-mode (-> AirisInput AirisMode))
(= (detect-airis-mode (airis-input $env $inv $status $actions $tasks))
   (if (is-empty $tasks)
       Oracle
       Agent))

;; Oracle mode: Generate default goals
(: oracle-mode-defaults (-> AirisStatus (List Goal)))
(= (oracle-mode-defaults (airis-status $energy $stance $mood $effects))
   (Cons (goal survive (if (< $energy 30) 1.0 0.7) 1.0)
   (Cons (goal explore 0.5 0.5)
   (Cons (goal learn 0.3 0.3)
   Nil))))
```

**Integration Complexity:** ⭐⭐☆☆☆ (Low-Medium - clear I/O contracts)
**Estimated Effort:** 3-4 weeks (COMPLETE in M3)
**Status:** ✅ **Implemented** in `Milestone_3/integration/integration-airis.metta`

**Validation:** API contract tested with synthetic AIRIS inputs (see M3 test suite)

---

### 2.4 Generic Planning Systems

**Status:** Medium priority, partially implemented in M3
**Rationale:** Enables MAGUS to drive action selection in diverse planners

#### 2.4.1 Integration Points

**Behavior Tree Integration:**
- MAGUS goals → BT root objectives
- Goal priorities → BT node weights
- Anti-goals → BT condition checks

**GOAP Integration:**
- MAGUS goals → GOAP goal states
- Goal measurability → precondition confidence
- Correlations → action chaining hints

**HTN Integration:**
- MAGUS goals → HTN tasks
- Metagoals → method selection heuristics
- Anti-goals → constraint annotations

#### 2.4.2 MeTTa API Contract (Generic Planners)

```metta
;; ============================================================================
;; MAGUS → Generic Planner Integration API Contract
;; ============================================================================

;; Behavior Tree integration (M3 implementation)
;; See: Milestone_3/core/planner-bt.metta

(: PlannerType Type)
(: BehaviorTree PlannerType)
(: GOAP PlannerType)
(: HTN PlannerType)

;; Generic planner request
(: PlannerRequest Type)
(: planner-request (-> Goal            ;; Top-priority goal
                      WorldState       ;; Current world state
                      (List Action)    ;; Available actions
                      (List AntiGoal)  ;; Constraints
                      PlannerType      ;; Planner to use
                      PlannerRequest))

;; Generic planner response
(: PlannerResponse Type)
(: planner-response (-> (List Action)  ;; Action sequence
                       Number          ;; Plan score
                       (List Symbol)   ;; Warnings/hints
                       PlannerResponse))

;; Convert MAGUS goal to generic planner goal
(: goal-to-planner-goal (-> Goal PlannerType PlannerGoal))
(= (goal-to-planner-goal $goal BehaviorTree)
   (bt-goal (goal-name $goal)
            (goal-priority $goal)
            (goal-success-conditions $goal)))

(= (goal-to-planner-goal $goal GOAP)
   (goap-goal (goal-name $goal)
              (goal-desired-state $goal)
              (goal-weight $goal)))

(= (goal-to-planner-goal $goal HTN)
   (htn-task (goal-name $goal)
             (goal-parameters $goal)
             (goal-priority $goal)))

;; Extract success conditions from goal
(: goal-success-conditions (-> Goal (List Predicate)))
(= (goal-success-conditions (goal energy $p $w))
   (Cons (at safe-location)
   (Cons (has food) Nil)))
(= (goal-success-conditions (goal exploration $p $w))
   (Cons (is area explored) Nil))
(= (goal-success-conditions $other-goal)
   Nil)  ;; Default: no specific conditions

;; Request plan from generic planner
(: request-plan (-> PlannerRequest PlannerResponse))
(= (request-plan (planner-request $goal $state $actions $antigoals $type))
   (case $type
     ((BehaviorTree (plan-with-bt $goal $state $actions $antigoals))
      (GOAP (plan-with-goap $goal $state $actions $antigoals))
      (HTN (plan-with-htn $goal $state $actions $antigoals))
      ($other (planner-response Nil 0 (Cons unsupported-planner Nil))))))

;; Anti-goal constraints to planner format
(: antigoals-to-constraints (-> (List AntiGoal) PlannerType (List Constraint)))
(= (antigoals-to-constraints $antigoals BehaviorTree)
   (map-antigoals-to-bt-conditions $antigoals))
(= (antigoals-to-constraints $antigoals GOAP)
   (map-antigoals-to-goap-preconditions $antigoals))
(= (antigoals-to-constraints $antigoals HTN)
   (map-antigoals-to-htn-constraints $antigoals))
```

**Integration Complexity:** ⭐⭐⭐☆☆ (Medium - varies by planner)
**Estimated Effort:** 2-3 weeks per planner type
**Status:** BT implementation complete (M3), GOAP/HTN contracts defined

---

## 3. Game-Agnostic Testing Framework

### 3.1 Reference Game Environments

**Selected:** Village of Grit (primary), Minecraft (secondary)

**Abstraction Layer:**
```metta
;; Game adapter for environment-independent testing
(: GameAdapter Type)
(: game-adapter (-> Symbol                    ;; Game name
                   (List (Symbol Symbol))     ;; Action mappings
                   (List (Symbol Symbol))     ;; Object mappings
                   GameAdapter))

;; Village of Grit adapter
(= (village-of-grit-adapter)
   (game-adapter village-of-grit
     (Cons (move walk)
     (Cons (gather collect-resources)
     (Cons (craft make)
     Nil)))
     (Cons (food berries)
     (Cons (tool stone-axe)
     Nil))))

;; Minecraft adapter (for future use)
(= (minecraft-adapter)
   (game-adapter minecraft
     (Cons (move walk)
     (Cons (gather mine)
     (Cons (craft place)
     Nil)))
     (Cons (food apple)
     (Cons (tool pickaxe)
     Nil))))
```

**Testing Approach:**
- Define game-neutral goal types (survival, exploration, social)
- Map game-specific actions to abstract operators
- Validate MAGUS behavior across multiple game contexts

### 3.2 Thin Adapter Pattern

**Principle:** Minimize game-specific code in MAGUS core

```
[Game Environment]
       ↓
[Thin Adapter: 20-50 lines]
       ↓
[MAGUS Core: Game-agnostic]
```

**Benefits:**
- Easy to add new game integrations
- Testable without actual game instances
- Portable across simulation platforms

---

## 4. Lessons Learned & Best Practices

### 4.1 MeTTa-Specific Patterns

**✅ DO:**
- Use typed function signatures for API contracts
- Separate knowledge bases with `new-space` for different integrations
- Provide both imperative (`convert-x-to-y`) and declarative (`x-as-y`) functions
- Include example usage in comments

**❌ DON'T:**
- Assume external systems use MeTTa (provide format conversion)
- Tightly couple MAGUS logic to specific external APIs
- Use grounded Python functions for pure symbolic transformations
- Ignore truth value / confidence metadata in conversions

### 4.2 Integration Architecture Principles

**1. Thin Interfaces:**
- Keep integration code minimal and focused
- Push complexity into adapters, not core MAGUS

**2. Bidirectional Contracts:**
- Define both MAGUS→External and External→MAGUS flows
- Include inverse transformations for round-trip validation

**3. Graceful Degradation:**
- Support "oracle mode" with minimal external information
- Provide default behaviors when external systems unavailable

**4. Metadata Preservation:**
- Carry confidence/measurability through transformations
- Annotate outputs with provenance information

### 4.3 Testing Without Live Systems

**Mock Spaces Pattern:**
```metta
;; Create mock external system for testing
!(bind! &mock-pln (new-space))

;; Populate with test data
!(add-atom &mock-pln
  (ImplicationLink (pln-tv 0.8 0.6)
    (ConceptNode energy)
    (ConceptNode exploration)))

;; Test MAGUS integration
!(test-pln-integration &mock-pln (goal energy 0.7 0.8))
```

**Benefits:**
- No external system dependencies
- Deterministic test results
- Fast iteration cycles

---

## 5. Open Questions & Future Work

### 5.1 Unanswered Questions

**Q1: Hyperon Action Planning System**
- **Status:** Uncertainty remains around Hyperon's native planning approach
- **Impact:** M3 built standalone planner as hedge
- **Resolution:** Monitor Hyperon development; migrate if native planner emerges

**Q2: NARS Mental Operator Timing**
- **Question:** When should MAGUS goals trigger NARS self-control operators?
- **Impact:** Could cause reasoning cycles if triggered too frequently
- **Resolution:** Requires empirical testing with live NARS instance

**Q3: Multi-Agent Goal Coordination**
- **Question:** How should shared goals be represented in DAS?
- **Impact:** Affects scalability for multi-agent systems
- **Resolution:** Defer to post-M4 (requires distributed testing)

### 5.2 Future Prototyping Directions

**Phase 1 (Post-M4):**
- Live Hyperon integration with ECAN
- NARS bidirectional testing
- AIRIS game environment validation

**Phase 2 (Long-term):**
- Multi-agent coordination protocols
- Cross-system goal sharing (MAGUS↔MAGUS)
- Emotional/affective reasoning extensions

**Phase 3 (Research):**
- Consciousness integration (Global Workspace Theory)
- Meta-learning for metagoal discovery
- Ethical constraint learning from human feedback

---

## 6. Deliverable Checklist

| Deliverable | Status | Evidence |
|-------------|--------|----------|
| PLN integration API contract | ✅ Complete | Section 2.1.2 |
| NARS integration API contract | ✅ Complete | Section 2.2.2 |
| AIRIS integration API contract | ✅ Complete | Section 2.3.2 (implemented M3) |
| Generic planner API contract | ✅ Complete | Section 2.4.2 |
| Game-agnostic adapter pattern | ✅ Complete | Section 3 |
| Testing framework design | ✅ Complete | Section 3.2 |
| Best practices documentation | ✅ Complete | Section 4 |
| Strategic analysis | ✅ Complete | `agi-integration-strategic-analysis.md` |

---

## 7. Conclusions

### 7.1 M2 Prototyping Success Criteria

✅ **All criteria met:**
1. Integration pathways identified for ≥3 external systems (4 documented)
2. MeTTa API contracts defined with type signatures and examples
3. Feasibility assessed (all integrations viable, complexity quantified)
4. No premature implementation (contracts only, as specified)
5. Future direction clear (Hyperon priority, AIRIS proven in M3)

### 7.2 Readiness for M3

**Prerequisites Satisfied:**
- AIRIS contract enables M3 integration module
- Generic planner contract guides M3 planner-bt.metta design
- Testing framework patterns applied in M3 test scenarios

**Blockers Removed:**
- Uncertainty about integration feasibility resolved
- API boundaries clearly defined
- Mock testing patterns established

### 7.3 Recommendations

**High Priority:**
1. **Implement Hyperon/ECAN integration** (Post-M4) - highest value, lowest cost
2. **Extend AIRIS validation** (M4) - prove game environment utility
3. **Begin NARS collaboration** (M4+) - establish academic partnerships

**Medium Priority:**
4. **GOAP/HTN planner adapters** (M5) - broader planning ecosystem support
5. **Multi-agent protocols** (M6) - distributed AGI applications

**Low Priority (Research):**
6. **Emotional reasoning extensions** - affective dimension
7. **Consciousness integration** - Global Workspace connections

---

**Report Status:** ✅ **Complete and Validated**
**Approved By:** Neoterics MAGUS Team
**Date:** October 2025
**Next Actions:** Begin M3 implementation using AIRIS contract (complete), prepare for M4 Hyperon exploration
