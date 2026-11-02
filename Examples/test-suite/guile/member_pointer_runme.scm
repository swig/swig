;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_member_pointer_module" (dynamic-link "./libmember_pointer"))

(define-macro (check form)
  `(if (not ,form)
       (error "Check failed: " ',form)))

(define s (new-Square 10))
(check (= 100.0 (do-op s (areapt))))
(check (= 40.0 (do-op s (perimeterpt))))

;; Const references to member pointers
(check (= 100.0 (do-op-cref s (areapt))))
(check (= 40.0 (do-op-cref s (perimetervar-td-cref))))
(check (= 40.0 (do-op s (perimetervar-td-cref))))
(check (eq? 'wrong-type-arg (catch #t (lambda () (do-op-cref s (ADD-BY-VALUE))) (lambda (key . args) key))))

;; Overloaded on the member pointer type
(check (= 3 (call-overloaded (ADD-BY-VALUE) 1 2)))
(check (= -7 (call-overloaded (ADD-BY-POINTER) 3 4)))
(check (= 110 (call-overloaded 10 5 6)))

(exit 0)
