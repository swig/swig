(Counter-reset-counts)
(define mo (new-MoveOnly 111))
(Counter-check-counts 1 0 0 0 0 0)
(MoveOnly-take mo)
(Counter-check-counts 1 0 0 1 0 2)
(delete-MoveOnly mo)
(Counter-check-counts 1 0 0 1 0 2)

(Counter-reset-counts)
(define mo (new-MovableCopyable 111))
(Counter-check-counts 1 0 0 0 0 0)
(MovableCopyable-take mo)
(Counter-check-counts 1 0 0 1 0 2)
(delete-MovableCopyable mo)
(Counter-check-counts 1 0 0 1 0 2)

(define mo (new-MoveOnly 222))
(MoveOnly-take mo)
(expect-throw 'misc-error
              (MoveOnly-take mo))
; TODO: check the exception message

(exit 0)
