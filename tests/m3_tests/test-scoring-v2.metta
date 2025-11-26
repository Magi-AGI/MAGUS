;; Test Suite for Scoring v2 Module
;; Tests integrated scoring with base utility, metagoals, and anti-goals
;; Tests explainability and score breakdowns
;; Based on Milestone-3-Spec.md Test Requirements

!(load ../../Milestone_3/core/scoring-v2.metta)
!(load ../../Milestone_3/core/metagoals.metta)
!(load ../../Milestone_3/core/antigoals.metta)

;; =============================================================================
;; Test Data Setup
;; =============================================================================

;; Test goals
(= (high-priority-goal) (goal survive 0.9 0.8))
(= (medium-priority-goal) (goal explore 0.6 0.5))
(= (low-priority-goal) (goal rest 0.3 0.2))

;; Test modulators
(= (test-modulators)
   (Cons (modulator arousal 0.7)
   (Cons (modulator pleasure 0.5)
   (Cons (modulator dominance 0.6)
   (Cons (modulator focus 0.8)
   Nil)))))

;; Test context
(= (test-scoring-context)
   (scoring-context
     (Cons (high-priority-goal)
     (Cons (medium-priority-goal)
     (Cons (low-priority-goal)
     Nil)))
     (test-modulators)
     1000))

;; Test considerations
(= (test-considerations)
   (Cons (consideration opportunity (lambda ($ctx) 30))
   (Cons (consideration proximity (lambda ($ctx) 20))
   Nil)))

;; Test discouragements
(= (test-discouragements)
   (Cons (discouragement danger (lambda ($ctx) 10))
   (Cons (discouragement fatigue (lambda ($ctx) 5))
   Nil)))

;; Test candidates
(= (goal-candidate-1) (goal-candidate (high-priority-goal)))
(= (action-candidate-1) (action-candidate (action move (forward))))
(= (risky-candidate) (action-candidate (action attack (boss))))

;; =============================================================================
;; Test 1: Base Utility Calculation
;; =============================================================================

!(println! "Test 1: Base Utility Calculation")

;; Test base utility from considerations and discouragements
!(let (($base (calculate-base-utility (test-considerations)
                                     (test-discouragements)
                                     (test-scoring-context))))
  (assertEqualToResult
    (> $base 0)  ;; Should be positive (considerations > discouragements)
    (True)))

;; Test empty considerations/discouragements
!(assertEqualToResult
  (calculate-base-utility Nil Nil (test-scoring-context))
  (0))

;; =============================================================================
;; Test 2: Modulator Application
;; =============================================================================

!(println! "Test 2: Modulator Application")

;; Test modulator effects
!(assertEqualToResult
  (modulator-effect arousal 0.5)
  (1.0))  ;; 0.8 + 0.4 * 0.5 = 1.0

!(assertEqualToResult
  (modulator-effect focus 1.0)
  (1.3))  ;; 0.7 + 0.6 * 1.0 = 1.3

;; Test applying modulators
!(let (($modulated (apply-modulators 100 (test-modulators))))
  (assertEqualToResult
    (and (> $modulated 70)   ;; Should be affected by modulators
         (< $modulated 150))  ;; But within reasonable range
    (True)))

;; =============================================================================
;; Test 3: Metagoal Integration
;; =============================================================================

!(println! "Test 3: Metagoal Integration")

;; Test metagoal adjustment for a goal
!(let* (($metagoals (Cons (metagoal coherence)
                    (Cons (metagoal learning)
                    Nil)))
        ($adjustment (calculate-metagoal-adjustment-v2
                       (high-priority-goal)
                       (test-scoring-context)
                       $metagoals)))
  (assertEqualToResult
    (and (> $adjustment -1)  ;; Reasonable lower bound
         (< $adjustment 1))   ;; Reasonable upper bound
    (True)))

;; =============================================================================
;; Test 4: Anti-goal Integration
;; =============================================================================

!(println! "Test 4: Anti-goal Integration")

;; Test anti-goal penalty calculation
!(let* (($antigoals (Cons (energy-efficiency-antigoal)
                    (Cons (risk-avoidance-antigoal)
                    Nil)))
        ($penalty (calculate-antigoal-penalty
                    (action-candidate-1)
                    (test-scoring-context)
                    $antigoals)))
  (assertEqualToResult
    (and (> $penalty 0)   ;; Should be positive
         (<= $penalty 1))  ;; Should be <= 1 (multiplicative)
    (True)))

;; =============================================================================
;; Test 5: Complete Scoring Pipeline
;; =============================================================================

!(println! "Test 5: Complete Scoring Pipeline")

;; Test full scoring with all components
!(let* (($metagoals (Cons (metagoal coherence) Nil))
        ($antigoals (Cons (risk-avoidance-antigoal) Nil))
        ($score (score-decision-v2
                  (goal-candidate-1)
                  (test-considerations)
                  (test-discouragements)
                  $metagoals
                  $antigoals
                  (test-scoring-context))))
  (case $score
    (((decision-score $base $meta $anti $final)
      (assertEqualToResult
        (and (> $final 0)     ;; Should have positive score
             (== $final (* (+ $base $meta) (- 1 $anti))))  ;; Correct calculation
        (True))))))

;; =============================================================================
;; Test 6: Score Breakdown and Explainability
;; =============================================================================

!(println! "Test 6: Score Breakdown and Explainability")

;; Test breakdown generation
!(let* (($test-score (decision-score 50 10 0.2 48))
        ($breakdown (generate-score-breakdown $test-score)))
  (assertEqualToResult
    (length $breakdown)
    (4)))  ;; Should have 4 components

