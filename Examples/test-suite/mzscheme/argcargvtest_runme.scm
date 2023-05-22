(load-extension "argcargvtest.so")

(define largs #("hi" "hola" "hello"))
(when (not (= (mainc largs) 3))
    (error "calling mainc failed"))

(define targs #("hi" "hola"))
(when (not (string=? (mainv targs 0) "hi"))
    (error "calling mainv failed"))
(when (not (string=? (mainv targs 1) "hola"))
    (error "calling mainv failed"))
(when (not (string=? (mainv targs 2) "<<NULL>>"))
    (error "calling mainv failed"))

(with-handlers ([exn:fail? (lambda (exn)
                 (when (not (string=? (exn-message exn)
                       "SWIG contract, assertion failed: function=mainv, message=null array"))
                    (error "wrong error")))])
  (mainv "hello" 1)
  (error "mainv should generate exception"))

(initializeApp largs)

; Check that an empty array works.
(define empty_args #())
(when (not (= (mainc empty_args) 0))
    (error "calling mainc failed"))
(when (not (string=? (mainv empty_args 0) "<<NULL>>"))
    (error "calling mainv failed"))

; Check that empty strings are handled.
(define empty_string #("hello" "" "world"))
(when (not (= (mainc empty_string) 3))
    (error "calling mainc failed"))
(when (not (string=? (mainv empty_string 0) "hello"))
    (error "calling mainv 0 failed"))
(when (not (string=? (mainv empty_string 1) ""))
    (error "calling mainv 1 failed"))
(when (not (string=? (mainv empty_string 2) "world"))
    (error "calling mainv 2 failed"))
(when (not (string=? (mainv empty_string 3) "<<NULL>>"))
    (error "calling mainv 3 failed"))

(exit 0)
