;;;************************************************************************
;;;*common.scm
;;;*
;;;*     This file contains generic SWIG GOOPS classes for generated
;;;*     GOOPS file support
;;;*
;;;* Copyright (C) 2003 John Lenz (jelenz@wisc.edu)
;;;*
;;;* This file may be freely redistributed without license or fee provided
;;;* this copyright message remains intact.
;;;************************************************************************

(define-module (Swig common))
(use-modules (oop goops))

(define-class <swig-metaclass> (<class>)
  (new-function #:init-value #f))

(define-method (initialize (class <swig-metaclass>) initargs)
  (slot-set! class 'new-function (get-keyword #:new-function initargs #f))
  (next-method))

(define-class <swig> () 
  (swig-smob #:init-value #f)
  #:metaclass <swig-metaclass>
)

(define-method (initialize (obj <swig>) initargs)
  (next-method)
  (slot-set! obj 'swig-smob
    (let ((arg (get-keyword #:init-smob initargs #f)))
      (if arg
        arg
        (let ((ret (apply (slot-ref (class-of obj) 'new-function) (get-keyword #:args initargs '()))))
          ;; if the class is registered with runtime environment,
          ;; new-Function will return a <swig> goops class.  In that case, extract the smob
          ;; from that goops class and set it as the current smob.
          (if (slot-exists? ret 'swig-smob)
            (slot-ref ret 'swig-smob)
            ret))))))
                                              
(export <swig-metaclass> <swig>)
