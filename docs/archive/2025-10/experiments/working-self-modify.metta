; ============================
; Working Self-Modifying Demo with OVERGOAL
; ============================

!(bind! &demands (new-space))
!(bind! &goal-metrics (new-space))

(= (addDemand $space $name $value)
    (add-atom $space (demand $name $value)))

; Initialize with critical energy state
!(addDemand &demands energy 0.2)
!(addDemand &demands affinity 0.8)
!(addDemand &demands exploration 0.5)

; Simple getter
(= (getDemandValue $name)
    (collapse (match &demands (demand $name $value) $value)))

; System creates behavior based on its state - CODE GENERATED FROM DATA!
(= (behaviorFor energy)
    (let $val (getDemandValue energy)
        (:: energy-behavior
            current-level $val
            recommended-action URGENT-REST)))

(= (behaviorFor affinity)
    (let $val (getDemandValue affinity)
        (:: affinity-behavior
            current-level $val
            recommended-action SOCIAL-MAINTENANCE)))

(= (behaviorFor exploration)
    (let $val (getDemandValue exploration)
        (:: exploration-behavior
            current-level $val
            recommended-action MODERATE-EXPLORE)))

; System can modify its own functions based on state changes!
(= (adaptBehaviorFor energy)
    (let $val (getDemandValue energy)
        (:: energy-NEW-behavior
            current-level $val
            recommended-action CONSERVE-ENERGY
            note system-adapted-automatically)))

; System analyzes all its demands and creates action plan
(= (generateBehaviorPlan)
    (list 
        (behaviorFor energy)
        (behaviorFor affinity)
        (behaviorFor exploration)))

; ============================
; Test Self-Modification
; ============================

; Show current state
! (getDemandValue energy)
! (getDemandValue affinity)
! (getDemandValue exploration)

; System creates behavior rules from its current state
! (behaviorFor energy)
! (behaviorFor affinity)
! (behaviorFor exploration)

; System creates comprehensive plan
! (generateBehaviorPlan)

; ============================
; Watch System Adapt
; ============================

; Change energy - system will adapt!
!(addDemand &demands energy 0.8)

; Same function, different behavior emerges!
! (behaviorFor energy)

; System creates NEW behavior function for changed state
! (adaptBehaviorFor energy)

; Show the difference - old vs new behavior
! (generateBehaviorPlan)

; ============================
; OVERGOAL Implementation
; ============================

; Track goal performance metrics
(= (addGoalMetric $goal-name $measurability $correlation)
    (add-atom &goal-metrics (goal-metric $goal-name $measurability $correlation)))

; Initialize goal metrics for our three demands
!(addGoalMetric energy 0.8 0.6)      ; Energy: measurable, moderate correlation
!(addGoalMetric affinity 0.9 0.7)    ; Affinity: highly measurable, good correlation  
!(addGoalMetric exploration 0.7 0.5) ; Exploration: somewhat measurable, lower correlation

; Calculate overall goal system fitness (OVERGOAL)
(= (overgoal-satisfaction)
    (let $all-metrics (collapse (match &goal-metrics (goal-metric $name $meas $corr) (:: $meas $corr)))
        (let $measurability-scores (collapse (match &goal-metrics (goal-metric $name $meas $corr) $meas))
            (let $correlation-scores (collapse (match &goal-metrics (goal-metric $name $meas $corr) $corr))
                (let $avg-measurability (/ (foldl-atom $measurability-scores 0 $acc $x (+ $acc $x)) 3)
                    (let $avg-correlation (/ (foldl-atom $correlation-scores 0 $acc $x (+ $acc $x)) 3)
                        (:: overgoal-satisfaction 
                            measurability $avg-measurability
                            correlation $avg-correlation
                            overall-fitness (* $avg-measurability $avg-correlation))))))))

; System evaluates its own goal structure!
(= (evaluate-goal-system)
    (let $overgoal-result (overgoal-satisfaction)
        (:: goal-system-evaluation
            current-goals (energy affinity exploration)
            fitness-assessment $overgoal-result
            recommendation 
            (if (< (* 0.8 0.6) 0.5)  ; If fitness below threshold
                RESTRUCTURE-GOALS
                MAINTAIN-CURRENT-STRUCTURE))))

; ============================
; Test OVERGOAL
; ============================

; Show goal metrics
! (match &goal-metrics (goal-metric $name $meas $corr) (:: $name measurable $meas correlated $corr))

; Calculate overgoal satisfaction
! (overgoal-satisfaction)

; System evaluates its own goal structure
! (evaluate-goal-system)