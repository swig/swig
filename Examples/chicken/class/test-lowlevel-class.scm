;; This file illustrates the low-level C++ interface generated
;; by SWIG.

(declare (uses example))

;; ----- Object creation -----

(display "Creating some objects:\n")
(define c (example:new-Circle 10.0))
(display "    Created circle ")
(display c)
(display "\n")
(define s (example:new-Square 10.0))
(display "    Created square ")
(display s)
(display "\n")

;; ----- Access a static member -----

(display "\nA total of ")
(display (example:Shape-nshapes))
(display " shapes were created\n")

;; ----- Member data access -----

;; Set the location of the object

(example:Shape-x-set c 20.0)
(example:Shape-y-set c 30.0)

(example:Shape-x-set s -10.0)
(example:Shape-y-set s 5.0)

(display "\nHere is their current position:\n")
(display "    Circle = (")
(display (example:Shape-x-get c))
(display ", ")
(display (example:Shape-y-get c))
(display ")\n")
(display "    Square = (")
(display (example:Shape-x-get s))
(display ", ")
(display (example:Shape-y-get s))
(display ")\n")

;; ----- Call some methods -----

(display "\nHere are some properties of the shapes:\n")
(let
    ((disp (lambda (o)
             (display "   ")
             (display o)
             (display "\n")
             (display "        area      = ")
             (display (example:Shape-area o))
             (display "\n")
             (display "        perimeter = ")
             (display (example:Shape-perimeter o))
             (display "\n"))))
  (disp c)
  (disp s))

(display "\nGuess I'll clean up now\n")

;; Note: this invokes the virtual destructor
(example:delete-Shape c)
(example:delete-Shape s)

(set! s 3)
(display (example:Shape-nshapes))
(display " shapes remain\n")
(display "Goodbye\n")
