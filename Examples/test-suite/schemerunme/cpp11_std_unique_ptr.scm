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
(expect-throw 'misc-error 
              (takeKlassUniquePtr kin))
; TODO: check the exception message
(set! kin '()) (gc) ; Should not fail, even though already deleted
(checkCount 0)

(define kin (new-Klass "KlassInput"))
(define notowned (get-not-owned-ptr kin))
(expect-throw 'misc-error 
              (takeKlassUniquePtr notowned))
; TODO: check the exception message
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
(define nullnil #nil)
(takeKlassUniquePtr nullnil)
(takeKlassUniquePtr (make-null))
(checkCount 0)

; overloaded parameters
(unless (= (overloadTest) 0)
  (error "overloadTest failed"))
(unless (= (overloadTest nullnil) 1)
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
