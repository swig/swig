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

(exit 0)
