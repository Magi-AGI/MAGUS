; ============================
; Test Script for Anna's Demand System
; ============================

; ============================
; Type Definitions
; ============================

(: Demand Type)
(: Goal Type)
(: demand (-> Symbol Number Demand))
(: goal (-> Symbol Number Number Goal))

; ============================
; Space Setup
; ============================

!(bind! &magus-demands (new-space))
!(bind! &magus-goals (new-space))

; ============================
; Basic Functions
; ============================

(= (addDemand $space $name $value)
    (let $demand-atom (demand $name $value)
        (add-atom $space $demand-atom)
    )
)

(= (addGoal $space $name $priority $confidence)
    (let $goal-atom (goal $name $priority $confidence)
        (add-atom $space $goal-atom)
    )
)

; ============================
; Initialize Test Data
; ============================

!(addDemand &magus-demands energy 0.6)
!(addDemand &magus-demands affinity 0.4) 
!(addDemand &magus-demands exploration 0.3)

!(addGoal &magus-goals rest-goal 0.2 0.8)
!(addGoal &magus-goals nutrition-goal 0.5 0.9)

; ============================
; Test Expressions
; ============================

; Test 1: Basic demand creation
! (demand energy 0.6)

; Test 2: Basic goal creation  
! (goal rest-goal 0.2 0.8)

; Test 3: Check what's in demand space
! (match &magus-demands (demand $name $value) (:: $name $value))

; Test 4: Check what's in goal space
! (match &magus-goals (goal $name $priority $confidence) (:: $name $priority $confidence))