;; run with './constants test-constants.scm'
;; feel free to uncomment and comment sections

(declare (uses example))

(display "starting test ... you will see 'finished' if successful.\n")
(or (= (example:ICONST) 42) (exit 1))
(or (< (abs (- (example:FCONST) 2.1828)) 0.00001) (exit 1))
(or (char=? (example:CCONST) #\x) (exit 1))
(or (char=? (example:CCONST2) #\newline) (exit 1))
(or (string=? (example:SCONST) "Hello World") (exit 1))
(or (string=? (example:SCONST2) "\"Hello World\"") (exit 1))
(or (< (abs (- (example:EXPR) (+ (example:ICONST) (* 3 (example:FCONST))))) 0.00001) (exit 1))
(or (= (example:iconstX) 37) (exit 1))
(or (< (abs (- (example:fconstX) 3.14)) 0.00001) (exit 1))
(display "finished test.\n")
(exit 0)
