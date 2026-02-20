;; Test cross-module type cast: DenseMatrix (module B) to Operator (module A)

(define dm (new-DenseMatrix 100 200))
(define height (Operator-Height dm))

(if (not (= height 100))
    (error "Expected height 100, got" height))

;; Test factory function: Make_DenseMatrix (module C) returns Operator*
(define op (Make-DenseMatrix 50 60))
(define height2 (Operator-Height op))

(if (not (= height2 50))
    (error "Expected height 50, got" height2))

(exit 0)
