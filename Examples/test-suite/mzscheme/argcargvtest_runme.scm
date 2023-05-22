(load-extension "argcargvtest.so")

(define largs #("hi" "hola" "hello"))
(when (not (= (mainc largs) 3))
    (error "calling mainc failed"))

(define targs #("hi" "hola"))
(when (not (string=? (mainv targs 0) "hi"))
    (error "calling mainv failed"))
(when (not (string=? (mainv targs 1) "hola"))
    (error "calling mainv failed"))

(with-handlers ([exn:fail? (lambda (exn)
                 (when (not (string=? (exn-message exn)
                       "SWIG contract, assertion failed: function=mainv, message=null array"))
                    (error "wrong error")))])
  (mainv "hello" 1)
  (error "mainv should generate exception"))

(initializeApp largs)

(exit 0)
