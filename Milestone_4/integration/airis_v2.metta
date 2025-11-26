;; MAGUS Milestone 4: AIRIS Integration v2
;; Enhanced AIRIS integration with ethical scenario support
;; Implements IN1: Include scenario-id, ethical-notes, and rationale hints

;; Import dependencies
!(import! &self ../ethical/scenarios.metta)
!(import! &self ../Milestone_3/core/scoring-v2.metta)

;; =============================================================================
;; AIRIS Output Schema v2 (Enhanced)
;; =============================================================================

;; Enhanced AIRIS output with ethical context
(: airis-output-v2 (->
    Symbol              ;; action
    (List $a)           ;; parameters
    (List String)       ;; hints (procedural guidance)
    Symbol              ;; scenario-id (new in v2)
    String              ;; ethical-notes (new in v2)
    Number              ;; decision-score (new in v2)
    (List (Tuple Symbol Number))  ;; metagoal-breakdown (new in v2)
    (List (Tuple Symbol Number))  ;; antigoal-breakdown (new in v2)
    airis-output-v2))

;; =============================================================================
;; AIRIS Hint Generation
;; =============================================================================

;; Generate ethical hint for AIRIS UI
(: airis-ethical-hint (->
    Symbol              ;; scenario-id
    Number              ;; decision-score
    (List (Tuple Symbol Number))  ;; metagoal-breakdown
    (List (Tuple Symbol Number))  ;; antigoal-breakdown
    String))
(= (airis-ethical-hint $scenario-id $score $metagoals $antigoals)
   (concat-hint-parts
     $scenario-id
     $score
     (format-metagoal-contributions $metagoals)
     (format-antigoal-impacts $antigoals)))

;; Format metagoal contributions as string
(: format-metagoal-contributions (-> (List (Tuple Symbol Number)) String))
(= (format-metagoal-contributions Nil) "No metagoal adjustments")
(= (format-metagoal-contributions $breakdown)
   (concat-metagoal-items $breakdown))

;; Concatenate metagoal items
(: concat-metagoal-items (-> (List (Tuple Symbol Number)) String))
(= (concat-metagoal-items Nil) "")
(= (concat-metagoal-items (Cons (Tuple $name $delta) Nil))
   (format-metagoal-item $name $delta))
(= (concat-metagoal-items (Cons (Tuple $name $delta) $tail))
   (string-concat
     (format-metagoal-item $name $delta)
     ", "
     (concat-metagoal-items $tail)))

;; Format single metagoal item
(: format-metagoal-item (-> Symbol Number String))
(= (format-metagoal-item $name $delta)
   (string-concat
     (symbol-to-string $name)
     ": "
     (if (> $delta 0) "+" "")
     (number-to-string $delta)))

;; Format anti-goal impacts as string
(: format-antigoal-impacts (-> (List (Tuple Symbol Number)) String))
(= (format-antigoal-impacts Nil) "No anti-goal constraints")
(= (format-antigoal-impacts (Cons (Tuple hard-veto $count) $_))
   (string-concat
     "HARD VETO: "
     (number-to-string $count)
     " candidates rejected"))
(= (format-antigoal-impacts $breakdown)
   (concat-antigoal-items $breakdown))

;; Concatenate anti-goal items
(: concat-antigoal-items (-> (List (Tuple Symbol Number)) String))
(= (concat-antigoal-items Nil) "")
(= (concat-antigoal-items (Cons (Tuple $name $penalty) Nil))
   (format-antigoal-item $name $penalty))
(= (concat-antigoal-items (Cons (Tuple $name $penalty) $tail))
   (string-concat
     (format-antigoal-item $name $penalty)
     ", "
     (concat-antigoal-items $tail)))

;; Format single anti-goal item
(: format-antigoal-item (-> Symbol Number String))
(= (format-antigoal-item $name $penalty)
   (string-concat
     (symbol-to-string $name)
     " penalty: "
     (number-to-string $penalty)))

;; Concatenate hint parts
(: concat-hint-parts (-> Symbol Number String String String))
(= (concat-hint-parts $scenario-id $score $mg-text $ag-text)
   (string-concat
     "[Scenario: "
     (symbol-to-string $scenario-id)
     "] Score: "
     (number-to-string $score)
     " | Metagoals: "
     $mg-text
     " | Anti-goals: "
     $ag-text))

;; =============================================================================
;; String Utilities (Placeholders for actual implementation)
;; =============================================================================

(: string-concat (-> String String String))
(= (string-concat $a $b) (concat $a $b))

(: string-concat (-> String String String String))
(= (string-concat $a $b $c) (concat $a (concat $b $c)))

(: symbol-to-string (-> Symbol String))
(= (symbol-to-string $sym)
   ;; Placeholder - would use actual symbol->string conversion
   "symbol")

(: number-to-string (-> Number String))
(= (number-to-string $num)
   ;; Placeholder - would use actual number->string conversion
   "0.0")

(: concat (-> String String String))
(= (concat $a $b)
   ;; Placeholder - would use actual string concatenation
   "concatenated")

;; =============================================================================
;; Candidate to AIRIS Output Conversion v2
;; =============================================================================

;; Convert scored candidate to AIRIS output with ethical context
(: candidate-to-airis-output-v2 (->
    Candidate
    Symbol              ;; scenario-id
    (List (Tuple Symbol Number))  ;; metagoal-breakdown
    (List (Tuple Symbol Number))  ;; antigoal-breakdown
    airis-output-v2))
