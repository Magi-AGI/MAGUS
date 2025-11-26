; Goal Ranking System Test Implementation
; Implements dynamic goal prioritization based on urgency and importance

; ============================================================================
; KNOWLEDGE BASE - GOAL STRUCTURE AND IMPORTANCE VALUES
; ============================================================================

; Define goal importance values
(importance Energy 0.8)
(importance Cognitive 0.6)
(importance Social 0.7)

; ============================================================================
; SCENARIO SATISFACTION VALUES
; ============================================================================

; Scenario 1: Energy Crisis
(satisfaction energy-crisis Energy 0.1)
(satisfaction energy-crisis Cognitive 0.7)
(satisfaction energy-crisis Social 0.6)

; Scenario 2: Social Isolation
(satisfaction social-isolation Energy 0.8)
(satisfaction social-isolation Cognitive 0.7) 
(satisfaction social-isolation Social 0.2)

; Scenario 3: Knowledge Gap
(satisfaction knowledge-gap Energy 0.7)
(satisfaction knowledge-gap Cognitive 0.1)
(satisfaction knowledge-gap Social 0.7)

; Scenario 4: Balanced State
(satisfaction balanced-state Energy 0.5)
(satisfaction balanced-state Cognitive 0.5)
(satisfaction balanced-state Social 0.5)

; ============================================================================
; CORE FUNCTIONS
; ============================================================================

; Calculate urgency: 1.0 - satisfaction
(= (urgency $sat) (- 1.0 $sat))

; Calculate priority: urgency * importance
(= (calc-energy-priority $sat) (* (urgency $sat) 0.8))
(= (calc-cognitive-priority $sat) (* (urgency $sat) 0.6))
(= (calc-social-priority $sat) (* (urgency $sat) 0.7))

; ============================================================================
; DIRECT CALCULATION FOR EACH SCENARIO
; ============================================================================

; ============================================================================
; TEST EXECUTION AND VERIFICATION
; ============================================================================

; Test all scenarios with expected results
!(let* (
    ; Test 1: Energy Crisis (satisfaction: Energy=0.1, Cognitive=0.7, Social=0.6)
    ($e1-energy-priority (calc-energy-priority 0.1))        ; (1.0 - 0.1) * 0.8 = 0.72
    ($e1-cognitive-priority (calc-cognitive-priority 0.7))   ; (1.0 - 0.7) * 0.6 = 0.18
    ($e1-social-priority (calc-social-priority 0.6))        ; (1.0 - 0.6) * 0.7 = 0.28
    ($e1-primary (if (and (>= $e1-energy-priority $e1-cognitive-priority) 
                          (>= $e1-energy-priority $e1-social-priority))
                     Energy
                     (if (>= $e1-cognitive-priority $e1-social-priority) 
                         Cognitive Social)))
    ($e1-result (if (== $e1-primary Energy) "✓ PASSED" "✗ FAILED"))

    ; Test 2: Social Isolation (satisfaction: Energy=0.8, Cognitive=0.7, Social=0.2)
    ($e2-energy-priority (calc-energy-priority 0.8))        ; (1.0 - 0.8) * 0.8 = 0.16
    ($e2-cognitive-priority (calc-cognitive-priority 0.7))   ; (1.0 - 0.7) * 0.6 = 0.18
    ($e2-social-priority (calc-social-priority 0.2))        ; (1.0 - 0.2) * 0.7 = 0.56
    ($e2-primary (if (and (>= $e2-energy-priority $e2-cognitive-priority)
                          (>= $e2-energy-priority $e2-social-priority))
                     Energy
                     (if (>= $e2-cognitive-priority $e2-social-priority)
                         Cognitive Social)))
    ($e2-result (if (== $e2-primary Social) "✓ PASSED" "✗ FAILED"))

    ; Test 3: Knowledge Gap (satisfaction: Energy=0.7, Cognitive=0.1, Social=0.7)
    ($e3-energy-priority (calc-energy-priority 0.7))        ; (1.0 - 0.7) * 0.8 = 0.24
    ($e3-cognitive-priority (calc-cognitive-priority 0.1))   ; (1.0 - 0.1) * 0.6 = 0.54
    ($e3-social-priority (calc-social-priority 0.7))        ; (1.0 - 0.7) * 0.7 = 0.21
    ($e3-primary (if (and (>= $e3-energy-priority $e3-cognitive-priority)
                          (>= $e3-energy-priority $e3-social-priority))
                     Energy
                     (if (>= $e3-cognitive-priority $e3-social-priority)
                         Cognitive Social)))
    ($e3-result (if (== $e3-primary Cognitive) "✓ PASSED" "✗ FAILED"))

    ; Test 4: Balanced State (satisfaction: Energy=0.5, Cognitive=0.5, Social=0.5)
    ($e4-energy-priority (calc-energy-priority 0.5))        ; (1.0 - 0.5) * 0.8 = 0.40
    ($e4-cognitive-priority (calc-cognitive-priority 0.5))   ; (1.0 - 0.5) * 0.6 = 0.30
    ($e4-social-priority (calc-social-priority 0.5))        ; (1.0 - 0.5) * 0.7 = 0.35
    ($e4-primary (if (and (>= $e4-energy-priority $e4-cognitive-priority)
                          (>= $e4-energy-priority $e4-social-priority))
                     Energy
                     (if (>= $e4-cognitive-priority $e4-social-priority)
                         Cognitive Social)))
    ($e4-result (if (== $e4-primary Energy) "✓ PASSED" "✗ FAILED"))
    )
   ; Display results
   (list 
     "=== GOAL RANKING SYSTEM TEST RESULTS ==="
     ""
     "Formula: Priority = (1.0 - satisfaction) × importance"  
     "Importance: Energy=0.8, Cognitive=0.6, Social=0.7"
     ""
     (list "TEST 1 - Energy Crisis" $e1-result
           "Energy:" $e1-energy-priority "Cognitive:" $e1-cognitive-priority "Social:" $e1-social-priority
           "Primary:" $e1-primary "(Expected: Energy)")
     ""
     (list "TEST 2 - Social Isolation" $e2-result  
           "Energy:" $e2-energy-priority "Cognitive:" $e2-cognitive-priority "Social:" $e2-social-priority
           "Primary:" $e2-primary "(Expected: Social)")
     ""
     (list "TEST 3 - Knowledge Gap" $e3-result
           "Energy:" $e3-energy-priority "Cognitive:" $e3-cognitive-priority "Social:" $e3-social-priority  
           "Primary:" $e3-primary "(Expected: Cognitive)")
     ""
     (list "TEST 4 - Balanced State" $e4-result
           "Energy:" $e4-energy-priority "Cognitive:" $e4-cognitive-priority "Social:" $e4-social-priority
           "Primary:" $e4-primary "(Expected: Energy)")
     ""
     "=== ALL TESTS COMPLETE ==="
     (list "Summary:" 
           (if (== $e1-result "✓ PASSED") "Test 1: PASSED" "Test 1: FAILED")
           (if (== $e2-result "✓ PASSED") "Test 2: PASSED" "Test 2: FAILED") 
           (if (== $e3-result "✓ PASSED") "Test 3: PASSED" "Test 3: FAILED")
           (if (== $e4-result "✓ PASSED") "Test 4: PASSED" "Test 4: FAILED"))))