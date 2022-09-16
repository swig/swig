(load-extension "cpp11_move_typemaps.so")
(require (lib "defmacro.ss"))

; Copied from ../schemerunme/cpp11_move_typemaps.scm and modified for exceptions

; Define an equivalent to Guile's gc procedure
(define-macro (gc)
  `(collect-garbage 'major))

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
(define exception_thrown "no exception thrown for mo")
(with-handlers ([exn:fail? (lambda (exn)
                             (set! exception_thrown (exn-message exn)))])
  (MoveOnly-take mo))
(unless (string-contains? exception_thrown "cannot release ownership as memory is not owned")
  (error "Wrong or no exception thrown: " exception_thrown))

(exit 0)
