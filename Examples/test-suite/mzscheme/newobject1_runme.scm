(load-extension "newobject1.so")

(require (lib "defmacro.ss"))

; Define an equivalent to Guile's gc procedure
(define-macro (gc)
  `(collect-garbage 'major))

(load "../schemerunme/newobject1.scm")
