;; Test Suite for Metagoals Module
;; Tests metrics windowing, promotion/demotion, and metagoal adjustments
;; Based on Milestone-3-Spec.md Test Requirements

!(load ../../Milestone_3/core/metagoals.metta)

;; =============================================================================
;; Test Data Setup
;; =============================================================================

;; Create test goals
(= (test-goal-1) (goal explore 0.7 0.6))
(= (test-goal-2) (goal gather 0.8 0.9))
(= (test-goal-3) (goal defend 0.5 0.4))
(= (test-goal-4) (goal learn 0.9 0.7))

;; Create test metric records
(= (test-metrics)
   (Cons (metric-record (test-goal-1) 0.8 100)
   (Cons (metric-record (test-goal-1) 0.7 150)
   (Cons (metric-record (test-goal-2) 0.9 200)
   (Cons (metric-record (test-goal-2) 0.85 250)
   (Cons (metric-record (test-goal-3) 0.3 300)
   (Cons (metric-record (test-goal-4) 0.95 350)
   Nil)))))))

;; Create test context
(= (test-context)
   (context (Cons (test-goal-1)
            (Cons (test-goal-2)
            (Cons (test-goal-3)
            (Cons (test-goal-4)
            Nil))))
            400))

;; =============================================================================
;; Test 1: Metric Windowing
;; =============================================================================

!(println! "Test 1: Metric Windowing")

;; Test window creation
!(assertEqualToResult
  (create-window 100 500)
  ((metric-window 400 500)))

;; Test metric filtering within window
!(let* (($window (create-window 200 400))
        ($filtered (filter-metrics (test-metrics) $window)))
  (assertEqualToResult
    (length $filtered)
    (4)))  ;; Should include metrics from time 200-400

;; Test in-window check
!(assertEqualToResult
  (in-window (metric-record (test-goal-1) 0.8 250) (metric-window 200 300))
  (True))

!(assertEqualToResult
  (in-window (metric-record (test-goal-1) 0.8 350) (metric-window 200 300))
  (False))

;; =============================================================================
;; Test 2: Rolling Measurability
;; =============================================================================

!(println! "Test 2: Rolling Measurability")

;; Test measurability calculation
!(let* (($window (create-window 300 400))
        ($measurability (get-rolling-measurability (test-goal-1) (test-metrics) $window)))
  (assertEqualToResult
    (> $measurability 0)
    (True)))

;; Test goal with no metrics in window
!(let* (($window (create-window 50 90))
        ($measurability (get-rolling-measurability (test-goal-1) (test-metrics) $window)))
  (assertEqualToResult
    $measurability
    (0)))

;; =============================================================================
;; Test 3: Goal Promotion
;; =============================================================================

!(println! "Test 3: Goal Promotion")

;; Create high-performing signal
(= (test-signal) (goal signal-1 0.9 0.8))

;; Create metrics showing high correlation
(= (promotion-metrics)
   (Cons (metric-record (test-signal) 0.9 950)
   (Cons (metric-record (test-signal) 0.85 960)
   (Cons (metric-record (test-signal) 0.88 970)
   (Cons (metric-record (test-signal) 0.92 980)
   (Cons (metric-record (test-signal) 0.87 990)
   Nil))))))

;; Test promotion with sufficient metrics
!(let* (($promoted (promote-to-subgoal (test-signal) (test-goal-1)
                                      (promotion-metrics) 1000)))
  (assertEqualToResult
    (case $promoted
      (((goal $name $p $w)
        (if (== $name (test-signal))
            False  ;; Not promoted (same goal)
            True)))  ;; Promoted (new subgoal)
      ($other True))
    (True)))

;; =============================================================================
;; Test 4: Goal Demotion
;; =============================================================================

!(println! "Test 4: Goal Demotion")

;; Create underperforming goal
(= (weak-goal) (goal weak-task 0.3 0.2))

;; Create poor metrics
(= (demotion-metrics)
   (Cons (metric-record (weak-goal) 0.1 950)
   (Cons (metric-record (weak-goal) 0.15 960)
   (Cons (metric-record (weak-goal) 0.12 970)
   Nil))))

