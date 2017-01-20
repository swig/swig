(require 'cffi)
(shadowing-import 'cffi:defcallback)
(use-package :cffi)

(cffi:define-foreign-library :avar
  (t (:default "/home/jaten/dj/avar/avar")))

(cffi:load-foreign-library :avar)

;; ccl specific: (ccl:open-shared-library "./avar.so")

(compile-file "avar.lisp")
(load "avar.lx64fsl")

(compile-file "avar-clos.lisp")
(load "avar-clos.lx64fsl")


(use-package 'avar)

; side effect in the ctor: set a_global_int to 44.
(setf o (make-instance 'avar:MicroTestCppClass))

;; it works fine to access the global:

a_global_int
(MicroTestCppClass.show o)


(MicroTestCppClass.take o 7)
a_global_int
(MicroTestCppClass.show o)


(MicroTestCppClass.take o 22220)
a_global_int
(MicroTestCppClass.show o)

(MicroTestCppClass.take o 818)
a_global_int
(MicroTestCppClass.show o)


;; this doesn't work directly;
;(setf a_gobal_int 55)

; instead you have to use mem-ref first:
;  this does work to set, in 2 steps
(setf my-foreign-ptr (get-var-pointer 'a_global_int))
(setf (mem-ref my-foreign-ptr :int)  9090909)

; verify:
a_global_int
(MicroTestCppClass.show o)

; or rolled into one step, setting the global int:

(setf (mem-ref (get-var-pointer 'a_global_int) :int)  123123123)

; verify
a_global_int
(MicroTestCppClass.show o)

;; we want a global method for setting globar variables in this package:

(avar:avar.setf a_global_int :int 111)

a_global_int

; this was in the avar.lisp
(cffi:defcvar ("a_global_int" a_global_int  :read-only nil :library :avar)  :int)

;
; shortcut macro for setting a package's global variables. You have to give the type as the 2nd arg.
;
(avar.setf a_global_int :int 434)

(MicroTestCppClass.show o)


; works:
(defvar got)
(assert (equal 3 (setf got (MicroTestCppClass_StaticPublicMemberInt_get))))

(MicroTestCppClass_StaticPublicMemberInt_set 2)

(assert (equal 2 (setf got (MicroTestCppClass_StaticPublicMemberInt_get))))











(defparameter testspassed (not (or

nil

)))

(if testspassed
 (format t "~%~%~% * * * * * * * * * * * * * * *~% * * * all tests passed. * * *~% * * * * * * * * * * * * * * *~%")
 (error "small_test.cl : some function did not return the expected value from the C++ method.")
)



