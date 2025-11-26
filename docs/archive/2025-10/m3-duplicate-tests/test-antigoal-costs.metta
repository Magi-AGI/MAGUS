;; Test file for antigoal-costs.metta
;; Validates data-driven energy and risk cost calculations

;; Load the types and cost configuration
!(load ../core/types.metta)
!(load ../core/antigoal-costs.metta)

!(println "=== Anti-goal Cost Configuration Tests ===")
!(println "")

;; =============================================================================
;; Test Energy Cost Calculations
;; =============================================================================

!(println "--- Energy Cost Tests ---")

;; Test 1: Basic energy costs (no parameters)
!(println "Test 1: Basic move action (default distance)")
!(let $cost (calculate-energy-cost move Nil (context Nil 0))
  (println (list "Move cost:" $cost "Expected: ~5-6")))

!(println "Test 2: Attack action (high base cost)")
!(let $cost (calculate-energy-cost attack Nil (context Nil 0))
  (println (list "Attack cost:" $cost "Expected: 20")))

!(println "Test 3: Wait action (low cost)")
!(let $cost (calculate-energy-cost wait Nil (context Nil 0))
  (println (list "Wait cost:" $cost "Expected: 1")))

!(println "Test 4: Rest action (negative = recovery)")
!(let $cost (calculate-energy-cost rest Nil (context Nil 0))
  (println (list "Rest cost:" $cost "Expected: -10")))

!(println "")

;; =============================================================================
;; Test Risk Level Calculations
;; =============================================================================

!(println "--- Risk Level Tests ---")

;; Test 5: Basic risk levels
!(println "Test 5: Move action risk (low)")
!(let $risk (calculate-risk-level move Nil (context Nil 0))
  (println (list "Move risk:" $risk "Expected: ~0.1")))

!(println "Test 6: Attack action risk (high)")
!(let $risk (calculate-risk-level attack Nil (context Nil 0))
  (println (list "Attack risk:" $risk "Expected: ~0.8")))

!(println "Test 7: Self-destruct risk (maximum)")
!(let $risk (calculate-risk-level self-destruct Nil (context Nil 0))
  (println (list "Self-destruct risk:" $risk "Expected: 1.0")))

!(println "")

;; =============================================================================
;; Test Risky Goal Detection
;; =============================================================================

!(println "--- Risky Goal Detection Tests ---")

;; Test 8: Risky goal identification
!(println "Test 8: Check if 'dominate' is risky")
!(let $risky (is-risky-goal-v2 dominate)
  (println (list "Is dominate risky?" $risky "Expected: True")))

!(println "Test 9: Check if 'explore' is risky")
!(let $risky (is-risky-goal-v2 explore)
  (println (list "Is explore risky?" $risky "Expected: False")))

!(println "Test 10: Get risk level for 'conquer'")
!(let $risk (get-goal-risk-level conquer)
  (println (list "Conquer risk level:" $risk "Expected: 0.8")))

!(println "")

;; =============================================================================
;; Test Knowledge Base Retrieval
;; =============================================================================

!(println "--- Knowledge Base Retrieval Tests ---")

;; Test 11: Retrieve base energy cost
!(println "Test 11: Get base energy cost for teleport")
!(let $base (get-base-energy-cost teleport)
  (println (list "Teleport base cost:" $base "Expected: 30")))

;; Test 12: Retrieve base risk level
!(println "Test 12: Get base risk level for explore")
!(let $risk (get-base-risk-level explore)
  (println (list "Explore base risk:" $risk "Expected: 0.3")))

!(println "")

;; =============================================================================
;; Test Configuration Updates
;; =============================================================================

!(println "--- Configuration Update Tests ---")

;; Test 13: Add custom action cost
!(println "Test 13: Add custom 'sprint' action with energy cost 12")
!(set-energy-cost sprint 12 0.5)
!(let $cost (get-base-energy-cost sprint)
  (println (list "Sprint base cost:" $cost "Expected: 12")))

;; Test 14: Mark custom risky goal
!(println "Test 14: Mark 'world-domination' as risky with level 0.95")
!(mark-risky-goal world-domination 0.95)
!(let $risk (get-goal-risk-level world-domination)
  (println (list "World-domination risk:" $risk "Expected: 0.95")))

!(println "")

;; =============================================================================
;; Summary
;; =============================================================================

!(println "=== Test Suite Complete ===")
!(println "Manual validation required - check outputs match expected values")
!(println "Energy costs should reflect base + distance + fatigue")
!(println "Risk levels should reflect base + context danger multipliers")