(= (candidate-to-airis-output-v2
     (candidate $action $params $score $hints)
     $scenario-id
     $metagoals
     $antigoals)
   (airis-output-v2
     $action
     $params
     $hints
     $scenario-id
     (airis-ethical-hint $scenario-id $score $metagoals $antigoals)
     $score
     $metagoals
     $antigoals))

;; =============================================================================
;; AIRIS Output Field Accessors v2
;; =============================================================================

(: airis-action (-> airis-output-v2 Symbol))
(= (airis-action (airis-output-v2 $action $_ $_ $_ $_ $_ $_ $_)) $action)

(: airis-parameters (-> airis-output-v2 (List $a)))
(= (airis-parameters (airis-output-v2 $_ $params $_ $_ $_ $_ $_ $_)) $params)

(: airis-hints (-> airis-output-v2 (List String)))
(= (airis-hints (airis-output-v2 $_ $_ $hints $_ $_ $_ $_ $_)) $hints)

(: airis-scenario-id (-> airis-output-v2 Symbol))
(= (airis-scenario-id (airis-output-v2 $_ $_ $_ $scenario-id $_ $_ $_ $_)) $scenario-id)

(: airis-ethical-notes (-> airis-output-v2 String))
(= (airis-ethical-notes (airis-output-v2 $_ $_ $_ $_ $notes $_ $_ $_)) $notes)

(: airis-decision-score (-> airis-output-v2 Number))
(= (airis-decision-score (airis-output-v2 $_ $_ $_ $_ $_ $score $_ $_)) $score)

(: airis-metagoal-breakdown (-> airis-output-v2 (List (Tuple Symbol Number))))
(= (airis-metagoal-breakdown (airis-output-v2 $_ $_ $_ $_ $_ $_ $mg $_)) $mg)

(: airis-antigoal-breakdown (-> airis-output-v2 (List (Tuple Symbol Number))))
(= (airis-antigoal-breakdown (airis-output-v2 $_ $_ $_ $_ $_ $_ $_ $ag)) $ag)

;; =============================================================================
;; AIRIS Execution Engine Integration
;; =============================================================================

;; Execute action via AIRIS with ethical logging
(: execute-airis-action-v2 (->
    airis-output-v2
    Context
    Symbol              ;; status (success/failure/partial)
    ))
(= (execute-airis-action-v2 $output $context $status)
   (let* (($action (airis-action $output))
          ($params (airis-parameters $output))
          ($scenario-id (airis-scenario-id $output))
          ($notes (airis-ethical-notes $output)))
     ;; Log execution to ethical log
     (trace-ethical-step
       $scenario-id
       1
       (airis-decision-score $output)
       (airis-metagoal-breakdown $output)
       (airis-antigoal-breakdown $output)
       $output
       $status
       0.0
       $notes)
     ;; Placeholder for actual AIRIS execution
     ()))

;; =============================================================================
;; JSON Serialization for AIRIS API
;; =============================================================================

;; Serialize AIRIS output to JSON-compatible structure
(: airis-to-json (-> airis-output-v2 (List (Tuple Symbol $a))))
(= (airis-to-json (airis-output-v2 $action $params $hints $scenario-id $notes $score $mg $ag))
   (list
     (Tuple action $action)
     (Tuple parameters $params)
     (Tuple hints $hints)
     (Tuple scenarioId $scenario-id)
     (Tuple ethicalNotes $notes)
     (Tuple decisionScore $score)
     (Tuple metagoalBreakdown $mg)
     (Tuple antigoalBreakdown $ag)))

;; =============================================================================
;; Priority Conversion (from M3 integration-airis.metta)
;; =============================================================================

;; Convert floating-point score to AIRIS priority level
(: score-to-airis-priority (-> Number Symbol))
(= (score-to-airis-priority $score)
   (cond
     ((>= $score 0.8) high)
     ((>= $score 0.5) medium)
     ((>= $score 0.2) low)
     (otherwise very-low)))

;; Floor function (from M3)
(: floor (-> Number Number))
(= (floor $x)
   (if (< $x 0)
       (- 0 (ceiling (- 0 $x)))
       (truncate $x)))

(: truncate (-> Number Number))
(= (truncate $x) $x)  ;; Placeholder - actual truncation

(: ceiling (-> Number Number))
(= (ceiling $x) $x)  ;; Placeholder - actual ceiling

;; =============================================================================
;; Backward Compatibility
;; =============================================================================

;; Convert v2 output to v1 format for legacy systems
(: airis-output-v2-to-v1 (-> airis-output-v2 airis-output))
(= (airis-output-v2-to-v1 (airis-output-v2 $action $params $hints $_ $_ $_ $_ $_))
   (airis-output $action $params $hints))

;; Legacy output type (from M3)
(: airis-output (-> Symbol (List $a) (List String) airis-output))

;; =============================================================================
;; Export Functions
;; =============================================================================

(= (airis-v2-exports)
   (list
     candidate-to-airis-output-v2
     airis-ethical-hint
     execute-airis-action-v2
     airis-to-json
     score-to-airis-priority
     airis-output-v2-to-v1))

!(println "AIRIS Integration v2 Loaded")
!(println "Enhanced output: scenario-id, ethical-notes, metagoal/antigoal breakdowns")
!(println "Functions: candidate-to-airis-output-v2, airis-ethical-hint, execute-airis-action-v2")
