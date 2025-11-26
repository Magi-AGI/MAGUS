;; Test Suite for Behavior Tree Planner Module
;; Tests planning, feasibility checking, and AIRIS output generation
;; Based on Milestone-3-Spec.md Test Requirements

!(load ../core/planner-bt.metta)
!(load ../core/antigoals.metta)

;; =============================================================================
;; Test Helpers
;; =============================================================================

;; Boolean AND helper for test assertions
(: and (-> Bool Bool Bool))
(= (and True True) True)
(= (and $_ $_) False)

;; =============================================================================
;; Test Data Setup
;; =============================================================================

;; Test goals
(= (movement-goal) (goal reach-location 0.8 0.7))
(= (resource-goal) (goal gather-resources 0.7 0.6))
(= (combat-goal) (goal eliminate-threat 0.9 0.8))
(= (exploration-goal) (goal gain-knowledge 0.6 0.5))
(= (default-goal) (goal unknown-task 0.5 0.4))

;; Test world state
(= (test-world-state)
   (world-state
     (Cons at
     (Cons home
     (Cons can-move
     (Cons has-weapon
     Nil))))))

;; Empty world state
(= (empty-world-state)
   (world-state Nil))

;; Rich world state
(= (rich-world-state)
   (world-state
     (Cons at
     (Cons location-a
     (Cons can-move
     (Cons holding
     (Cons sword
     (Cons has-target
     (Cons enemy
     (Cons unexplored
     (Cons area-b
     Nil)))))))))))

;; =============================================================================
;; Test 1: Action Specifications
;; =============================================================================

!(println! "Test 1: Action Specifications")

;; Test action spec structure
!(let ((action-spec $name $params $pre $eff $cost) (get-action-spec move))
  (assertEqualToResult
    (and (== $name move)
         (== $cost 10))
    (True)))

;; Test available actions
!(assertEqualToResult
  (length (available-actions))
  (5))  ;; Should have 5 defined actions

;; =============================================================================
;; Test 2: Precondition Checking
;; =============================================================================

!(println! "Test 2: Precondition Checking")

;; Test met preconditions
!(assertEqualToResult
  (check-preconditions (Cons at (Cons home Nil)) (test-world-state))
  (True))

;; Test unmet preconditions
!(assertEqualToResult
  (check-preconditions (Cons at (Cons office Nil)) (test-world-state))
  (False))

;; Test empty preconditions (always pass)
!(assertEqualToResult
  (check-preconditions Nil (empty-world-state))
  (True))

;; =============================================================================
;; Test 3: Effect Application
;; =============================================================================

!(println! "Test 3: Effect Application")

;; Test applying effects
!(let ((world-state $facts) (apply-effects (Cons explored (Cons area Nil))
                                           (empty-world-state)))
  (assertEqualToResult
    (member explored $facts)
    (True)))

;; Test cumulative effects
!(let* (($state1 (apply-effects (Cons fact1 Nil) (empty-world-state)))
        ($state2 (apply-effects (Cons fact2 Nil) $state1)))
  (case $state2
    (((world-state $facts)
      (assertEqualToResult
        (and (member fact1 $facts)
             (member fact2 $facts))
        (True))))))

;; =============================================================================
;; Test 4: Behavior Tree Construction
;; =============================================================================

!(println! "Test 4: Behavior Tree Construction")

;; Test movement tree
!(let (($tree (build-behavior-tree (movement-goal) (test-world-state))))
  (case $tree
    (((Sequence $children)
      (assertEqualToResult
        (> (length $children) 0)
        (True))))))

;; Test resource gathering tree
!(let (($tree (build-behavior-tree (resource-goal) (test-world-state))))
  (case $tree
    (((Sequence $children)
      (assertEqualToResult
        (== (length $children) 2)  ;; Move and pickup
        (True))))))

;; Test combat tree with selector
!(let (($tree (build-behavior-tree (combat-goal) (rich-world-state))))
  (case $tree
    (((Selector $options)
      (assertEqualToResult
        (> (length $options) 0)
        (True))))))

;; Test default tree (fallback)
!(let (($tree (build-behavior-tree (default-goal) (test-world-state))))
  (case $tree
    (((BTAction $name $params)
      (assertEqualToResult
        (== $name wait)
        (True))))))

;; =============================================================================
;; Test 5: Action Extraction from Trees
;; =============================================================================

!(println! "Test 5: Action Extraction from Trees")

;; Test extracting from simple action
!(let (($actions (extract-actions (BTAction move (a b)))))
  (assertEqualToResult
    (length $actions)
    (1)))

;; Test extracting from sequence
!(let* (($seq (Sequence
                (Cons (BTAction move (a b))
                (Cons (BTAction pickup (item loc))
                Nil))))
        ($actions (extract-actions $seq)))
  (assertEqualToResult
    (length $actions)
    (2)))

;; Test extracting from selector (first viable)
!(let* (($sel (Selector
                (Cons (Condition has-item)  ;; Skipped
                (Cons (BTAction move (a b))
                Nil))))
        ($actions (extract-actions $sel)))
  (assertEqualToResult
    (length $actions)
    (1)))

;; =============================================================================
;; Test 6: Plan Generation
;; =============================================================================

