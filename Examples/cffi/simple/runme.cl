(setf *print-case* :downcase) ; legible.
; :invert actually turns on case-sensitivity, even though it says invert and not preserve.
; for details, see http://www.cliki.net/Case%20sensitivity
(setf (readtable-case *readtable*) :invert)

; we need cffi for swig<->common lisp to function, make sure it is installed.
; Then we load it here:
(require 'cffi)
(shadowing-import 'cffi:defcallback)
(use-package :cffi)




(:cd "~/dj/swig/Examples/cffi/simple")

;; make, if not already
(run-program "make" '() :output t)

(open-shared-library "./example.so")

(compile-file "example.lisp")
(load "example.lx64fsl")


(defparameter tests-passed

(progn

; Call our gcd() function

(defparameter x 42)
(defparameter y 105)
(defparameter g (gcd x y))


(format t "The gcd of ~A and ~A is ~A ~%" x y g)

; Manipulate the Foo global variable

; Output its current value
(format t "Before manipulating Foo, it is: ~A ~%" Foo)

; Change its value
(setf Foo 3.1415926)

; See if the change took effect
(format t "After manipulating Foo, it is: ~A ~%" Foo)

t))


(if tests-passed
 (format t "~%~%~% * * * * * * * * * * * * * * *~% * * * all tests passed. * * *~% * * * * * * * * * * * * * * *~%")
 (error "small_test.cl : some function did not return the expected value from the C++ method.")
)



