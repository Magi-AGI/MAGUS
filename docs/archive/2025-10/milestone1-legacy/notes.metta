


; (: filter-map-atom (-> (List) Symbol Atom (List)))
; (= (filter-map-atom () $var $body) ())
; (= (filter-map-atom (:: $x $xs) $var $body)
;    (let $result (subst $var $x $body)
;      (if (is-empty $result)
;          (filter-map-atom $xs $var $body)
;          (:: $result (filter-map-atom $xs $var $body)))))

;! let $max (max-score)
;! let $scores (eval (score-all))
;! let $maxless (eval (- $max epsilon))
; ! filter-atom $scores $a
; ! (let $right (eval (splitr $a)))
; ! (let $greater (eval (> $right $maxless)))
; ! (eval (if $greater $a ()))

; ! (let $scores ((Talk 0.6123682904358031) (Rest 0.2519842099789747) (Explore 0.23811015779522995)) (max-atom (map-atom $scores $a (splitr $a))))

;! (filter-atom (0.6123682904358031 0.2519842099789747 0.23811015779522995) $a (eval (> $a 0.6123682904358030)))

;! (let $right (splitr (Talk 3)) (let $size (size-atom (1 1 1)) (=alpha $right $size)))

;! (splitr (Talk 0.6123682904358031))

;! (choose-action)

;! (let $max (max-score) (match &self ($a $max) $a))

(: choose-best-action2 (-> Expression))
(= (choose-best-action2)
    (let $max (max-score)
    (let $scores (score-all)
        (map-atom $scores $a 
            (let $right (eval (splitr $a))
            (let $equal (=alpha $right $max)
                (if $equal $a ())
            )
            )
        )
    )
    )
)

(: choose-action (-> Expression))
(= (choose-action) 
    (let $max (max-score)
    (let $scores (score-all)
        (map-atom $scores $a 
            (let $right (eval (splitr $a))
            (let $equal (=alpha $right $max)
                (if $equal $a ())
            )
            )
        )
    )
    )
)





(: greater-than-3 (-> Atom Boolean))
(= (greater-than-3 $x)
   (> $x 3))

(: filter-fn (-> Expression (-> Atom Boolean) Expression))

(= (filter-fn $list $pred)
   (foldl-atom $list () $acc $x
     (if ($pred $x)
         (cons-atom $x $acc)
         $acc)))

; ! (filter-fn (1 2 3 4 5) greater-than-3)
; → (5 4)

; ! (reverse-atom (filter-fn (1 2 3 4 5) greater-than-3))
; → (4 5)

(: filter-gt3 (-> Expression Expression))

(= (filter-gt3 $list)
   (foldl-atom $list () $acc $x
     (if (> $x 3)
         (cons-atom $x $acc)
         $acc)))

;! (filter-gt3 (1 2 3 4 5))
; → (5 4)


(: filter-step (-> Atom Atom Variable Atom Atom))

(= (filter-step $elem $acc $var $filter)
   (function
     (let $sub (atom-subst $elem $var $filter)
       (let $result (eval $sub)
         (if $result
             (cons-atom $elem $acc)
             $acc)))))




(: filter-atom2 (-> Expression Variable Atom Expression))

(= (filter-atom2 $list $var $filter)
   (foldl-atom $list () $acc $elem
     (filter-step $elem $acc $var $filter)))






;!(filter-atom2 (1 2 3 4 5) $x (> $x 3)) ; Returns (4 5)




; sanity tests
; ! (get-considerations (Action Talk (Considerations (:: 0.9 (:: 0.5 (:: 0.7 ())))) (Discouragements (:: 0.9 ()))))
; ! (get-metatype (get-considerations (Action Talk ...)))
; ! (decision-score (Action Talk (Considerations (:: 0.9 (:: 0.5 (:: 0.7 ())))) (Discouragements (:: 0.9 ()))))
; ! (get-type 0.9)
; ! (get-type (:: 0.9 (:: 0.5 (:: 0.7 ()))))
; ! (gmean (:: 0.9 (:: 0.5 (:: 0.7 ())))) ; should now return ≈ 0.666

