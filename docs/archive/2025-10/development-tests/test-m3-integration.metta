; Test M3 Integration with Fixed M2
; This verifies that M3 metagoals can use M2 metrics

!(println "=== M3 Integration Test with Fixed M2 ===")
!(println "")

; Load M2 modules first
!(println "Loading M2 Measurability...")
!(load Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.metta)

!(println "Loading M2 Correlation...")
!(load Milestone_2/goal-fitness-metrics/correlation/initial_correlation_calculation.metta)

!(println "")
!(println "Testing M2 functions directly:")
!(println "Energy measurability:")
!(get-measurability energy)

!(println "Energy-Exploration correlation:")
!(get-correlation energy exploration)

!(println "")
!(println "Now loading M3 metagoals...")
!(load Milestone_3/core/metagoals.metta)

!(println "")
!(println "Testing M3 helper functions:")
!(println "goal-name extraction:")
!(goal-name (goal energy 5 1.0))

!(println "")
!(println "Testing M3 coherence check (uses M2 correlation):")
!(goals-coherent (goal energy 5 1.0) (goal exploration 3 0.8))

!(println "")
!(println "=== M3 Integration Test Complete ===")
