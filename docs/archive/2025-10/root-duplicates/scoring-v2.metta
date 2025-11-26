;; MAGUS Milestone 3: Scoring v2 Module (Refined)
;; Integrates base utility, metagoal adjustments, and anti-goal penalties
;; Provides explainability through structured score breakdowns
;; Based on Milestone-3-Spec.md requirements and M3-Refinement-Plan.md

;; Import shared types
!(load types.metta)

;; Import other modules
!(load metagoals.metta)
!(load antigoals.metta)

;; =============================================================================
;; Additional Types (beyond types.metta)
;; =============================================================================

;; Types are already defined in types.metta, just adding any missing ones here

;; =============================================================================
;; Base Utility Calculation (from v1)
;; =============================================================================

;; Calculate base utility from considerations and discouragements
(: calculate-base-utility (-> (List Consideration) (List Discouragement)
                              ScoringContext Number))
(= (calculate-base-utility $considerations $discouragements $context)
   (let* (($con-score (sum-considerations $considerations $context))
          ($dis-score (sum-discouragements $discouragements $context))
          ($modulated (apply-modulators (- $con-score $dis-score)
                                       (get-modulators $context))))
     $modulated))

;; Sum consideration scores
(: sum-considerations (-> (List Consideration) ScoringContext Number))
(= (sum-considerations Nil $context) 0)
(= (sum-considerations (Cons (consideration $name $fn) $tail) $context)
   (+ ($fn $context) (sum-considerations $tail $context)))

;; Sum discouragement scores
(: sum-discouragements (-> (List Discouragement) ScoringContext Number))
(= (sum-discouragements Nil $context) 0)
(= (sum-discouragements (Cons (discouragement $name $fn) $tail) $context)
   (+ ($fn $context) (sum-discouragements $tail $context)))

;; Get modulators from context
(: get-modulators (-> ScoringContext (List Modulator)))
(= (get-modulators (scoring-context $goals $modulators $time)) $modulators)

;; Apply modulators to base score
(: apply-modulators (-> Number (List Modulator) Number))
(= (apply-modulators $score Nil) $score)
(= (apply-modulators $score (Cons (modulator $name $value) $tail))
   (let (($modulated (* $score (modulator-effect $name $value))))
     (apply-modulators $modulated $tail)))

;; Calculate modulator effect
(: modulator-effect (-> Symbol Number Number))
(= (modulator-effect arousal $value) (+ 0.8 (* 0.4 $value)))  ;; 0.8 to 1.2
(= (modulator-effect pleasure $value) (+ 0.9 (* 0.2 $value))) ;; 0.9 to 1.1
(= (modulator-effect dominance $value) (+ 0.85 (* 0.3 $value))) ;; 0.85 to 1.15
(= (modulator-effect focus $value) (+ 0.7 (* 0.6 $value)))    ;; 0.7 to 1.3
(= (modulator-effect $other $value) 1.0)  ;; No effect for unknown

;; =============================================================================
;; Metagoal Integration
;; =============================================================================

;; Named helper for metagoal fold operation
(: metagoal-score-helper (-> Metagoal Goal ScoringContext Number Number))
(= (metagoal-score-helper $metagoal $goal $context $acc)
   (+ $acc (single-metagoal-score $goal $context $metagoal)))

;; Calculate metagoal adjustment using imported functions
(: calculate-metagoal-adjustment-v2 (-> Goal ScoringContext (List Metagoal) Number))
(= (calculate-metagoal-adjustment-v2 $goal $context Nil) 0)
(= (calculate-metagoal-adjustment-v2 $goal $context (Cons $metagoal $tail))
   (+ (single-metagoal-score $goal $context $metagoal)
      (calculate-metagoal-adjustment-v2 $goal $context $tail)))

;; Calculate single metagoal contribution
(: single-metagoal-score (-> Goal ScoringContext Metagoal Number))
(= (single-metagoal-score $goal $context (metagoal coherence))
   (* 0.1 (goal-coherence-score $goal $context)))
(= (single-metagoal-score $goal $context (metagoal efficiency))
   (* -0.05 (goal-inefficiency-score $goal $context)))
