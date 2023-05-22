(define largs #("hi" "hola" "hello"))
(when (not (= (mainc largs) 3))
    (error "calling mainc failed"))

(define targs #("hi" "hola"))
(when (not (string=? (mainv targs 0) "hi"))
    (error "calling mainv failed"))
(when (not (string=? (mainv targs 1) "hola"))
    (error "calling mainv failed"))

(expect-throw 'swig-contract-assertion-failed
    (mainv "hello"  1))

(initializeApp largs)

(exit 0)
