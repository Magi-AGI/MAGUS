;; MAGUS Milestone 4: Ethical Scenario Definitions
;; Data structures and schema for ethical testing scenarios
;; Implements ES1: scenario schema with structured fields

;; Import core types
!(load ../../types.metta)

;; =============================================================================
;; Scenario Schema ADT
;; =============================================================================

;; ScenarioContext represents environmental and agent state (renamed to avoid clash with core Context)
(: ScenarioContext Type)
(: scenario-context (-> Symbol Symbol Symbol (List (Tuple Symbol $a)) ScenarioContext))
;; scenario-context(location, agent-state, environment-danger, additional-properties)

;; SuccessMetric represents a boolean evaluation criterion
(: SuccessMetric Type)
(: metric-boolean (-> Symbol Bool SuccessMetric))
(: metric-comparison (-> Symbol Symbol Number SuccessMetric))
;; Examples: (metric-boolean no-hard-violations True), (metric-comparison final-score >= 0.0)

;; ExpectedAction represents an action in the expected plan
(: ExpectedAction Type)
(: expected-action (-> Symbol (List $a) String ExpectedAction))
;; expected-action(action-name, parameters, rationale)

;; EthicalScenario represents a complete test scenario
(: EthicalScenario Type)
(: scenario (->
    Symbol                          ;; scenario-id
    String                          ;; description
    (List Symbol)                   ;; tags
    Symbol                          ;; risk-level (low/medium/high)
    ScenarioContext                 ;; context
    (List Goal)                     ;; goals
    (List AntiGoal)                 ;; anti-goals (hard and soft)
    (List SuccessMetric)            ;; success-metrics
    (List ExpectedAction)           ;; expected-plan
    String                          ;; remediation-hint
    EthicalScenario))

;; =============================================================================
;; Scenario Storage
;; =============================================================================

;; Dedicated space for scenario definitions
!(bind! &ethical-scenarios (new-space))

;; =============================================================================
;; Scenario Registration Functions
;; =============================================================================

;; Register a scenario in the ethical scenarios space
(: register-scenario (-> EthicalScenario ()))
(= (register-scenario $scenario)
   (add-atom &ethical-scenarios $scenario))

;; Retrieve scenario by ID
(: get-scenario (-> Symbol EthicalScenario))
(= (get-scenario $scenario-id)
   (match &ethical-scenarios
     (scenario $scenario-id $desc $tags $risk $ctx $goals $antigoals $metrics $plan $hint)
     (scenario $scenario-id $desc $tags $risk $ctx $goals $antigoals $metrics $plan $hint)))

;; List all scenario IDs
(: list-scenarios (-> (List Symbol)))
(= (list-scenarios)
   (match &ethical-scenarios
     (scenario $id $_ $_ $_ $_ $_ $_ $_ $_ $_)
     $id))

;; Get scenarios by tag
(: get-scenarios-by-tag (-> Symbol (List EthicalScenario)))
(= (get-scenarios-by-tag $tag)
   (match &ethical-scenarios
     (scenario $id $desc $tags $risk $ctx $goals $antigoals $metrics $plan $hint)
     (if (contains $tags $tag)
         (scenario $id $desc $tags $risk $ctx $goals $antigoals $metrics $plan $hint)
         Empty)))

;; Get scenarios by risk level
(: get-scenarios-by-risk (-> Symbol (List EthicalScenario)))
(= (get-scenarios-by-risk $risk-level)
   (match &ethical-scenarios
     (scenario $id $desc $tags $risk $ctx $goals $antigoals $metrics $plan $hint)
     (if (== $risk $risk-level)
         (scenario $id $desc $tags $risk $ctx $goals $antigoals $metrics $plan $hint)
         Empty)))

;; =============================================================================
;; Scenario Field Accessors
;; =============================================================================

(: scenario-id (-> EthicalScenario Symbol))
(= (scenario-id (scenario $id $_ $_ $_ $_ $_ $_ $_ $_ $_)) $id)

(: scenario-description (-> EthicalScenario String))
(= (scenario-description (scenario $_ $desc $_ $_ $_ $_ $_ $_ $_ $_)) $desc)

(: scenario-tags (-> EthicalScenario (List Symbol)))
(= (scenario-tags (scenario $_ $_ $tags $_ $_ $_ $_ $_ $_ $_)) $tags)

(: scenario-risk-level (-> EthicalScenario Symbol))
(= (scenario-risk-level (scenario $_ $_ $_ $risk $_ $_ $_ $_ $_ $_)) $risk)

(: get-scenario-context (-> EthicalScenario ScenarioContext))
(= (get-scenario-context (scenario $_ $_ $_ $_ $ctx $_ $_ $_ $_ $_)) $ctx)

(: scenario-goals (-> EthicalScenario (List Goal)))
(= (scenario-goals (scenario $_ $_ $_ $_ $_ $goals $_ $_ $_ $_)) $goals)

(: scenario-antigoals (-> EthicalScenario (List AntiGoal)))
(= (scenario-antigoals (scenario $_ $_ $_ $_ $_ $_ $antigoals $_ $_ $_)) $antigoals)

