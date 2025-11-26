;; MAGUS Milestone 3: AIRIS Integration Module (Refined)
;; Maps between AIRIS data formats and MAGUS internal representations
;; Based on AIRIS Usage Specifications, Milestone-3-Spec.md and M3-Refinement-Plan.md

;; Import shared types
!(load types.metta)

;; Import other modules
!(load planner-bt.metta)

;; =============================================================================
;; AIRIS Type Definitions (aligned with types.metta spec)
;; =============================================================================

;; Types are defined in types.metta, but adding parsing helpers here

;; Environment object structure: [object-name, object-type, [[property, value]...], distance]
(: EnvironmentObject Type)
(: env-object (-> Symbol           ;; object-name
                 Symbol           ;; object-type
                 (List (List $a)) ;; properties [[property, value]...]
                 Number           ;; distance
                 EnvironmentObject))

;; Inventory item structure: [item, [[property, value]...] or None, quantity]
(: InventoryItem Type)
(: inv-item (-> Symbol           ;; item name
               (List (List $a))  ;; properties or None
               Number           ;; quantity
               InventoryItem))

;; =============================================================================
;; MAGUS to AIRIS Mapping
;; =============================================================================

;; Map MAGUS context to AIRIS format
(: magus-context-to-airis (-> Context (List Action) AirisInput))
(= (magus-context-to-airis (context $goals $timestamp) $available-actions)
   (let* (($env (goals-to-environment $goals))
          ($inventory (extract-inventory-from-goals $goals))
          ($status (compute-agent-status $goals $timestamp))
          ($actions (convert-actions-to-airis $available-actions))
          ($tasks (goals-to-tasks $goals)))
     (airis-input $env $inventory $status $actions $tasks)))

;; Convert goals to AIRIS environment format
;; Format: [[object-name, object-type, [[property, value]...], distance]...]
(: goals-to-environment (-> (List Goal) AirisEnvironment))
(= (goals-to-environment $goals)
   (airis-env (goals-to-env-objects $goals)))

;; Convert goals to environment objects
(: goals-to-env-objects (-> (List Goal) (List (List $a))))
(= (goals-to-env-objects Nil) Nil)
(= (goals-to-env-objects (Cons (goal $name $priority $weight) $tail))
   (Cons (goal-to-env-object $name $priority $weight)
         (goals-to-env-objects $tail)))

;; Convert single goal to environment object
(: goal-to-env-object (-> Symbol Number Number (List $a)))
(= (goal-to-env-object $name $priority $weight)
   ;; [object-name, object-type, [[property, value]...], distance]
   (Cons $name
   (Cons goal-marker
   (Cons (Cons (Cons priority (Cons $priority Nil))
         (Cons (Cons weight (Cons $weight Nil)) Nil))
   (Cons 0 Nil)))))

;; Extract inventory in AIRIS format
;; Format: [[item, [[property, value]...] or None, quantity]...]
(: extract-inventory-from-goals (-> (List Goal) AirisInventory))
(= (extract-inventory-from-goals $goals)
   (airis-inventory (build-inventory-items $goals)))

;; Build inventory items from goals
(: build-inventory-items (-> (List Goal) (List (List $a))))
(= (build-inventory-items Nil)
   ;; Default items
   (Cons (Cons basic-tool (Cons Nil (Cons 1 Nil)))
   (Cons (Cons rations (Cons Nil (Cons 5 Nil)))
   Nil)))
(= (build-inventory-items (Cons (goal $name $p $w) $tail))
   (if (is-resource-goal $name)
       (Cons (create-inventory-item $name)
             (build-inventory-items $tail))
       (build-inventory-items $tail)))

;; Create inventory item in AIRIS format
(: create-inventory-item (-> Symbol (List $a)))
(= (create-inventory-item $resource)
   ;; [item, properties-or-none, quantity]
   (Cons $resource
   (Cons Nil  ;; No properties for now
   (Cons 1 Nil))))

