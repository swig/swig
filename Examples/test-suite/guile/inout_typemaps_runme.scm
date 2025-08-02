;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_inout_typemaps_module" (dynamic-link "./libinout_typemaps"))
(load "testsuite.scm")
(load "../schemerunme/inout_typemaps.scm")
