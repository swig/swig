(dynamic-call "scm_init_typename_module" (dynamic-link "./libtypename.so"))
;;(dynamic-call "scm_init_types_module" (dynamic-link "./libtypes.so"))

(define f (new-Foo))
(define b (new-Bar))

(define x (twoFoo f))
;;(if (not (isinstance x (types-FloatType)))
;;    (error "wrong return type"))

(define y (twoBar b))
;;(if (not (isinstance y (types-IntType)))
;;    (error "wrong return type"))

(exit 0)