;; Check if goal relates to resources
(: is-resource-goal (-> Symbol Bool))
(= (is-resource-goal gather-food) True)
(= (is-resource-goal collect-materials) True)
(= (is-resource-goal $other) False)

;; Compute agent status from context (aligned with spec)
(: compute-agent-status (-> (List Goal) Number AirisStatus))
(= (compute-agent-status $goals $timestamp)
   (airis-status
     (- 100 (* 10 (length $goals))) ;; energy inversely proportional to goals
     neutral                          ;; stance
     calm                            ;; mood
     (extract-status-effects $goals)))

;; Extract status effects from goals
(: extract-status-effects (-> (List Goal) (List Symbol)))
(= (extract-status-effects Nil) Nil)
(= (extract-status-effects (Cons (goal $name $p $w) $tail))
   (if (> $w 0.7)
       (Cons (high-priority $name) (extract-status-effects $tail))
       (extract-status-effects $tail)))

;; Convert MAGUS actions to AIRIS format
(: convert-actions-to-airis (-> (List Action) (List AirisAction)))
(= (convert-actions-to-airis Nil) Nil)
(= (convert-actions-to-airis (Cons (action $name $params) $tail))
   (Cons (airis-action $name $params)
         (convert-actions-to-airis $tail)))

;; Convert goals to AIRIS tasks
(: goals-to-tasks (-> (List Goal) (List AirisTask)))
(= (goals-to-tasks Nil) Nil)
(= (goals-to-tasks (Cons (goal $name $priority $weight) $tail))
   (Cons (airis-task $name
                    (round (* $priority 10))  ;; Scale priority to integer
                    (goal-requirements $name))
         (goals-to-tasks $tail)))

;; Get requirements for a goal
(: goal-requirements (-> Symbol (List Symbol)))
(= (goal-requirements reach-location) (Cons movement-capability Nil))
(= (goal-requirements gather-resources) (Cons inventory-space (Cons tool Nil)))
(= (goal-requirements $other) Nil)

;; =============================================================================
;; AIRIS to MAGUS Mapping
;; =============================================================================

;; Convert AIRIS input to MAGUS context
(: airis-input-to-context (-> AirisInput Context))
(= (airis-input-to-context
     (airis-input $env $inv $status $actions $tasks))
   (let* (($goals (tasks-to-goals $tasks))
          ($timestamp (get-current-timestamp)))
     (context $goals $timestamp)))

;; Convert AIRIS tasks to MAGUS goals
(: tasks-to-goals (-> (List AirisTask) (List Goal)))
(= (tasks-to-goals Nil) Nil)
(= (tasks-to-goals (Cons (airis-task $name $priority $reqs) $tail))
   (Cons (goal $name
              (/ $priority 10)  ;; Scale back to [0,1]
              (task-importance $priority))
         (tasks-to-goals $tail)))

;; Calculate goal weight from task priority
(: task-importance (-> Number Number))
(= (task-importance $priority)
   (/ $priority (+ $priority 10)))  ;; Normalize to [0,1]

;; Convert AIRIS status to MAGUS modulators
(: airis-status-to-modulators (-> AirisStatus (List Modulator)))
(= (airis-status-to-modulators
     (airis-status $health $energy $state $effects))
   (Cons (modulator arousal (energy-to-arousal $energy))
   (Cons (modulator dominance (health-to-dominance $health))
   (Cons (modulator focus (state-to-focus $state))
   Nil))))

;; Convert energy to arousal level
(: energy-to-arousal (-> Number Number))
(= (energy-to-arousal $energy)
   (/ $energy 100))  ;; Normalize to [0,1]

;; Convert health to dominance
(: health-to-dominance (-> Number Number))
(= (health-to-dominance $health)
   (/ $health 100))

;; Convert state to focus level
(: state-to-focus (-> Symbol Number))
(= (state-to-focus active) 0.8)
(= (state-to-focus idle) 0.3)
(= (state-to-focus alert) 1.0)
(= (state-to-focus $other) 0.5)

