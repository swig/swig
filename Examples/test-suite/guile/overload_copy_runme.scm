(dynamic-call "scm_init_overload_copy_module" (dynamic-link "./liboverload_copy.so"))

(define f (new-Foo))
(define g (new-Foo f))

(exit 0)
