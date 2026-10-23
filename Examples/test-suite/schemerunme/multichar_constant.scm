;; Multicharacter constants have type int, not char.
(if (= (MULTICHAR-AB) (imulti-ab))
    (exit 0)
    (exit 1))
