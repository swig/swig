;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_name_module" (dynamic-link "./libname.so"))

(foo-2)
bar-2
Baz-2

(exit 0)
