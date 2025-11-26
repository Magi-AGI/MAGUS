; ================================================================================
; MAGUS Action Evaluation Prototype v1  
; ================================================================================
; Each action evaluated FOR EACH GOAL using:
; - Considerations: geometric_mean (higher = better for goal)
; - Discouragements: product (lower = more blocking)  
; - Goal score = weight * geometric_mean(considerations) * product(discouragements)
; - Total action score = sum of all goal scores
; - Uses goal weights from magus-goal-weighting-v1.metta
; ================================================================================

!(bind! &actions-kb (new-space))

; ================================================================================
; MATH FUNCTIONS
; ================================================================================

(= (geometric-mean $values)
   (case $values
     (($single) $single)
     (($a $b) (sqrt (* $a $b)))
     (($a $b $c) (** (* $a $b $c) (/ 1 3)))
     (() 0.0)))

(= (product-discouragements $values)
   (case $values
     (($single) $single)
     (($a $b) (* $a $b))
     (($a $b $c) (* $a $b $c))
     (() 1.0)))

; ================================================================================
; EXAMPLE ACTIONS with multiple considerations/discouragements
; ================================================================================

!(assert-into-space &actions-kb (action rest exploration (0.2 0.3) (0.8 0.9)))
!(assert-into-space &actions-kb (action rest affinity (0.4 0.6 0.5) (0.9)))
!(assert-into-space &actions-kb (action rest energy (0.9) (0.7 0.8)))

!(assert-into-space &actions-kb (action explore exploration (0.8 0.9 0.7) (0.6)))
!(assert-into-space &actions-kb (action explore affinity (0.1) (0.9 0.8)))
!(assert-into-space &actions-kb (action explore energy (0.2 0.1) (0.4 0.3 0.5)))

; ================================================================================
; SCORE CALCULATION - Uses weights from goal weighting module
; ================================================================================

; Get score for one action on one goal (uses dynamic weight from goal module)
(= (get-action-goal-score $action_name $goal_name $goal_weight)
   (match &actions-kb (action $action_name $goal_name $considerations $discouragements)
     (let $cons_score (geometric-mean $considerations)
          $disc_score (product-discouragements $discouragements)
          (* $goal_weight $cons_score $disc_score))))

; Get total score for one action across all goals  
; Pulls weights dynamically from magus-goal-weighting-v1.metta functions
(= (get-action-total-score $action_name)
   (let $exploration_score (get-action-goal-score $action_name exploration (get-goal-weight exploration))
        $affinity_score (get-action-goal-score $action_name affinity (get-goal-weight affinity)) 
        $energy_score (get-action-goal-score $action_name energy (get-goal-weight energy))
        (+ $exploration_score $affinity_score $energy_score)))

; Choose action with highest total score
(= (choose-best-action)
   (let $rest_score (get-action-total-score rest)
        $explore_score (get-action-total-score explore)
        (if (> $rest_score $explore_score) 
            (list rest $rest_score)
            (list explore $explore_score))))

; ================================================================================
; TEST - Requires magus-goal-weighting-v1.metta to be loaded first
; ================================================================================

!(println "=== Action Evaluation Test ===")
!(println "REST total:" (get-action-total-score rest))
!(println "EXPLORE total:" (get-action-total-score explore)) 
!(println "Best action:" (choose-best-action))