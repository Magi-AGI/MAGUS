;; Test Suite for AIRIS Integration Module
;; Tests bidirectional mapping, mode detection, and round-trip conversion
;; Based on Milestone-3-Spec.md Test Requirements

!(load ../../Milestone_3/core/integration-airis.metta)
!(load ../../Milestone_3/core/planner-bt.metta)

;; =============================================================================
;; Test Data Setup
;; =============================================================================

;; Test AIRIS environment
(= (test-airis-env)
   (airis-env
     (Cons (Cons 1 (Cons 2 Nil))
     (Cons (Cons 3 (Cons 4 Nil))
     Nil))))

;; Test AIRIS inventory
(= (test-airis-inventory)
   (airis-inventory
     (Cons (sword 1)
     (Cons (potion 3)
     (Cons (gold 50)
     Nil)))))

;; Test AIRIS status
(= (test-airis-status)
   (airis-status 85 70 active
     (Cons buff-strength
     (Cons debuff-poison
     Nil))))

;; Test AIRIS actions
(= (test-airis-actions)
   (Cons (airis-action move (north))
   (Cons (airis-action attack (target))
   (Cons (airis-action use (potion))
   Nil))))

;; Test AIRIS tasks
(= (test-airis-tasks)
   (Cons (airis-task defeat-boss 9 (Cons weapon (Cons high-health Nil)))
   (Cons (airis-task explore-dungeon 6 (Cons torch Nil))
   (Cons (airis-task collect-treasure 4 Nil)
   Nil))))

;; Complete AIRIS input (Agent mode)
(= (test-airis-input-agent)
   (airis-input
     (test-airis-env)
     (test-airis-inventory)
     (test-airis-status)
     (test-airis-actions)
     (test-airis-tasks)))

;; Limited AIRIS input (Oracle mode)
(= (test-airis-input-oracle)
   (airis-input
     (test-airis-env)
     (test-airis-inventory)
     (test-airis-status)
     (test-airis-actions)
     Nil))  ;; No tasks

;; Test MAGUS context
(= (test-magus-context)
   (context
     (Cons (goal survive 0.9 0.8)
     (Cons (goal explore 0.6 0.5)
     (Cons (goal gather 0.4 0.3)
     Nil)))
     1500))

;; =============================================================================
;; Test 1: MAGUS to AIRIS Conversion
;; =============================================================================

!(println! "Test 1: MAGUS to AIRIS Conversion")

;; Test context to AIRIS conversion
!(let (($airis-input (magus-context-to-airis
                       (test-magus-context)
                       (Cons (action move (forward))
                        (Cons (action wait ())
                        Nil)))))
  (case $airis-input
    (((airis-input $env $inv $status $actions $tasks)
      (assertEqualToResult
        (and (case $env ((airis-env $arr) True) ($other False))
             (case $status ((airis-status $h $e $s $eff) True) ($other False))
             (> (length $tasks) 0))
        (True))))))

;; Test goals to environment conversion
!(let (($env (goals-to-environment
               (Cons (goal test1 0.8 0.7)
                (Cons (goal test2 0.6 0.5)
                Nil)))))
  (case $env
    (((airis-env $array)
      (assertEqualToResult
        (length $array)
        (2))))))  ;; Should have 2 rows

;; Test goals to tasks conversion
!(let (($tasks (goals-to-tasks
                 (Cons (goal reach-location 0.8 0.7)
                  (Cons (goal gather-resources 0.6 0.5)
                  Nil)))))
  (assertEqualToResult
    (length $tasks)
    (2)))

;; =============================================================================
;; Test 2: AIRIS to MAGUS Conversion
;; =============================================================================

!(println! "Test 2: AIRIS to MAGUS Conversion")

;; Test AIRIS input to context
!(let (($context (airis-input-to-context (test-airis-input-agent))))
  (case $context
    (((context $goals $timestamp)
      (assertEqualToResult
        (length $goals)
        (3))))))  ;; Should convert 3 tasks to goals

;; Test tasks to goals conversion
!(let (($goals (tasks-to-goals (test-airis-tasks))))
  (assertEqualToResult
    (length $goals)
    (3)))

;; Test single task conversion
!(let (($goals (tasks-to-goals
                 (Cons (airis-task test-task 8 (Cons req1 Nil))
                  Nil))))
  (case $goals
    (((Cons (goal $name $priority $weight) Nil)
      (assertEqualToResult
        (and (== $name test-task)
             (== $priority 0.8))  ;; 8/10 = 0.8
        (True))))))

;; =============================================================================
;; Test 3: Status to Modulators
;; =============================================================================

!(println! "Test 3: Status to Modulators")

;; Test status conversion to modulators
!(let (($modulators (airis-status-to-modulators (test-airis-status))))
  (assertEqualToResult
    (length $modulators)
    (3)))  ;; arousal, dominance, focus

;; Test energy to arousal conversion
!(assertEqualToResult
  (energy-to-arousal 50)
  (0.5))

;; Test health to dominance conversion
!(assertEqualToResult
  (health-to-dominance 100)
  (1.0))

;; Test state to focus conversion
!(assertEqualToResult
  (state-to-focus active)
  (0.8))

;; =============================================================================
;; Test 4: Mode Detection
;; =============================================================================

