;; MAGUS Milestone 3: Behavior Tree Planner Prototype (Refined)
;; Minimal planner that accepts a prioritized goal and generates action sequences
;; Outputs AIRIS-compatible tuples
;; Based on Milestone-3-Spec.md requirements and M3-Refinement-Plan.md

;; Import shared types
!(load types.metta)

;; Import other modules
!(load antigoals.metta)

;; =============================================================================
;; Additional Types (beyond types.metta)
;; =============================================================================

;; Planning context
(: PlanningContext Type)
(: planning-context (-> WorldState Goal Number PlanningContext))

;; Planning depth limit
(: max-planning-depth (-> Number))
(= (max-planning-depth) 10)

;; Step cost accumulator
(: StepInfo Type)
(: step-info (-> Number DecisionScore StepInfo))  ;; depth, accumulated_score

;; =============================================================================
;; Action Library
;; =============================================================================

;; Define available actions with structured predicates
(: get-action-spec (-> Symbol ActionSpec))
(= (get-action-spec move)
   (action-spec move
     (Cons from (Cons to Nil))                      ;; parameters
     (Cons (at from) (Cons (can move) Nil))        ;; preconditions
     (Cons (at to) Nil)                            ;; effects
     10))                                           ;; cost

(= (get-action-spec pickup)
   (action-spec pickup
     (Cons item (Cons location Nil))
     (Cons (at location)
     (Cons (is item available)
     (Cons (can pickup) Nil)))
     (Cons (holding item) Nil)
     5))

(= (get-action-spec use)
   (action-spec use
     (Cons item (Cons target Nil))
     (Cons (holding item)
     (Cons (has target)
     (Cons (can use) Nil)))
     (Cons (is item used)
     (Cons (is target affected) Nil))
     8))

(= (get-action-spec wait)
   (action-spec wait
     Nil                          ;; No parameters
     Nil                          ;; No preconditions
     (Cons (is time advanced) Nil)
     1))

(= (get-action-spec explore)
   (action-spec explore
     (Cons area Nil)
     (Cons (at area)
     (Cons (is area unexplored) Nil))
     (Cons (is area explored)
     (Cons (has knowledge) Nil))
     15))

;; Get all available actions
(: available-actions (-> (List Symbol)))
(= (available-actions)
   (Cons move
   (Cons pickup
   (Cons use
   (Cons wait
   (Cons explore
   Nil))))))

;; =============================================================================
;; Precondition Checking with Structured Predicates
;; =============================================================================

;; Check if preconditions are met in world state
(: check-preconditions (-> (List Predicate) WorldState Bool))
(= (check-preconditions Nil $state) True)
(= (check-preconditions (Cons $pre $tail) $state)
   (if (predicate-holds $pre $state)
       (check-preconditions $tail $state)
       False))

;; Check if a predicate holds in the world state
(: predicate-holds (-> Predicate WorldState Bool))
(= (predicate-holds $pred (world-state $predicates))
   (member $pred $predicates))

;; Apply effects to world state
(: apply-effects (-> (List Predicate) WorldState WorldState))
(= (apply-effects Nil $state) $state)
(= (apply-effects (Cons $effect $tail) (world-state $predicates))
   (apply-effects $tail (world-state (add-predicate $effect $predicates))))

;; Add a predicate to the world state if not already present
(: add-predicate (-> Predicate (List Predicate) (List Predicate)))
(= (add-predicate $pred $preds)
   (if (member $pred $preds)
       $preds
       (Cons $pred $preds)))

;; =============================================================================
;; Behavior Tree Construction
;; =============================================================================

;; Build a behavior tree for a goal
(: build-behavior-tree (-> Goal WorldState BTNode))
(= (build-behavior-tree (goal $name $priority $weight) $state)
   (case $name
     ((reach-location (build-movement-tree $state))
      (gather-resources (build-gathering-tree $state))
      (eliminate-threat (build-combat-tree $state))
      (gain-knowledge (build-exploration-tree $state))
      ($default (build-default-tree $state)))))

;; Build movement behavior tree
(: build-movement-tree (-> WorldState BTNode))
(= (build-movement-tree $state)
   (Sequence
     (Cons (Condition (can move))
     (Cons (BTAction move (Cons current-location (Cons target-location Nil)))
     Nil))))

;; Build resource gathering tree
(: build-gathering-tree (-> WorldState BTNode))
(= (build-gathering-tree $state)
   (Sequence
     (Cons (BTAction move (Cons current-location (Cons resource-location Nil)))
     (Cons (BTAction pickup (Cons resource (Cons resource-location Nil)))
     Nil))))

