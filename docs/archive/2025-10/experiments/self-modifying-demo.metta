; ============================
; Self-Modifying MAGUS Demo
; Code = Data in Action
; ============================

; ============================
; Basic Setup
; ============================

(: Demand Type)
(: Rule Type)
(: demand (-> Symbol Number Demand))
(: rule (-> Symbol Expression Rule))

!(bind! &magus-demands (new-space))
!(bind! &magus-rules (new-space))

; Helper functions
(= (addDemand $space $name $value)
    (add-atom $space (demand $name $value)))

(= (getDemandValue $space $name)
    (let $result (match $space (demand $name $value) $value)
        (if (== $result ()) 0.0 $result)))

; ============================
; Initialize Demands
; ============================

!(addDemand &magus-demands energy 0.3)    ; Low energy
!(addDemand &magus-demands affinity 0.8)  ; High affinity  
!(addDemand &magus-demands exploration 0.5) ; Medium exploration

; ============================
; Self-Modifying Decision Logic
; ============================

; The system analyzes its own demand state and creates new rules!
(= (generate-decision-rule $demand-name $space)
    (let $value (getDemandValue $space $demand-name)
        (if (< $value 0.4)
            ; LOW demand -> Create URGENT rule
            (rule (concat urgent- $demand-name)
                  (priority-action $demand-name))
            ; HIGH demand -> Create MAINTENANCE rule  
            (rule (concat maintain- $demand-name)
                  (sustain-action $demand-name)))))

; The system creates its own action recommendations
(= (priority-action $demand-name)
    (case $demand-name
        ((energy (:: action Rest urgency 0.9))
         (affinity (:: action Talk urgency 0.6))  ; Less urgent when already high
         (exploration (:: action Explore urgency 0.8)))))

(= (sustain-action $demand-name)
    (case $demand-name
        ((energy (:: action Conserve urgency 0.3))
         (affinity (:: action SocialMaintenance urgency 0.4))
         (exploration (:: action MonitorEnvironment urgency 0.2)))))

; ============================
; Meta-Programming: System Analyzes Itself
; ============================

(= (analyze-current-state)
    (let $energy-val (getDemandValue &magus-demands energy)
        (let $affinity-val (getDemandValue &magus-demands affinity)
            (let $exploration-val (getDemandValue &magus-demands exploration)
                (:: 
                    (state-summary
                        (energy $energy-val)
                        (affinity $affinity-val) 
                        (exploration $exploration-val))
                    (dominant-need 
                        (if (< $energy-val 0.4) energy
                            (if (< $exploration-val 0.4) exploration
                                affinity))))))))

; ============================
; Dynamic Rule Generation
; ============================

(= (auto-generate-all-rules)
    (let $energy-rule (generate-decision-rule energy &magus-demands)
        (let $affinity-rule (generate-decision-rule affinity &magus-demands)
            (let $exploration-rule (generate-decision-rule exploration &magus-demands)
                ; Store the generated rules
                (list
                    (add-atom &magus-rules $energy-rule)
                    (add-atom &magus-rules $affinity-rule)  
                    (add-atom &magus-rules $exploration-rule))))))

; ============================
; System Self-Modification in Action
; ============================

(= (adapt-behavior)
    (let $analysis (analyze-current-state)
        ; System modifies its behavior based on self-analysis
        (match $analysis 
            ((state-summary $demands (dominant-need $need))
                (case $need
                    ((energy 
                        ; System rewrites its action priorities!
                        (: prioritize-rest (-> Bool))
                        (= (prioritize-rest) True))
                     (affinity
                        (: prioritize-social (-> Bool)) 
                        (= (prioritize-social) True))
                     (exploration
                        (: prioritize-discovery (-> Bool))
                        (= (prioritize-discovery) True)))))))

; ============================
; Test the Self-Modification
; ============================

; Test 1: Show current demand state
! (getDemandValue &magus-demands energy)
! (getDemandValue &magus-demands affinity)  
! (getDemandValue &magus-demands exploration)

; Test 2: System analyzes itself
! (analyze-current-state)

; Test 3: Generate rules based on current state
! (generate-decision-rule energy &magus-demands)
! (generate-decision-rule affinity &magus-demands)
! (generate-decision-rule exploration &magus-demands)

; Test 4: System creates all rules automatically
! (auto-generate-all-rules)

; Test 5: Show what rules were created
! (match &magus-rules (rule $name $action) (:: rule-created $name $action))

; ============================
; Demonstrate State Change & Re-adaptation
; ============================

; Change energy level and watch system adapt
!(addDemand &magus-demands energy 0.9)  ; Now high energy

; Test 6: See how rules change with new state
! (generate-decision-rule energy &magus-demands)

; The system has different behavior now!
! (analyze-current-state)