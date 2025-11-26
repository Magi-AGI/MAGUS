;; MAGUS Milestone 4: Ethical Suite Tests
;; Comprehensive tests for ethical scenario framework

!(load ../../ethical/scenarios.metta)
!(load ../../ethical/scenario-runner.metta)
!(load ../../evaluation/benchmarks.metta)
!(load ../../evaluation/ablations.metta)

;; =============================================================================
;; Test 1: Scenario Schema Validation
;; =============================================================================

;; Test scenario registration
!(assertEqual
  (register-scenario
    (scenario
      test-scenario-1
      "Test scenario description"
      (list safety testing)
      medium
      (scenario-context lab normal safe Nil)
      (list (goal test-goal 0.8 1.0))
      (list (hard-antigoal no-harm 0.0))
      (list (metric-boolean no-hard-violations True))
      (list (expected-action wait Nil "Safety first"))
      "Test remediation hint"))
  ())

;; Test scenario retrieval
!(assertEqualToResult
  (scenario-id (get-scenario test-scenario-1))
  (test-scenario-1))

;; Test scenario validation
!(assertEqualToResult
  (validate-scenario (get-scenario test-scenario-1))
  (True))

;; =============================================================================
;; Test 2: Context Management
;; =============================================================================

;; Test context creation and accessors
!(assertEqual
  (let $ctx (scenario-context laboratory normal hostile (list (Tuple resources 100)))
    (scenario-context-location $ctx))
  (laboratory))

!(assertEqual
  (let $ctx (scenario-context laboratory normal hostile (list (Tuple resources 100)))
    (scenario-context-danger-level $ctx))
  (hostile))

;; =============================================================================
;; Test 3: Success Metric Evaluation
;; =============================================================================

;; Test boolean metric evaluation
!(assertEqualToResult
  (eval-metric (metric-boolean no-hard-violations True) True)
  (True))

!(assertEqualToResult
  (eval-metric (metric-boolean no-hard-violations True) False)
  (False))

;; Test comparison metric evaluation
!(assertEqualToResult
  (eval-metric (metric-comparison final-score >= 0.5) 0.8)
  (True))

!(assertEqualToResult
  (eval-metric (metric-comparison final-score >= 0.5) 0.3)
  (False))

;; =============================================================================
;; Test 4: Ethical Logging
;; =============================================================================

;; Test log entry creation
!(assertEqual
  (trace-ethical-step
    test-scenario-logging
    1
    0.85
    (list (Tuple coherence 0.2))
    (list (Tuple minimize-risk 0.3))
    (candidate test-action Nil 0.85 Nil)
    success
    15.0
    "Test log entry")
  ())

;; Test log retrieval
!(assertNotEqual
  (get-scenario-log test-scenario-logging)
  (Nil))

;; Test log clearing
!(assertEqual
  (clear-scenario-log test-scenario-logging)
  ())

;; =============================================================================
;; Test 5: Metric Collection
;; =============================================================================

;; Test metric collection
!(assertEqual
  (collect-metric hard-violation-count test-metrics-1 0.0)
  ())

!(assertEqual
  (collect-metric goal-satisfaction-after test-metrics-1 0.85)
  ())

;; Test metric retrieval
!(assertEqualToResult
  (get-metric test-metrics-1 goal-satisfaction-after)
  (0.85))

;; =============================================================================
;; Test 6: Ablation Configuration
;; =============================================================================

;; Test ablation flag setting
!(assertEqual
  (set-ablation metagoals-enabled False)
  ())

!(assertEqualToResult
  (get-ablation metagoals-enabled)
  (False))

;; Test ablation reset
!(assertEqual
  (reset-ablations)
  ())

!(assertEqualToResult
  (get-ablation metagoals-enabled)
  (True))

;; Test predefined configurations
!(assertEqual
  (configure-baseline)
  ())

!(assertEqualToResult
  (get-ablation metagoals-enabled)
  (False))

!(assertEqualToResult
  (get-ablation antigoals-enabled)
  (False))

;; Reset to full system
!(assertEqual
  (configure-full)
  ())

;; =============================================================================
;; Test 7: Scenario Query Functions
;; =============================================================================

;; Test scenario listing
!(assertNotEqual
  (list-scenarios)
  (Nil))

;; Test tag-based filtering
!(assertEqual
  (register-scenario
    (scenario
      safety-test
      "Safety tag test"
      (list safety)
      high
      (scenario-context lab normal safe Nil)
      (list (goal test-goal 0.8 1.0))
      Nil
      (list (metric-boolean no-hard-violations True))
      Nil
      "Test"))
  ())

!(assertNotEqual
  (get-scenarios-by-tag safety)
  (Nil))

;; Test risk-based filtering
!(assertNotEqual
  (get-scenarios-by-risk high)
  (Nil))

;; =============================================================================
;; Test 8: Helper Functions
;; =============================================================================

;; Test contains function
!(assertEqualToResult
  (contains (list a b c) b)
  (True))

!(assertEqualToResult
  (contains (list a b c) d)
  (False))

;; Test statistical helpers
!(assertEqualToResult
  (mean (list 1.0 2.0 3.0 4.0 5.0))
  (3.0))

!(assertEqualToResult
  (sum (list 1.0 2.0 3.0))
  (6.0))

!(assertEqualToResult
  (abs -5.0)
  (5.0))

!(assertEqualToResult
  (abs 5.0)
  (5.0))

;; =============================================================================
;; Test Summary
;; =============================================================================

!(println "")
!(println "====================================================================")
!(println "  M4 ETHICAL SUITE TESTS COMPLETE")
!(println "====================================================================")
!(println "Tests executed:")
!(println "  1. Scenario schema validation")
!(println "  2. Context management")
!(println "  3. Success metric evaluation")
!(println "  4. Ethical logging pipeline")
!(println "  5. Metric collection")
!(println "  6. Ablation configuration")
!(println "  7. Scenario query functions")
!(println "  8. Helper functions")
!(println "====================================================================")
