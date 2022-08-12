(define checkCount
  (lambda (expected-count)
    (define actual-count (Klass-getTotal-count))
    (if (not (= actual-count expected-count)) (error "Counts incorrect, expected:" expected-count " actual:" actual-count))))

; Test raw pointer handling involving virtual inheritance
(define kini (new-KlassInheritance "KlassInheritanceInput"))
(checkCount 1)
(define s (useKlassRawPtr kini))
(if (not (string=? s "KlassInheritanceInput"))
  (error "Incorrect string: " s))
(delete-Klass kini)
(checkCount 0)

; auto_ptr as input
(define kin (new-Klass "KlassInput"))
(checkCount 1)
(define s (takeKlassAutoPtr kin))
(checkCount 0)
(if (not (string=? s "KlassInput"))
  (error "Incorrect string: " s))
(if (not (is-nullptr kin))
  (error "is_nullptr failed"))
(delete-Klass kin) ; Should not fail, even though already deleted
(checkCount 0)

(define kin (new-Klass "KlassInput"))
(checkCount 1)
(define s (takeKlassAutoPtr kin))
(checkCount 0)
(if (not (string=? s "KlassInput"))
  (error "Incorrect string: " s))
(if (not (is-nullptr kin))
  (error "is_nullptr failed"))
(expect-throw 'misc-error 
              (takeKlassAutoPtr kin))
; TODO: check the exception message
(delete-Klass kin) ; Should not fail, even though already deleted
(checkCount 0)

(define kin (new-Klass "KlassInput"))
(define notowned (get-not-owned-ptr kin))
(expect-throw 'misc-error 
              (takeKlassAutoPtr notowned))
; TODO: check the exception message
(checkCount 1)
(delete-Klass kin)
(checkCount 0)

(define kini (new-KlassInheritance "KlassInheritanceInput"))
(checkCount 1)
(define s (takeKlassAutoPtr kini))
(checkCount 0)
(if (not (string=? s "KlassInheritanceInput"))
  (error "Incorrect string: " s))
(if (not (is-nullptr kini))
  (error "is_nullptr failed"))
(delete-Klass kini) ; Should not fail, even though already deleted
(checkCount 0)

; auto_ptr as output
(define k1 (makeKlassAutoPtr "first"))
(define k2 (makeKlassAutoPtr "second"))
(checkCount 2)

(delete-Klass k1)
(checkCount 1)

(if (not (string=? (Klass-getLabel k2) "second"))
  (error "wrong object label" ))

(delete-Klass k2)
(checkCount 0)

(exit 0)
