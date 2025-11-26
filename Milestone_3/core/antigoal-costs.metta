;; MAGUS Milestone 3: Anti-goal Cost Configuration
;; Data-driven cost estimation for energy and risk anti-goals
;; Replaces hardcoded heuristics with configurable lookup tables

;; =============================================================================
;; Energy Cost Knowledge Base
;; =============================================================================

;; Create dedicated space for energy cost data
!(bind! &energy-costs (new-space))

;; Base energy costs for different action types
;; Format: (action-energy-cost action-name base-cost distance-multiplier)
!(add-atom &energy-costs (action-energy-cost move 5 1.0))
!(add-atom &energy-costs (action-energy-cost attack 20 0.0))
!(add-atom &energy-costs (action-energy-cost wait 1 0.0))
!(add-atom &energy-costs (action-energy-cost teleport 30 2.0))
!(add-atom &energy-costs (action-energy-cost explore 10 0.5))
!(add-atom &energy-costs (action-energy-cost pickup 3 0.0))
!(add-atom &energy-costs (action-energy-cost use 8 0.0))
!(add-atom &energy-costs (action-energy-cost craft 15 0.0))
!(add-atom &energy-costs (action-energy-cost rest -10 0.0))  ;; Negative = recovery
!(add-atom &energy-costs (action-energy-cost eat -15 0.0))

;; Default cost for unknown actions
(= (default-energy-cost) 5)

;; =============================================================================
;; Risk Cost Knowledge Base
;; =============================================================================

!(bind! &risk-costs (new-space))

;; Base risk levels for different action types
;; Format: (action-risk-level action-name base-risk context-multiplier)
!(add-atom &risk-costs (action-risk-level move 0.1 0.0))
!(add-atom &risk-costs (action-risk-level attack 0.8 0.2))
!(add-atom &risk-costs (action-risk-level wait 0.05 0.0))
!(add-atom &risk-costs (action-risk-level teleport 0.4 0.1))
!(add-atom &risk-costs (action-risk-level explore 0.3 0.15))
!(add-atom &risk-costs (action-risk-level pickup 0.1 0.05))
!(add-atom &risk-costs (action-risk-level use 0.2 0.1))
!(add-atom &risk-costs (action-risk-level craft 0.15 0.0))
!(add-atom &risk-costs (action-risk-level rest 0.0 0.0))
!(add-atom &risk-costs (action-risk-level eat 0.05 0.0))

;; Dangerous actions
!(add-atom &risk-costs (action-risk-level self-destruct 1.0 0.0))
!(add-atom &risk-costs (action-risk-level abandon-team 0.9 0.0))

;; Default risk for unknown actions
(= (default-risk-level) 0.3)

;; =============================================================================
;; Risky Goal Indicators
;; =============================================================================

!(bind! &risky-goals (new-space))

;; Goals considered inherently risky
!(add-atom &risky-goals (risky-goal dominate 0.7))
!(add-atom &risky-goals (risky-goal conquer 0.8))
!(add-atom &risky-goals (risky-goal attack-base 0.9))
!(add-atom &risky-goals (risky-goal infiltrate 0.6))
!(add-atom &risky-goals (risky-goal sabotage 0.85))

;; =============================================================================
;; Context Factors
;; =============================================================================

!(bind! &context-factors (new-space))

;; Environmental danger multipliers
!(add-atom &context-factors (danger-level safe 0.5))
!(add-atom &context-factors (danger-level neutral 1.0))
!(add-atom &context-factors (danger-level hostile 1.5))
!(add-atom &context-factors (danger-level extreme 2.0))

;; Agent state multipliers for energy cost
!(add-atom &context-factors (fatigue-multiplier rested 0.8))
!(add-atom &context-factors (fatigue-multiplier normal 1.0))
!(add-atom &context-factors (fatigue-multiplier tired 1.3))
!(add-atom &context-factors (fatigue-multiplier exhausted 1.8))

;; =============================================================================
;; Parameter Analysis Functions
;; =============================================================================

;; Extract distance from move parameters
(: extract-distance (-> (List $a) Number))
(= (extract-distance Nil) 1.0)  ;; Default distance
(= (extract-distance (Cons from (Cons to Nil)))
   (calculate-distance from to))
