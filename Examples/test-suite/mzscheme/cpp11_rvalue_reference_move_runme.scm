(load-extension "cpp11_rvalue_reference_move.so")
(require (lib "defmacro.ss"))

; Copied from ../schemerunme/cpp11_rvalue_reference_move.scm and modified for exceptions

; Function containing rvalue reference parameter
(Counter-reset-counts)
(define mo (new-MovableCopyable 222))
(Counter-check-counts 1 0 0 0 0 0)
(MovableCopyable-movein mo)
(Counter-check-counts 1 0 0 1 0 2)
(unless (MovableCopyable-is-nullptr mo)
  (error "is_nullptr failed"))
(delete-MovableCopyable mo)
(Counter-check-counts 1 0 0 1 0 2)

; Move constructor test
(Counter-reset-counts)
(define mo (new-MovableCopyable 222))
(Counter-check-counts 1 0 0 0 0 0)
(define mo_moved (new-MovableCopyable mo))
(Counter-check-counts 1 0 0 1 0 1)
(unless (MovableCopyable-is-nullptr mo)
  (error "is_nullptr failed"))
(delete-MovableCopyable mo)
(Counter-check-counts 1 0 0 1 0 1)
(delete-MovableCopyable mo_moved)
(Counter-check-counts 1 0 0 1 0 2)

; Move assignment operator test
(Counter-reset-counts)
(define mo111 (new-MovableCopyable 111))
(define mo222 (new-MovableCopyable 222))
(Counter-check-counts 2 0 0 0 0 0)
(MovableCopyable-MoveAssign mo111 mo222)
(Counter-check-counts 2 0 0 0 1 1)
(unless (MovableCopyable-is-nullptr mo222)
  (error "is_nullptr failed"))
(delete-MovableCopyable mo222)
(Counter-check-counts 2 0 0 0 1 1)
(delete-MovableCopyable mo111)
(Counter-check-counts 2 0 0 0 1 2)

; null check
(Counter-reset-counts)
(define exception_thrown "no exception thrown for kin")
(with-handlers ([exn:fail? (lambda (exn)
                             (set! exception_thrown (exn-message exn)))])
  (MovableCopyable-movein '()))
(unless (string=? exception_thrown "MovableCopyable-movein: swig-type-error (null reference)")
  (error (format "incorrect exception message: ~a" exception_thrown)))
(Counter-check-counts 0 0 0 0 0 0)

; output
(Counter-reset-counts)
(define mc (MovableCopyable-moveout 1234))
(Counter-check-counts 2 0 0 0 1 1)
(MovableCopyable-check-numbers-match mc 1234)

(define exception_thrown "no exception thrown for kin")
(with-handlers ([exn:fail? (lambda (exn)
                             (set! exception_thrown (exn-message exn)))])
  (MovableCopyable-movein mc))
(unless (string-contains? exception_thrown "cannot release ownership as memory is not owned")
  (error (format "incorrect exception message: ~a" exception_thrown)))
(Counter-check-counts 2 0 0 0 1 1)

(exit 0)
