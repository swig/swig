(require 'tinyclos)
(load "../../../Lib/chicken/multi-generic.scm")
(load-library 'overload-copy "./overload_copy.so")

(define f (make <Foo>))
(define g (make <Foo> f))

(exit 0)
