(load-library 'example "./zlib.so")

;; Init zstream
(define s (new-z-stream))
(z-stream-zalloc-set s #f)
(z-stream-zfree-set s #f)
(z-stream-opaque-set s #f)
(deflate-init s (Z-DEFAULT-COMPRESSION))

;; Deflate something small so we don't need to loop/stream data
(define in "some pony et jumping et jack et flash et had a jack pony")
(define out (make-string 1000))
(printf "to be compressed: ~A~%to be compressed bytes: ~A~%~%" in (string-length in))
(z-stream-next-in-set s in)
(z-stream-avail-in-set s (string-length in))
(z-stream-next-out-set s out)
(z-stream-avail-out-set s (string-length out))
(let*
    ((saved-out (z-stream-save-next-out s))
     (ret (deflate s (Z-FINISH))))
  (cond
   ((= ret (Z-STREAM-END))
    (printf "deflated properly!~%compressed bytes: ~A~%compressed stream: ~A~%" 
            (z-stream-total-out-get s) (z-stream-get-next-chunk s saved-out)))
   ((= ret (Z-OK))
    (display "only partial deflation ... not enough output space\n"))
   (else
    (printf "deflate error(~D): ~A ~%" ret (z-stream-msg-get s)))))

;; Use simple compress routine, and set max output size to 100
(newline)
(call-with-values (lambda () (compress 100 in))
  (lambda (ret compressed)
    (cond
     ((= ret (Z-OK))
      (printf "compressed properly!~%compressed bytes: ~A~%compressed stream: ~A~%"
              (string-length compressed) compressed))
     (else
      (printf "compress error(~D): ~A ~%" ret (z-error ret))))))

(exit 0)