;; Build combat tree
(: build-combat-tree (-> WorldState BTNode))
(= (build-combat-tree $state)
   (Selector
     (Cons (Sequence
             (Cons (Condition (has weapon))
             (Cons (BTAction use (Cons weapon (Cons target Nil)))
             Nil)))
     (Cons (BTAction move (Cons current-location (Cons safe-location Nil)))
     Nil))))

;; Build exploration tree
(: build-exploration-tree (-> WorldState BTNode))
(= (build-exploration-tree $state)
   (Sequence
     (Cons (BTAction explore (Cons unknown-area Nil))
     Nil)))

;; Build default tree (just wait)
(: build-default-tree (-> WorldState BTNode))
(= (build-default-tree $state)
   (BTAction wait Nil))

;; =============================================================================
;; Behavior Tree Execution Planning
;; =============================================================================

;; Extract action sequence from behavior tree
(: extract-actions (-> BTNode (List BTNode)))
(= (extract-actions (BTAction $name $params))
   (Cons (BTAction $name $params) Nil))
(= (extract-actions (Condition $check))
   Nil)  ;; Conditions don't produce actions
(= (extract-actions (Sequence $children))
   (flatten-actions $children))
(= (extract-actions (Selector $children))
   (extract-first-viable $children))

;; Flatten actions from multiple nodes
(: flatten-actions (-> (List BTNode) (List BTNode)))
(= (flatten-actions Nil) Nil)
(= (flatten-actions (Cons $node $tail))
   (append (extract-actions $node) (flatten-actions $tail)))

;; Extract first viable path from selector
(: extract-first-viable (-> (List BTNode) (List BTNode)))
(= (extract-first-viable Nil) Nil)
(= (extract-first-viable (Cons $node $tail))
   (let (($actions (extract-actions $node)))
     (if (is-empty $actions)
         (extract-first-viable $tail)
         $actions)))

;; Check if list is empty
(: is-empty (-> (List $a) Bool))
(= (is-empty Nil) True)
(= (is-empty (Cons $h $t)) False)

;; =============================================================================
;; Plan Generation and Scoring
;; =============================================================================

;; Generate a plan for a goal
(: generate-plan (-> Goal WorldState Plan))
(= (generate-plan $goal $state)
   (let* (($tree (build-behavior-tree $goal $state))
          ($actions (extract-actions $tree))
          ($score (estimate-plan-score $actions $state)))
     (plan $goal $actions $score)))

;; Estimate plan score
(: estimate-plan-score (-> (List BTNode) WorldState Number))
(= (estimate-plan-score Nil $state) 0)
(= (estimate-plan-score (Cons (BTAction $name $params) $tail) $state)
   (let* (($spec (get-action-spec $name))
          ((action-spec $n $p $pre $eff $cost) $spec))
     (+ (- 100 $cost)  ;; Prefer lower cost actions
        (estimate-plan-score $tail $state))))

;; =============================================================================
;; Feasibility and Recovery
;; =============================================================================

;; Check if a plan is feasible
(: is-plan-feasible (-> Plan WorldState Bool))
(= (is-plan-feasible (plan $goal $actions $score) $state)
   (check-action-sequence $actions $state))

;; Check if action sequence is executable with depth limit
(: check-action-sequence (-> (List BTNode) WorldState Bool))
(= (check-action-sequence $actions $state)
   (check-action-sequence-depth $actions $state 0))

;; Check action sequence with depth tracking
(: check-action-sequence-depth (-> (List BTNode) WorldState Number Bool))
(= (check-action-sequence-depth Nil $state $depth) True)
(= (check-action-sequence-depth $actions $state $depth)
   (if (> $depth (max-planning-depth))
       False  ;; Depth limit exceeded
       (check-action-sequence-impl $actions $state $depth)))

;; Implementation of action sequence checking
(: check-action-sequence-impl (-> (List BTNode) WorldState Number Bool))
(= (check-action-sequence-impl Nil $state $depth) True)
(= (check-action-sequence-impl (Cons (BTAction $name $params) $tail) $state $depth)
   (let* (($spec (get-action-spec $name))
          ((action-spec $n $p $pre $eff $cost) $spec))
     (if (check-preconditions $pre $state)
         (check-action-sequence-depth $tail (apply-effects $eff $state) (+ $depth 1))
         False)))

;; Attempt to repair an infeasible plan with retry logic
(: repair-plan (-> Plan WorldState Plan))
(= (repair-plan (plan $goal $actions $score) $state)
   (let (($alternative (find-alternative-actions $goal $state)))
     (if (is-empty $alternative)
         (plan $goal (Cons (BTAction wait Nil) Nil) 0)  ;; Fallback to wait
         (plan $goal $alternative (estimate-plan-score $alternative $state)))))

