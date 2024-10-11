(define-macro (check form)
  `(if (not ,form)
       (error "Check failed: " ',form)))

(define (=~ a b)
  (< (abs (- a b)) 1e-8))

(check (=~ 2 (AddOne1 1)))
(check (=~ 21 (AddOne1r 20)))

(define a (NonVoidOut -42))
(unless (null? (list-ref a 0))
  (error "Element 0 should be NULL"))
(check (=~ 0 (list-ref a 1)))

(exit 0)
