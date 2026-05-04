(define-macro (check test)
  `(if (not ,test) (error "Error in test" ',test)))

(define b (new-Bar))
(check (= (Bar-bar b) 1))

(define f (new-Foo))
(check (= (Foo-foo f) 2))

(define fb (new-FooBar))
(check (= (Bar-bar fb) 1))
(check (= (Foo-foo fb) 2))
(check (= (FooBar-fooBar fb) 3))

(define id1 (new-IgnoreDerived1))
(check (= (Bar-bar id1) 1))
(check (= (IgnoreDerived1-ignorederived1 id1) 7))

(define id2 (new-IgnoreDerived2))
(check (= (Bar-bar id2) 1))
(check (= (IgnoreDerived2-ignorederived2 id2) 8))

(define id3 (new-IgnoreDerived3))
(check (= (Bar-bar id3) 1))
(check (= (IgnoreDerived3-ignorederived3 id3) 9))

(define id4 (new-IgnoreDerived4))
(check (= (Bar-bar id4) 1))
(check (= (IgnoreDerived4-ignorederived4 id4) 10))

(exit 0)
