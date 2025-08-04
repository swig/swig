(define t (new-Test))

(if (not (= (Test-strlen t "hile") 4))
    (error "bad multi-arg typemap"))

(if (not (= (Test-strlen t "hil\x00") 4))
    (error "bad multi-arg typemap"))

(exit 0)
