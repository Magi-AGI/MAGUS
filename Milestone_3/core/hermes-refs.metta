;; MAGUS Milestone 3: HERMES Causal Reference Module (Refined)
;; Provides atoms and structures for causal link references
;; Supports integration with HERMES for causal attribution
;; Based on Milestone-3-Spec.md requirements and M3-Refinement-Plan.md

;; Import shared types
!(load types.metta)

;; =============================================================================
;; Additional Types (causal types are in types.metta)
;; =============================================================================

;; Types are defined in types.metta, no additional types needed here

;; =============================================================================
;; Edge Type Definitions
;; =============================================================================

;; Define standard edge types
(: edge-type-causes (-> Symbol))
(= (edge-type-causes) causes)
(: edge-type-enables (-> Symbol))
(= (edge-type-enables) enables)
(: edge-type-prevents (-> Symbol))
(= (edge-type-prevents) prevents)
(: edge-type-correlates (-> Symbol))
(= (edge-type-correlates) correlates)
(: edge-type-implies (-> Symbol))
(= (edge-type-implies) implies)
(: edge-type-supports (-> Symbol))
(= (edge-type-supports) supports)
(: edge-type-opposes (-> Symbol))
(= (edge-type-opposes) opposes)

;; Check if edge type is positive
(: is-positive-edge (-> Symbol Bool))
(= (is-positive-edge causes) True)
(= (is-positive-edge enables) True)
(= (is-positive-edge supports) True)
(= (is-positive-edge implies) True)
(= (is-positive-edge prevents) False)
(= (is-positive-edge opposes) False)
(= (is-positive-edge correlates) True)  ;; Neutral but treated as positive

;; =============================================================================
;; Causal Graph Operations
;; =============================================================================

;; Add edge to causal graph
(: add-causal-edge (-> CausalGraphRef CausalEdgeRef CausalGraphRef))
(= (add-causal-edge (causal-graph $id $edges $conf) $new-edge)
   (causal-graph $id
                (Cons $new-edge $edges)
                (update-confidence $conf $new-edge)))

;; Update confidence based on new edge
(: update-confidence (-> Number CausalEdgeRef Number))
(= (update-confidence $current (causal-edge $s $t $strength $type))
   (* $current (+ 0.5 (* 0.5 $strength))))  ;; Weighted average

;; Find path between nodes in graph
(: find-causal-path (-> Symbol Symbol CausalGraphRef (List CausalEdgeRef)))
(= (find-causal-path $start $end (causal-graph $id $edges $conf))
   (find-path-recursive $start $end $edges Nil))

;; Recursive path finding
(: find-path-recursive (-> Symbol Symbol (List CausalEdgeRef)
                          (List Symbol) (List CausalEdgeRef)))
(= (find-path-recursive $current $target $edges $visited)
   (if (== $current $target)
       Nil  ;; Found target
       (find-next-step $current $target $edges $visited)))

;; Find next step in path
(: find-next-step (-> Symbol Symbol (List CausalEdgeRef)
                     (List Symbol) (List CausalEdgeRef)))
(= (find-next-step $current $target Nil $visited) Empty)  ;; No path found
(= (find-next-step $current $target (Cons $edge $rest) $visited)
   (let ((causal-edge $source $dest $strength $type) $edge)
     (if (and (== $source $current)
              (not (member $dest $visited)))
         (let (($subpath (find-path-recursive $dest $target
                          (Cons $edge $rest)
                          (Cons $current $visited))))
           (if (== $subpath Empty)
               (find-next-step $current $target $rest $visited)
               (Cons $edge $subpath)))
         (find-next-step $current $target $rest $visited))))

;; Calculate path strength (weakest link)
(: calculate-path-strength (-> (List CausalEdgeRef) Number))
(= (calculate-path-strength Nil) 1.0)
(= (calculate-path-strength (Cons (causal-edge $s $t $strength $type) $tail))
   (min $strength (calculate-path-strength $tail)))

;; =============================================================================
;; Goal Evidence Management
;; =============================================================================

;; Create goal satisfaction evidence
(: create-goal-evidence (-> Goal Symbol (List CausalEdgeRef) GoalSatisfactionEvidence))
(= (create-goal-evidence $goal $status $edges)
   (goal-evidence $goal $status $edges
                 (calculate-evidence-confidence $edges)))

;; Calculate confidence from edges
(: calculate-evidence-confidence (-> (List CausalEdgeRef) Number))
(= (calculate-evidence-confidence Nil) 0)
(= (calculate-evidence-confidence $edges)
   (/ (sum-edge-strengths $edges) (length-edges $edges)))

;; Sum edge strengths
(: sum-edge-strengths (-> (List CausalEdgeRef) Number))
(= (sum-edge-strengths Nil) 0)
(= (sum-edge-strengths (Cons (causal-edge $s $t $strength $type) $tail))
   (+ $strength (sum-edge-strengths $tail)))

;; Use length from types.metta for counting edges
(: length-edges (-> (List CausalEdgeRef) Number))
(= (length-edges $edges) (length $edges))

