(define-macro (check test)
  `(if (not ,test) (error "Error in test" ',test)))

(define b (make <Bar>))
(check (= (bar b) 1))

(define f (make <Foo>))
(check (= (foo f) 2))

(define fb (make <FooBar>))
(check (= (bar fb) 1))
(check (= (foo fb) 2))
(check (= (fooBar fb) 3))

(exit 0)
