;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_pointer_in_out_module" (dynamic-link "./libpointer_in_out.so"))

(define-macro (check form)
  `(if (not ,form)
       (error "Check failed: " ',form)))

(define p (produce-int-pointer 47 11))

(check (= (consume-int-pointer p) 47))

(define q (frobnicate-int-pointer p))

(check (= (consume-int-pointer q) 11))

(exit 0)