(= (single-metagoal-score $goal $context (metagoal learning))
   (* 0.15 (goal-novelty-score $goal $context)))
(= (single-metagoal-score $goal $context (metagoal uncertainty-reduction))
   (* 0.1 (goal-uncertainty-value $goal $context)))

;; Goal coherence score - measures compatibility with other goals
(: goal-coherence-score (-> Goal ScoringContext Number))
(= (goal-coherence-score $goal (scoring-context $goals $mods $time))
   (count-coherent-goals $goal $goals))

;; Count coherent goals
(: count-coherent-goals (-> Goal (List Goal) Number))
(= (count-coherent-goals $goal Nil) 0)
(= (count-coherent-goals $goal (Cons $other $tail))
   (if (goals-compatible $goal $other)
       (+ 1 (count-coherent-goals $goal $tail))
       (count-coherent-goals $goal $tail)))

;; Check goal compatibility based on goal names
(: goals-compatible (-> Goal Goal Bool))
(= (goals-compatible (goal $n1 $p1 $w1) (goal $n2 $p2 $w2))
   (check-goal-synergy $n1 $n2))

;; Goal synergy rules
(: check-goal-synergy (-> Symbol Symbol Bool))
(= (check-goal-synergy explore discover) True)
(= (check-goal-synergy discover learn) True)
(= (check-goal-synergy survive defend) True)
(= (check-goal-synergy attack dominate) True)
(= (check-goal-synergy build create) True)
(= (check-goal-synergy gather prepare) True)
(= (check-goal-synergy $g1 $g2)
   (if (== $g1 $g2) False False))  ;; Same goals don't synergize, different goals default to no synergy

;; Goal inefficiency score - estimates resource cost
(: goal-inefficiency-score (-> Goal ScoringContext Number))
(= (goal-inefficiency-score (goal $name $priority $weight) $context)
   (estimate-goal-cost $name $priority $weight))

;; Estimate resource cost of a goal
(: estimate-goal-cost (-> Symbol Number Number Number))
(= (estimate-goal-cost explore $p $w) (* $w 1.5))   ;; Medium cost
(= (estimate-goal-cost attack $p $w) (* $w 2.5))    ;; High cost
(= (estimate-goal-cost defend $p $w) (* $w 2.0))    ;; High cost
(= (estimate-goal-cost gather $p $w) (* $w 1.2))    ;; Low-medium cost
(= (estimate-goal-cost build $p $w) (* $w 3.0))     ;; Very high cost
(= (estimate-goal-cost learn $p $w) (* $w 0.8))     ;; Low cost
(= (estimate-goal-cost survive $p $w) (* $w 0.5))   ;; Very low cost
(= (estimate-goal-cost $other $p $w) (* $w 1.0))    ;; Default cost

;; Goal novelty score - measures unexplored potential
(: goal-novelty-score (-> Goal ScoringContext Number))
(= (goal-novelty-score (goal $name $priority $weight) $context)
   (calculate-novelty $name $context))

;; Calculate novelty based on goal type and context
(: calculate-novelty (-> Symbol ScoringContext Number))
(= (calculate-novelty explore $context) 0.8)    ;; High novelty
(= (calculate-novelty discover $context) 0.9)   ;; Very high novelty
(= (calculate-novelty learn $context) 0.7)      ;; High novelty
(= (calculate-novelty experiment $context) 1.0) ;; Maximum novelty
(= (calculate-novelty build $context) 0.5)      ;; Medium novelty
(= (calculate-novelty $routine $context) 0.2)   ;; Low novelty for routine goals

;; Goal uncertainty reduction value
(: goal-uncertainty-value (-> Goal ScoringContext Number))
(= (goal-uncertainty-value (goal $name $priority $weight) $context)
   (estimate-info-gain $name $priority))

;; Estimate information gain from achieving goal
(: estimate-info-gain (-> Symbol Number Number))
(= (estimate-info-gain explore $p) (* $p 0.6))
(= (estimate-info-gain scout $p) (* $p 0.7))
(= (estimate-info-gain investigate $p) (* $p 0.8))
(= (estimate-info-gain analyze $p) (* $p 0.9))
(= (estimate-info-gain test $p) (* $p 0.5))
(= (estimate-info-gain $other $p) (* $p 0.3))

