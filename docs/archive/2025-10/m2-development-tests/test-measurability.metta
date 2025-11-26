; Test file for Measurability calculation functions
; Load the main implementation first

!(include "initial_measurability_calculation.metta")

; Test individual measurability retrieval
!(println "=== Individual Measurability Tests ===")
!(println (list "Energy Measurability:" (get-measurability energy)))
!(println (list "Exploration Measurability:" (get-measurability exploration))) 
!(println (list "Affinity Measurability:" (get-measurability affinity)))

; Test component breakdown
!(println "\n=== Component Breakdown Tests ===")
!(get-measurability-breakdown)

; Test all measurabilities function
!(println "\n=== All Measurabilities Test ===")
!(println (get-all-measurabilities))

; Run comprehensive tests
!(println "\n=== Comprehensive Test Suite ===")
!(run-measurability-tests)