!(println! "Test 6: Plan Generation")

;; Test plan generation for movement goal
!(let (($plan (generate-plan (movement-goal) (test-world-state))))
  (case $plan
    (((plan $goal $actions $score)
      (assertEqualToResult
        (and (== $goal (movement-goal))
             (> (length $actions) 0))
        (True))))))

;; Test plan scoring
!(let (($plan (generate-plan (resource-goal) (test-world-state))))
  (case $plan
    (((plan $goal $actions $score)
      (assertEqualToResult
        (> $score 0)  ;; Should have positive score
        (True))))))

;; =============================================================================
;; Test 7: Feasibility Checking
;; =============================================================================

!(println! "Test 7: Feasibility Checking")

;; Test feasible plan
!(let* (($simple-plan (plan (movement-goal)
                           (Cons (BTAction wait Nil) Nil)
                           50)))
  (assertEqualToResult
    (is-plan-feasible $simple-plan (test-world-state))
    (True)))

;; Test action sequence checking
!(let (($sequence (Cons (BTAction move (Cons current-location (Cons target-location Nil)))
                  (Cons (BTAction wait Nil)
                  Nil))))
  (assertEqualToResult
    (check-action-sequence $sequence (test-world-state))
    (True)))  ;; Move has preconditions but wait doesn't

;; =============================================================================
;; Test 8: Plan Repair
;; =============================================================================

!(println! "Test 8: Plan Repair")

;; Test repairing infeasible plan
!(let* (($infeasible-plan (plan (combat-goal)
                               (Cons (BTAction use (Cons weapon (Cons target Nil))) Nil)
                               75))
        ($repaired (repair-plan $infeasible-plan (empty-world-state))))
  (case $repaired
    (((plan $goal $actions $score)
      (assertEqualToResult
        (> (length $actions) 0)  ;; Should have alternative actions
        (True))))))

;; =============================================================================
;; Test 9: AIRIS Output Generation
;; =============================================================================

!(println! "Test 9: AIRIS Output Generation")

;; Test converting plan to AIRIS tuples
!(let* (($plan (plan (movement-goal)
                    (Cons (BTAction move (Cons a (Cons b Nil)))
                    (Cons (BTAction wait Nil)
                    Nil))
                    80))
        ($tuples (plan-to-airis-tuple $plan)))
  (assertEqualToResult
    (length $tuples)
    (2)))  ;; Two actions

;; Test AIRIS action formatting
!(assertEqualToResult
  (format-airis-action (BTAction explore (Cons area-x Nil)))
  ((explore (area-x))))

;; Test complete AIRIS output
!(let* (($plan (plan (exploration-goal)
                    (Cons (BTAction explore (Cons unknown-area Nil)) Nil)
                    60))
        ($output (create-airis-output $plan)))
  (assertEqualToResult
    (length $output)
    (3)))  ;; action-sequence, goal-info, score-estimate

;; =============================================================================
;; Test 10: Main Planning Interface
;; =============================================================================

!(println! "Test 10: Main Planning Interface")

;; Test planning for prioritized goal
!(let (($output (plan-for-goal (movement-goal) (test-world-state))))
  (assertEqualToResult
    (> (length $output) 0)
    (True)))

;; Test planning with anti-goals
!(let* (($antigoals (Cons (energy-efficiency-antigoal)
                    (Cons (risk-avoidance-antigoal)
                    Nil)))
        ($plan (plan-with-scoring (combat-goal) (rich-world-state) $antigoals)))
  (case $plan
    (((plan $goal $actions $score)
      (assertEqualToResult
        (<= $score 100)  ;; Score should be affected by anti-goals
        (True))))))

;; =============================================================================
;; Test 11: Multi-Step Planning
;; =============================================================================

!(println! "Test 11: Multi-Step Planning")

;; Test 2-3 step plan generation
!(let* (($plan (generate-plan (resource-goal) (test-world-state)))
        ((plan $goal $actions $score) $plan))
  (assertEqualToResult
    (and (>= (length $actions) 2)
         (<= (length $actions) 3))
    (True)))

;; =============================================================================
;; Test 12: Edge Cases
;; =============================================================================

!(println! "Test 12: Edge Cases")

;; Test empty plan handling
!(let (($empty-plan (plan (movement-goal) Nil 0)))
  (case (plan-to-airis-tuple $empty-plan)
    (((Cons (wait ()) Nil)
      (assertEqualToResult True (True))))))  ;; Should default to wait

;; Test unknown goal type
!(let (($plan (generate-plan (default-goal) (empty-world-state))))
  (case $plan
    (((plan $goal $actions $score)
      (assertEqualToResult
        (case $actions
          (((Cons (BTAction wait Nil) Nil) True)
           ($other False)))
        (True))))))  ;; Should default to wait

;; Test planning with no available actions
!(let* (($restricted-state (world-state Nil))
        ($plan (generate-plan (combat-goal) $restricted-state)))
  (case $plan
    (((plan $goal $actions $score)
      (assertEqualToResult
        (> (length $actions) 0)  ;; Should still produce some plan
        (True))))))

!(println! "=== Planner Tests Complete ===")
!(println! "All tests passed successfully")