;; Find alternative actions for a goal
(: find-alternative-actions (-> Goal WorldState (List BTNode)))
(= (find-alternative-actions $goal $state)
   (Cons (BTAction explore (Cons unknown-area Nil))
   (Cons (BTAction wait Nil)
   Nil)))

;; =============================================================================
;; AIRIS Integration
;; =============================================================================

;; Convert plan to AIRIS action tuple format
(: plan-to-airis-tuple (-> Plan AirisOutput))
(= (plan-to-airis-tuple (plan $goal Nil $score))
   (airis-output wait Nil Nil))  ;; Empty plan defaults to wait
(= (plan-to-airis-tuple (plan $goal (Cons (BTAction $name $params) $tail) $score))
   (let (($hints (extract-plan-hints $goal $score)))
     (airis-output $name $params $hints)))

;; Extract hints from plan for AIRIS
(: extract-plan-hints (-> Goal Number (List Symbol)))
(= (extract-plan-hints (goal $name $p $w) $score)
   (Cons $name (Cons confidence-high Nil)))  ;; Simple hint generation

;; Format single action for AIRIS
(: format-airis-action (-> BTNode AirisAction))
(= (format-airis-action (BTAction $name $params))
   (airis-action $name $params))

;; Create AIRIS output with metadata
(: create-airis-output (-> Plan AirisOutput))
(= (create-airis-output (plan $goal $actions $score))
   (plan-to-airis-tuple (plan $goal $actions $score)))

;; =============================================================================
;; Main Planning Interface
;; =============================================================================

;; Main planning function accepting a prioritized goal
(: plan-for-goal (-> Goal WorldState AirisOutput))
(= (plan-for-goal $goal $state)
   (let* (($initial-plan (generate-plan $goal $state))
          ($feasible (is-plan-feasible $initial-plan $state))
          ($final-plan (if $feasible
                          $initial-plan
                          (repair-plan $initial-plan $state))))
     (create-airis-output $final-plan)))

;; Plan with scoring integration
(: plan-with-scoring (-> Goal WorldState (List AntiGoal) Plan))
(= (plan-with-scoring $goal $state $antigoals)
   (let* (($plan (generate-plan $goal $state))
          ($actions (let ((plan $g $acts $s) $plan) $acts))
          ($penalties (calculate-plan-antigoal-penalties $actions $antigoals))
          ($adjusted-score (* (let ((plan $g $a $s) $plan) $s) $penalties)))
     (plan $goal $actions $adjusted-score)))

;; Calculate anti-goal penalties for a plan
(: calculate-plan-antigoal-penalties (-> (List BTNode) (List AntiGoal) Number))
(= (calculate-plan-antigoal-penalties Nil $antigoals) 1.0)
(= (calculate-plan-antigoal-penalties (Cons $action $tail) $antigoals)
   (* (action-antigoal-factor $action $antigoals)
      (calculate-plan-antigoal-penalties $tail $antigoals)))

;; Calculate anti-goal factor for a single action
(: action-antigoal-factor (-> BTNode (List AntiGoal) Number))
(= (action-antigoal-factor (BTAction $name $params) $antigoals)
   (calculate-action-penalty $name $params $antigoals))

;; Calculate action penalty based on antigoals
(: calculate-action-penalty (-> Symbol (List $a) (List AntiGoal) Number))
(= (calculate-action-penalty $name $params Nil) 1.0)
(= (calculate-action-penalty $name $params (Cons $antigoal $tail))
   (* (single-action-penalty $name $antigoal)
      (calculate-action-penalty $name $params $tail)))

;; Single action penalty computation
(: single-action-penalty (-> Symbol AntiGoal Number))
(= (single-action-penalty attack (anti-goal safety $sev $fn)) 0.5)  ;; High penalty
(= (single-action-penalty teleport (anti-goal energy-efficiency $sev $fn)) 0.4)  ;; High energy cost
(= (single-action-penalty wait (anti-goal $name $sev $fn)) 1.0)  ;; No penalty for wait
(= (single-action-penalty $other $antigoal) 0.9)  ;; Default mild penalty

;; =============================================================================
;; Module Export
;; =============================================================================

;; Export main functions for use by other modules
(: planner-module-exports (-> (List Symbol)))
(= (planner-module-exports)
   (list
     plan-for-goal
     plan-with-scoring
     generate-plan
     is-plan-feasible
     repair-plan
     plan-to-airis-tuple
     create-airis-output))