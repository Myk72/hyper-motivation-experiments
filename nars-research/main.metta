!(import! &self galactic-rules)
!(import! &self nars-planner)
!(bind! &worldSpace (new-space))
!(bind! &cachespace (new-space))

;;Subject = (AND Context Action)
;;Predicate = Goal
;;Statement = (Subject --> Predicate)




!(addWorldRules &worldSpace)

(= (overlaps $l1 $l2) (not (== (intersection-atom $l1 $l2) ())))

(= (filterRules $rules $type $pattern)
   (if (== $rules ()) ()
       (let* (
          (($head $tail) (decons-atom $rules))
          ($content (extractRule $type $head)) 
          ($rest (filterRules $tail $type $pattern))
       )
          (if (overlaps $content $pattern)
              (cons-atom $head $rest)
              $rest
          )
       )
   )
)

(= (reasoningEngine $context $goal $space $cacheSpace)
   (let* (
      ($allRules (collapse (get-atoms $space)))
      ($contextRules (filterRules $allRules ContextValues $context))
      ($_ (println! ("Context Rules:" (size-atom $contextRules))))
      
      ($goalRules (filterRules $allRules GoalValues $goal))
      ($_ (println! ("Goal Rules:" (size-atom $goalRules))))
      
      ($relevantRules (unique-atom (union-atom $contextRules $goalRules)))
      ($_ (println! ("Relevant Rules:" (size-atom $relevantRules))))
      
      ($_ (add-atoms $cacheSpace $relevantRules))
      
      ($inferedRules (applyInference $cacheSpace))
      ($_ (println! ("Inferred NARS Rules:" (size-atom $inferedRules))))
      
      ($convertedRules (convertRulesToPSI $inferedRules))
      ($_ (println! ("Converted PSI Rules:" $convertedRules)))
      
      ($_ (add-atoms $space $convertedRules))
      ($_ (remove-atoms $cacheSpace))
   )
   (psiPlanner $context $goal $space)
   )
)

!(reasoningEngine (PLANET_A) (PLANET_B) &worldSpace &cachespace)
; !(reasoningEngine (PLANET_A) (HAS_MONEY) &worldSpace &cachespace)

