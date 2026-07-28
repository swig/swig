;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_multichar_constant_module" (dynamic-link "./libmultichar_constant"))
(load "../schemerunme/multichar_constant.scm")
