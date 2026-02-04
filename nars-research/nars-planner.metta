!(import! &self sampler)
!(import! &self rule-ops)
!(import! &self nars-util)
;;!(import! &self utils)

;;(A --> B) & (B --> C) |- (A --> C) deduction
;;(B --> A) & (B --> C) |- (A --> C) abduction
;;(A --> B) & (C --> B) |- (A --> C) induction
;;(A --> B) & (B --> C) |- (C --> A) exemplification



(= (k) 1) ;; this is experience parameter
(= (Truth_w2c $w) (/ $w (+ $w (k))))

;;Deduction implementation in NARS
(= (narsFreqDeduction $f1 $f2)
   (/ (* $f1 $f2) (+ $f1 (* $f2 (- 1 $f1)))))
(= (narsConfDeduction $f1 $f2 $c1 $c2)
   ( * (* $c1 $c2) (+ $f1 (* $f2 (- 1 $f1)))))
(= (narsPowerDeduction $f1 $f2 $c1 $c2)
   (* (narsFreqDeduction $f1 $f2)
      (narsConfDeduction $f1 $f2 $c1 $c2)))

;;Induction implementation in NARS
(= (narsFreqInduction $f1 $f2) $f1)
(= (narsConfInduction $f1 $f2 $c1 $c2)
    (Truth_w2c (* (* $f2 $c1) $c2)))
(= (narsPowerInduction $f1 $f2 $c1 $c2)
   (* (narsFreqInduction $f1 $f2)
      (narsConfInduction $f1 $f2 $c1 $c2)))

;;Abduction implementation in NARS
(= (narsFreqAbduction $f1 $f2) $f2)
(= (narsConfAbduction $f1 $f2 $c1 $c2)
    (Truth_w2c (* (* $f1 $c1) $c2)))
(= (narsPowerAbduction $f1 $f2 $c1 $c2)
   (* (narsFreqAbduction $f1 $f2)
      (narsConfAbduction $f1 $f2 $c1 $c2)))


(= (DeductiveTruth ($f1 $c1) ($f2 $c2)) 
   ((narsFreqDeduction $f1 $f2) (narsConfDeduction $f1 $f2 $c1 $c2)))
(= (AbductiveTruth ($f1 $c1) ($f2 $c2)) 
    ((narsFreqAbduction $f1 $f2) (narsConfAbduction $f1 $f2 $c1 $c2)))
(= (InductiveTruth $T1 $T2) 
   (AbductiveTruth $T2 $T1))

(= (ExemplificationTruth ($f1 $c1) ($f2 $c2)) 
   (1.0 (Truth_w2c (* (* $f1 $f2) (* $c1 $c2)))))


;;NAL-1
(= (reason (($a --> $b) $T1) (($b --> $c) $T2)) (($a --> $c) (DeductiveTruth $T1 $T2)))
(= (reason (($a --> $b) $T1) (($c --> $b) $T2)) (($a --> $c) (AbductiveTruth $T1 $T2)))
(= (reason (($b --> $a) $T1) (($b --> $c) $T2)) (($a --> $c) (InductiveTruth $T1 $T2)))
(= (reason (($a --> $b) $T1) (($b --> $c) $T2)) (($c --> $a) (ExemplificationTruth $T1 $T2)))
(= (reason (($a --> $b) $T1) (($c --> $d) $T2)) (if (== (intersection-atom ($a $b) ($c $d)) ()) () (empty)))
(= (reason (($a --> $b) $T1) (($a --> $b) $T1)) ())


(= (complexity $rule)
    (let* (
        (($id $mainRule) $rule)
        ($_ (println! (The id $id)))
        (((($context $action) --> $goal) $tv) $mainRule)
    )
      (size-atom $action)
    )
)

;;!(complexity (3 (((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (DEAD (STV 0.2 0.1)))) (0.5 0.002))))


