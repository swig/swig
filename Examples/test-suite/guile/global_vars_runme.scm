;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_global_vars_module" (dynamic-link "./libglobal_vars"))
(load "testsuite.scm")
(load "../schemerunme/global_vars.scm")
