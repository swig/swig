;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_test_module" (dynamic-link "./liblist_vector.so"))

(if (and (= (sum-list '(1 3 4 6 7)) 21)
	 (= (sum-vector #(2 4 6 7 9) 28))
	 (equal? (one-to-seven-list) '(1 2 3 4 5 6 7))
	 (equal? (one-to-seven-vector) #(1 2 3 4 5 6 7)))
    (exit 0)
    (exit 1))
