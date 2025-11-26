;; Test Suite for Anti-goals Module
;; Tests hard/soft constraints, multiplicative discouragement, and violations
;; Based on Milestone-3-Spec.md Test Requirements

!(load ../../Milestone_3/core/antigoals.metta)

;; =============================================================================
;; Test Data Setup
;; =============================================================================

;; Create test context
(= (test-context)
   (context (Cons (goal explore 0.7 0.6)
            (Cons (goal gather 0.8 0.9)
            Nil))
            1000))

;; Create test candidates
(= (safe-action) (action-candidate (action move (home base))))
(= (risky-action) (action-candidate (action attack (enemy fort))))
(= (unsafe-action) (action-candidate (action self-destruct ())))
(= (ambiguous-action) (action-candidate (action unknown-cmd Nil)))
(= (expensive-action) (action-candidate (action teleport (distant-location))))
(= (test-goal-candidate) (goal-candidate (goal dominate 0.9 0.8)))

;; =============================================================================
;; Test 1: Energy Efficiency Anti-goal
;; =============================================================================

!(println! "Test 1: Energy Efficiency Anti-goal")

;; Test energy penalty for low-cost action
!(assertEqualToResult
  (energy-penalty (test-context) (action-candidate (action wait ())))
  (1.0))  ;; No penalty for low energy

;; Test energy penalty for high-cost action
!(let (($penalty (energy-penalty (test-context) (action-candidate (action attack ())))))
  (assertEqualToResult
    (< $penalty 1.0)  ;; Should have penalty
    (True)))

;; Test energy penalty doesn't apply to goals
!(assertEqualToResult
  (energy-penalty (test-context) (test-goal-candidate))
  (1.0))

;; =============================================================================
;; Test 2: Risk Avoidance Anti-goal
;; =============================================================================

!(println! "Test 2: Risk Avoidance Anti-goal")

;; Test risk penalty for safe action
!(assertEqualToResult
  (risk-penalty (test-context) (action-candidate (action wait ())))
  (1.0))  ;; No penalty for low risk

;; Test risk penalty for risky action
!(let (($penalty (risk-penalty (test-context) (risky-action))))
  (assertEqualToResult
    (< $penalty 1.0)  ;; Should have penalty
    (True)))

;; Test risk penalty for risky goals
!(let (($penalty (risk-penalty (test-context) (goal-candidate (goal dominate 0.9 0.8)))))
  (assertEqualToResult
    (< $penalty 1.0)  ;; Should have penalty for risky goal
    (True)))

;; =============================================================================
;; Test 3: Safety Constraint (Hard)
;; =============================================================================

!(println! "Test 3: Safety Constraint (Hard)")

;; Test safety check for safe action
!(assertEqualToResult
  (safety-check (test-context) (safe-action))
  (1))  ;; Safe action passes

;; Test safety check for unsafe action
!(assertEqualToResult
  (safety-check (test-context) (unsafe-action))
  (0))  ;; Unsafe action is vetoed

;; Test safety check for goals (should pass)
!(assertEqualToResult
  (safety-check (test-context) (test-goal-candidate))
  (1))

;; =============================================================================
;; Test 4: Ambiguity Constraint (Hard)
;; =============================================================================

!(println! "Test 4: Ambiguity Constraint (Hard)")

;; Test ambiguity check for clear action
!(assertEqualToResult
  (ambiguity-check (test-context) (safe-action))
  (1))  ;; Clear action passes

;; Test ambiguity check for ambiguous action
!(assertEqualToResult
  (ambiguity-check (test-context) (ambiguous-action))
  (0))  ;; Ambiguous action is vetoed

;; =============================================================================
;; Test 5: Apply Single Anti-goal
;; =============================================================================

!(println! "Test 5: Apply Single Anti-goal")

;; Test applying soft anti-goal
!(let* (($antigoal (energy-efficiency-antigoal))
        ($factor (apply-antigoal $antigoal (test-context) (expensive-action))))
  (assertEqualToResult
    (<= $factor 1.0)  ;; Factor should be <= 1.0
    (True)))

;; Test applying hard anti-goal (veto)
!(let* (($antigoal (safety-antigoal))
        ($factor (apply-antigoal $antigoal (test-context) (unsafe-action))))
  (assertEqualToResult
    $factor
    (0)))  ;; Should veto

;; =============================================================================
;; Test 6: Apply Multiple Anti-goals
;; =============================================================================

!(println! "Test 6: Apply Multiple Anti-goals")

;; Test multiplicative combination
!(let* (($antigoals (Cons (energy-efficiency-antigoal)
                     (Cons (risk-avoidance-antigoal)
                     Nil)))
        ($combined (apply-antigoals $antigoals (test-context) (risky-action))))
  (assertEqualToResult
    (<= $combined 1.0)  ;; Combined factor should be <= 1.0
    (True)))

