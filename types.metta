;; MAGUS Milestone 3: Unified Type Definitions
;; This file contains all shared types used across MAGUS modules
;; All modules should import this file to ensure type consistency

;; =============================================================================
;; Basic ADTs
;; =============================================================================

;; Tuple for pairs
(: Tuple (-> $a $b Type))

;; List ADT
(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))

;; List length function
(: length (-> (List $a) Number))
(= (length Nil) 0)
(= (length (Cons $head $tail)) (+ 1 (length $tail)))

;; Map function over lists
(: map (-> (-> $a $b) (List $a) (List $b)))
(= (map $f Nil) Nil)
(= (map $f (Cons $head $tail))
   (Cons ($f $head) (map $f $tail)))

;; Fold function - takes named function not lambda
(: fold (-> (List $a) $b (-> $a $b $b) $b))
(= (fold Nil $acc $f) $acc)
(= (fold (Cons $head $tail) $acc $f)
   (fold $tail ($f $head $acc) $f))

;; Filter function - takes named predicate
(: filter (-> (-> $a Bool) (List $a) (List $a)))
(= (filter $pred Nil) Nil)
(= (filter $pred (Cons $head $tail))
   (if ($pred $head)
       (Cons $head (filter $pred $tail))
       (filter $pred $tail)))

;; Member check
(: member (-> $a (List $a) Bool))
(= (member $x Nil) False)
(= (member $x (Cons $head $tail))
   (if (== $x $head)
       True
       (member $x $tail)))

;; Append lists
(: append (-> (List $a) (List $a) (List $a)))
(= (append Nil $list) $list)
(= (append (Cons $head $tail) $list)
   (Cons $head (append $tail $list)))

;; Reverse list
(: reverse (-> (List $a) (List $a)))
(= (reverse $list) (reverse-acc $list Nil))
(: reverse-acc (-> (List $a) (List $a) (List $a)))
(= (reverse-acc Nil $acc) $acc)
(= (reverse-acc (Cons $head $tail) $acc)
   (reverse-acc $tail (Cons $head $acc)))

;; Find element matching predicate
(: find (-> (-> $a Bool) (List $a) $a))
(= (find $pred Nil) Empty)
(= (find $pred (Cons $head $tail))
   (if ($pred $head)
       $head
       (find $pred $tail)))

;; =============================================================================
;; Core MAGUS Types
;; =============================================================================

;; Goal type with properties
(: Goal Type)
(: goal (-> Symbol Number Number Goal))  ;; name, priority [0,1], weight [0,1]

;; Action type with parameters
(: Action Type)
(: action (-> Symbol (List $a) Action))  ;; name, parameters

;; Context type - unified across modules
(: Context Type)
(: context (-> (List Goal) Number Context))  ;; goals, timestamp

;; Scoring context with modulators
(: ScoringContext Type)
(: scoring-context (-> (List Goal) (List Modulator) Number ScoringContext))

;; Modulator type
(: Modulator Type)
(: modulator (-> Symbol Number Modulator))  ;; name, value [0,1]

;; =============================================================================
;; Metagoal Types
;; =============================================================================

;; Metagoal type
(: Metagoal Type)
(: metagoal (-> Symbol Metagoal))

;; Metric window for time-based tracking
(: MetricWindow Type)
(: metric-window (-> Number Number MetricWindow))  ;; start_time, end_time

;; Metric record with timestamp
(: MetricRecord Type)
(: metric-record (-> Goal Number Number MetricRecord))  ;; goal, value, timestamp

;; Justification for audit trail
(: Justification Type)
(: justification (-> Symbol Number Number Justification))  ;; reason, measurability, correlation

;; Weight adjustment
(: WeightAdjustment Type)
(: weight-adj (-> Goal Number WeightAdjustment))

;; =============================================================================
;; Anti-goal Types
;; =============================================================================

;; Severity levels for anti-goals
(: Severity Type)
(: Hard Severity)   ;; Veto - score becomes 0
(: Soft Severity)   ;; Penalty - score is reduced

;; Anti-goal type - unified signature
(: AntiGoal Type)
(: anti-goal (-> Symbol Severity (-> Context Candidate Number) AntiGoal))

;; Candidate type (can be a goal or action)
(: Candidate Type)
(: goal-candidate (-> Goal Candidate))
(: action-candidate (-> Action Candidate))

;; Violation record for tracking
(: Violation Type)
(: violation (-> AntiGoal Candidate Number Number Violation))  ;; antigoal, candidate, penalty, timestamp

;; Anti-goal configuration
(: AntiGoalConfig Type)
(: ag-config (-> AntiGoal Number Bool AntiGoalConfig))  ;; antigoal, weight, enabled

;; =============================================================================
;; Scoring Types
;; =============================================================================

;; Decision score breakdown - standardized format
(: DecisionScore Type)
(: decision-score (-> Number Number Number Number Number DecisionScore))
;; base_utility, metagoal_adjustment, overgoal_adjustment, antigoal_penalties, final_score

;; Score component for explainability
(: ScoreComponent Type)
(: score-component (-> Symbol Number String ScoreComponent))
;; component_name, value, description

;; Consideration type
(: Consideration Type)
(: consideration (-> Symbol (-> ScoringContext Number) Consideration))

;; Discouragement type
(: Discouragement Type)
(: discouragement (-> Symbol (-> ScoringContext Number) Discouragement))

;; Scoring weights configuration
(: ScoringWeights Type)
(: scoring-weights (-> Number Number Number ScoringWeights))
;; base_weight, metagoal_weight, antigoal_strength

