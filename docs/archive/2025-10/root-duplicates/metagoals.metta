;; MAGUS Milestone 3: Metagoals Module (Refined)
;; Provides metagoal representations, evaluation, and goal promotion/demotion
;; Implements metrics windowing with thresholds and hysteresis
;; Based on Milestone-3-Spec.md requirements and M3-Refinement-Plan.md

;; Import shared types
!(load types.metta)

;; Import M2 metrics if available
;; !(load ../Milestone_2/goal-fitness-metrics/measurability.metta)
;; !(load ../Milestone_2/goal-fitness-metrics/correlation.metta)

;; =============================================================================
;; Metagoal-specific Functions
;; =============================================================================

;; Check if a metric record is within the window
(: in-window (-> MetricRecord MetricWindow Bool))
(= (in-window (metric-record $goal $value $timestamp)
              (metric-window $start $end))
   (if (and (>= $timestamp $start) (<= $timestamp $end))
       True
       False))

;; Named predicate for filter - checks if record is in window
(: is-in-window (-> MetricWindow MetricRecord Bool))
(= (is-in-window $window $record)
   (in-window $record $window))

;; Filter metrics within a time window using named predicate
(: filter-metrics (-> (List MetricRecord) MetricWindow (List MetricRecord)))
(= (filter-metrics Nil $window) Nil)
(= (filter-metrics (Cons $record $tail) $window)
   (if (in-window $record $window)
       (Cons $record (filter-metrics $tail $window))
       (filter-metrics $tail $window)))

;; Count metrics for a specific goal
(: count-goal-metrics (-> Goal (List MetricRecord) Number))
(= (count-goal-metrics $goal Nil) 0)
(= (count-goal-metrics $goal (Cons (metric-record $g $v $t) $tail))
   (if (== $g $goal)
       (+ 1 (count-goal-metrics $goal $tail))
       (count-goal-metrics $goal $tail)))

;; =============================================================================
;; Metrics Tracking with M2 Integration
;; =============================================================================

;; Create a new metric window
(= (create-window $duration $current-time)
   (metric-window (- $current-time $duration) $current-time))

;; Calculate rolling measurability for a goal
;; This would integrate with M2's get-measurability if available
(: get-rolling-measurability (-> Goal (List MetricRecord) MetricWindow Number))
(= (get-rolling-measurability $goal $metrics $window)
   (let* (($filtered (filter-metrics $metrics $window))
          ($count (count-goal-metrics $goal $filtered))
          ((metric-window $start $end) $window)
          ($duration (- $end $start)))
     (if (> $duration 0)
         (/ $count $duration)
         0)))

;; Calculate rolling correlation between goals
;; This would integrate with M2's get-correlation if available
(: get-rolling-correlation (-> Goal Goal (List MetricRecord) MetricWindow Number))
(= (get-rolling-correlation $goal1 $goal2 $metrics $window)
   (let (($filtered (filter-metrics $metrics $window)))
     (calculate-correlation $goal1 $goal2 $filtered)))

;; Placeholder for actual correlation calculation
;; Should be replaced with M2 implementation
(: calculate-correlation (-> Goal Goal (List MetricRecord) Number))
(= (calculate-correlation $g1 $g2 $metrics)
   0.5)  ;; TODO: Use M2's get-correlation

;; =============================================================================
;; Metagoal Classes with Evaluation
;; =============================================================================

;; Coherence metagoal: promotes consistency across goals
(= (coherence-metagoal)
   (metagoal coherence))

;; Efficiency metagoal: optimizes for resource usage
(= (efficiency-metagoal)
   (metagoal efficiency))

;; Learning/Growth metagoal: promotes novelty and value
(= (learning-metagoal)
   (metagoal learning))

;; Uncertainty reduction metagoal
(= (uncertainty-metagoal)
   (metagoal uncertainty-reduction))

;; Evaluate a metagoal to produce weight adjustments
(: evaluate-metagoal (-> Metagoal Context (List Goal) (List WeightAdjustment)))
(= (evaluate-metagoal (metagoal coherence) $context $goalset)
   (coherence-adjustments $goalset $context))

(= (evaluate-metagoal (metagoal efficiency) $context $goalset)
   (efficiency-adjustments $goalset $context))

(= (evaluate-metagoal (metagoal learning) $context $goalset)
   (learning-adjustments $goalset $context))

(= (evaluate-metagoal (metagoal uncertainty-reduction) $context $goalset)
   (uncertainty-adjustments $goalset $context))

;; Helper for coherence calculation
(: coherence-helper (-> Goal (List Goal) WeightAdjustment))
(= (coherence-helper $goal $others)
   (weight-adj $goal (coherence-score $goal $others)))