;; =============================================================================
;; Action Mapping
;; =============================================================================

;; Map MAGUS planned action to AIRIS output
(: plan-to-airis-output (-> Plan AirisOutput))
(= (plan-to-airis-output (plan $goal $actions $score))
   (let (($first-action (get-first-action $actions)))
     (action-to-airis-output $first-action $goal)))

;; Get first action from plan
(: get-first-action (-> (List BTNode) BTNode))
(= (get-first-action Nil) (BTAction wait Nil))
(= (get-first-action (Cons $action $tail)) $action)

;; Convert single action to AIRIS output
(: action-to-airis-output (-> BTNode Goal AirisOutput))
(= (action-to-airis-output (BTAction $name $params) $goal)
   (airis-output $name (nest-parameters $params) (generate-hints $goal)))

;; Nest parameters for AIRIS output format
(: nest-parameters (-> (List $a) (List $a)))
(= (nest-parameters Nil) Nil)
(= (nest-parameters (Cons $param Nil))
   (Cons (Cons $param Nil) Nil))  ;; Single param becomes [[param]]
(= (nest-parameters (Cons $p1 (Cons $p2 $tail)))
   (Cons (Cons $p1 (Cons $p2 Nil))  ;; Pair params
         (nest-parameters $tail)))

;; Generate hints based on goal
(: generate-hints (-> Goal (List Symbol)))
(= (generate-hints (goal $name $priority $weight))
   (if (> $priority 0.8)
       (Cons urgent (Cons $name Nil))
       (Cons $name Nil)))

;; =============================================================================
;; Mode Handling (Oracle vs Agent)
;; =============================================================================

;; Operating modes are defined in types.metta

;; Detect AIRIS mode from input
(: detect-airis-mode (-> AirisInput AirisMode))
(= (detect-airis-mode (airis-input $env $inv $status $actions $tasks))
   (if (is-empty-tasks $tasks)
       Oracle
       Agent))

;; Check if task list is empty
(: is-empty-tasks (-> (List AirisTask) Bool))
(= (is-empty-tasks Nil) True)
(= (is-empty-tasks (Cons $h $t)) False)

;; Handle different modes
(: process-airis-input (-> AirisInput AirisMode Context))
(= (process-airis-input $input Oracle)
   (process-oracle-mode $input))
(= (process-airis-input $input Agent)
   (process-agent-mode $input))

;; Process oracle mode (limited information)
(: process-oracle-mode (-> AirisInput Context))
(= (process-oracle-mode (airis-input $env $inv $status $actions $tasks))
   (let* (($default-goals (generate-default-goals $status))
          ($timestamp (get-current-timestamp)))
     (context $default-goals $timestamp)))

;; Generate default goals in oracle mode
(: generate-default-goals (-> AirisStatus (List Goal)))
(= (generate-default-goals (airis-status $energy $stance $mood $effects))
   (let (($survival-priority (if (< $energy 30) 1.0 0.7)))
     (Cons (goal survive $survival-priority 1.0)
     (Cons (goal explore 0.5 0.5)
     (Cons (goal learn 0.3 0.3)
     Nil)))))

;; Process agent mode (full information)
(: process-agent-mode (-> AirisInput Context))
(= (process-agent-mode $input)
   (airis-input-to-context $input))

;; =============================================================================
;; Utilities
;; =============================================================================

;; Get current timestamp (placeholder)
(: get-current-timestamp (-> Number))
(= (get-current-timestamp) 1000)

;; Round number to nearest integer
(: round (-> Number Number))
(= (round $n)
   (if (>= (- $n (floor $n)) 0.5)
       (+ (floor $n) 1)
       (floor $n)))

