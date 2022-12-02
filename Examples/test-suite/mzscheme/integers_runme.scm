(load-extension "integers.so")
(require (lib "defmacro.ss"))

(define-macro (throws-exception? form)
  `(with-handlers ((not-break-exn? (lambda (exn) #t)))
     ,form
     #f))

(load (build-path (path-only (path->complete-path (find-system-path 'run-file))) "../schemerunme/integers.scm"))
