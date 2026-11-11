;; C++ using double, create real Scheme complex number!
(define c (createComplex 6 8))
(if (not (= (getReal c) 6))
    (error "getReal failed"))
(if (not (= (getImaginary c) 8))
    (error "getImaginary failed"))
(if (not (= (getMagnitude c) 10))
    (error "getMagnitude failed"))
;; Create a Scheme complex number directly, and compare it.
(define r (make-rectangular 6 8))
(if (not (= c r))
    (error "compare to rectangle failed"))

;; C++ using float, create encapsulated object, which is NOT a Scheme complex number!
(define f (createComplexFlt 6 8))
(if (not (= (getRealFlt f) 6))
    (error "getRealFlt failed"))
(if (not (= (getImaginaryFlt f) 8))
    (error "getImaginaryFlt failed"))
(if (not (= (getMagnitudeFlt f) 10))
    (error "getMagnitudeFlt failed"))
(exit 0)
