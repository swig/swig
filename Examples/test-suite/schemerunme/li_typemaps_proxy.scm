(define-macro (check func val test)
  (cons 'begin
    (map
      (lambda (x) 
        `(if (not (,test (,(string->symbol (string-append x func)) ,val) ,val))
           (error ,(string-append "Error in test " x func))))
      (list "in-" "inr-" "out-" "outr-" "inout-" "inoutr-"))))

(define (=~ a b)
  (< (abs (- a b)) 1e-5))
                      
(check "bool" #t and)
(check "int" -2 =)
(check "long" -32 =)
(check "short" -15 =)
(check "uint" 75 =)
(check "ushort" 123 =)
(check "ulong" 462 =)
;(check "uchar" 16 =)
;(check "schar" -53 =)
(check "float" 4.3 =~)
(check "double" -175.42 =~)
(check "longlong" 1634 =)
(check "ulonglong" 6432 =)

(let ((lst (inoutr-int2 3 -2)))
  (if (not (and (= (car lst) 3) (= (cadr lst) -2)))
    (error "Error in inoutr-int2")))

(let ((lst (out-foo 4)))
  (if (not (and (= (slot-ref (car lst) 'a) 4) (= (cadr lst) 8)))
    (error "Error in out-foo")))

(exit 0)
