;; Fetch predefined vector
(define m (predefStr))
;; Convert it to binary string
(define s (cdata m  512))
;; Temporary varibale
(define val 0)
(define i2 0)
(define c 'a)

;; Verify binary string content is correct
(map (lambda (i)
  (set! c (string-ref s i))
  (set! val (char->integer c))
  (if (not (= val i))
      (error (format #f "Wrong value ~A for index ~A ~%" val i)))
  (set! i2 (+ i 256))
  (set! c (string-ref s i2))
  (set! val (char->integer c))
  (if (not (= val i))
      (error (format #f "Wrong value ~A for index ~A ~%" val i2))))
  (iota 256))

;; Set binary string content for verifying
(map (lambda (i)
  (set! val (- 256 (+ 1 i)))
  (set! c (integer->char val))
  (string-set! s i c)
  (set! i2 (+ i 256))
  (string-set! s i2 c))
   (iota 256))

;; Copy binary string into another C buffer
(define m2 (malloc 512))
(memmove m2 s)
;; Verfy the other C buffer have the proper content
(if (< (verifyBytes m2) 0)
    (error "failed verifyBytes"))
;; Release the other buffer
(free m2)

(exit 0)
