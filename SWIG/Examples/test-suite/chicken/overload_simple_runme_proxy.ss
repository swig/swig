(load-library 'overload_simple "overload_simple.so")

(define-macro (check test)
  `(if (not ,test) (error ,'test)))

(check (string=? (foo 3) "foo:int"))
(exit 0)
(check (string=? (foo 3.01) "foo:double"))
(check (string=? (foo "hey") "foo:char *"))

(define f (make <Foo>))
(define b (make <Bar>))
(define s (make <Spam>))

(check (string=? (foo f) "foo:Foo *"))
(check (string=? (foo b) "foo:Bar *"))

;; now check blah
(check (string=? (blah 2.01) "blah:double"))
(check (string=? (blah "hey") "blah:char *"))

;; now check Spam member functions
(check (string=? (foo s 2) "foo:int"))
(check (string=? (foo s 2.1) "foo:double"))
(check (string=? (foo s "hey") "foo:char *"))
(check (string=? (foo s f) "foo:Foo *"))
(check (string=? (foo s b) "foo:Bar *"))

;; check static member funcs
(check (string=? (bar 3) "bar:int"))
(check (string=? (bar 3.2) "bar:double"))
(check (string=? (bar "hey") "bar:char *"))
(check (string=? (bar f) "bar:Foo *"))
(check (string=? (bar b) "bar:Bar *"))

(exit 0)
