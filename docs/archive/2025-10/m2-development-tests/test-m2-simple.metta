;; Simple M2 Measurability Test - Actually Runnable
;; Tests the core calculations without complex let bindings

;; Load measurability module
!(import! &self ../Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.metta)

;; Test 1: Get measurability for energy
!(println "Test 1: Energy Measurability")
!(get-measurability energy)

;; Test 2: Get measurability for exploration
!(println "Test 2: Exploration Measurability")
!(get-measurability exploration)

;; Test 3: Get measurability for affinity
!(println "Test 3: Affinity Measurability")
!(get-measurability affinity)

;; Test 4: Calculate average
!(println "Test 4: Average Measurability")
!(calculate-average-measurability)

!(println "Tests Complete")
