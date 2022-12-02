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
(expect-throw 'misc-error
              (MovableCopyable-movein '()))
; TODO: check the exception message
(Counter-check-counts 0 0 0 0 0 0)

; output
(Counter-reset-counts)
(define mc (MovableCopyable-moveout 1234))
(Counter-check-counts 2 0 0 0 1 1)
(MovableCopyable-check-numbers-match mc 1234)

(expect-throw 'misc-error
              (MovableCopyable-movein mc))
; TODO: check the exception message
(Counter-check-counts 2 0 0 0 1 1)

(exit 0)
