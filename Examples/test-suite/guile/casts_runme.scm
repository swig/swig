;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_casts_module" (dynamic-link "./libcasts.so"))

(define x (new-B))

;; This fails in 1.3a5 because the SWIG/Guile runtime code gets the
;; source and the target of a cast the wrong way around.

(A-hello x)				

(exit 0)
