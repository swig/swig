;; run with mzscheme -r runme.scm

(load-extension "example.so")

; Call our gcd() function

(define x 42)
(define y 105)
(define g (gcd x y))
(display "The gcd of ")
(display x)
(display " and ")
(display y)
(display " is ")
(display g)
(newline)

; Manipulate the Foo global variable

; Output its current value
(display "Foo = ")
(display (Foo))
(newline)

; Change its value
(Foo 3.1415926)

; See if the change took effect
(display "Foo = ")
(display (Foo))
(newline)