(= (extract-distance $_) 1.0)

;; Calculate distance between locations (simplified)
(: calculate-distance (-> $a $a Number))
(= (calculate-distance $loc1 $loc2)
   (if (== $loc1 $loc2)
       0.0
       1.0))  ;; Placeholder - could use actual coordinates

;; Extract target danger level from parameters
(: extract-target-danger (-> (List $a) Symbol))
(= (extract-target-danger Nil) neutral)
(= (extract-target-danger (Cons target-location $_))
   (get-location-danger target-location))
(= (extract-target-danger $_) neutral)

;; Get danger level of a location
(: get-location-danger (-> Symbol Symbol))
(= (get-location-danger safe-location) safe)
(= (get-location-danger home-base) safe)
(= (get-location-danger wilderness) neutral)
(= (get-location-danger enemy-territory) hostile)
(= (get-location-danger dungeon) hostile)
(= (get-location-danger dragon-lair) extreme)
(= (get-location-danger $_) neutral)

;; =============================================================================
;; Energy Cost Calculation (Data-Driven)
;; =============================================================================

;; Get base energy cost from knowledge base
(: get-base-energy-cost (-> Symbol Number))
(= (get-base-energy-cost $action)
   (extract-energy-cost
     (match &energy-costs
       (action-energy-cost $action $cost $mult)
       (action-energy-cost $action $cost $mult))))

(: extract-energy-cost (-> $a Number))
(= (extract-energy-cost Empty) (default-energy-cost))
(= (extract-energy-cost (action-energy-cost $_ $cost $_)) $cost)

;; Get distance multiplier from knowledge base
(: get-distance-multiplier (-> Symbol Number))
(= (get-distance-multiplier $action)
   (extract-distance-mult
     (match &energy-costs
       (action-energy-cost $action $cost $mult)
       (action-energy-cost $action $cost $mult))))

(: extract-distance-mult (-> $a Number))
(= (extract-distance-mult Empty) 0.0)
(= (extract-distance-mult (action-energy-cost $_ $_ $mult)) $mult)

;; Calculate total energy cost with parameters and context
(: calculate-energy-cost (-> Symbol (List $a) Context Number))
(= (calculate-energy-cost $action $params $context)
   (let* (($base-cost (get-base-energy-cost $action))
          ($dist-mult (get-distance-multiplier $action))
          ($distance (extract-distance $params))
          ($fatigue-mult (get-fatigue-multiplier $context))
          ($distance-cost (* $dist-mult $distance))
          ($total-base (+ $base-cost $distance-cost)))
     (* $total-base $fatigue-mult)))

;; Get fatigue multiplier from context
(: get-fatigue-multiplier (-> Context Number))
(= (get-fatigue-multiplier $context)
   (let $state (extract-agent-state $context)
     (match &context-factors
       (fatigue-multiplier $state $mult)
       $mult)))

;; Extract agent fatigue state from context (placeholder)
(: extract-agent-state (-> Context Symbol))
(= (extract-agent-state $_) normal)  ;; Default, could extract from context goals

;; =============================================================================
;; Risk Level Calculation (Data-Driven)
;; =============================================================================

;; Get base risk level from knowledge base
(: get-base-risk-level (-> Symbol Number))
(= (get-base-risk-level $action)
   (extract-risk-level
     (match &risk-costs
       (action-risk-level $action $risk $mult)
       (action-risk-level $action $risk $mult))))

(: extract-risk-level (-> $a Number))
(= (extract-risk-level Empty) (default-risk-level))
(= (extract-risk-level (action-risk-level $_ $risk $_)) $risk)

;; Get context multiplier from knowledge base
(: get-context-multiplier (-> Symbol Number))
(= (get-context-multiplier $action)
   (extract-context-mult
     (match &risk-costs
       (action-risk-level $action $risk $mult)
       (action-risk-level $action $risk $mult))))

(: extract-context-mult (-> $a Number))
(= (extract-context-mult Empty) 0.0)
(= (extract-context-mult (action-risk-level $_ $_ $mult)) $mult)

