(define x "hello")

(if (not (string=? (test-value x) x))
  (begin (error "Error 1") (exit 1)))

(if (not (string=? (test-const-reference x) x))
  (begin (error "Error 2") (exit 1)))

(define y (test-pointer-out))
(test-pointer y)
(define z (test-const-pointer-out))
(test-const-pointer z)

(define a (test-reference-out))
(test-reference a)

(exit 0)
