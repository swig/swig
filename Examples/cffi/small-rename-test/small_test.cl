(require 'cffi)
(shadowing-import 'cffi:defcallback)
(use-package :cffi)

;;; (:cd "~/dj/basic_swig")
(open-shared-library "./small.so")
(load (compile-file "./small.lisp"))
(load (compile-file "./small-clos.lisp"))

(use-package 'small)

; To use the generic methods, you use the CLOS object 
;; generated with make-instance, as in the following example.

(setf a (make-instance 'TESTCLASS))

; The swig CFFI module generated methods approximate operator overloading in C++
;  by creating a custom dispatch function in Lisp to call through C to (eventually)
;  the correct C++ overload. See the small-clos.lisp file for examples.
;
; each of these will invoke a different (overloaded) C++ method.
;
; Notice that this also demonstrates the %rename directive provided
;   by swig to avoid nameclashes. Here we rename oldme -> newME.
;

(if (not (and 

; calls C++ a->TESTCLASS::oldme()
(equal 8 (TESTCLASS.newME a))

; calls C++ a->TESTCLASS::oldme(int a)
(equal 9 (TESTCLASS.newME a 1)  )        

; calls C++ a->TESTCLASS::oldme(double a)
(equal 7 (TESTCLASS.newME a 1.0d0)  )    

; calls C++ a->TESTCLASS::oldme(int, int)
(equal 6 (TESTCLASS.newME a 1 2)  )      

; calls C++ a->TESTCLASS::oldme(int, double)
(equal 5 (TESTCLASS.newME a 1 2.0d0)  )

))
 (error "small_test.cl : some function did not return the expected value from the C++ method.")
 (format t "~% * * * * * * * * * * * * * * *~% * * * all tests passed. * * *~% * * * * * * * * * * * * * * *~%")
)



