(define a (make-rectangular -1 2))
(define expected (make-rectangular -1 -2))

(define r (Conj a))
(if (not (= r expected))
    (error "Conj failed"))

(define r2 (Conj2 a))
(if (not (= r2 expected))
    (error "Conj2 failed"))

;; (define v (vector (make-rectangular 1 2) (make-rectangular 2 3) (make-rectangular 4 3) 1))

;; TODO Scheme CopyHalf/CopyHalfRef do not work with native vector
;; (define vh (CopyHalf v))
;; (if (not (= (vector-length vh) 2))
;;     (error "CopyHalf failed"))

;; (define vhr (CopyHalf v))
;; (if (not (= (vector-length vhr) 2))
;;     (error "CopyHalfRef failed"))
(exit 0)
