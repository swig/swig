;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_li_cdata_cpp_module" (dynamic-link "./libli_cdata_cpp"))
(load "testsuite.scm")
(load "../schemerunme/li_cdata_cpp.scm")
