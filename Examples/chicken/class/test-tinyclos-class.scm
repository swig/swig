;; This file illustrates the shadow C++ interface generated
;; by SWIG.

(declare (uses example))
(declare (uses tinyclos))

;; All generic methods must be included first
(include "example-generic")

;; After generic are defined, can include TinyCLOS code
(include "example-clos")

;; ----- Object creation -----

(display "Creating some objects:\n")
(define c (make <example:Circle> 10.0))
(display "    Created circle ")
(display c)
(display "\n")
(define s (make <example:Square> 10.0))
(display "    Created square ")
(display s)
(display "\n")

;; ----- Access a static member -----

(display "\nA total of ")
(display (+example:Shape-nshapes+))
(display " shapes were created\n")

;; ----- Member data access -----

;; Set the location of the object

(-set-x!- c 20.0)
(-set-y!- c 30.0)

(-set-x!- s -10.0)
(-set-y!- s 5.0)

(display "\nHere is their current position:\n")
(display "    Circle = (")
(display (-get-x- c))
(display ", ")
(display (-get-y- c))
(display ")\n")
(display "    Square = (")
(display (-get-x- s))
(display ", ")
(display (-get-y- s))
(display ")\n")

;; ----- Call some methods -----

(display "\nHere are some properties of the shapes:\n")
(let
    ((disp (lambda (o)
             (display "   ")
             (display o)
             (display "\n")
             (display "        area      = ")
             (display (-area- o))
             (display "\n")
             (display "        perimeter = ")
             (display (-perimeter- o))
             (display "\n"))))
  (disp c)
  (disp s))

(display "\nGuess I'll clean up now\n")

;; Note: Invoke the virtual destructors by forcing garbage collection
(set! c 77)
(set! s 88)
(gc #t)

(display (+example:Shape-nshapes+))
(display " shapes remain\n")
(display "Goodbye\n")
