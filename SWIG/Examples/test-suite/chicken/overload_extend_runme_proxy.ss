(require 'tinyclos)
(load "../../../Lib/chicken/multi-generic.scm")
(load-library 'overload-extend "./overload_extend.so")

(define f (make <Foo>))

(if (not (= (test f 3) 1))
  (error "test integer bad"))

(if (not (= (test f "hello") 2))
  (error "test string bad"))

(if (not (= (test f 3.5 2.5) 6.0))
  (error "test reals bad"))

(exit 0)