;; Check if evidence supports goal
(: evidence-supports-goal (-> GoalSatisfactionEvidence Bool))
(= (evidence-supports-goal (goal-evidence $goal $status $edges $conf))
   (and (== $status satisfied) (> $conf 0.5)))

;; =============================================================================
;; Causal Attribution
;; =============================================================================

;; Attribute outcome to decision/action
(: attribute-outcome (-> Symbol Symbol CausalGraphRef CausalAttribution))
(= (attribute-outcome $decision $outcome $graph)
   (let* (($path (find-causal-path $decision $outcome $graph))
          ($strength (calculate-path-strength $path)))
     (causal-attr $decision $outcome $path $strength)))

;; Get attribution strength
(: get-attribution-strength (-> CausalAttribution Number))
(= (get-attribution-strength (causal-attr $d $o $path $strength))
   $strength)

;; Find all attributions for an outcome
(: find-all-attributions (-> Symbol CausalGraphRef (List CausalAttribution)))
(= (find-all-attributions $outcome (causal-graph $id $edges $conf))
   (find-attributions-from-edges $outcome $edges))

;; Find attributions from edge list
(: find-attributions-from-edges (-> Symbol (List CausalEdgeRef) (List CausalAttribution)))
(= (find-attributions-from-edges $outcome Nil) Nil)
(= (find-attributions-from-edges $outcome $edges)
   (collect-unique-sources $outcome $edges))

;; Named helper for creating attribution from source
(: create-attribution-from-source (-> Symbol Symbol (List CausalEdgeRef) CausalAttribution))
(= (create-attribution-from-source $source $target $edges)
   (let (($path-edges (find-edges-from-to $source $target $edges)))
     (causal-attr $source $target $path-edges
                 (calculate-combined-strength $path-edges))))

;; Collect unique source nodes
(: collect-unique-sources (-> Symbol (List CausalEdgeRef) (List CausalAttribution)))
(= (collect-unique-sources $target $edges)
   (create-attributions-for-sources
     (get-sources-for-target $target $edges) $target $edges))

;; Create attributions for list of sources
(: create-attributions-for-sources (-> (List Symbol) Symbol (List CausalEdgeRef)
                                      (List CausalAttribution)))
(= (create-attributions-for-sources Nil $target $edges) Nil)
(= (create-attributions-for-sources (Cons $source $tail) $target $edges)
   (Cons (create-attribution-from-source $source $target $edges)
         (create-attributions-for-sources $tail $target $edges)))

;; Get all sources that lead to target
(: get-sources-for-target (-> Symbol (List CausalEdgeRef) (List Symbol)))
(= (get-sources-for-target $target Nil) Nil)
(= (get-sources-for-target $target (Cons (causal-edge $s $t $str $type) $tail))
   (if (== $t $target)
       (cons-unique $s (get-sources-for-target $target $tail))
       (get-sources-for-target $target $tail)))

;; Add unique element to list
(: cons-unique (-> $a (List $a) (List $a)))
(= (cons-unique $elem $list)
   (if (member $elem $list)
       $list
       (Cons $elem $list)))

;; Find edges from source to target
(: find-edges-from-to (-> Symbol Symbol (List CausalEdgeRef) (List CausalEdgeRef)))
(= (find-edges-from-to $source $target Nil) Nil)
(= (find-edges-from-to $source $target (Cons $edge $tail))
   (let ((causal-edge $s $t $str $type) $edge)
     (if (and (== $s $source) (== $t $target))
         (Cons $edge (find-edges-from-to $source $target $tail))
         (find-edges-from-to $source $target $tail))))

;; Calculate combined strength of multiple edges
(: calculate-combined-strength (-> (List CausalEdgeRef) Number))
(= (calculate-combined-strength Nil) 0)
(= (calculate-combined-strength $edges)
   (- 1 (product-of-complements $edges)))  ;; Noisy-OR combination

;; Product of complements for noisy-OR
(: product-of-complements (-> (List CausalEdgeRef) Number))
(= (product-of-complements Nil) 1)
(= (product-of-complements (Cons (causal-edge $s $t $str $type) $tail))
   (* (- 1 $str) (product-of-complements $tail)))

;; =============================================================================
;; Provenance Tracking
;; =============================================================================

;; Create provenance record
(: create-provenance (-> Symbol Number (List Symbol) Provenance))
(= (create-provenance $source $timestamp $proof-terms)
   (provenance $source $timestamp $proof-terms))

;; Add provenance to causal chain
(: add-provenance-to-chain (-> CausalChain Provenance CausalChain))
(= (add-provenance-to-chain (causal-chain $nodes $strength $old-prov) $new-prov)
   (causal-chain $nodes $strength $new-prov))

;; Extract proof terms from provenance
(: get-proof-terms (-> Provenance (List Symbol)))
(= (get-proof-terms (provenance $source $time $terms)) $terms)

;; =============================================================================
;; Integration with MAGUS Decision Making
;; =============================================================================

