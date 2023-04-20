(load-extension "catches_strings.so")
(require (lib "defmacro.ss"))

(define exception_thrown "no exception thrown for kin")
(with-handlers ([exn:fail? (lambda (exn)
                             (set! exception_thrown (exn-message exn)))])
  (StringsThrower-charstring))
(unless (string-contains? exception_thrown "charstring message")
  (error (format "incorrect exception message: ~a" exception_thrown)))

(define exception_thrown "no exception thrown for kin")
(with-handlers ([exn:fail? (lambda (exn)
                             (set! exception_thrown (exn-message exn)))])
  (StringsThrower-stdstring))
(unless (string-contains? exception_thrown "stdstring message")
  (error (format "incorrect exception message: ~a" exception_thrown)))

(exit 0)
