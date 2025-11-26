; Manual test of loaded measurability system

; First load the system (without automatic tests)
; Create knowledge base for storing measurability data and components
!(bind! &measurability-kb (new-space))

; Load the data
!(assert-into-space &measurability-kb (measurement-confidence energy 0.8))
!(assert-into-space &measurability-kb (measurement-confidence exploration 0.7))
!(assert-into-space &measurability-kb (measurement-confidence affinity 0.5))
!(assert-into-space &measurability-kb (metric-clarity energy 0.9))
!(assert-into-space &measurability-kb (metric-clarity exploration 0.8))
!(assert-into-space &measurability-kb (metric-clarity affinity 0.4))

; Define core functions
(= (calculate-measurability $goal)
   (let $confidence (cond ((== $goal energy) 0.8) ((== $goal exploration) 0.7) ((== $goal affinity) 0.5) (otherwise 0.0))
   (let $clarity (cond ((== $goal energy) 0.9) ((== $goal exploration) 0.8) ((== $goal affinity) 0.4) (otherwise 0.0))
        (* $confidence $clarity))))

(= (get-measurability $goal)
   (calculate-measurability $goal))

(= (get-all-measurabilities)
   (list (list energy (get-measurability energy))
         (list exploration (get-measurability exploration))
         (list affinity (get-measurability affinity))))

; Test the functions
!(println "=== Manual Measurability Tests ===")
!(println (list "Energy measurability:" (get-measurability energy)))
!(println (list "Exploration measurability:" (get-measurability exploration)))
!(println (list "Affinity measurability:" (get-measurability affinity)))
!(println "All measurabilities:")
!(println (get-all-measurabilities))