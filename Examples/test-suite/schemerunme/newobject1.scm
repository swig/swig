(define-macro (check test)
  `(unless ,test (error "Error in test" ',test)))

(define foo1 (Foo-makeFoo))
(check (= (Foo-fooCount) 1))

(define foo2 (Foo-makeMore foo1))
(check (= (Foo-fooCount) 2))

(set! foo1 '())
(gc)
(check (= (Foo-fooCount) 1))

(set! foo2 '())
(gc)
(check (= (Foo-fooCount) 0))

(exit 0)
