(dynamic-call "scm_init_cpp11_rvalue_reference_array_module" (dynamic-link "./libcpp11_rvalue_reference_array"))

(define-macro (check form)
  `(if (not ,form)
       (error "Check failed: " ',form)))

(define-macro (check-null-rejected form)
  `(check (catch 'misc-error (lambda () ,form #f) (lambda (key . args) #t))))

; An rvalue reference to an array is passed as a reference to an array, which cannot be NULL.
(check (= (sum-of (others-address)) 100))
(check (= (first-of (others-unsized-address)) 10))
(check (= (items-sum (items-address)) 3))
(check-null-rejected (sum-of #nil))
(check-null-rejected (first-of #nil))

; An rvalue reference to an array of char is a string.
(check (= (length-of "abc") 3))
(check (= (length-of-writable "xy") 2))

; Setting a variable that is an rvalue reference to an array copies into the array it refers to.
(check (= (numbers-sum) 10))
(numbers-rref (others-address))
(check (= (numbers-sum) 100))
(check (string=? (letters-rref) "abc"))
(letters-rref "xy")
(check (string=? (letters-are) "xy"))

(define member (new-RvalueRefArrayMember))
(check (= (RvalueRefArrayMember-sum member) 10))
(RvalueRefArrayMember-member-rref-set member (others-address))
(check (= (RvalueRefArrayMember-sum member) 100))
(check (string=? (RvalueRefArrayMember-text-rref-get member) "hi"))
(RvalueRefArrayMember-text-rref-set member "bye")
(check (string=? (RvalueRefArrayMember-text-is member) "bye"))

(exit 0)