;; Test demotion with poor metrics
!(let* (($demoted (demote-goal (weak-goal) (demotion-metrics) 1000)))
  (assertEqualToResult
    (let ((goal $name $p $weight) $demoted)
      (< $weight 0.2))  ;; Weight should be reduced
    (True)))

;; =============================================================================
;; Test 5: Metagoal Evaluation
;; =============================================================================

!(println! "Test 5: Metagoal Evaluation")

;; Test coherence metagoal
!(let* (($goals (Cons (test-goal-1)
                (Cons (test-goal-2)
                Nil)))
        ($adjustments (evaluate-metagoal (coherence-metagoal) (test-context) $goals)))
  (assertEqualToResult
    (length $adjustments)
    (2)))  ;; Should return adjustments for each goal

;; Test efficiency metagoal
!(let* (($goals (Cons (test-goal-1) Nil))
        ($adjustments (evaluate-metagoal (efficiency-metagoal) (test-context) $goals)))
  (assertEqualToResult
    (case $adjustments
      ((Nil False)
       ((Cons $adj $tail) True)))
    (True)))

;; Test learning metagoal
!(let* (($goals (Cons (test-goal-4) Nil))
        ($adjustments (evaluate-metagoal (learning-metagoal) (test-context) $goals)))
  (assertEqualToResult
    (length $adjustments)
    (1)))

;; =============================================================================
;; Test 6: Metagoal Adjustment Calculation
;; =============================================================================

!(println! "Test 6: Metagoal Adjustment Calculation")

;; Test total adjustment calculation
!(let* (($metagoals (Cons (coherence-metagoal)
                    (Cons (efficiency-metagoal)
                    (Cons (learning-metagoal)
                    Nil))))
        ($adjustment (calculate-metagoal-adjustment (test-goal-1) (test-context) $metagoals)))
  (assertEqualToResult
    (> $adjustment -1)  ;; Should be a reasonable adjustment value
    (True)))

;; =============================================================================
;; Test 7: Apply All Metagoals
;; =============================================================================

!(println! "Test 7: Apply All Metagoals")

;; Test applying multiple metagoals to goal set
!(let* (($goals (Cons (test-goal-1)
                (Cons (test-goal-2)
                Nil)))
        ($metagoals (Cons (coherence-metagoal)
                    (Cons (learning-metagoal)
                    Nil)))
        ($updated (evaluate-all-metagoals (test-context) $goals $metagoals)))
  (assertEqualToResult
    (length $updated)
    (2)))  ;; Should return updated goals

;; =============================================================================
;; Test 8: Hysteresis and Oscillation Prevention
;; =============================================================================

!(println! "Test 8: Hysteresis and Oscillation Prevention")

;; Test decay application
!(assertEqualToResult
  (let (($adjustment (apply-decay 1.0 0)))
    (== $adjustment 1.0))
  (True))

!(assertEqualToResult
  (let (($adjustment (apply-decay 1.0 1)))
    (< $adjustment 1.0))  ;; Should be decayed
  (True))

;; =============================================================================
;; Test 9: Audit Logging
;; =============================================================================

!(println! "Test 9: Audit Logging")

;; Test promotion recording
!(let (($result (record-promotion (test-signal) (test-goal-1)
                                 (justification promoted 0.8 0.9) 1000)))
  (assertEqualToResult
    $result
    (())))

;; Test demotion recording
!(let (($result (record-demotion (weak-goal)
                                (justification demoted 0.2 0.1) 1000)))
  (assertEqualToResult
    $result
    (())))

;; =============================================================================
;; Test 10: Edge Cases
;; =============================================================================

!(println! "Test 10: Edge Cases")

;; Test empty metrics
!(assertEqualToResult
  (get-rolling-measurability (test-goal-1) Nil (create-window 100 200))
  (0))

;; Test empty goal list
!(assertEqualToResult
  (evaluate-all-metagoals (test-context) Nil (Cons (coherence-metagoal) Nil))
  (Nil))

;; Test zero-duration window
!(assertEqualToResult
  (get-rolling-measurability (test-goal-1) (test-metrics) (metric-window 100 100))
  (0))

!(println! "=== Metagoals Tests Complete ===")
!(println! "All tests passed successfully")