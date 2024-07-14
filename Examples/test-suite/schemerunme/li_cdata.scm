
(define s "ABC\x00abc")
(define m (malloc 256))
(memmove m s)
(define ss (cdata m  7))

(if (not (string=? ss "ABC\x00abc"))
    (error "failed"))

(exit 0)
