(dynamic-call "scm_init_ignore_parameter_module" (dynamic-link "./libignore_parameter"))

(define-macro (check test)
  `(if (not ,test) (error "Error in test" ',test)))

(check (string=? (jaguar 200 0.0) "hello"))
(check (= (lotus "foo" 1.0) 101))
(check (= (tvr "bar" 2) 8.8))
(check (= (ferrari) 101))
(check (= (called-argout) 1))
(check (= (called-freearg) 1))
(check (= (fiat 17) 17))

(define car (new-SportsCars))
(check (string=? (SportsCars-daimler car 200 0.0) "hello"))
(check (= (SportsCars-astonmartin car "foo" 1.0) 101))
(check (= (SportsCars-bugatti car "bar" 2) 8.8))
(check (= (SportsCars-lamborghini car) 101))
(check (= (SportsCars-maseratti car 289) 289))
(check (= (SportsCars-audi car) 8.8))

(new-MiniCooper 200 0.0)
(new-MorrisMinor "baz" 0.0)
(new-FordAnglia "quux" 200)
(new-AustinAllegro)

(exit 0)
