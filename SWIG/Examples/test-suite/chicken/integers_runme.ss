(load "integers.so")
(define-macro (throws-exception? form)
  `(condition-case (begin ,form #f)
     ((exn) #t)))

(include "../schemerunme/integers.scm")
