(load-extension "cpp11_std_unique_ptr.so")
(require (lib "defmacro.ss"))

; Copied from ../schemerunme/cpp11_std_unique_ptr.scm and modified for exceptions

; Define an equivalent to Guile's gc procedure
(define-macro (gc)
  `(collect-garbage 'major))

(define checkCount
  (lambda (expected-count)
    (define actual-count (Klass-getTotal-count))
    (unless (= actual-count expected-count) (error (format "Counts incorrect, expected:~a actual:~a" expected-count  actual-count)))))

; Test raw pointer handling involving virtual inheritance
(define kini (new-KlassInheritance "KlassInheritanceInput"))
(checkCount 1)
(define s (useKlassRawPtr kini))
(unless (string=? s "KlassInheritanceInput")
  (error "Incorrect string: " s))
(set! kini '()) (gc)
(checkCount 0)

; ;;;; INPUT BY VALUE ;;;;
; unique_ptr as input
(define kin (new-Klass "KlassInput"))
(checkCount 1)
(define s (takeKlassUniquePtr kin))
(checkCount 0)
(unless (string=? s "KlassInput")
  (error "Incorrect string: " s))
(unless (is-nullptr kin)
  (error "is_nullptr failed"))
(set! kini '()) (gc) ; Should not fail, even though already deleted
(checkCount 0)

(define kin (new-Klass "KlassInput"))
(checkCount 1)
(define s (takeKlassUniquePtr kin))
(checkCount 0)
(unless (string=? s "KlassInput")
  (error "Incorrect string: " s))
(unless (is-nullptr kin)
  (error "is_nullptr failed"))

(define exception_thrown "no exception thrown for kin")
(with-handlers ([exn:fail? (lambda (exn)
                             (set! exception_thrown (exn-message exn)))])
  (takeKlassUniquePtr kin))
(unless (string=? exception_thrown "takeKlassUniquePtr: cannot release ownership as memory is not owned for argument 1 of type 'Klass *'")
  (error "Wrong or no exception thrown: " exception_thrown))
(set! kin '()) (gc) ; Should not fail, even though already deleted
(checkCount 0)

(define kin (new-Klass "KlassInput"))
(define notowned (get-not-owned-ptr kin))
(set! exception_thrown "no exception thrown for notowned")
(with-handlers ([exn:fail? (lambda (exn)
                             (set! exception_thrown (exn-message exn)))])
  (takeKlassUniquePtr notowned))
(unless (string=? exception_thrown "takeKlassUniquePtr: cannot release ownership as memory is not owned for argument 1 of type 'Klass *'")
  (error "Wrong or no exception thrown: " exception_thrown))
(checkCount 1)
(set! kin '()) (gc)
(checkCount 0)

(define kini (new-KlassInheritance "KlassInheritanceInput"))
(checkCount 1)
(define s (takeKlassUniquePtr kini))
(checkCount 0)
(unless (string=? s "KlassInheritanceInput")
  (error "Incorrect string: " s))
(unless (is-nullptr kini)
  (error "is_nullptr failed"))
(set! kini '()) (gc) ; Should not fail, even though already deleted
(checkCount 0)

(define null '())
(takeKlassUniquePtr null)
(takeKlassUniquePtr (make-null))
(checkCount 0)

; overloaded parameters
(unless (= (overloadTest) 0)
  (error "overloadTest failed"))
(unless (= (overloadTest null) 1)
  (error "overloadTest failed"))
(unless (= (overloadTest (new-Klass "over")) 1)
  (error "overloadTest failed"))
(checkCount 0)


; ;;;; INPUT BY RVALUE REF ;;;;
; unique_ptr as input
(define kin (new-Klass "KlassInput"))
(checkCount 1)
(define s (moveKlassUniquePtr kin))
(checkCount 0)
(unless (string=? s "KlassInput")
  (error "Incorrect string: " s))
(unless (is-nullptr kin)
  (error "is_nullptr failed"))
(set! kini '()) (gc) ; Should not fail, even though already deleted
(checkCount 0)

(define kin (new-Klass "KlassInput"))
(checkCount 1)
(define s (moveKlassUniquePtr kin))
(checkCount 0)
(unless (string=? s "KlassInput")
  (error "Incorrect string: " s))
(unless (is-nullptr kin)
  (error "is_nullptr failed"))

(define exception_thrown "no exception thrown for kin")
(with-handlers ([exn:fail? (lambda (exn)
                             (set! exception_thrown (exn-message exn)))])
  (moveKlassUniquePtr kin))
(unless (string=? exception_thrown "moveKlassUniquePtr: cannot release ownership as memory is not owned for argument 1 of type 'Klass *'")
  (error "Wrong or no exception thrown: " exception_thrown))
(set! kin '()) (gc) ; Should not fail, even though already deleted
(checkCount 0)

(define kin (new-Klass "KlassInput"))
(define notowned (get-not-owned-ptr kin))
(set! exception_thrown "no exception thrown for notowned")
(with-handlers ([exn:fail? (lambda (exn)
                             (set! exception_thrown (exn-message exn)))])
  (moveKlassUniquePtr notowned))
(unless (string=? exception_thrown "moveKlassUniquePtr: cannot release ownership as memory is not owned for argument 1 of type 'Klass *'")
  (error "Wrong or no exception thrown: " exception_thrown))
(checkCount 1)
(set! kin '()) (gc)
(checkCount 0)

(define kini (new-KlassInheritance "KlassInheritanceInput"))
(checkCount 1)
(define s (moveKlassUniquePtr kini))
(checkCount 0)
(unless (string=? s "KlassInheritanceInput")
  (error "Incorrect string: " s))
(unless (is-nullptr kini)
  (error "is_nullptr failed"))
(set! kini '()) (gc) ; Should not fail, even though already deleted
(checkCount 0)

(define null '())
(moveKlassUniquePtr null)
(moveKlassUniquePtr (make-null))
(checkCount 0)

; overloaded parameters
(unless (= (moveOverloadTest) 0)
  (error "moveOverloadTest failed"))
(unless (= (moveOverloadTest null) 1)
  (error "moveOverloadTest failed"))
(unless (= (moveOverloadTest (new-Klass "over")) 1)
  (error "moveOverloadTest failed"))
(checkCount 0)


; ;;;; INPUT BY NON-CONST LVALUE REF ;;;;
; unique_ptr as input
(define kin (new-Klass "KlassInput"))
(checkCount 1)
(define s (moveRefKlassUniquePtr kin))
(checkCount 0)
(unless (string=? s "KlassInput")
  (error "Incorrect string: " s))
(unless (is-nullptr kin)
  (error "is_nullptr failed"))
(set! kini '()) (gc) ; Should not fail, even though already deleted
(checkCount 0)

(define kin (new-Klass "KlassInput"))
(checkCount 1)
(define s (moveRefKlassUniquePtr kin))
(checkCount 0)
(unless (string=? s "KlassInput")
  (error "Incorrect string: " s))
(unless (is-nullptr kin)
  (error "is_nullptr failed"))

(define exception_thrown "no exception thrown for kin")
(with-handlers ([exn:fail? (lambda (exn)
                             (set! exception_thrown (exn-message exn)))])
  (moveRefKlassUniquePtr kin))
(unless (string=? exception_thrown "moveRefKlassUniquePtr: cannot release ownership as memory is not owned for argument 1 of type 'Klass *'")
  (error "Wrong or no exception thrown: " exception_thrown))
(set! kin '()) (gc) ; Should not fail, even though already deleted
(checkCount 0)

(define kin (new-Klass "KlassInput"))
(define notowned (get-not-owned-ptr kin))
(set! exception_thrown "no exception thrown for notowned")
(with-handlers ([exn:fail? (lambda (exn)
                             (set! exception_thrown (exn-message exn)))])
  (moveRefKlassUniquePtr notowned))
(unless (string=? exception_thrown "moveRefKlassUniquePtr: cannot release ownership as memory is not owned for argument 1 of type 'Klass *'")
  (error "Wrong or no exception thrown: " exception_thrown))
(checkCount 1)
(set! kin '()) (gc)
(checkCount 0)

(define kini (new-KlassInheritance "KlassInheritanceInput"))
(checkCount 1)
(define s (moveRefKlassUniquePtr kini))
(checkCount 0)
(unless (string=? s "KlassInheritanceInput")
  (error "Incorrect string: " s))
(unless (is-nullptr kini)
  (error "is_nullptr failed"))
(set! kini '()) (gc) ; Should not fail, even though already deleted
(checkCount 0)

(define null '())
(moveRefKlassUniquePtr null)
(moveRefKlassUniquePtr (make-null))
(checkCount 0)

; overloaded parameters
(unless (= (moveRefOverloadTest) 0)
  (error "moveRefOverloadTest failed"))
(unless (= (moveRefOverloadTest null) 1)
  (error "moveRefOverloadTest failed"))
(unless (= (moveRefOverloadTest (new-Klass "over")) 1)
  (error "moveRefOverloadTest failed"))
(checkCount 0)


; ;;;; INPUT BY CONST LVALUE REF ;;;;
; unique_ptr as input
(define kin (new-Klass "KlassInput"))
(checkCount 1)
(define s (useRefKlassUniquePtr kin))
(checkCount 1)
(unless (string=? s "KlassInput")
  (error "Incorrect string: " s))
(set! kin '()) (gc)
(checkCount 0)

(define kini (new-KlassInheritance "KlassInheritanceInput"))
(checkCount 1)
(define s (useRefKlassUniquePtr kini))
(checkCount 1)
(unless (string=? s "KlassInheritanceInput")
  (error "Incorrect string: " s))
(set! kini '()) (gc)
(checkCount 0)

(define null '())
(useRefKlassUniquePtr null)
(useRefKlassUniquePtr (make-null))
(checkCount 0)

; overloaded parameters
(unless (= (useRefOverloadTest) 0)
  (error "useRefOverloadTest failed"))
(unless (= (useRefOverloadTest null) 1)
  (error "useRefOverloadTest failed"))
(define kin (new-Klass "over"))
(unless (= (useRefOverloadTest kin) 1)
  (error "useRefOverloadTest failed"))
(checkCount 1)
(set! kin '()) (gc)
(checkCount 0)


; unique_ptr as output
(define k1 (makeKlassUniquePtr "first"))
(define k2 (makeKlassUniquePtr "second"))
(checkCount 2)

(set! k1 '()) (gc)
(checkCount 1)

(unless (string=? (Klass-getLabel k2) "second")
  (error "wrong object label" ))

(set! k2 '()) (gc)
(checkCount 0)

(unless (null? (makeNullUniquePtr))
  (error "null failure"))

; unique_ptr as output (rvalue ref)
(define k1 (makeRVRKlassUniquePtr "first"))
(unless (string=? (Klass-getLabel k1) "first")
  (error "wrong object label" ))
(unless (null? (makeRVRKlassUniquePtr '()))
  (error "null failure"))

; unique_ptr as output (lvalue ref)
(define k1 (makeRefKlassUniquePtr "lvalueref"))
(unless (string=? (Klass-getLabel k1) "lvalueref")
  (error "wrong object label" ))
(unless (null? (makeRefKlassUniquePtr '()))
  (error "null failure"))

(exit 0)