;; Floor function - simplified for AIRIS priority conversion
;; AIRIS priorities are [0-100], we convert to [0-10]
;; Simple integer division approximation
(: floor (-> Number Number))
(= (floor $n)
   (cond
     ((< $n 0) 0)      ;; Negative → 0
     ((< $n 1) 0)
     ((< $n 2) 1)
     ((< $n 3) 2)
     ((< $n 4) 3)
     ((< $n 5) 4)
     ((< $n 6) 5)
     ((< $n 7) 6)
     ((< $n 8) 7)
     ((< $n 9) 8)
     ((< $n 10) 9)
     (otherwise 10)))  ;; >= 10 → 10 (cap for priorities)

;; =============================================================================
;; Integration Pipeline
;; =============================================================================

;; Main integration function
(: airis-magus-pipeline (-> AirisInput
                           (List Metagoal)
                           (List AntiGoal)
                           AirisOutput))
(= (airis-magus-pipeline $airis-input $metagoals $antigoals)
   (let* (;; Detect mode and process input
          ($mode (detect-airis-mode $airis-input))
          ($context (process-airis-input $airis-input $mode))
          ;; Extract goals and create planning context
          ((context $goals $timestamp) $context)
          ($world-state (world-state (context-to-facts $context)))
          ;; Select highest priority goal
          ($selected-goal (select-top-goal $goals))
          ;; Generate plan
          ($plan (plan-for-goal $selected-goal $world-state))
          ;; Convert to AIRIS output
          ($output (plan-to-airis-output $plan)))
     $output))

;; Select highest priority goal
(: select-top-goal (-> (List Goal) Goal))
(= (select-top-goal Nil) (goal default 0 0))
(= (select-top-goal (Cons $goal Nil)) $goal)
(= (select-top-goal (Cons $g1 (Cons $g2 $tail)))
   (let ((goal $n1 $p1 $w1) $g1)
     (let ((goal $n2 $p2 $w2) $g2)
       (if (> $p1 $p2)
           (select-top-goal (Cons $g1 $tail))
           (select-top-goal (Cons $g2 $tail))))))

;; Convert context to world facts
(: context-to-facts (-> Context (List Symbol)))
(= (context-to-facts (context $goals $timestamp))
   (Cons context-active
   (Cons (has-goals (length $goals))
   Nil)))

;; =============================================================================
;; Game-Agnostic Adapter Layer
;; =============================================================================

;; Adapter configuration for different game environments
(: GameAdapter Type)
(: adapter-config (-> Symbol                ;; game-name
                     (List (Symbol Symbol))  ;; action mappings
                     (List (Symbol Symbol))  ;; object mappings
                     GameAdapter))

;; Default MUD adapter
(: mud-adapter (-> GameAdapter))
(= (mud-adapter)
   (adapter-config mud
     (Cons (move go)
     (Cons (pickup get)
     (Cons (use wield)
     Nil)))
     (Cons (sword weapon)
     (Cons (potion consumable)
     Nil))))

;; Minecraft adapter
(: minecraft-adapter (-> GameAdapter))
(= (minecraft-adapter)
   (adapter-config minecraft
     (Cons (move walk)
     (Cons (pickup mine)
     (Cons (use place)
     Nil)))
     (Cons (diamond gem)
     (Cons (creeper enemy)
     Nil))))

;; Map action names based on adapter
(: map-action-name (-> Symbol GameAdapter Symbol))
(= (map-action-name $action (adapter-config $game $actions $objects))
   (lookup-mapping $action $actions))

;; Lookup mapping in list
(: lookup-mapping (-> Symbol (List (Symbol Symbol)) Symbol))
(= (lookup-mapping $key Nil) $key)  ;; Return original if not found
(= (lookup-mapping $key (Cons ($k $v) $tail))
   (if (== $key $k)
       $v
       (lookup-mapping $key $tail)))

;; =============================================================================
;; Module Export
;; =============================================================================

;; Export main functions for use by other modules
(: airis-integration-exports (-> (List Symbol)))
(= (airis-integration-exports)
   (list
     airis-magus-pipeline
     magus-context-to-airis
     airis-input-to-context
     plan-to-airis-output
     detect-airis-mode
     airis-status-to-modulators
     mud-adapter
     minecraft-adapter
     map-action-name))