;; =============================================================================
;; Planning Types
;; =============================================================================

;; World state representation with structured predicates
(: WorldState Type)
(: world-state (-> (List Predicate) WorldState))

;; Predicate type for preconditions/effects
(: Predicate Type)
(: at (-> Symbol Predicate))              ;; at(location)
(: holding (-> Symbol Predicate))         ;; holding(item)
(: has (-> Symbol Predicate))             ;; has(property)
(: can (-> Symbol Predicate))             ;; can(capability)
(: is (-> Symbol Symbol Predicate))       ;; is(entity, state)

;; Behavior tree node types
(: BTNode Type)
(: Sequence (-> (List BTNode) BTNode))      ;; Execute children in order
(: Selector (-> (List BTNode) BTNode))      ;; Try children until one succeeds
(: BTAction (-> Symbol (List $a) BTNode))   ;; Leaf node - actual action (renamed from Action)
(: Condition (-> Predicate BTNode))         ;; Condition check

;; Plan representation
(: Plan Type)
(: plan (-> Goal (List BTNode) Number Plan))  ;; goal, actions, estimated_score

;; Action specification with structured predicates
(: ActionSpec Type)
(: action-spec (-> Symbol                    ;; action name
                   (List Symbol)             ;; parameters
                   (List Predicate)          ;; preconditions
                   (List Predicate)          ;; effects
                   Number                    ;; cost
                   ActionSpec))

;; =============================================================================
;; AIRIS Integration Types (Aligned with Spec)
;; =============================================================================

;; AIRIS Environment - per spec: [[object-name, object-type, [[property, value] ...], distance], ...]
(: AirisEnvironment Type)
(: airis-env (-> (List (List $a)) AirisEnvironment))

;; AIRIS Inventory - per spec: [[item, [[property, value] ...] or None, quantity], ...]
(: AirisInventory Type)
(: airis-inventory (-> (List (List $a)) AirisInventory))

;; AIRIS Agent Status - per spec
(: AirisStatus Type)
(: airis-status (-> Number         ;; energy
                   Symbol         ;; stance
                   Symbol         ;; mood
                   (List Symbol)  ;; active-effects
                   AirisStatus))

;; AIRIS Action format
(: AirisAction Type)
(: airis-action (-> Symbol         ;; action-name
                   (List $a)       ;; nested parameters
                   AirisAction))

;; AIRIS Task format
(: AirisTask Type)
(: airis-task (-> Symbol          ;; task-name
                 Number           ;; priority
                 (List Symbol)    ;; requirements
                 AirisTask))

;; AIRIS Complete Input
(: AirisInput Type)
(: airis-input (-> AirisEnvironment
                  AirisInventory
                  AirisStatus
                  (List AirisAction)
                  (List AirisTask)
                  AirisInput))

;; AIRIS Output format (action tuple)
(: AirisOutput Type)
(: airis-output (-> Symbol         ;; selected-action
                   (List $a)       ;; nested action-parameters
                   (List Symbol)   ;; optional-hints
                   AirisOutput))

;; Operating mode
(: AirisMode Type)
(: Oracle AirisMode)  ;; Only actions and status provided
(: Agent AirisMode)   ;; Full tasks and environment provided

;; =============================================================================
;; HERMES Causal Reference Types
;; =============================================================================

;; Causal edge reference
(: CausalEdgeRef Type)
(: causal-edge (-> Symbol          ;; source node
                   Symbol          ;; target node
                   Number          ;; strength/confidence [0,1]
                   Symbol          ;; edge type
                   CausalEdgeRef))

;; Causal graph reference
(: CausalGraphRef Type)
(: causal-graph (-> Symbol         ;; graph ID
                   (List CausalEdgeRef)  ;; edges
                   Number          ;; overall confidence
                   CausalGraphRef))

;; Goal satisfaction evidence
(: GoalSatisfactionEvidence Type)
(: goal-evidence (-> Goal          ;; the goal
                    Symbol         ;; satisfaction status
                    (List CausalEdgeRef)  ;; supporting edges
                    Number         ;; confidence
                    GoalSatisfactionEvidence))

;; Causal attribution
(: CausalAttribution Type)
(: causal-attr (-> Symbol          ;; decision/action
                   Symbol          ;; outcome
                   (List CausalEdgeRef)  ;; causal path
                   Number          ;; attribution strength
                   CausalAttribution))

;; Provenance information
(: Provenance Type)
(: provenance (-> Symbol           ;; source system (HERMES/MAGUS/etc)
                 Number            ;; timestamp
                 (List Symbol)     ;; proof terms or references
                 Provenance))

;; Causal chain
(: CausalChain Type)
(: causal-chain (-> (List Symbol)  ;; sequence of nodes
                   Number          ;; chain strength (weakest link)
                   Provenance      ;; source info
                   CausalChain))

;; =============================================================================
;; Helper Functions
;; =============================================================================

;; Math functions
;; Note: sqrt, pow, and other advanced math functions are provided by
;; the grounded Python extension in math_ext.py and math-grounded.metta
;; Load math-grounded.metta to use them

;; Min/Max functions
(: min (-> Number Number Number))
(= (min $a $b) (if (< $a $b) $a $b))

(: max (-> Number Number Number))
(= (max $a $b) (if (> $a $b) $a $b))

;; Empty value
(= Empty Empty)

;; Boolean type
(: Bool Type)
(: True Bool)
(: False Bool)