; ============================
; Recursive Utilities
; ============================

(: product (-> Expression Number))
(= (product $lst)
   (foldl-atom $lst 1 $acc $x (* $acc $x)))

(: epsilon (-> Number))
(= (epsilon) 0.0000000000000001)

(: gmean (-> Expression Number))
(= (gmean $lst)
    (let $prod (product $lst)
    (let $size (size-atom $lst)
    (pow-math $prod (/ (+ 1.0 0.0) $size)))))

(: splitr (-> Expression Number))
(= (splitr ($x $y)) $y)


; ============================
; Arousal Modulator
; ============================

(: arousal-level (-> Number))
(= (arousal-level) 0.5)

(: arousal-bias (-> Symbol Number))
(= (arousal-bias Explore) (+ 0.5 (arousal-level)))
(= (arousal-bias Talk) (+ 0.5 (- 1.0 (abs (- (arousal-level) 0.5)))))
(= (arousal-bias Rest) (+ 0.5 (- 1.0 (arousal-level))))

(: update-arousal (-> Bool Number))
(= (update-arousal $success)
   (if $success 
       (min 1.0 (+ (arousal-level) 0.1))
       (max 0.0 (- (arousal-level) 0.1))))

; ============================
; Action Definition
; ============================



(: action-definition (-> (List)))

(= (action-definition)
  (
    (Action Talk
      (Considerations (0.9 0.5 0.7))
      (Discouragements (0.9))
    )

    (Action Rest
      (Considerations (0.2 0.1 0.8))
      (Discouragements (1.0))
    )

    (Action Explore
      (Considerations (0.3 0.9 0.4))
      (Discouragements (0.5))
    )
  )
)


; ============================
; Field Accessors
; ============================

(: get-action-name (-> Atom Symbol))
(= (get-action-name (Action $name $a $b)) $name)

(: get-considerations (-> Atom Expression))
(= (get-considerations (Action $a (Considerations $b) $c)) $b)

(: get-discouragements (-> Atom Expression))
(= (get-discouragements (Action $a $b (Discouragements $c))) $c)



; ============================
; Decision Score
; ============================

(: decision-score (-> Atom Number))
(= (decision-score $a)
   (let $cs (get-considerations $a)
     (let $ds (get-discouragements $a)
       (let $action-name (get-action-name $a)
         (* (arousal-bias $action-name)
            (* (gmean $cs) (product $ds)))))))



; ============================
; Score All Actions
; ============================

(: score-all (-> (List)))
(= (score-all)
    (let $actions (action-definition)
   (map-atom $actions $a
         ( (get-action-name $a)
           (decision-score $a) )
         )))


; ============================
; argmax: find best (name, score) pair
; ============================

(: max-score (-> Number))
(= (max-score)
    (let $scores (score-all) 
    (let $finals (map-atom $scores $a (eval (splitr $a)))
        (max-atom $finals))))

; ============================
; Choose Best Action
; ============================

(: choose-best-action (-> Expression))
(= (choose-best-action)
    (let $max (eval (max-score))
    (let $scores (eval (score-all))
        (let $maxless (eval (- $max epsilon))
          (filter-atom $scores $a 
            (let $right (eval (splitr $a))
            (let $greater (eval (> $right $maxless))
                (eval (if $greater $a ()))
            )
            )
          )
        )
    )
    )
)





; ============================
; Usage
; ============================

! (arousal-level)
; → current arousal level (0.0 to 1.0)

! (score-all)
; → list of (action-name score) pairs with arousal bias

! (max-score)
; → best (action-name score)

! (choose-best-action)
; → action name with highest arousal-modulated decision-score

; ============================
; Arousal Testing
; ============================

; Test arousal bias at current level (0.5)
! (arousal-bias Explore)
! (arousal-bias Talk) 
! (arousal-bias Rest)
