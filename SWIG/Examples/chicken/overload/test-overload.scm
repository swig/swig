;; This file demonstrates the overloading capabilities of SWIG

(declare (uses example))
(declare (uses tinyclos))

;; Low level
;; ---------

(display "
Trying low level code ...
  (example:foo 1)
  (example:foo \"some string\")
  (define A-FOO (example:new-Foo))
  (define ANOTHER-FOO (example:new-Foo A-FOO)) ;; copy constructor
  (example:Foo-bar A-FOO 2)
  (example:Foo-bar ANOTHER-FOO \"another string\" 3)
")

(example:foo 1)
(example:foo "some string")
(define A-FOO (example:new-Foo))
(define ANOTHER-FOO (example:new-Foo A-FOO)) ;; copy constructor
(example:Foo-bar A-FOO 2)
(example:Foo-bar ANOTHER-FOO "another string" 3)

;; TinyCLOS
;; --------

(display "
Trying TinyCLOS code ...
  (+example:foo+ 1)
  (+example:foo+ \"some string\")
  (define A-FOO (make <example:Foo>))
  (define ANOTHER-FOO (make <example:Foo> A-FOO)) ;; copy constructor
  (-bar- A-FOO 2)
  (-bar- ANOTHER-FOO \"another string\" 3)
")

;; ALL generic methods must be included first
(include "example-generic")
;; After generic methods are defined, can include TinyCLOS code
(include "example-clos")

(+example:foo+ 1)
(+example:foo+ "some string")
(define A-FOO (make <example:Foo>))
(define ANOTHER-FOO (make <example:Foo> A-FOO)) ;; copy constructor
(-bar- A-FOO 2)
(-bar- ANOTHER-FOO "another string" 3)
