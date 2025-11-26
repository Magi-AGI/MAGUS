; Test M2 Fixed Measurability and Correlation
; This tests the equality-based dispatch fixes

!(println "=== Testing M2 Fixed Measurability ===")

; Load measurability module
!(import! &self Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.metta)

; Test individual measurabilities
!(println "Test 1: Energy Measurability (should be 0.72)")
!(get-measurability energy)

!(println "Test 2: Exploration Measurability (should be 0.56)")
!(get-measurability exploration)

!(println "Test 3: Affinity Measurability (should be 0.20)")
!(get-measurability affinity)

!(println "Test 4: Average Measurability (should be ~0.493)")
!(calculate-average-measurability)

!(println "")
!(println "=== Testing M2 Fixed Correlation ===")

; Load correlation module
!(import! &self Milestone_2/goal-fitness-metrics/correlation/initial_correlation_calculation.metta)

!(println "Test 5: Energy-Exploration Correlation (should be 0.70)")
!(get-correlation energy exploration)

!(println "Test 6: Energy-Affinity Correlation (should be 0.50)")
!(get-correlation energy affinity)

!(println "Test 7: Exploration-Affinity Correlation (should be 0.30)")
!(get-correlation exploration affinity)

!(println "Test 8: Total Correlation Score (should be 0.50)")
!(calculate-total-score)

!(println "")
!(println "=== M2 Fixed Tests Complete ===")
