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

(define-method (compute-get-n-set (class <swig-metaclass>) s)
  (case (slot-definition-allocation s)
    ((#:swig-virtual)
      (list
        ;getter
        (let ((func (get-keyword #:slot-ref (slot-definition-options s) #f)))
          (lambda (x) (func (slot-ref x 'smob))))
        ;setter
        (let ((func (get-keyword #:slot-set! (slot-definition-options s) #f)))
          (lambda (x val) (func (slot-ref x 'smob) val)))))
    ((#:swig-virtual-class)
      (list
        ;getter
        (let ((func  (get-keyword #:slot-ref (slot-definition-options s) #f))
              (class (get-keyword #:class    (slot-definition-options s) #f)))
          (lambda (x) (make class #:init-smob (func (slot-ref x 'smob)))))
        ;setter
        (let ((func (get-keyword #:slot-set! (slot-definition-options s) #f)))
          (lambda (x val) (func (slot-ref x 'smob) (slot-ref val 'smob))))))
    (else (next-method))))

(define-method (initialize (class <swig-metaclass>) initargs)
  (slot-set! class 'new-function (get-keyword #:new-function initargs #f))
  (next-method))

(define-class <swig> ()
  (smob #:init-value #f)
  #:metaclass <swig-metaclass>)

(define-method (initialize (obj <swig>) initargs)
  (next-method)
  (let ((arg (get-keyword #:init-smob initargs #f)))
    (if arg
      (slot-set! obj 'smob arg)
      (slot-set! obj 'smob (apply (slot-ref (class-of obj) 'new-function) 
                                  (get-keyword #:args initargs '()))))))

(export <swig-metaclass> <swig>)
