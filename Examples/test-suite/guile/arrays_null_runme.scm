;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_arrays_null_module" (dynamic-link "./libarrays_null"))

(define-macro (check form)
  `(if (not ,form)
       (error "Check failed: " ',form)))

(define-macro (check-null-rejected form)
  `(check (catch 'misc-error (lambda () ,form #f) (lambda (key . args) #t))))

(define s (new-ArraysNull))
(define other (new-ArraysNull))
(arrays-null-fill other 10)
(ArraysNull-ints-set s (ArraysNull-ints-get other))
(ArraysNull-items-set s (ArraysNull-items-get other))
(ArraysNull-grid-set s (ArraysNull-grid-get other))
(check (= (arrays-null-check s 10) 1))

(check-null-rejected (ArraysNull-ints-set s #nil))
(check-null-rejected (ArraysNull-items-set s #nil))
(check-null-rejected (ArraysNull-grid-set s #nil))
(check (= (arrays-null-check s 10) 1))

(arrays-null-ints (ArraysNull-ints-get s))
(arrays-null-items (ArraysNull-items-get s))
(arrays-null-grid (ArraysNull-grid-get s))
(check (= (arrays-null-globals-check 10) 1))

(check-null-rejected (arrays-null-ints #nil))
(check-null-rejected (arrays-null-items #nil))
(check-null-rejected (arrays-null-grid #nil))
(check-null-rejected (arrays-null-ints-ref #nil))
(check-null-rejected (arrays-null-bools #nil))
(check (= (arrays-null-globals-check 10) 1))

(check (= (arrays-null-ints-isnull #nil) 1))
(check (= (arrays-null-ints-unsized-isnull #nil) 1))
(check (= (arrays-null-enums-isnull #nil) 1))
(check (= (arrays-null-enums-unsized-isnull #nil) 1))
(check (= (arrays-null-items-isnull #nil) 1))
(check (= (arrays-null-items-unsized-isnull #nil) 1))
(check (= (arrays-null-bools-isnull #nil) 1))
(check (= (arrays-null-bools-unsized-isnull #nil) 1))
(check (= (arrays-null-strings-isnull #nil) 1))
(check (= (arrays-null-strings-unsized-isnull #nil) 1))

;; A reference to an array cannot be NULL
(check-null-rejected (arrays-null-ints-ref-first #nil))

(exit 0)
