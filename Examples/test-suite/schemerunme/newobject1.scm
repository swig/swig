(define-macro (check test)
  `(if (not ,test) (error "Error in test" ',test)))

(define foo1 (Foo-makeFoo))
(check (= (Foo-fooCount) 1))

(define foo2 (Foo-makeMore foo1))
(check (= (Foo-fooCount) 2))

(delete-Foo foo1)
(check (= (Foo-fooCount) 1))

(delete-Foo foo2)
(check (= (Foo-fooCount) 0))

(exit 0)
