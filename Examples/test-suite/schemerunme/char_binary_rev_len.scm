(define t (new-Test))

(if (not (= (Test-strlen t "hile") 4))
    (error "bad multi-arg typemap 1"))

(if (not (= (Test-strlen t "hil\x00") 4))
    (error "bad multi-arg typemap 2"))

(define t2 (new-Test "hile"))

(if (not (= (Test-getisize t2) 4))
    (error "bad multi-arg typemap 3"))

(if (not (= (Test-strlen t2 "hil\x00a") 5))
    (error "bad multi-arg typemap 4"))

(exit 0)
