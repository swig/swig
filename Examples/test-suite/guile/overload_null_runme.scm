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

; fwd class declaration
(check (=~ 17 (Overload-byval1fwdptr o x)))
(check (=~ 18 (Overload-byval1fwdptr o #nil)))

(check (=~ 19 (Overload-byval2fwdptr o #nil)))
(check (=~ 20 (Overload-byval2fwdptr o x)))

(check (=~ 21 (Overload-byval1fwdref o x)))

(check (=~ 22 (Overload-byval2fwdref o x)))

(check (=~ 23 (Overload-bychar1 o #\a)))
;; NULL is not a char and char * does not accept it either
(check (not (false-if-exception (Overload-bychar1 o #nil))))

;; An array of char is a string, which cannot be NULL here, as for char *
(check (=~ 37 (Overload-bychararray o x)))
(check (=~ 38 (Overload-bychararray o "ab")))
(check (not (false-if-exception (Overload-bychararray o #nil))))

(check (=~ 39 (Overload-byunsizedchararray o x)))
(check (=~ 40 (Overload-byunsizedchararray o "ab")))
(check (not (false-if-exception (Overload-byunsizedchararray o #nil))))

(exit 0)