(= (convertRuleToPSI $rule)
    (if (== $rule ()) ()
    (let* (
    ;   ($_ (println! ("Converting Rule" $rule)))
      ((($precedent --> $antecedent) ($freq $conf)) $rule)

      ;; temporary id assignment
      ;; solution for temp id is to have the total rule size and continue from there
      ($id 25) 

      ($complexity (size-atom $antecedent))
      ($truthValue (STV $freq $conf)) 
      (($context $action) $precedent)
    ;   ($_ (println! ("debug here for context format" $context)))
      ($goal $antecedent)

    )
      (: Rule $id 
        (TTV 0)
        $truthValue
        (Complexity $complexity)
        (IMPLICATION 
            (AND 
                (Context 
                    (STV 0.2 0.1) ;; hardcoded for now
                    (AND $context)
                )
                (Action (SEQ_AND $action)))
            (Goal 
                (STV 0.2 0.1) ;; hardcoded for now
                (AND $goal)
            )
        )))
    )
)

(= (convertRulesToPSI $rules) (collapse (convertRuleToPSI (superpose $rules))))
(= (addRules $space) 
    (let $rules (superpose (
    ;; Rule 1
    (: Rule 1
        (TTV 0)
        (STV 0.5 0.002)  
        (Complexity 1)
        (IMPLICATION
            (AND 
                (Context (STV 0.2 0.1) (AND (
                    (LEFT_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))))
                (Action (SEQ_AND (MOVE_RIGHT))))
            (Goal (STV 0.2 0.1) (AND (
                    (CENTER_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))
        )) 
    ))

    ;; Rule 3
    (: Rule 3
        (TTV 0)
        (STV 0.5 0.002)  
        (Complexity 1)
        (IMPLICATION 
            (AND 
                (Context (STV 0.2 0.1) (AND (
                    (LEFT_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))))
                (Action (SEQ_AND (MOVE_RIGHT))))
            (Goal (STV 0.2 0.1) (AND (
                    (CENTER_SQUARE (STV 0.2 0.1))
                    (DEAD (STV 0.2 0.1)))
        )) 
    ))

    ;; Rule 2
    (: Rule 2
        (TTV 0)
        (STV 0.5 0.002)  
        (Complexity 1)
        (IMPLICATION 
            (AND 
                (Context (STV 0.2 0.1) (AND (
                    (CENTER_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))))
                (Action (SEQ_AND (MOVE_RIGHT)) ) )
            (Goal (STV 0.2 0.1) (AND (
                    (RIGHT_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))
        )) 
    ))

    ;; Rule 4
    (: Rule 4
        (TTV 0)
        (STV 0.7 0.62)  
        (Complexity 1)
        (IMPLICATION 
            (AND 
                (Context (STV 0.2 0.1) (AND (
                    (LEFT_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))))
                (Action (SEQ_AND (JUMP_RIGHT)) ) )
            (Goal (STV 0.2 0.1) (AND (
                    (CENTER_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))
        )) 
    ))
)) (add-atom $space $rules) ))


(= (add-atoms $space $values)
  (if (== $values ()) () 
      (let* (
          ($head (car-atom $values))
          ($tail (cdr-atom $values))
          ($_ (add-atom $space $head))
      )
        (add-atoms $space $tail)

      )
  )
)
(= (remove-atoms $space $values)
    (if (== $values ())
        ()
        (let* (
            ($head (car-atom $values))
            ($tail (cdr-atom $values))
            ($_ (remove-atom $space $head))
        )
          (remove-atoms $space $tail)
        )
    )
)

;; Description
;; Changes these rules to nars representation (narsese)
(= (convertRuleToNars $rule) 
    (let* (
      ($context (eval (extractRule Context $rule)))
      ($action (eval (extractRule Action $rule)))
      ($goal (eval (extractRule Goal $rule)))
      ($STV (eval (extractRule STV $rule)))
      ((STV $freq $conf) $STV)

      ($id (eval (extractRule Id $rule)))
    )
      ($id ((($context $action) --> $goal) ($freq $conf))) 
    )
)


(= (|- $rule1 $rule2)
    (let* (
        (($id1 $narsRule1) $rule1)
        ; ($_ (println! (narsRule1 $narsRule1)))
        (($id2 $narsRule2) $rule2)
        ; ($_ (println! (narsRule2 $narsRule2)))
        ($result (reason $narsRule1 $narsRule2))
        ($_ (println! (resultInference $result)))
      )
       (reason $narsRule1 $narsRule2) 
    )
)


