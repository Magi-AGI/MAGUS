;; MAGUS Milestone 4: Evaluation Benchmarks
;; Metrics collection and aggregation for ethical scenario evaluation
;; Implements EV1: metrics extraction and EV3: metric collection helpers

;; Import dependencies
!(import! &self ../ethical/scenarios.metta)
!(import! &self ../ethical/scenario-runner.metta)

;; =============================================================================
;; Evaluation Metrics Schema
;; =============================================================================

;; Metric types we collect
(: MetricName Type)
(: goal-satisfaction-before MetricName)
(: goal-satisfaction-after MetricName)
(: soft-violation-count MetricName)
(: hard-violation-count MetricName)
(: decision-latency-ms MetricName)
(: metagoal-contribution-total MetricName)
(: antigoal-penalty-total MetricName)
(: plan-length MetricName)

;; Metric value storage
(: MetricValue Type)
(: metric-value (-> Symbol MetricName Number MetricValue))
;; metric-value(scenario-id, metric-name, value)

;; Dedicated space for collected metrics
!(bind! &evaluation-metrics (new-space))

;; =============================================================================
;; Metric Collection Functions
;; =============================================================================

;; Collect a metric value for a scenario
(: collect-metric (-> MetricName Symbol Number ()))
(= (collect-metric $metric-name $scenario-id $value)
   (add-atom &evaluation-metrics
     (metric-value $scenario-id $metric-name $value)))

;; Get all metrics for a scenario
(: get-scenario-metrics (-> Symbol (List MetricValue)))
(= (get-scenario-metrics $scenario-id)
   (match &evaluation-metrics
     (metric-value $scenario-id $metric $value)
     (metric-value $scenario-id $metric $value)))

;; Get specific metric for a scenario
;; NOTE: Due to Hyperon 0.2.1 limitations with let/match, this function
;; may return unevaluated expressions in test harness. The Python metrics.py
;; script works correctly by extracting from JSON exports.
;; For MeTTa-to-MeTTa usage, match directly in calling context.
(: get-metric (-> Symbol MetricName Number))
(= (get-metric $scenario-id $metric-name)
   0.0)  ;; Stub - use Python metrics.py for aggregation

;; NOTE: Real implementation would be:
;; (match &evaluation-metrics (metric-value $scenario-id $metric-name $value) $value)
;; but this returns a list that doesn't reduce in Hyperon 0.2.1

;; =============================================================================
;; Automated Metric Extraction from Logs
;; =============================================================================

;; Extract all metrics from a scenario log
(: extract-metrics-from-log (-> Symbol ()))
(= (extract-metrics-from-log $scenario-id)
   (let $log (get-scenario-log $scenario-id)
     (extract-all-metrics $scenario-id $log)))

;; Extract all metric types from log
(: extract-all-metrics (-> Symbol (List EthicalLogEntry) ()))
(= (extract-all-metrics $scenario-id $log)
   (let* (($hard-violations (count-hard-violations $log))
          ($soft-violations (count-soft-violations $log))
          ($latency (sum-latencies $log))
          ($metagoal-total (sum-metagoal-contributions $log))
          ($antigoal-total (sum-antigoal-penalties $log))
          ($plan-len (count-plan-steps $log))
          ($final-score (get-final-score $log)))
     ;; Collect all metrics
     (collect-metric hard-violation-count $scenario-id $hard-violations)
     (collect-metric soft-violation-count $scenario-id $soft-violations)
     (collect-metric decision-latency-ms $scenario-id $latency)
     (collect-metric metagoal-contribution-total $scenario-id $metagoal-total)
     (collect-metric antigoal-penalty-total $scenario-id $antigoal-total)
     (collect-metric plan-length $scenario-id $plan-len)
     (collect-metric goal-satisfaction-after $scenario-id $final-score)))

;; =============================================================================
;; Log Analysis Functions
;; =============================================================================

