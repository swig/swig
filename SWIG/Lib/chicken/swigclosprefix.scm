;(declare (hide swig-initialize))

;(define (swig-initialize obj initargs create destroy)
;     (if (memq 'swig-init initargs)
;        (slot-set! obj 'swig-this (cadr initargs))
;        (begin
 ;           (slot-set! obj 'swig-this (apply create initargs))
                ;(let ((ret (apply create initargs)))
                ;  (if (instance? ret)
                ;    (slot-ref ret 'swig-this)
                ;    ret)))
;            (set-finalizer! obj destroy))))

(define-class <swig-metaclass-$module> (<class>) (void))

(define-method (compute-getter-and-setter (class <swig-metaclass-$module>) slot allocator)
  (if (not (memq ':swig-virtual slot))
    (call-next-method)
    (let ((getter (let search-get ((lst slot))
                    (if (null? lst)
                      #f
                      (if (eq? (car lst) ':swig-get)
                        (cadr lst)
                        (search-get (cdr lst))))))
          (setter (let search-set ((lst slot))
                    (if (null? lst)
                      #f
                      (if (eq? (car lst) ':swig-set)
                        (cadr lst)
                        (search-set (cdr lst)))))))
      (values
        (lambda (o) (getter (slot-ref o 'swig-this)))
	(lambda (o new) (setter (slot-ref o 'swig-this) new) new)))))