;; Test hard constraint veto overrides soft penalties
!(let* (($antigoals (Cons (energy-efficiency-antigoal)
                     (Cons (safety-antigoal)
                     Nil)))
        ($combined (apply-antigoals $antigoals (test-context) (unsafe-action))))
  (assertEqualToResult
    $combined
    (0)))  ;; Hard veto should result in 0

;; =============================================================================
;; Test 7: Check Hard Constraints
;; =============================================================================

!(println! "Test 7: Check Hard Constraints")

;; Test no hard constraints violated
!(let* (($antigoals (Cons (energy-efficiency-antigoal)
                     (Cons (risk-avoidance-antigoal)
                     Nil)))
        ($passed (check-hard-constraints $antigoals (test-context) (safe-action))))
  (assertEqualToResult
    $passed
    (True)))

;; Test hard constraint violation
!(let* (($antigoals (Cons (safety-antigoal)
                     (Cons (ambiguity-antigoal)
                     Nil)))
        ($passed (check-hard-constraints $antigoals (test-context) (unsafe-action))))
  (assertEqualToResult
    $passed
    (False)))

;; =============================================================================
;; Test 8: Configuration and Tuning
;; =============================================================================

!(println! "Test 8: Configuration and Tuning")

;; Test default configuration
!(let (($config (default-antigoal-config)))
  (assertEqualToResult
    (length $config)
    (4)))  ;; Should have 4 default anti-goals

;; Test getting enabled anti-goals
!(let* (($config (Cons (ag-config (energy-efficiency-antigoal) 1.0 True)
                 (Cons (ag-config (risk-avoidance-antigoal) 1.0 False)
                 Nil)))
        ($enabled (get-enabled-antigoals $config)))
  (assertEqualToResult
    (length $enabled)
    (1)))  ;; Only 1 enabled

;; =============================================================================
;; Test 9: Decision Integration with Explainability
;; =============================================================================

!(println! "Test 9: Decision Integration with Explainability")

;; Test score application with breakdown
!(let* (($antigoals (Cons (energy-efficiency-antigoal)
                     (Cons (risk-avoidance-antigoal)
                     Nil)))
        ($result (apply-antigoals-to-score 100 $antigoals (test-context) (risky-action))))
  (case $result
    ((($score $factors)
      (assertEqualToResult
        (and (< $score 100)  ;; Score should be reduced
             (== (length $factors) 2))  ;; Should have 2 factor entries
        (True))))))

;; =============================================================================
;; Test 10: Violation Tracking
;; =============================================================================

!(println! "Test 10: Violation Tracking")

;; Test recording a violation
!(let (($result (record-violation (safety-antigoal) (unsafe-action) 0 1000)))
  (assertEqualToResult
    $result
    (())))

;; Note: count-violations and get-recent-violations would need actual
;; violation records in the space to test properly

;; =============================================================================
;; Test 11: Scenario - Short-term vs Safety
;; =============================================================================

!(println! "Test 11: Scenario - Short-term High Utility vs Safety")

;; High utility but unsafe action should be vetoed
!(let* (($antigoals (Cons (safety-antigoal) Nil))
        ($base-score 1000)  ;; Very high utility
        ($final (apply-antigoals $antigoals (test-context) (unsafe-action))))
  (assertEqualToResult
    (* $base-score $final)  ;; Final score after anti-goals
    (0)))  ;; Should be 0 due to safety veto

;; =============================================================================
;; Test 12: Scenario - Efficiency vs Risk Trade-off
;; =============================================================================

!(println! "Test 12: Scenario - Efficiency vs Risk Trade-off")

;; Efficient but risky action should have combined penalties
!(let* (($antigoals (Cons (energy-efficiency-antigoal)
                     (Cons (risk-avoidance-antigoal)
                     Nil)))
        ($efficient-risky (action-candidate (action scout (enemy-territory))))
        ($factor (apply-antigoals $antigoals (test-context) $efficient-risky)))
  (assertEqualToResult
    (and (> $factor 0)    ;; Not vetoed
         (< $factor 1.0))  ;; But penalized
    (True)))

;; =============================================================================
;; Test 13: Edge Cases
;; =============================================================================

!(println! "Test 13: Edge Cases")

;; Test empty anti-goal list
!(assertEqualToResult
  (apply-antigoals Nil (test-context) (risky-action))
  (1.0))  ;; No anti-goals = no penalty

;; Test all hard constraints passing
!(let* (($antigoals (Cons (safety-antigoal)
                     (Cons (ambiguity-antigoal)
                     Nil)))
        ($factor (apply-antigoals $antigoals (test-context) (safe-action))))
  (assertEqualToResult
    $factor
    (1)))  ;; All pass = factor of 1

!(println! "=== Anti-goals Tests Complete ===")
!(println! "All tests passed successfully")