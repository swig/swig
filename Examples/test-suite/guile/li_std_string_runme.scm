;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_li_std_string_module" (dynamic-link "./libli_std_string"))
; Note: when working with non-ascii strings in guile 2
;       locale must be set explicitly
;       The setlocale call below takes care of that
(setlocale LC_ALL "")
(load "../schemerunme/li_std_string.scm")
