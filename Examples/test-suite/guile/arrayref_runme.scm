(dynamic-call "scm_init_arrayref_module" (dynamic-link "./libarrayref"))

(define-macro (check test)
  `(if (not ,test) (error "Error in test" ',test)))

; An array of char is a string here, and so is a reference to one.
(check (string=? (letters) "abc"))
(check (string=? (letters-ref) "abc"))
(letters-ref "xy")
(check (string=? (letters-are) "xy"))
(check (string=? (frozen-ref) "xyz"))

(exit 0)
