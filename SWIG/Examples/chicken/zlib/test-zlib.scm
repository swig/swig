;; run with './zlib test-zlib.scm'

(declare (uses example))
(declare (uses format))

;; Init zstream
(define s (zlib:new-z-stream))
(zlib:z-stream-zalloc-set s #f)
(zlib:z-stream-zfree-set s #f)
(zlib:z-stream-opaque-set s #f)
(zlib:deflate-init s (zlib:z-default-compression))

;; Deflate something small so we don't need to loop/stream data
(define in "some pony et jumping et jack et flash et had a jack pony")
(define out (make-string 1000))
(format #t "to be compressed: ~A~%to be compressed bytes: ~D~%~%" in (string-length in))
(zlib:z-stream-next-in-set s in)
(zlib:z-stream-avail-in-set s (string-length in))
(zlib:z-stream-next-out-set s out)
(zlib:z-stream-avail-out-set s (string-length out))
(let*
    ((saved-out (zlib:z-stream-save-next-out s))
     (ret (zlib:deflate s (zlib:z-finish))))
  (cond
   ((= ret (zlib:z-stream-end))
    (format #t "deflated properly!~%compressed bytes: ~D~%compressed stream: ~S~%" 
            (zlib:z-stream-total-out-get s) (zlib:z-stream-get-next-chunk s saved-out)))
   ((= ret (zlib:z-ok))
    (display "only partial deflation ... not enough output space\n"))
   (else
    (format #t "deflate error(~D): ~A ~%" ret (zlib:z-stream-msg-get s)))))

;; Use simple compress routine, and set max output size to 100
(define c (zlib:compress 100 in))
(newline)
(let
    ((ret (car c))
     (compressed (cadr c)))
  (cond
   ((= ret (zlib:z-ok))
    (format #t "compressed properly!~%compressed bytes: ~D~%compressed stream: ~S~%"
            (string-length compressed) compressed))
   (else
    (format #t "compress error(~D): ~A ~%" ret (zlib:z-error ret)))))