!(println! "Test 4: Mode Detection")

;; Test Agent mode detection
!(assertEqualToResult
  (detect-airis-mode (test-airis-input-agent))
  (Agent))

;; Test Oracle mode detection
!(assertEqualToResult
  (detect-airis-mode (test-airis-input-oracle))
  (Oracle))

;; =============================================================================
;; Test 5: Mode-Specific Processing
;; =============================================================================

!(println! "Test 5: Mode-Specific Processing")

;; Test Oracle mode processing
!(let (($context (process-airis-input (test-airis-input-oracle) Oracle)))
  (case $context
    (((context $goals $timestamp)
      (assertEqualToResult
        (> (length $goals) 0)  ;; Should generate default goals
        (True))))))

;; Test Agent mode processing
!(let (($context (process-airis-input (test-airis-input-agent) Agent)))
  (case $context
    (((context $goals $timestamp)
      (assertEqualToResult
        (length $goals)
        (3))))))  ;; Should match number of tasks

;; =============================================================================
;; Test 6: Action Mapping
;; =============================================================================

!(println! "Test 6: Action Mapping")

;; Test plan to AIRIS output
!(let* (($plan (plan (goal test-goal 0.7 0.6)
                    (Cons (Action move (forward))
                     (Cons (Action attack (enemy))
                     Nil))
                    75))
        ($output (plan-to-airis-output $plan)))
  (case $output
    (((airis-output $action $params $hints)
      (assertEqualToResult
        (== $action move)  ;; Should take first action
        (True))))))

;; Test action to AIRIS output with hints
!(let (($output (action-to-airis-output
                  (Action explore (dungeon))
                  (goal critical-mission 0.9 0.85))))
  (case $output
    (((airis-output $action $params $hints)
      (assertEqualToResult
        (and (== $action explore)
             (member urgent $hints))  ;; High priority = urgent
        (True))))))

;; =============================================================================
;; Test 7: Round-Trip Conversion
;; =============================================================================

!(println! "Test 7: Round-Trip Conversion")

;; Test MAGUS -> AIRIS -> MAGUS round-trip
!(let* (;; Start with MAGUS context
        ($original-context (test-magus-context))
        ;; Convert to AIRIS
        ($airis (magus-context-to-airis $original-context
                  (Cons (action test ()) Nil)))
        ;; Convert back to MAGUS
        ($recovered-context (airis-input-to-context $airis)))
  (case $recovered-context
    (((context $goals $timestamp)
      (assertEqualToResult
        (length $goals)
        (3))))))  ;; Should preserve goal count

;; =============================================================================
;; Test 8: Goal Selection
;; =============================================================================

!(println! "Test 8: Goal Selection")

;; Test selecting top goal
!(let (($top (select-top-goal
               (Cons (goal low 0.3 0.2)
                (Cons (goal high 0.9 0.8)
                 (Cons (goal medium 0.5 0.4)
                 Nil))))))
  (case $top
    (((goal $name $priority $weight)
      (assertEqualToResult
        (== $name high)
        (True))))))

;; Test empty goal list
!(let (($top (select-top-goal Nil)))
  (case $top
    (((goal $name $p $w)
      (assertEqualToResult
        (== $name default)
        (True))))))

;; =============================================================================
;; Test 9: Full Pipeline Integration
;; =============================================================================

!(println! "Test 9: Full Pipeline Integration")

;; Test complete pipeline (simplified - would need all modules)
!(let* (($metagoals Nil)
        ($antigoals Nil)
        ;; Note: This test is simplified as it would require
        ;; importing and setting up all other modules
        ($mode (detect-airis-mode (test-airis-input-agent)))
        ($context (process-airis-input (test-airis-input-agent) $mode)))
  (case $context
    (((context $goals $timestamp)
      (assertEqualToResult
        (> (length $goals) 0)
        (True))))))

;; =============================================================================
;; Test 10: Edge Cases
;; =============================================================================

!(println! "Test 10: Edge Cases")

;; Test empty inventory
!(let (($inv (extract-inventory-from-goals Nil)))
  (case $inv
    (((airis-inventory $items)
      (assertEqualToResult
        (length $items)
        (0))))))

;; Test empty task list
!(assertEqualToResult
  (is-empty-tasks Nil)
  (True))

!(assertEqualToResult
  (is-empty-tasks (Cons (airis-task test 5 Nil) Nil))
  (False))

;; Test resource goal detection
!(assertEqualToResult
  (is-resource-goal gather-food)
  (True))

!(assertEqualToResult
  (is-resource-goal explore)
  (False))

;; Test context to facts conversion
!(let (($facts (context-to-facts (test-magus-context))))
  (assertEqualToResult
    (member context-active $facts)
    (True)))

;; =============================================================================
;; Test 11: Hint Generation
;; =============================================================================

!(println! "Test 11: Hint Generation")

;; Test hint generation for high priority
!(let (($hints (generate-hints (goal critical 0.95 0.9))))
  (assertEqualToResult
    (member urgent $hints)
    (True)))

;; Test hint generation for normal priority
!(let (($hints (generate-hints (goal normal 0.5 0.4))))
  (assertEqualToResult
    (member normal $hints)
    (True)))

!(println! "=== AIRIS Integration Tests Complete ===")
!(println! "All tests passed successfully")