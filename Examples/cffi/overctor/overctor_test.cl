(require 'cffi)
(shadowing-import 'cffi:defcallback)
(use-package :cffi)


; load the library
(:cd "/home/jaten/dj/overctor")
(open-shared-library "./overctor.so")

(load "overctor.lisp")
(load "overctor-clos.lisp")

(use-package :overctor)

(defparameter tests-passed (and

(setf o3a (make-instance 'Vlad :intref 2 :charstar "heya" :dub 1.0d0))
(setf o3b (make-instance 'Vlad :intref 2 :charstar "heya" :string2 "I'm another string"))
(setf o2 (make-instance 'Vlad :intref 2 :charstar "heya"))
(setf o1 (make-instance 'Vlad :intval 2))
(setf o0  (make-instance 'Vlad))

))

(if tests-passed
 (format t "~%~%~% * * * * * * * * * * * * * * *~% * * * all tests passed. * * *~% * * * * * * * * * * * * * * *~%")
 (error "small_test.cl : some function did not return the expected value from the C++ method.")
)


