;; The SWIG modules have "passive" Linkage, i.e., they don't generate
;; Guile modules (namespaces) but simply put all the bindings into the
;; current module.  That's enough for such a simple test.
(dynamic-call "scm_init_overload_null_module" (dynamic-link "./liboverload_null"))

(define-macro (check form)
  `(if (not ,form)
       (error "Check failed: " ',form)))

(define (=~ a b)
  (< (abs (- a b)) 1e-8))

(define o (new-Overload))
(define x (new-X))

(check (=~ 1 (Overload-byval1 o x)))
(check (=~ 2 (Overload-byval1 o #nil)))

(check (=~ 3 (Overload-byval2 o #nil)))
(check (=~ 4 (Overload-byval2 o x)))

(check (=~ 5 (Overload-byref1 o x)))
(check (=~ 6 (Overload-byref1 o #nil)))

(check (=~ 7 (Overload-byref2 o #nil)))
(check (=~ 8 (Overload-byref2 o x)))

(check (=~ 9 (Overload-byconstref1 o x)))
(check (=~ 10 (Overload-byconstref1 o #nil)))

(check (=~ 11 (Overload-byconstref2 o #nil)))
(check (=~ 12 (Overload-byconstref2 o x)))

; const pointer references
; No SWIGTYPE *const& typemaps for Guile yet
;(check (=~ 13 (Overload-byval1cpr o x)))
;(check (=~ 14 (Overload-byval1cpr o #nil)))

;(check (=~ 15 (Overload-byval2cpr o #nil)))
;(check (=~ 16 (Overload-byval2cpr o x)))

; forward class declaration
(check (=~ 17 (Overload-byval1forwardptr o x)))
(check (=~ 18 (Overload-byval1forwardptr o #nil)))

(check (=~ 19 (Overload-byval2forwardptr o #nil)))
(check (=~ 20 (Overload-byval2forwardptr o x)))

(check (=~ 21 (Overload-byval1forwardref o x)))

(check (=~ 22 (Overload-byval2forwardref o x)))

(exit 0)