(: scenario-success-metrics (-> EthicalScenario (List SuccessMetric)))
(= (scenario-success-metrics (scenario $_ $_ $_ $_ $_ $_ $_ $metrics $_ $_)) $metrics)

(: scenario-expected-plan (-> EthicalScenario (List ExpectedAction)))
(= (scenario-expected-plan (scenario $_ $_ $_ $_ $_ $_ $_ $_ $plan $_)) $plan)

(: scenario-remediation-hint (-> EthicalScenario String))
(= (scenario-remediation-hint (scenario $_ $_ $_ $_ $_ $_ $_ $_ $_ $hint)) $hint)

;; =============================================================================
;; ScenarioContext Accessors
;; =============================================================================

(: scenario-context-location (-> ScenarioContext Symbol))
(= (scenario-context-location (scenario-context $loc $_ $_ $_)) $loc)

(: scenario-context-agent-state (-> ScenarioContext Symbol))
(= (scenario-context-agent-state (scenario-context $_ $state $_ $_)) $state)

(: scenario-context-danger-level (-> ScenarioContext Symbol))
(= (scenario-context-danger-level (scenario-context $_ $_ $danger $_)) $danger)

(: scenario-context-properties (-> ScenarioContext (List (Tuple Symbol $a))))
(= (scenario-context-properties (scenario-context $_ $_ $_ $props)) $props)

;; Get specific property from scenario context
(: get-scenario-context-property (-> ScenarioContext Symbol $a))
(= (get-scenario-context-property (scenario-context $_ $_ $_ $props) $key)
   (match $props
     (Cons (Tuple $key $value) $_) $value
     (Cons $_ $tail) (get-scenario-context-property (scenario-context _ _ _ $tail) $key)
     Nil Empty))

;; =============================================================================
;; SuccessMetric Evaluation
;; =============================================================================

;; Evaluate a success metric against actual results
(: eval-metric (-> SuccessMetric $result Bool))
(= (eval-metric (metric-boolean $name $expected) $actual)
   (== $expected $actual))

(= (eval-metric (metric-comparison $name >= $threshold) $actual)
   (>= $actual $threshold))

(= (eval-metric (metric-comparison $name > $threshold) $actual)
   (> $actual $threshold))

(= (eval-metric (metric-comparison $name <= $threshold) $actual)
   (<= $actual $threshold))

(= (eval-metric (metric-comparison $name < $threshold) $actual)
   (< $actual $threshold))

(= (eval-metric (metric-comparison $name == $expected) $actual)
   (== $actual $expected))

;; =============================================================================
;; Helper Functions
;; =============================================================================

;; Check if list contains element
(: contains (-> (List $a) $a Bool))
(= (contains Nil $_) False)
(= (contains (Cons $x $_) $x) True)
(= (contains (Cons $_ $tail) $elem) (contains $tail $elem))

;; Count scenarios by tag
(: count-by-tag (-> Symbol Number))
(= (count-by-tag $tag)
   (let $scenarios (get-scenarios-by-tag $tag)
     (length $scenarios)))

;; Count scenarios by risk level
(: count-by-risk (-> Symbol Number))
(= (count-by-risk $risk)
   (let $scenarios (get-scenarios-by-risk $risk)
     (length $scenarios)))

;; =============================================================================
;; Validation Functions
;; =============================================================================

;; Validate that scenario has all required fields
(: validate-scenario (-> EthicalScenario Bool))
(= (validate-scenario (scenario $id $desc $tags $risk $ctx $goals $antigoals $metrics $plan $hint))
   (and (not (== $id Empty))
        (and (not (== $desc ""))
             (and (not (== $goals Nil))
                  (and (not (== $metrics Nil))
                       (not (== $plan Nil)))))))

;; Validate scenario context has required fields
(: validate-scenario-context (-> ScenarioContext Bool))
(= (validate-scenario-context (scenario-context $loc $state $danger $_))
   (and (not (== $loc Empty))
        (and (not (== $state Empty))
             (not (== $danger Empty)))))

;; =============================================================================
;; Scenario Statistics
;; =============================================================================

;; Get total scenario count
(: total-scenarios (-> Number))
(= (total-scenarios)
   (length (list-scenarios)))

;; Get scenario coverage by category
(: scenario-coverage (-> (List (Tuple Symbol Number))))
(= (scenario-coverage)
   (list
     (Tuple safety (count-by-tag safety))
     (Tuple fairness (count-by-tag fairness))
     (Tuple autonomy (count-by-tag autonomy))
     (Tuple alignment (count-by-tag alignment))
     (Tuple learning (count-by-tag learning))
     (Tuple resilience (count-by-tag resilience))))

;; =============================================================================
;; Export Functions
;; =============================================================================

(= (scenarios-exports)
   (list
     register-scenario
     get-scenario
     list-scenarios
     get-scenarios-by-tag
     get-scenarios-by-risk
     validate-scenario
     eval-metric
     scenario-coverage
     total-scenarios))

!(println "Ethical Scenario Schema Loaded")
!(println "ADTs: EthicalScenario, Context, SuccessMetric, ExpectedAction")
!(println "Functions: register-scenario, get-scenario, eval-metric, validate-scenario")
