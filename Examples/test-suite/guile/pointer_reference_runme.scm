(dynamic-call "scm_init_pointer_reference_module" (dynamic-link "./libpointer_reference"))

(define-macro (check form)
  `(if (not ,form)
       (error "Check failed: " ',form)))

(check (= (Struct-value-get (get)) 10))

(define ss (new-Struct 20))
(set ss)
(check (= (Struct-value-get (Struct-instance)) 20))

(check (= (overloading 1) 111))
(check (= (overloading ss) 222))
(check (= (pointer-reference-typedef-const ss) 20))
(check (= (pointer-reference-typedef-const '()) -1))
(check (= (opaque-value (opaque-pointer-reference)) 30))

(exit 0)
