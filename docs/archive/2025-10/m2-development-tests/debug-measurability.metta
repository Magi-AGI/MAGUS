; Debug file to isolate the parameter error
!(include "initial_measurability_calculation.metta")

; Test basic functions one by one
!(println "=== Testing Individual Functions ===")

; Test get-measurability for each goal
!(println "Testing get-measurability:")
!(println (list "Energy:" (get-measurability energy)))
!(println (list "Exploration:" (get-measurability exploration)))
!(println (list "Affinity:" (get-measurability affinity)))

; Test get-all-measurabilities
!(println "Testing get-all-measurabilities:")
!(println (get-all-measurabilities))

; Test calculate-average-measurability
!(println "Testing calculate-average-measurability:")
!(println (calculate-average-measurability))