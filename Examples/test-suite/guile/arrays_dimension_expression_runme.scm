(dynamic-call "scm_init_arrays_dimension_expression_module" (dynamic-link "./libarrays_dimension_expression"))

(define-macro (check test)
  `(if (not ,test) (error "Error in test" ',test)))

; Setting an array sized 'DIM_FLAGS | 4' copies its 7 elements, and no more.
(or-array (or-source))
(check (= (or-array-sum) 28))
(or-grid (or-grid-source))
(check (= (or-grid-sum) 21))
(or-text "abcdef")
(check (string=? (or-text) "abcdef"))
(check (= (or-text-length "abcdef") 6))

(exit 0)
