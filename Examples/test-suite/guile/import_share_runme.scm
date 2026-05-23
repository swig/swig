;; Load order A, C, B is critical: C registers DenseMatrix in the
;; shared type table without the inheritance cast to Operator, then B
;; must add the cast — exercising the bug fixed in swiginit.swg.
(dynamic-call "scm_init_import_share_a_module" (dynamic-link "./libimport_share_a"))
(dynamic-call "scm_init_import_share_c_module" (dynamic-link "./libimport_share_c"))
(dynamic-call "scm_init_import_share_b_module" (dynamic-link "./libimport_share_b"))
(load "../schemerunme/import_share.scm")
