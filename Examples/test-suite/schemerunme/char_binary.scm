(define t (new-Test))

(if (not (= (Test-strlen t "hile") 4))
    (error "bad multi-arg typemap"))
(if (not (= (Test-ustrlen t "hile") 4))
    (error "bad multi-arg typemap"))

(if (not (= (Test-strlen t "hil\x00") 4))
    (error "bad multi-arg typemap"))
(if (not (= (Test-ustrlen t "hil\x00") 4))
    (error "bad multi-arg typemap"))

;; creating a raw char*

(define pc (new-pchar 5))
(pchar-setitem pc 0 #\h)
(pchar-setitem pc 1 #\o)
(pchar-setitem pc 2 #\l)
(pchar-setitem pc 3 #\a)
(pchar-setitem pc 4 0)

;; FIXME: pc in not string
;; (if (not (= (Test-strlen pc) 4))
;;     (error "bad multi-arg typemap"))
;; (if (not (= (Test-ustrlen pc) 4))
;;     (error "bad multi-arg typemap"))

;; FIXME: pc in not string
;; (var-pchar pc)
(var-pchar "hola")
(if (not (string=? (var-pchar) "hola"))
    (error "bad pointer case"))

;; FIXME: pc in not string and var-namet do not except string
;; (var-namet pc)
;; (if (not (string=? (var-namet) "hola"))
;;     (error "bad pointer case"))

(delete-pchar pc)

(exit 0)
