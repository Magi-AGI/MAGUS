;; MAGUS Milestone 4: Ablation Framework
;; Feature toggles for systematic ablation studies
;; Implements EV2: feature toggles (metagoals-off, anti-goals-off, planner-off)

;; =============================================================================
;; Ablation Configuration
;; =============================================================================

;; Ablation toggle storage
!(bind! &ablation-config (new-space))

;; Available ablation flags
(: AblationFlag Type)
(: metagoals-enabled AblationFlag)
(: antigoals-enabled AblationFlag)
(: planner-enabled AblationFlag)
(: correlation-enabled AblationFlag)
(: measurability-enabled AblationFlag)

;; Ablation configuration entry
(: ablation-setting (-> AblationFlag Bool ablation-setting))

;; =============================================================================
;; Configuration Management
;; =============================================================================

;; Set an ablation flag
(: set-ablation (-> AblationFlag Bool ()))
(= (set-ablation $flag $enabled)
   (add-atom &ablation-config (ablation-setting $flag $enabled)))

;; Get ablation flag status (using direct matching to avoid evaluation issues)
(: get-ablation (-> AblationFlag Bool))
(= (get-ablation metagoals-enabled)
   (get-ablation-value metagoals-enabled))
(= (get-ablation antigoals-enabled)
   (get-ablation-value antigoals-enabled))
(= (get-ablation planner-enabled)
   (get-ablation-value planner-enabled))
(= (get-ablation correlation-enabled)
   (get-ablation-value correlation-enabled))
(= (get-ablation measurability-enabled)
   (get-ablation-value measurability-enabled))
(= (get-ablation $_) True)  ;; Unknown flag defaults to enabled

;; Extract value from ablation-setting atom
(: get-ablation-value (-> AblationFlag Bool))
(= (get-ablation-value $flag)
   (extract-ablation-from-atom
     (match &ablation-config
       (ablation-setting $flag $enabled)
       (ablation-setting $flag $enabled))))

;; Extract enabled field from ablation-setting atom
(: extract-ablation-from-atom (-> $a Bool))
(= (extract-ablation-from-atom Empty) True)  ;; Default: all features enabled
(= (extract-ablation-from-atom (ablation-setting $_ $enabled)) $enabled)

;; Reset all ablations to default (all enabled)
(: reset-ablations (-> ()))
(= (reset-ablations)
   (let ((_ (clear-space &ablation-config))
         (_ (set-ablation metagoals-enabled True))
         (_ (set-ablation antigoals-enabled True))
         (_ (set-ablation planner-enabled True))
         (_ (set-ablation correlation-enabled True))
         (_ (set-ablation measurability-enabled True)))
     ()))

;; =============================================================================
;; Predefined Ablation Configurations
;; =============================================================================

;; Baseline: M2 only (no metagoals, no anti-goals, no planner)
(: configure-baseline (-> ()))
(= (configure-baseline)
   (let ((_ (set-ablation metagoals-enabled False))
         (_ (set-ablation antigoals-enabled False))
         (_ (set-ablation planner-enabled False))
         (_ (set-ablation correlation-enabled True))
         (_ (set-ablation measurability-enabled True)))
     ()))

;; M3 without metagoals
(: configure-no-metagoals (-> ()))
(= (configure-no-metagoals)
   (let ((_ (set-ablation metagoals-enabled False))
         (_ (set-ablation antigoals-enabled True))
         (_ (set-ablation planner-enabled True))
         (_ (set-ablation correlation-enabled True))
         (_ (set-ablation measurability-enabled True)))
     ()))

;; M3 without anti-goals
(: configure-no-antigoals (-> ()))
(= (configure-no-antigoals)
   (let ((_ (set-ablation metagoals-enabled True))
         (_ (set-ablation antigoals-enabled False))
         (_ (set-ablation planner-enabled True))
         (_ (set-ablation correlation-enabled True))
         (_ (set-ablation measurability-enabled True)))
     ()))

