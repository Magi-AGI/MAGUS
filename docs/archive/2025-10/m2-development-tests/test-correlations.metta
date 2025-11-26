; Test file for MIC correlation functions
; Load the main implementation first

!(load initial_correlation_calculation.metta)

; Test individual correlation retrieval
!(println "=== Individual Correlation Tests ===")
!(println (list "Energy-Exploration:" (get-correlation energy exploration)))
!(println (list "Energy-Affinity:" (get-correlation energy affinity))) 
!(println (list "Exploration-Affinity:" (get-correlation exploration affinity)))

; Test all correlations function
!(println "\n=== All Correlations Test ===")
!(println (get-all-correlations))

; Test total score calculation
!(println "\n=== Total Score Test ===")
!(println (list "Total Score:" (calculate-total-score)))

; Verify calculations
!(println "\n=== Manual Verification ===")
!(println (list "Expected total:" (/ (+ (+ 0.7 0.5) 0.3) 3)))