;; Calculate total risk with parameters and context
(: calculate-risk-level (-> Symbol (List $a) Context Number))
(= (calculate-risk-level $action $params $context)
   (let* (($base-risk (get-base-risk-level $action))
          ($ctx-mult (get-context-multiplier $action))
          ($danger (extract-target-danger $params))
          ($danger-mult (get-danger-multiplier $danger))
          ($context-risk (* $ctx-mult $danger-mult)))
     (+ $base-risk $context-risk)))

;; Get danger multiplier from knowledge base
(: get-danger-multiplier (-> Symbol Number))
(= (get-danger-multiplier $danger-level)
   (extract-danger-mult
     (match &context-factors
       (danger-level $danger-level $mult)
       (danger-level $danger-level $mult))))

(: extract-danger-mult (-> $a Number))
(= (extract-danger-mult Empty) 1.0)
(= (extract-danger-mult (danger-level $_ $mult)) $mult)

;; =============================================================================
;; Risky Goal Detection (Data-Driven)
;; =============================================================================

;; Check if goal is risky using knowledge base
(: get-goal-risk-level (-> Symbol Number))
(= (get-goal-risk-level $goal-name)
   (extract-goal-risk
     (match &risky-goals
       (risky-goal $goal-name $risk)
       (risky-goal $goal-name $risk))))

(: extract-goal-risk (-> $a Number))
(= (extract-goal-risk Empty) 0.0)  ;; Not risky
(= (extract-goal-risk (risky-goal $_ $risk)) $risk)

;; Check if goal exceeds risk threshold (0.5)
(: is-risky-goal-v2 (-> Symbol Bool))
(= (is-risky-goal-v2 $goal-name)
   (> (get-goal-risk-level $goal-name) 0.5))

;; =============================================================================
;; Configuration Update Functions
;; =============================================================================

;; Add or update energy cost for an action
(: set-energy-cost (-> Symbol Number Number ()))
(= (set-energy-cost $action $base-cost $distance-mult)
   (add-atom &energy-costs
     (action-energy-cost $action $base-cost $distance-mult)))

;; Add or update risk level for an action
(: set-risk-level (-> Symbol Number Number ()))
(= (set-risk-level $action $base-risk $context-mult)
   (add-atom &risk-costs
     (action-risk-level $action $base-risk $context-mult)))

;; Mark a goal as risky
(: mark-risky-goal (-> Symbol Number ()))
(= (mark-risky-goal $goal-name $risk-level)
   (add-atom &risky-goals
     (risky-goal $goal-name $risk-level)))

;; =============================================================================
;; Violation Feedback Integration
;; =============================================================================

;; Adjust costs based on violation history
;; If energy costs are consistently violated, increase penalty factors
(: adjust-costs-from-violations (-> (List Violation) ()))
(= (adjust-costs-from-violations $violations)
   (process-violation-feedback $violations))

;; Process violation feedback (placeholder for learning loop)
(: process-violation-feedback (-> (List Violation) ()))
(= (process-violation-feedback Nil) ())
(= (process-violation-feedback (Cons (violation $ag $cand $penalty $time) $tail))
   (let ((_ (record-cost-adjustment $ag $cand $penalty)))
     (process-violation-feedback $tail)))

;; Record cost adjustment suggestion
(: record-cost-adjustment (-> AntiGoal Candidate Number ()))
(= (record-cost-adjustment $antigoal $candidate $penalty)
   ;; Future: Implement learning-based cost updates
   ())

;; =============================================================================
;; Export Functions
;; =============================================================================

(: antigoal-costs-exports (-> (List Symbol)))
(= (antigoal-costs-exports)
   (list
     calculate-energy-cost
     calculate-risk-level
     get-goal-risk-level
     is-risky-goal-v2
     set-energy-cost
     set-risk-level
     mark-risky-goal
     adjust-costs-from-violations))

!(println "Anti-goal Cost Configuration Loaded")
!(println "Energy costs: 10 action types defined")
!(println "Risk levels: 12 action types + 5 risky goals defined")
!(println "Context factors: danger levels and fatigue multipliers configured")
