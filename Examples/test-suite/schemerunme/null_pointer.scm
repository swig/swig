(define null '())
(unless (funk null)
  (error "funk(null) does not return true"))

(unless (null? (getnull))
  (error "NULL pointer should be null"))

(exit 0)