;; Coherence adjustments - boost mutually supporting goals
(: coherence-adjustments (-> (List Goal) Context (List WeightAdjustment)))
(= (coherence-adjustments Nil $context) Nil)
(= (coherence-adjustments (Cons $goal $tail) $context)
   (Cons (coherence-helper $goal $tail)
         (coherence-adjustments $tail $context)))

;; Calculate coherence score for a goal relative to others
(: coherence-score (-> Goal (List Goal) Number))
(= (coherence-score $goal Nil) 0)
(= (coherence-score $goal (Cons $other $tail))
   (+ (if (goals-coherent $goal $other) 0.1 0)
      (coherence-score $goal $tail)))

;; Check if two goals are coherent
(: goals-coherent (-> Goal Goal Bool))
(= (goals-coherent $g1 $g2) True)  ;; TODO: Implement actual coherence check

;; Helper for efficiency calculation
(: efficiency-helper (-> Goal Context WeightAdjustment))
(= (efficiency-helper $goal $context)
   (weight-adj $goal (- 0 (estimate-cost $goal $context))))

;; Efficiency adjustments - penalize resource-heavy goals
(: efficiency-adjustments (-> (List Goal) Context (List WeightAdjustment)))
(= (efficiency-adjustments Nil $context) Nil)
(= (efficiency-adjustments (Cons $goal $tail) $context)
   (Cons (efficiency-helper $goal $context)
         (efficiency-adjustments $tail $context)))

;; Estimate cost of a goal
(: estimate-cost (-> Goal Context Number))
(= (estimate-cost (goal $name $priority $weight) $context)
   (* $weight 0.5))  ;; Placeholder cost calculation

;; Helper for learning calculation
(: learning-helper (-> Goal Context WeightAdjustment))
(= (learning-helper $goal $context)
   (weight-adj $goal (novelty-score $goal $context)))

;; Learning adjustments - boost novel goals
(: learning-adjustments (-> (List Goal) Context (List WeightAdjustment)))
(= (learning-adjustments Nil $context) Nil)
(= (learning-adjustments (Cons $goal $tail) $context)
   (Cons (learning-helper $goal $context)
         (learning-adjustments $tail $context)))

;; Calculate novelty score
(: novelty-score (-> Goal Context Number))
(= (novelty-score $goal $context) 0.2)  ;; Placeholder

;; Helper for uncertainty calculation
(: uncertainty-helper (-> Goal Context WeightAdjustment))
(= (uncertainty-helper $goal $context)
   (weight-adj $goal (uncertainty-value $goal $context)))

;; Uncertainty adjustments - prioritize uncertainty reduction
(: uncertainty-adjustments (-> (List Goal) Context (List WeightAdjustment)))
(= (uncertainty-adjustments Nil $context) Nil)
(= (uncertainty-adjustments (Cons $goal $tail) $context)
   (Cons (uncertainty-helper $goal $context)
         (uncertainty-adjustments $tail $context)))

;; Calculate uncertainty reduction value
(: uncertainty-value (-> Goal Context Number))
(= (uncertainty-value $goal $context) 0.1)  ;; Placeholder

;; =============================================================================
;; Promotion and Demotion Logic with Hysteresis
;; =============================================================================

;; Configuration parameters with hysteresis
(= (promotion-measurability-threshold) 0.7)
(= (promotion-correlation-threshold) 0.8)
(= (demotion-measurability-threshold) 0.3)
(= (demotion-correlation-threshold) 0.2)
(= (evaluation-window-duration) 1000)  ;; Time units
(= (hysteresis-factor) 0.1)  ;; Prevents oscillation

;; Promote signals to subgoals when thresholds are met
(: promote-to-subgoal (-> Goal Goal (List MetricRecord) Number Goal))
(= (promote-to-subgoal $signal $parent-goal $metrics $current-time)
   (let* (($window (create-window (evaluation-window-duration) $current-time))
          ($measurability (get-rolling-measurability $signal $metrics $window))
          ($correlation (get-rolling-correlation $signal $parent-goal $metrics $window))
          ($m-threshold (- (promotion-measurability-threshold) (hysteresis-factor)))
          ($c-threshold (- (promotion-correlation-threshold) (hysteresis-factor))))
     (if (and (> $measurability $m-threshold)
              (> $correlation $c-threshold))
         (create-subgoal $signal $parent-goal
                        (justification promoted $measurability $correlation))
         $signal)))

;; Create a subgoal from a signal
(: create-subgoal (-> Goal Goal Justification Goal))
(= (create-subgoal (goal $name $p $w) $parent $justification)
   (goal (subgoal-of $name $parent) $p (* $w 0.8)))

;; Demote or remove underperforming goals
(: demote-goal (-> Goal (List MetricRecord) Number Goal))
(= (demote-goal $goal $metrics $current-time)
   (let* (($window (create-window (evaluation-window-duration) $current-time))
          ($measurability (get-rolling-measurability $goal $metrics $window))
          ($m-threshold (+ (demotion-measurability-threshold) (hysteresis-factor))))
     (if (< $measurability $m-threshold)
         (reduce-goal-weight $goal (justification demoted $measurability 0))
         $goal)))

