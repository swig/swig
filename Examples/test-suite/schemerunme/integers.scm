(define-macro (check-equality form1 form2)
  `(let ((result1 ,form1)
	 (result2 ,form2))
     (if (not (equal? result1 result2))
	 (error "Check failed:"
		(list 'equal? ',form1 ',form2)
		result1 result2))))

(define-macro (check-range function from to)
  `(begin (check-equality (,function ,from) ,from)
	  (check-equality (,function ,to)   ,to)
	  (check-equality (throws-exception? (- ,from 1)) #t)
	  (check-equality (throws-exception? (+ ,to 1)) #t)))

;;; signed char, unsigned char typemaps deal with characters, not integers.
;; (check-range signed-char-identity (- (expt 2 7)) (- (expt 2 7) 1))
;; (check-range unsigned-char-identity 0 (- (expt 2 8) 1))
(check-range signed-short-identity (- (expt 2 15)) (- (expt 2 15) 1))
(check-range unsigned-short-identity 0 (- (expt 2 16) 1))
(check-range signed-int-identity (- (expt 2 31)) (- (expt 2 31) 1))
(check-range unsigned-int-identity 0 (- (expt 2 32) 1))
(check-range signed-long-identity (- (expt 2 31)) (- (expt 2 31) 1))
(check-range unsigned-long-identity 0 (- (expt 2 32) 1))
;;; long long not implemented in Guile.
;; (check-range signed-long-long-identity (- (expt 2 63)) (- (expt 2 63) 1))
;; (check-range unsigned-long-long-identity 0 (- (expt 2 64) 1))
(quit)
