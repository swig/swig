;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_cpp17_string_view_module" (dynamic-link "./libcpp17_string_view"))
(load "testsuite.scm")
(load "../schemerunme/cpp17_string_view.scm")