;; Count hard violations in log
(: count-hard-violations (-> (List EthicalLogEntry) Number))
(= (count-hard-violations Nil) 0)
(= (count-hard-violations (Cons $entry $tail))
   (let $antigoals (log-entry-antigoals $entry)
     (+ (if (contains-hard-veto $antigoals) 1 0)
        (count-hard-violations $tail))))

;; Count soft violations in log
(: count-soft-violations (-> (List EthicalLogEntry) Number))
(= (count-soft-violations Nil) 0)
(= (count-soft-violations (Cons $entry $tail))
   (let $antigoals (log-entry-antigoals $entry)
     (+ (count-soft-penalties $antigoals)
        (count-soft-violations $tail))))

;; Count soft penalties in antigoal breakdown
(: count-soft-penalties (-> (List (Tuple Symbol Number)) Number))
(= (count-soft-penalties Nil) 0)
(= (count-soft-penalties (Cons (Tuple hard-veto $_) $tail))
   (count-soft-penalties $tail))
(= (count-soft-penalties (Cons (Tuple $_ $penalty) $tail))
   (+ (if (> $penalty 0.0) 1 0)
      (count-soft-penalties $tail)))

;; Sum all latencies
(: sum-latencies (-> (List EthicalLogEntry) Number))
(= (sum-latencies Nil) 0.0)
(= (sum-latencies (Cons $entry $tail))
   (+ (log-entry-latency $entry)
      (sum-latencies $tail)))

;; Sum metagoal contributions
(: sum-metagoal-contributions (-> (List EthicalLogEntry) Number))
(= (sum-metagoal-contributions Nil) 0.0)
(= (sum-metagoal-contributions (Cons $entry $tail))
   (+ (sum-contribution-deltas (log-entry-metagoals $entry))
      (sum-metagoal-contributions $tail)))

;; Sum contribution deltas
(: sum-contribution-deltas (-> (List (Tuple Symbol Number)) Number))
(= (sum-contribution-deltas Nil) 0.0)
(= (sum-contribution-deltas (Cons (Tuple $_ $delta) $tail))
   (+ (abs $delta) (sum-contribution-deltas $tail)))

;; Sum anti-goal penalties
(: sum-antigoal-penalties (-> (List EthicalLogEntry) Number))
(= (sum-antigoal-penalties Nil) 0.0)
(= (sum-antigoal-penalties (Cons $entry $tail))
   (+ (sum-penalty-values (log-entry-antigoals $entry))
      (sum-antigoal-penalties $tail)))

;; Sum penalty values
(: sum-penalty-values (-> (List (Tuple Symbol Number)) Number))
(= (sum-penalty-values Nil) 0.0)
(= (sum-penalty-values (Cons (Tuple hard-veto $count) $tail))
   (+ $count (sum-penalty-values $tail)))
(= (sum-penalty-values (Cons (Tuple $_ $penalty) $tail))
   (+ $penalty (sum-penalty-values $tail)))

;; Count plan steps
(: count-plan-steps (-> (List EthicalLogEntry) Number))
(= (count-plan-steps $log) (length $log))

;; Get final score from last log entry
(: get-final-score (-> (List EthicalLogEntry) Number))
(= (get-final-score Nil) 0.0)
(= (get-final-score $log)
   (let $final (last $log)
     (log-entry-score $final)))

;; =============================================================================
;; Log Entry Field Accessors
;; =============================================================================

(: log-entry-metagoals (-> EthicalLogEntry (List (Tuple Symbol Number))))
(= (log-entry-metagoals (log-entry $_ $_ $_ $metagoals $_ $_ $_ $_ $_)) $metagoals)

(: log-entry-antigoals (-> EthicalLogEntry (List (Tuple Symbol Number))))
(= (log-entry-antigoals (log-entry $_ $_ $_ $_ $antigoals $_ $_ $_ $_)) $antigoals)