;; M3 without planner
(: configure-no-planner (-> ()))
(= (configure-no-planner)
   (let ((_ (set-ablation metagoals-enabled True))
         (_ (set-ablation antigoals-enabled True))
         (_ (set-ablation planner-enabled False))
         (_ (set-ablation correlation-enabled True))
         (_ (set-ablation measurability-enabled True)))
     ()))

;; Full M3 system
(: configure-full (-> ()))
(= (configure-full)
   (reset-ablations))

;; =============================================================================
;; Ablation-Aware Wrappers
;; =============================================================================

;; Apply anti-goals only if enabled
(: apply-antigoals-ablation (-> (List AntiGoal) (List Candidate) (List Candidate)))
(= (apply-antigoals-ablation $antigoals $candidates)
   (if (get-ablation antigoals-enabled)
       (apply-anti-goals $antigoals $candidates)
       $candidates))  ;; Pass through unchanged if disabled

;; Use planner only if enabled
(: generate-candidates-ablation (-> (List Goal) ScoringContext (List Candidate)))
(= (generate-candidates-ablation $goals $context)
   (if (get-ablation planner-enabled)
       (generate-candidates $goals $context)
       (generate-candidates-simple $goals)))  ;; Use simple generator if disabled

;; Simple candidate generator (without planner)
(: generate-candidates-simple (-> (List Goal) (List Candidate)))
(= (generate-candidates-simple Nil) Nil)
(= (generate-candidates-simple (Cons $goal $tail))
   (Cons (goal-candidate $goal)
         (generate-candidates-simple $tail)))

;; Use correlation only if enabled
(: get-correlation-ablation (-> Symbol Symbol Number))
(= (get-correlation-ablation $goal1 $goal2)
   (if (get-ablation correlation-enabled)
       (get-correlation $goal1 $goal2)
       0.0))  ;; Return zero if disabled

;; Use measurability only if enabled
(: get-measurability-ablation (-> Symbol Number))
(= (get-measurability-ablation $goal)
   (if (get-ablation measurability-enabled)
       (get-measurability $goal)
       1.0))  ;; Return default if disabled

;; =============================================================================
;; Scenario Runner with Ablations
;; =============================================================================

;; Run scenario with current ablation configuration
(: run-scenario-ablated (-> Symbol ScenarioContext (List Goal) (List AntiGoal) (List Metagoal) $result))
(= (run-scenario-ablated $scenario-id $scenario-ctx $goals $antigoals $metagoals)
   (let* ((start-time (get-timestamp-ms))
          ;; Create ScoringContext from scenario context
          ($scoring-ctx (create-scoring-context-from-scenario $scenario-ctx $goals))
          ;; Generate candidates (planner if enabled)
          ($candidates (generate-candidates-ablation $goals $scoring-ctx))
          ;; Apply anti-goals (if enabled)
          ($vetted-candidates (apply-antigoals-ablation $antigoals $candidates))
          ;; Get active metagoals based on ablation
          ($active-metagoals (if (get-ablation metagoals-enabled) $metagoals Nil))
          ($active-antigoals (if (get-ablation antigoals-enabled) $antigoals Nil))
          ;; Score with M3 pipeline
          ($scored (score-all-v2 $vetted-candidates $goals $active-antigoals $active-metagoals $scoring-ctx))
          ;; Select best
          ((Tuple $best $best-score) (select-best-candidate $scored))
          ;; Extract DecisionScore components
          ((decision-score $base $meta-adj $anti-penalty $final) $best-score)
          ;; Create breakdown tuples
          ($metagoal-breakdown (list (Tuple metagoal-adjustment $meta-adj)))
          ($antigoal-breakdown (list (Tuple antigoal-penalty $anti-penalty)))
          (end-time (get-timestamp-ms))
          ($latency (- end-time start-time)))
     ;; Log the decision
     (trace-ethical-step
       $scenario-id
       1
       $final
       $metagoal-breakdown
       $antigoal-breakdown
       $best
       pending
       $latency
       (get-ablation-description))
     ;; Return result
     (tuple $best $final $metagoal-breakdown $antigoal-breakdown)))

