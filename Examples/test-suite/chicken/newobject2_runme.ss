(load-library 'newobject2 "newobject2.so")

(define f (make <Foo>))

(slot-set! f 'dummy 14)
(if (not (= (slot-ref f 'dummy) 14))
  (error "Bad dummy value"))

(define f2 (makeFoo))

(slot-set! f2 'dummy 16)
(if (not (= (slot-ref f2 'dummy) 16))
  (error "Bad dummy value for f2"))

(set! f #f)
(set! f2 #f)

(gc)

(exit 0)
