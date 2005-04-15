;; run with './multimap test-multimap.scm'
;; feel free to uncomment and comment sections

(load-library 'example "multimap.so")

(display "(gcd 90 12): ")
(display (gcd 90 12))
(display "\n")

(display "(gcd 90 'a): ")
;;(display (gcd 90 'a))
(display "\n")

(display "(gcd 'b 12): ")
;;(display (gcd 'b 12))
(display "\n")

(display "(circle 0.5 0.5): ")
(circle 0.5 0.5)
(display "\n")

(display "(circle 1.0 1.0): ")
;;(circle 1.0 1.0)
(display "\n")

(display "(circle 1 1): ")
;;(circle 1 1)
(display "\n")

(display "(capitalize \"will this be all capital letters?\"): ")
(display (capitalize "will this be all capital letters?"))
(display "\n")

(display "(capitalize 'a): ")
;;(display (capitalize 'a))
(display "\n")

(display "(count \"jumpity little spider\" #\\t): ")
(display (count "jumpity little spider" #\t))
(display "\n")

(display "(gcdmain '#(\"hi\" \"there\")): ")
(display (gcdmain '#("hi" "there")))
(display "\n")

(display "(gcdmain '#(\"gcd\" \"9\" \"28\")): ")
(gcdmain '#("gcd" "9" "28"))
(display "\n")

(display "(gcdmain '#(\"gcd\" \"12\" \"90\")): ")
(gcdmain '#("gcd" "12" "90"))
(display "\n")

(display "(squarecubed 3: ")
(display (squareCubed 3))
(display "\n")

(exit)