;; Reduce goal weight
(: reduce-goal-weight (-> Goal Justification Goal))
(= (reduce-goal-weight (goal $name $priority $weight) $justification)
   (goal $name $priority (* $weight 0.5)))

;; =============================================================================
;; Goal Adjustment Pipeline
;; =============================================================================

;; Apply weight adjustments to goals
(: apply-adjustments (-> (List Goal) (List WeightAdjustment) (List Goal)))
(= (apply-adjustments Nil $adjustments) Nil)
(= (apply-adjustments (Cons $goal $tail) $adjustments)
   (Cons (apply-goal-adjustment $goal $adjustments)
         (apply-adjustments $tail $adjustments)))

;; Apply adjustment to a single goal
(: apply-goal-adjustment (-> Goal (List WeightAdjustment) Goal))
(= (apply-goal-adjustment $goal Nil) $goal)
(= (apply-goal-adjustment $goal (Cons (weight-adj $g $delta) $tail))
   (if (== $goal $g)
       (adjust-weight $goal $delta)
       (apply-goal-adjustment $goal $tail)))

;; Adjust goal weight
(: adjust-weight (-> Goal Number Goal))
(= (adjust-weight (goal $name $priority $weight) $delta)
   (goal $name $priority (+ $weight $delta)))

;; Named accumulator for fold
(: metagoal-fold-helper (-> (List Goal) Metagoal Context (List Goal)))
(= (metagoal-fold-helper $goals $metagoal $context)
   (let* (($adjustments (evaluate-metagoal $metagoal $context $goals)))
     (apply-adjustments $goals $adjustments)))

;; Evaluate all metagoals and combine adjustments
(: evaluate-all-metagoals (-> Context (List Goal) (List Metagoal) (List Goal)))
(= (evaluate-all-metagoals $context $goalset Nil) $goalset)
(= (evaluate-all-metagoals $context $goalset (Cons $metagoal $tail))
   (let* (($updated (metagoal-fold-helper $goalset $metagoal $context)))
     (evaluate-all-metagoals $context $updated $tail)))

;; Apply decay to prevent oscillations
(: apply-decay (-> Number Number Number))
(= (apply-decay $adjustment $time-since-last)
   (let (($decay-rate 0.95))
     (* $adjustment (pow $decay-rate $time-since-last))))

;; =============================================================================
;; Metagoal Adjustment Terms for Scoring Integration
;; =============================================================================

;; Calculate total metagoal adjustment for a specific goal
(: calculate-metagoal-adjustment (-> Goal Context (List Metagoal) Number))
(= (calculate-metagoal-adjustment $goal $context Nil) 0)
(= (calculate-metagoal-adjustment $goal $context (Cons $metagoal $tail))
   (+ (single-metagoal-adjustment $goal $context $metagoal)
      (calculate-metagoal-adjustment $goal $context $tail)))

;; Calculate adjustment from a single metagoal
(: single-metagoal-adjustment (-> Goal Context Metagoal Number))
(= (single-metagoal-adjustment $goal $context (metagoal coherence)) 0.1)
(= (single-metagoal-adjustment $goal $context (metagoal efficiency)) -0.05)
(= (single-metagoal-adjustment $goal $context (metagoal learning)) 0.15)
(= (single-metagoal-adjustment $goal $context (metagoal uncertainty-reduction)) 0.1)

;; =============================================================================
;; Audit and Logging
;; =============================================================================

;; Audit log space
!(bind! &audit-log (new-space))

;; Record promotion event with timestamp and justification
(: record-promotion (-> Goal Goal Justification Number ()))
(= (record-promotion $signal $parent-goal $justification $timestamp)
   (add-atom &audit-log
     (promotion-event $signal $parent-goal $justification $timestamp)))

;; Record demotion event with timestamp and justification
(: record-demotion (-> Goal Justification Number ()))
(= (record-demotion $goal $justification $timestamp)
   (add-atom &audit-log
     (demotion-event $goal $justification $timestamp)))

;; Query audit history for a specific goal
(: get-goal-history (-> Goal (List (Symbol Justification Number))))
(= (get-goal-history $goal)
   (match &audit-log
     ($event-type $g $justification $timestamp)
     (if (== $g $goal)
         (list $event-type $justification $timestamp)
         Empty)))

;; =============================================================================
;; Module Export
;; =============================================================================

;; Export main functions for use by other modules
(= (metagoals-module-exports)
   (list
     evaluate-all-metagoals
     promote-to-subgoal
     demote-goal
     calculate-metagoal-adjustment
     get-rolling-measurability
     get-rolling-correlation
     record-promotion
     record-demotion))