;; Tag decision with causal references
(: tag-decision-with-causality (-> DecisionScore (List CausalEdgeRef)
                                  (DecisionScore (List CausalEdgeRef))))
(= (tag-decision-with-causality $score $edges)
   ($score $edges))

;; Extract causal justification for decision
(: extract-causal-justification (-> Goal CausalGraphRef (List CausalEdgeRef)))
(= (extract-causal-justification $goal $graph)
   (find-supporting-edges $goal $graph))

;; Find edges that support a goal
(: find-supporting-edges (-> Goal CausalGraphRef (List CausalEdgeRef)))
(= (find-supporting-edges (goal $name $p $w) (causal-graph $id $edges $conf))
   (filter-edges-for-goal $name $edges))

;; Filter edges related to goal
(: filter-edges-for-goal (-> Symbol (List CausalEdgeRef) (List CausalEdgeRef)))
(= (filter-edges-for-goal $goal-name Nil) Nil)
(= (filter-edges-for-goal $goal-name (Cons $edge $tail))
   (let ((causal-edge $s $t $str $type) $edge)
     (if (or (== $t $goal-name)
             (== $s $goal-name))
         (Cons $edge (filter-edges-for-goal $goal-name $tail))
         (filter-edges-for-goal $goal-name $tail))))

;; =============================================================================
;; Causal Chain Construction
;; =============================================================================

;; Build causal chain from decision to outcome
(: build-causal-chain (-> Symbol Symbol (List CausalEdgeRef) CausalChain))
(= (build-causal-chain $start $end $edges)
   (let* (($path (find-causal-path $start $end (causal-graph temp $edges 1)))
          ($nodes (extract-nodes-from-path $path))
          ($strength (calculate-path-strength $path))
          ($prov (create-provenance MAGUS (get-timestamp) $nodes)))
     (causal-chain $nodes $strength $prov)))

;; Extract nodes from edge path
(: extract-nodes-from-path (-> (List CausalEdgeRef) (List Symbol)))
(= (extract-nodes-from-path Nil) Nil)
(= (extract-nodes-from-path (Cons (causal-edge $s $t $str $type) Nil))
   (Cons $s (Cons $t Nil)))
(= (extract-nodes-from-path (Cons (causal-edge $s $t $str $type) $tail))
   (Cons $s (extract-nodes-from-path $tail)))

;; Get current timestamp (placeholder)
(: get-timestamp (-> Number))
(= (get-timestamp) 1000)

;; =============================================================================
;; Confidence Updates
;; =============================================================================

;; Update edge confidence based on observation
(: update-edge-confidence (-> CausalEdgeRef Bool Number CausalEdgeRef))
(= (update-edge-confidence (causal-edge $s $t $old-str $type) $observed $learning-rate)
   (let (($target (if $observed 1 0))
         ($new-str (+ (* (- 1 $learning-rate) $old-str)
                     (* $learning-rate $target))))
     (causal-edge $s $t $new-str $type)))

;; Batch update graph confidence
(: update-graph-confidence (-> CausalGraphRef (List (CausalEdgeRef Bool))
                              Number CausalGraphRef))
(= (update-graph-confidence $graph Nil $learning-rate) $graph)
(= (update-graph-confidence (causal-graph $id $edges $conf)
                           (Cons ($edge $observed) $updates)
                           $learning-rate)
   (let* (($updated-edges (update-edge-in-list $edges $edge $observed $learning-rate))
          ($new-conf (recalculate-graph-confidence $updated-edges)))
     (update-graph-confidence
       (causal-graph $id $updated-edges $new-conf)
       $updates
       $learning-rate)))

;; Update specific edge in list
(: update-edge-in-list (-> (List CausalEdgeRef) CausalEdgeRef Bool Number
                          (List CausalEdgeRef)))
(= (update-edge-in-list Nil $edge $obs $lr) Nil)
(= (update-edge-in-list (Cons $e $tail) $edge $obs $lr)
   (if (edge-equals $e $edge)
       (Cons (update-edge-confidence $e $obs $lr) $tail)
       (Cons $e (update-edge-in-list $tail $edge $obs $lr))))

;; Check edge equality
(: edge-equals (-> CausalEdgeRef CausalEdgeRef Bool))
(= (edge-equals (causal-edge $s1 $t1 $str1 $type1)
               (causal-edge $s2 $t2 $str2 $type2))
   (and (== $s1 $s2) (== $t1 $t2)))

;; Recalculate overall graph confidence
(: recalculate-graph-confidence (-> (List CausalEdgeRef) Number))
(= (recalculate-graph-confidence $edges)
   (if (== (length-edges $edges) 0)
       0
       (/ (sum-edge-strengths $edges) (length-edges $edges))))

;; =============================================================================
;; Module Export
;; =============================================================================

;; Export main functions for use by other modules
(: hermes-refs-exports (-> (List Symbol)))
(= (hermes-refs-exports)
   (list
     create-goal-evidence
     attribute-outcome
     find-all-attributions
     tag-decision-with-causality
     extract-causal-justification
     build-causal-chain
     update-graph-confidence
     add-causal-edge
     find-causal-path))