;; =============================================================================
;; Ablation Description
;; =============================================================================

;; Get current ablation configuration as string
(: get-ablation-description (-> String))
(= (get-ablation-description)
   (let* (($mg (get-ablation metagoals-enabled))
          ($ag (get-ablation antigoals-enabled))
          ($pl (get-ablation planner-enabled))
          ($corr (get-ablation correlation-enabled))
          ($meas (get-ablation measurability-enabled)))
     (concat-ablation-flags $mg $ag $pl $corr $meas)))

;; Build ablation description string
(: concat-ablation-flags (-> Bool Bool Bool Bool Bool String))
(= (concat-ablation-flags True True True True True) "full-system")
(= (concat-ablation-flags False False False True True) "baseline-m2")
(= (concat-ablation-flags False True True True True) "no-metagoals")
(= (concat-ablation-flags True False True True True) "no-antigoals")
(= (concat-ablation-flags True True False True True) "no-planner")
(= (concat-ablation-flags $mg $ag $pl $corr $meas)
   (custom-ablation-description $mg $ag $pl $corr $meas))

;; Custom ablation description builder
(: custom-ablation-description (-> Bool Bool Bool Bool Bool String))
(= (custom-ablation-description $mg $ag $pl $corr $meas)
   "custom-ablation")  ;; Placeholder for custom configurations

;; =============================================================================
;; Ablation Study Execution
;; =============================================================================

;; Run scenario with multiple ablation configurations
(: run-ablation-study (-> Symbol (List Symbol) (List $result)))
(= (run-ablation-study $scenario-id $config-names)
   (run-ablation-study-configs $scenario-id $config-names))

;; Helper to run multiple configs
(: run-ablation-study-configs (-> Symbol (List Symbol) (List $result)))
(= (run-ablation-study-configs $_ Nil) Nil)
(= (run-ablation-study-configs $scenario-id (Cons $config-name $tail))
   (let* (($ (apply-config $config-name))
          ($scenario (get-scenario $scenario-id))
          ($scenario-ctx (get-scenario-context $scenario))
          ($goals (scenario-goals $scenario))
          ($antigoals (scenario-antigoals $scenario))
          ;; Default metagoals for ablation studies
          ($metagoals (Cons (metagoal coherence)
                      (Cons (metagoal efficiency)
                      (Cons (metagoal learning)
                      Nil))))
          ($result (run-scenario-ablated $scenario-id $scenario-ctx $goals $antigoals $metagoals)))
     (Cons $result
           (run-ablation-study-configs $scenario-id $tail))))

;; Apply named configuration
(: apply-config (-> Symbol ()))
(= (apply-config baseline) (configure-baseline))
(= (apply-config no-metagoals) (configure-no-metagoals))
(= (apply-config no-antigoals) (configure-no-antigoals))
(= (apply-config no-planner) (configure-no-planner))
(= (apply-config full) (configure-full))
(= (apply-config $_) (reset-ablations))

;; =============================================================================
;; Clear Space Helper
;; =============================================================================

;; Clear all atoms from a space
(: clear-space (-> Atomspace ()))
(= (clear-space $space)
   (let $atoms (match $space $atom $atom)
     (map-atom $atoms (lambda $a (remove-atom $space $a)))))

;; =============================================================================
;; Export Functions
;; =============================================================================

(: ablations-exports (-> (List Symbol)))
(= (ablations-exports)
   (list
     set-ablation
     get-ablation
     reset-ablations
     configure-baseline
     configure-no-metagoals
     configure-no-antigoals
     configure-no-planner
     configure-full
     run-scenario-ablated
     run-ablation-study
     get-ablation-description))

!(println "Ablation Framework Loaded")
!(println "Configurations: baseline, no-metagoals, no-antigoals, no-planner, full")
!(println "Functions: set-ablation, run-scenario-ablated, run-ablation-study")
