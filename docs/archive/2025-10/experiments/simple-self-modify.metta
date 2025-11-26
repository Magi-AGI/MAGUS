; ============================
; Simple Self-Modifying Demo
; ============================

; ============================
; Basic Setup
; ============================

(: Demand Type)
(: demand (-> Symbol Number Demand))

!(bind! &demands (new-space))

(= (addDemand $space $name $value)
    (add-atom $space (demand $name $value)))

(= (getDemandValue $space $name)
    (collapse (match $space (demand $name $value) $value)))

; ============================
; Initialize State
; ============================

!(addDemand &demands energy 0.2)    ; Very low energy - CRITICAL!
!(addDemand &demands affinity 0.8)  ; High social connection
!(addDemand &demands exploration 0.5) ; Medium curiosity

; ============================
; Self-Modifying Logic
; ============================

; System creates different action priorities based on its internal state
(= (generate-action-priority $demand-name)
    (let $value (getDemandValue &demands $demand-name)
        (if (< $value 0.3)
            (:: $demand-name URGENT priority 0.9)
            (if (> $value 0.7)
                (:: $demand-name SATISFIED priority 0.2)
                (:: $demand-name NORMAL priority 0.5)))))

; System analyzes ALL demands and creates behavior rules
(= (auto-create-behavior)
    (let $energy-rule (generate-action-priority energy)
        (let $affinity-rule (generate-action-priority affinity)
            (let $exploration-rule (generate-action-priority exploration)
                (list $energy-rule $affinity-rule $exploration-rule)))))

; System determines its dominant need
(= (find-dominant-need)
    (let $energy-val (getDemandValue &demands energy)
        (let $affinity-val (getDemandValue &demands affinity)
            (let $exploration-val (getDemandValue &demands exploration)
                (if (< $energy-val 0.3) 
                    (:: dominant-need energy critical-level $energy-val)
                    (if (< $exploration-val 0.3)
                        (:: dominant-need exploration low-level $exploration-val)
                        (:: dominant-need affinity highest-level $affinity-val)))))))

; ============================
; Test the Self-Modification
; ============================

; Show current demand values
! (getDemandValue &demands energy)
! (getDemandValue &demands affinity)
! (getDemandValue &demands exploration)

; System analyzes itself and creates behavior rules
! (generate-action-priority energy)
! (generate-action-priority affinity)
! (generate-action-priority exploration)

; System creates comprehensive behavior automatically
! (auto-create-behavior)

; System identifies its most critical need
! (find-dominant-need)

; ============================
; Watch System Adapt to State Change
; ============================

; Now change the energy level - watch the system adapt!
!(addDemand &demands energy 0.9)  ; Energy restored!

; Test again - different behavior emerges
! (generate-action-priority energy)
! (find-dominant-need)
! (auto-create-behavior)