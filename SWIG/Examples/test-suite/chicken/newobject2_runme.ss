(load-library 'newobject2 "newobject2.so")

(define f (make <Foo>))

(slot-set! f 'dummy 14)
(if (not (= (slot-ref f 'dummy) 14))
  (error "Bad dummy value"))

(exit 0)
