;; run with './multimap test-multimap.scm'
;; feel free to uncomment and comment sections

(declare (uses example))

(display "(example:gcd 90 12): ")
(display (example:gcd 90 12))
(display "\n")

(display "(example:gcd 90 'a): ")
;;(display (example:gcd 90 'a))
(display "\n")

(display "(example:gcd 'b 12): ")
;;(display (example:gcd 'b 12))
(display "\n")

(display "(example:circle 0.5 0.5): ")
(example:circle 0.5 0.5)
(display "\n")

(display "(example:circle 1.0 1.0): ")
;;(example:circle 1.0 1.0)
(display "\n")

(display "(example:circle 1 1): ")
;;(example:circle 1 1)
(display "\n")

(display "(example:capitalize \"will this be all capital letters?\"): ")
(display (example:capitalize "will this be all capital letters?"))
(display "\n")

(display "(example:capitalize 'a): ")
;;(display (example:capitalize 'a))
(display "\n")

(display "(example:count \"jumpity little spider\" #\\t): ")
(display (example:count "jumpity little spider" #\t))
(display "\n")

(display "(example:gcdmain '#(\"hi\" \"there\")): ")
(display (example:gcdmain '#("hi" "there")))
(display "\n")

(display "(example:gcdmain '#(\"gcd\" \"9\" \"28\")): ")
(example:gcdmain '#("gcd" "9" "28"))
(display "\n")

(display "(example:gcdmain '#(\"gcd\" \"12\" \"90\")): ")
(example:gcdmain '#("gcd" "12" "90"))
(display "\n")

(display "(example:squarecubed 3: ")
(display (example:squareCubed 3))
(display "\n")
