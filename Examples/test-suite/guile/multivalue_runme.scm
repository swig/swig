;;;; Automatic test of multiple return values

;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_test_module" (dynamic-link "./libmultivalue.so"))

(let ((quotient/remainder (divide-l 37 5)))
  (if (not (equal? quotient/remainder '(7 2)))
      (exit 1)))

(let ((quotient-remainder-vector (divide-v 41 7)))
  (if (not (equal? quotient-remainder-vector #(5 6)))
      (exit 1)))

(call-with-values (lambda ()
		    (divide-mv 91 13))
		  (lambda (quotient remainder)
		    (if (not (and (= quotient 7)
				  (= remainder 0)))
			(exit 1))))

(exit 0)
			     