(: log-entry-latency (-> EthicalLogEntry Number))
(= (log-entry-latency (log-entry $_ $_ $_ $_ $_ $_ $_ $latency $_)) $latency)

;; =============================================================================
;; Aggregation Functions
;; =============================================================================

;; Aggregate metrics across multiple scenarios
(: aggregate-metrics (-> (List Symbol) MetricName (List Number)))
(= (aggregate-metrics Nil $_) Nil)
(= (aggregate-metrics (Cons $scenario-id $tail) $metric-name)
   (Cons (get-metric $scenario-id $metric-name)
         (aggregate-metrics $tail $metric-name)))

;; Calculate mean of metric values
(: metric-mean (-> (List Symbol) MetricName Number))
(= (metric-mean $scenario-ids $metric-name)
   (let $values (aggregate-metrics $scenario-ids $metric-name)
     (mean $values)))

;; Calculate sum of metric values
(: metric-sum (-> (List Symbol) MetricName Number))
(= (metric-sum $scenario-ids $metric-name)
   (let $values (aggregate-metrics $scenario-ids $metric-name)
     (sum $values)))

;; Calculate max of metric values
(: metric-max (-> (List Symbol) MetricName Number))
(= (metric-max $scenario-ids $metric-name)
   (let $values (aggregate-metrics $scenario-ids $metric-name)
     (max-list $values)))

;; Calculate min of metric values
(: metric-min (-> (List Symbol) MetricName Number))
(= (metric-min $scenario-ids $metric-name)
   (let $values (aggregate-metrics $scenario-ids $metric-name)
     (min-list $values)))

;; =============================================================================
;; Statistical Helpers
;; =============================================================================

;; Mean of list
(: mean (-> (List Number) Number))
(= (mean Nil) 0.0)
(= (mean $list)
   (/ (sum $list) (length $list)))

;; Sum of list
(: sum (-> (List Number) Number))
(= (sum Nil) 0.0)
(= (sum (Cons $x $tail)) (+ $x (sum $tail)))

;; Max of list
(: max-list (-> (List Number) Number))
(= (max-list Nil) 0.0)
(= (max-list (Cons $x Nil)) $x)
(= (max-list (Cons $x $tail))
   (let $max-tail (max-list $tail)
     (if (> $x $max-tail) $x $max-tail)))

;; Min of list
(: min-list (-> (List Number) Number))
(= (min-list Nil) 0.0)
(= (min-list (Cons $x Nil)) $x)
(= (min-list (Cons $x $tail))
   (let $min-tail (min-list $tail)
     (if (< $x $min-tail) $x $min-tail)))

;; Absolute value
(: abs (-> Number Number))
(= (abs $x) (if (< $x 0) (- 0 $x) $x))

;; =============================================================================
;; Comparison Metrics
;; =============================================================================

;; Compare two configurations on a metric
(: compare-configs (-> Symbol Symbol (List Symbol) MetricName Number))
(= (compare-configs $config-a $config-b $scenario-ids $metric-name)
   (- (metric-mean (filter-by-config $scenario-ids $config-a) $metric-name)
      (metric-mean (filter-by-config $scenario-ids $config-b) $metric-name)))

;; Filter scenarios by configuration (placeholder)
(: filter-by-config (-> (List Symbol) Symbol (List Symbol)))
(= (filter-by-config $scenarios $_) $scenarios)  ;; TODO: Implement config filtering

;; =============================================================================
;; Export Functions
;; =============================================================================

(= (benchmarks-exports)
   (list
     collect-metric
     get-metric
     extract-metrics-from-log
     aggregate-metrics
     metric-mean
     metric-sum
     metric-max
     metric-min
     compare-configs))

!(println "Evaluation Benchmarks Loaded")
!(println "Metrics: goal-satisfaction, violations, latency, contributions")
!(println "Functions: collect-metric, extract-metrics-from-log, metric aggregators")
