
(define (mdisplay-newline . args)       ; does guile-1.3.4 have `format #t'?
  (for-each display args)
  (newline))

; Call our gcd() function

(define x 42)
(define y 105)
(define g (gcd x y))
(mdisplay-newline "The gcd of " x " and " y " is " g)

; Manipulate the Foo global variable

; Output its current value
(mdisplay-newline "Foo = " (Foo))

; Change its value
(Foo 3.1415926)

; See if the change took effect
(mdisplay-newline "Foo = " (Foo))
