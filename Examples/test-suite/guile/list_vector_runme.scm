;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_list_vector_module" (dynamic-link "./liblist_vector.so"))

(define-macro (check form)
  `(if (not ,form)
       (error "Check failed: " ',form)))

(check (= (sum-list '(1 3 4 6 7)) 21))
(check (= (sum-vector #(2 4 6 7 9)) 28))
(check (equal? (one-to-seven-list) '(1 2 3 4 5 6 7)))
(check (equal? (one-to-seven-vector) #(1 2 3 4 5 6 7)))

(check (= (sum-list2 '(1 3 4 6 7)) 21))
(check (= (sum-vector2 #(2 4 6 7 9)) 28))
(check (equal? (one-to-seven-list2) '(1 2 3 4 5 6 7)))
(check (equal? (one-to-seven-vector2) #(1 2 3 4 5 6 7)))

(check (= (sum-lists '(1 2 3) '(4 5 6) '(7 8 9)) 45.0))
(check (= (sum-lists2 '(1 2 3) '(4 5 6) '(7 8 9)) 45.0))
(check (equal? (call-with-values produce-lists list)
	       '(#(0 1 2 3 4)
		 #(0 1 4 9 16)
		 #(0.0 1.5 3.0 4.5 6.0))))


(exit 0)