;; =============================================================================
;; Anti-goal Integration
;; =============================================================================

;; Named helper for antigoal fold operation
(: antigoal-penalty-helper (-> AntiGoal Candidate ScoringContext Number Number))
(= (antigoal-penalty-helper $antigoal $candidate $context $acc)
   (* $acc (apply-single-antigoal $antigoal $context $candidate)))

;; Calculate anti-goal penalties
(: calculate-antigoal-penalty (-> Candidate ScoringContext (List AntiGoal) Number))
(= (calculate-antigoal-penalty $candidate $context Nil) 1.0)
(= (calculate-antigoal-penalty $candidate $context (Cons $antigoal $tail))
   (* (apply-single-antigoal $antigoal $context $candidate)
      (calculate-antigoal-penalty $candidate $context $tail)))

;; Apply single anti-goal
(: apply-single-antigoal (-> AntiGoal ScoringContext Candidate Number))
(= (apply-single-antigoal (anti-goal $name Hard $fn) $context $candidate)
   ($fn (scoring-to-antigoal-context $context) $candidate))
(= (apply-single-antigoal (anti-goal $name Soft $fn) $context $candidate)
   ($fn (scoring-to-antigoal-context $context) $candidate))

;; Convert scoring context to anti-goal context
(: scoring-to-antigoal-context (-> ScoringContext Context))
(= (scoring-to-antigoal-context (scoring-context $goals $mods $time))
   (context $goals $time))

;; =============================================================================
;; Complete Scoring Pipeline v2
;; =============================================================================

;; Main scoring function with full integration
(: score-decision-v2 (-> Candidate
                        (List Consideration)
                        (List Discouragement)
                        (List Metagoal)
                        (List AntiGoal)
                        ScoringContext
                        DecisionScore))
(= (score-decision-v2 $candidate $considerations $discouragements
                     $metagoals $antigoals $context)
   (let* (;; Calculate base utility
          ($base (calculate-base-utility $considerations $discouragements $context))
          ;; Calculate metagoal adjustments
          ($metagoal-adj (if (is-goal-candidate $candidate)
                            (calculate-metagoal-adjustment-v2
                              (extract-goal $candidate) $context $metagoals)
                            0))
          ;; Calculate anti-goal penalties (multiplicative)
          ($antigoal-factor (calculate-antigoal-penalty $candidate $context $antigoals))
          ;; Combine scores
          ($adjusted (+ $base $metagoal-adj))
          ($final (* $adjusted $antigoal-factor)))
     (decision-score $base $metagoal-adj (- 1 $antigoal-factor) $final)))

;; Check if candidate is a goal
(: is-goal-candidate (-> Candidate Bool))
(= (is-goal-candidate (goal-candidate $g)) True)
(= (is-goal-candidate (action-candidate $a)) False)

;; Extract goal from candidate
(: extract-goal (-> Candidate Goal))
(= (extract-goal (goal-candidate $g)) $g)

;; =============================================================================
;; Explainability and Breakdown
;; =============================================================================

;; Generate detailed score breakdown
(: generate-score-breakdown (-> DecisionScore (List ScoreComponent)))
(= (generate-score-breakdown (decision-score $base $meta $anti $final))
   (Cons (score-component base-utility $base "Base utility from considerations/discouragements")
   (Cons (score-component metagoal-adjustment $meta "Long-term strategic value")
   (Cons (score-component antigoal-penalty $anti "Risk and constraint penalties")
   (Cons (score-component final-score $final "Combined final score")
   Nil)))))

;; Format score breakdown for logging (simplified - string ops not in minimal MeTTa)
(: format-score-breakdown (-> (List ScoreComponent) (List ScoreComponent)))
(= (format-score-breakdown $components) $components)

;; =============================================================================
;; Configuration and Tuning
;; =============================================================================

;; Scoring weights configuration
(: ScoringWeights Type)
(: scoring-weights (-> Number Number Number ScoringWeights))
;; base_weight, metagoal_weight, antigoal_strength

;; Default weights
(= (default-scoring-weights)
   (scoring-weights 1.0 0.3 1.0))