; ! (product (:: 0.9 (:: 0.5 (:: 0.7 ())))) ; Should return 0.315
; ! (length (:: 0.9 (:: 0.5 (:: 0.7 ())))) ; Should return 3
; ! (gmean (:: 0.9 (:: 0.5 (:: 0.7 ())))) ; Should return ≈ 0.666
; ! (/ 1 3)    ; → 0  (bad: integer division)
; ! (/ 1.0 3)  ; → 0.333... ✅

; ! (pow-math 0.315 0.333)
; ! (length (:: 0.9 (:: 0.5 (:: 0.7 ()))))
; ! (+ 1 (length (:: 0.9 (:: 0.5 (:: 0.7 ())))))
; ! (type-cast 4 Number &self)

; (: Number Type)
; (: 4 Number)
; ! (type-cast 4 Number &self)

; ! (/ 1.0 (type-cast ((+ 1 (length (:: 0.9 (:: 0.5 (:: 0.7 ()))))) Number &self)))

; ! (gmean (:: 0.9 (:: 0.5 (:: 0.7 ())))) ; should return ≈ 0.666
; ! (type-cast 2 Number &self)
; ! (pow-math 0.315 (/ 1.0 (type-cast 3 Number &self)))

; ! (action-definition)
; ! (car (action-definition))

; ! (get-action-name 
;      (Action Talk 
;        (Considerations (:: 0.9 (:: 0.5 (:: 0.7 ()))))
;        (Discouragements (:: 0.9 ()))))

; ! (get-action-name (car (ac(: product (-> (List) Number))))
; (= (product ($lst))
;    (foldl-atom ($lst) 1 $acc $x (* $acc $x)))let $actions (action-definition) (car $actions))

; ! (let $actions (action-definition) (map-atom $actions $a (get-action-name $a)))
; ! (flatten-cons-list (action-definition))

; ! (let $fcl (flatten-cons-list (action-definition)) (map-atom $fcl $a (get-metatype $a)))
; ! (get-metatype (car-atom (flatten-cons-list (action-definition))))

; ! (flatten-cons-list (action-definition))
; ! (map-atom (flatten-cons-list (action-definition)) $a (get-metatype $a))

; ! (map-atom (flatten-cons-list (action-definition)) $a (is-action? $a))

;! (size-atom (0.9 0.5 0.7))     ; → 3
;! (foldl-atom (0.9 0.5 0.7) 1 $acc $x (* $acc $x)) ; Returns 10 (1+2+3+4)

; ! (product (0.9 0.5 0.7))    ; → 0.315

; (= (length) (size-atom (0.9 0.5 0.7)))
; (= (prod) (product (0.9 0.5 0.7)))

; ! (size-atom (0.9 0.5 0.7))
; ! (prod)
; ! (length)
; ! (/ 1.0 (size-atom (0.9 0.5 0.7)))
; (: foo (-> Number Number Number))
; (= (foo $x $y) (/ $x $y))

; ! (foo 1.0 (size-atom(0.9 0.5 0.7)))

; ! (/ 1.0 2.0)
; ! (pow-math (product (0.9 0.5 0.7)) (/ 1.0 (size-atom (0.9 0.5 0.7))))

; ! (gmean (0.9 0.5 0.7))
;! (get-metatype [0.9 0.5 0.7])

;(: foo (-> Expression Number))
;(= (foo $x) 5)
;! (get-type (0.9 0.5 0.7))
;! (get-type foo)

;! (foo (0.9 0.5 0.7))


; ! (gmean (0.9 0.5 0.7))      ; → ~0.666

;! (foldl-atom (0.9 0.5 0.7) 1.0 $acc $x (* $acc $x))

; (: zero (-> Number))
; (= (zero) (+ 0 0))

; (: one (-> Number))
; (= (one) (+ 1 0))


; ; ! (* 1.0 0.9)
; ! (foldl-atom [1 2 3] (zero) $acc $x (+ $acc $x))


