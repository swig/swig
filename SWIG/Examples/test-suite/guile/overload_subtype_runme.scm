;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_overload_subtype_module" (dynamic-link "./liboverload_subtype.so"))

(if (not (= (spam (new-Foo)) 1))
    (error "foo"))

(if (not (= (spam (new-Bar)) 2))
    (error "bar"))

(exit 0)
