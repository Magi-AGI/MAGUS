; ================================================================================
; MAGUS Goal Weighting System v1
; ================================================================================
; Simple modular system for calculating goal weights from importance and urgency
; Weight = importance * urgency, where urgency = 1.0 - current_satisfaction
; ================================================================================

; Create knowledge base for goals
!(bind! &goals-kb (new-space))

; ================================================================================
; GOAL DATA - Fixed importance, current satisfaction levels
; ================================================================================

!(assert-into-space &goals-kb (goal exploration 0.6 0.5))  ; importance=0.6, satisfaction=0.5
!(assert-into-space &goals-kb (goal affinity 0.7 0.5))     ; importance=0.7, satisfaction=0.5  
!(assert-into-space &goals-kb (goal energy 0.9 0.3))       ; importance=0.9, satisfaction=0.3

; ================================================================================
; CORE FUNCTIONS
; ================================================================================

; Urgency = 1.0 - current_satisfaction (less satisfied = more urgent)
(= (calculate-urgency $satisfaction)
   (- 1.0 $satisfaction))

; Goal weight = importance * urgency
(= (calculate-goal-weight $importance $urgency)
   (* $importance $urgency))

; Get weight for a specific goal
(= (get-goal-weight $goal_name)
   (match &goals-kb (goal $goal_name $importance $satisfaction)
     (let $urgency (calculate-urgency $satisfaction)
          (calculate-goal-weight $importance $urgency))))

; ================================================================================
; TEST
; ================================================================================

!(println "Goal Weights:")
!(println (list exploration (get-goal-weight exploration)))  ; Should be 0.3
!(println (list affinity (get-goal-weight affinity)))        ; Should be 0.35
!(println (list energy (get-goal-weight energy)))            ; Should be 0.63