(= (isReduced $value) (if (== $value ()) false true))
(= (applyInferenceForRule $rule $rules $accum)
  (if (== $rules ())
     $accum
    (let* (
        (($head $tail) (decons-atom $rules))
        ; ($_ (println! (forApplication $rule space $head)))
        ($result (|- $rule $head))
        ; ($_ (println! (results $result)))
        ($reduced (isReduced $result))
        ; ($_ (println! (reduced $reduced)))
        ($accum' (if (not $reduced) $accum (union-atom $accum ($result))))
    ) 
      (applyInferenceForRule $rule $tail  $accum')
  )
)
)

(= (applyInference' $rules  $accum)
  (if (== $rules ())
     $accum
    (let* (
      (($head $tail) (decons-atom $rules))
    ;   ($_ (println! (decons-result $head $tail)))
      ($inferedRules (applyInferenceForRule $head $tail ()))
      ($_ (println! (inferedRules $inferedRules)))
      ($ruleSize (size-atom $inferedRules))
      ($accum' (union-atom $accum $inferedRules))
    )
     (applyInference' $tail  $accum')
    )
  )
)

(= (applyInference $space)
  (let* (
    ($rules (collapse (get-atoms $space)))
    ($narsRules (collapse (convertRuleToNars (superpose $rules))))
    ($_ (println! (narsRules $narsRules)))
    ($newRules (applyInference' $narsRules ()))
        
  )
    $newRules
  )
)
(= (matchContextRules $rules $contexts) (
    if (== $rules ())
        ()
        (let* (
            (($rule $restRules) (decons-atom $rules))
            ($_ (println! (dec $rule)))
            ($rule-context (extractRule ContextValues $rule))
            ($restMatching (matchContextRules $restRules $contexts))
        ) (if (sameElements $contexts $rule-context)
            (cons-atom $rule $restMatching)
            $restMatching
        ))
))


(= (psiPlanner $contexts $goals $ruleSpace) (
    let* (
        ($_ (println! (Current Values: Contexts: $contexts Goals: $goals)))
        ($rules (collapse (get-atoms $ruleSpace)))
        ($_ (println! ("Total Rules:"  (size-atom $rules))))
        ($matchingGoals (matchGoals $goals $rules))
        ($_ (println! (Matched Goals:  $matchingGoals)))
        ($matchingContexts (matchContextRules $matchingGoals $contexts))
        ($_ (println! (Matched Contexts:  $matchingContexts)))
        ($applicableRules $matchingContexts)
        ($_ (println! (Applicable Rules:  (size-atom $applicableRules))))
        (($sampledRule $sampledValue) (thompsonSample $applicableRules))
        ($_ (println! (Sampled Rule ID:  $sampledRule)))
    ) 
    (if (== $sampledRule -1)
        (println! (No rule selected))
        (let* (
            ($actions (extractRule Action $sampledRule))
            ($_ (println! (Performing Actions:  $actions)))
            ($result (performActions $actions))
            ($_ (println! (Resulting State:  $result)))
            ($updatedRule (updateRule $sampledRule $result $ruleSpace))
        ) () )
    )
))

(= (reasoningSelector $context $goal $space $cacheSpace)
  (let* (
    ($indices (probBasedSample $space 5))
    ($sampledRules (collectRules $space $indices ()))
    ($_ (add-atoms $cacheSpace $sampledRules))
    ($inferedRules (applyInference $cacheSpace))
    ($convertedRules (convertRulesToPSI $inferedRules))
    ($_ (println! (converted Rules $convertedRules)))
    ($_ (add-atoms $space $convertedRules))
    ($_ (remove-atoms $cacheSpace))
    
  )
    (psiPlanner $context $goal $space)
  )
)


; !(addRules &rulespace)
; !(reasoningSelector (LEFT_SQUARE STILL_ALIVE) (CENTER_SQUARE STILL_ALIVE) &rulespace &cachespace)

;;!(intersection-atom ((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) ( (((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) ((CENTER_SQUARE (STV 0.2 0.1)) (DEAD (STV 0.2 0.1))))) 
;;(((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (STV 0.5 0.002))
;;!(match &self (($a --> $b) $c) $c)
;;!(let (($A --> $B) $stv) (((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (STV 0.5 0.002)) $A)
;;!(reason (((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (STV 0.5 0.002)) 
;;          (((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (DEAD (STV 0.2 0.1)))) (STV 0.5 0.002)))
;;!(applyInference &rulespace)


;;!(convertRuleToPSI (1 (((((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((RIGHT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (0.5 0.002))))