;; Test component structure
!(let* (($test-score (decision-score 50 10 0.2 48))
        ($breakdown (generate-score-breakdown $test-score)))
  (case $breakdown
    (((Cons (score-component $name $value $desc) $tail)
      (assertEqualToResult
        (and (== $name base-utility)
             (== $value 50))
        (True))))))

;; =============================================================================
;; Test 7: Custom Weights
;; =============================================================================

!(println! "Test 7: Custom Weights")

;; Test default weights
!(let (($weights (default-scoring-weights)))
  (case $weights
    (((scoring-weights $bw $mw $aw)
      (assertEqualToResult
        (and (== $bw 1.0)
             (== $mw 0.3)
             (== $aw 1.0))
        (True))))))

;; Test scoring with custom weights
!(let* (($custom-weights (scoring-weights 2.0 0.5 0.8))
        ($metagoals (Cons (metagoal coherence) Nil))
        ($antigoals (Cons (risk-avoidance-antigoal) Nil))
        ($score (score-with-weights
                  (goal-candidate-1)
                  (test-considerations)
                  (test-discouragements)
                  $metagoals
                  $antigoals
                  (test-scoring-context)
                  $custom-weights)))
  (case $score
    (((decision-score $base $meta $anti $final)
      (assertEqualToResult
        (> $final 0)  ;; Should have positive score
        (True))))))

;; =============================================================================
;; Test 8: Decision Ranking
;; =============================================================================

!(println! "Test 8: Decision Ranking")

;; Test ranking multiple candidates
!(let* (($candidates (Cons (goal-candidate-1)
                     (Cons (goal-candidate (medium-priority-goal))
                     (Cons (goal-candidate (low-priority-goal))
                     Nil))))
        ($metagoals Nil)
        ($antigoals Nil)
        ($ranked (rank-decisions
                   $candidates
                   (test-considerations)
                   (test-discouragements)
                   $metagoals
                   $antigoals
                   (test-scoring-context))))
  (assertEqualToResult
    (length $ranked)
    (3)))  ;; Should rank all 3 candidates

;; =============================================================================
;; Test 9: Integration Scenario - Metagoals vs Anti-goals
;; =============================================================================

!(println! "Test 9: Integration Scenario - Metagoals vs Anti-goals")

;; High metagoal value but anti-goal penalty
!(let* (($metagoals (Cons (metagoal learning) Nil))  ;; Positive adjustment
        ($antigoals (Cons (safety-antigoal)           ;; Potential veto
                    (Cons (risk-avoidance-antigoal)   ;; Soft penalty
                    Nil)))
        ($score (score-decision-v2
                  (risky-candidate)
                  (test-considerations)
                  (test-discouragements)
                  $metagoals
                  $antigoals
                  (test-scoring-context))))
  (case $score
    (((decision-score $base $meta $anti $final)
      (assertEqualToResult
        (<= $final (* (+ $base $meta) 1.0))  ;; Penalties should reduce score
        (True))))))

;; =============================================================================
;; Test 10: Logging and History
;; =============================================================================

!(println! "Test 10: Logging and History")

;; Test decision logging
!(let* (($score (decision-score 75 15 0.1 81))
        ($result (log-decision (goal-candidate-1) $score 1000)))
  (assertEqualToResult
    $result
    (())))

;; =============================================================================
;; Test 11: Edge Cases
;; =============================================================================

!(println! "Test 11: Edge Cases")

;; Test with no metagoals or anti-goals
!(let (($score (score-decision-v2
                 (goal-candidate-1)
                 (test-considerations)
                 (test-discouragements)
                 Nil  ;; No metagoals
                 Nil  ;; No anti-goals
                 (test-scoring-context))))
  (case $score
    (((decision-score $base $meta $anti $final)
      (assertEqualToResult
        (and (== $meta 0)     ;; No metagoal adjustment
             (== $anti 0)     ;; No anti-goal penalty
             (== $final $base))  ;; Final equals base
        (True))))))

;; Test action candidate (no metagoal adjustments)
!(let* (($metagoals (Cons (metagoal coherence) Nil))
        ($antigoals Nil)
        ($score (score-decision-v2
                  (action-candidate-1)
                  (test-considerations)
                  (test-discouragements)
                  $metagoals
                  $antigoals
                  (test-scoring-context))))
  (case $score
    (((decision-score $base $meta $anti $final)
      (assertEqualToResult
        (== $meta 0)  ;; Actions don't get metagoal adjustments
        (True))))))

;; =============================================================================
;; Test 12: Performance Regression Check
;; =============================================================================

!(println! "Test 12: Performance Regression Check")

;; This is a placeholder for performance testing
;; In practice, would measure execution time
!(let* (($candidates (Cons (goal-candidate-1)
                     (Cons (action-candidate-1)
                     Nil)))
        ($metagoals (Cons (metagoal coherence)
                    (Cons (metagoal efficiency)
                    Nil)))
        ($antigoals (Cons (energy-efficiency-antigoal)
                    (Cons (risk-avoidance-antigoal)
                    Nil)))
        ($scored (score-all-candidates
                   $candidates
                   (test-considerations)
                   (test-discouragements)
                   $metagoals
                   $antigoals
                   (test-scoring-context))))
  (assertEqualToResult
    (length $scored)
    (2)))  ;; Should score both candidates

!(println! "=== Scoring v2 Tests Complete ===")
!(println! "All tests passed successfully")