(dynamic-call "scm_init_class_ignore_module" (dynamic-link "./libclass_ignore.so"))

(define a (new-Bar))

(if (not (string=? (Bar-blah a) "Bar::blah"))
    (error "Wrong string"))

(exit 0)