;; Apply custom weights to scoring
(: score-with-weights (-> Candidate
                          (List Consideration)
                          (List Discouragement)
                          (List Metagoal)
                          (List AntiGoal)
                          ScoringContext
                          ScoringWeights
                          DecisionScore))
(= (score-with-weights $candidate $cons $dis $meta $anti $context
                      (scoring-weights $bw $mw $aw))
   (let* (($base (* $bw (calculate-base-utility $cons $dis $context)))
          ($meta-adj (* $mw (if (is-goal-candidate $candidate)
                               (calculate-metagoal-adjustment-v2
                                 (extract-goal $candidate) $context $meta)
                               0)))
          ($anti-penalty (calculate-antigoal-penalty $candidate $context $anti))
          ($anti-factor (if (== $aw 1.0)
                           $anti-penalty
                           (pow $anti-penalty $aw)))
          ($adjusted (+ $base $meta-adj))
          ($final (* $adjusted $anti-factor)))
     (decision-score $base $meta-adj (- 1 $anti-factor) $final)))

;; =============================================================================
;; Decision Ranking
;; =============================================================================

;; Rank multiple candidates by score
(: rank-decisions (-> (List Candidate)
                     (List Consideration)
                     (List Discouragement)
                     (List Metagoal)
                     (List AntiGoal)
                     ScoringContext
                     (List (Candidate DecisionScore))))
(= (rank-decisions $candidates $cons $dis $meta $anti $context)
   (sort-by-score
     (score-all-candidates $candidates $cons $dis $meta $anti $context)))

;; Score all candidates
(: score-all-candidates (-> (List Candidate)
                           (List Consideration)
                           (List Discouragement)
                           (List Metagoal)
                           (List AntiGoal)
                           ScoringContext
                           (List (Candidate DecisionScore))))
(= (score-all-candidates Nil $cons $dis $meta $anti $context) Nil)
(= (score-all-candidates (Cons $cand $tail) $cons $dis $meta $anti $context)
   (Cons ($cand (score-decision-v2 $cand $cons $dis $meta $anti $context))
         (score-all-candidates $tail $cons $dis $meta $anti $context)))

;; Sort candidates by score (simple insertion sort)
(: sort-by-score (-> (List (Candidate DecisionScore))
                    (List (Candidate DecisionScore))))
(= (sort-by-score Nil) Nil)
(= (sort-by-score (Cons $head $tail))
   (insert-by-score $head (sort-by-score $tail)))

;; Insert candidate in sorted position
(: insert-by-score (-> (Candidate DecisionScore)
                       (List (Candidate DecisionScore))
                       (List (Candidate DecisionScore))))
(= (insert-by-score $item Nil) (Cons $item Nil))
(= (insert-by-score ($c1 (decision-score $b1 $m1 $a1 $f1))
                   (Cons ($c2 (decision-score $b2 $m2 $a2 $f2)) $tail))
   (if (> $f1 $f2)
       (Cons ($c1 (decision-score $b1 $m1 $a1 $f1))
             (Cons ($c2 (decision-score $b2 $m2 $a2 $f2)) $tail))
       (Cons ($c2 (decision-score $b2 $m2 $a2 $f2))
             (insert-by-score ($c1 (decision-score $b1 $m1 $a1 $f1)) $tail))))

;; =============================================================================
;; Logging and Observability
;; =============================================================================

;; Log space for decision history
!(bind! &decision-log (new-space))

;; Log a decision with breakdown
(: log-decision (-> Candidate DecisionScore Number ()))
(= (log-decision $candidate $score $timestamp)
   (add-atom &decision-log
     (decision-event $candidate $score $timestamp)))

;; Query decision history
(: get-decision-history (-> Number Number (List (Candidate DecisionScore Number))))
(= (get-decision-history $start-time $end-time)
   (match &decision-log
     (decision-event $c $s $t)
     (if (and (>= $t $start-time) (<= $t $end-time))
         ($c $s $t)
         Empty)))

;; =============================================================================
;; Module Export
;; =============================================================================

;; Export main functions for use by other modules
(= (scoring-v2-module-exports)
   (list
     score-decision-v2
     score-with-weights
     rank-decisions
     generate-score-breakdown
     format-score-breakdown
     log-decision
     default-scoring-weights))