;;;
;;; Guile script for simple example.
;;; Is a little clumsy since I'm not the greatest scheme programmer.
;;;

(display (get-time))
(display "My variable = ")
(display (My-variable))
(newline)

(define (facts x max)
  (if (< x max)
      (begin
        (display (string-append (number->string x) " factorial is "
                                (number->string (fact x))))
        (newline)
        (facts (+ x 1) max))))

(facts 0 14)


(define (mods i imax j jmax)
  (if (< i imax)
      (if (< j jmax)
          (begin
            (My-variable (+ (My-variable) (mod i j)))
            (mods i imax (+ j 1) jmax))
          (mods (+ i 1) imax 1 jmax))))

(mods 1 250 1 250)

(display (string-append "My-variable = " (number->string (My-variable))))
(newline)

;;; example.scm ends here
