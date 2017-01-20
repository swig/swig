# file: runme.lisp

;; (:cd "") ;; uncomment this and set it to the example directory; for Clozure CL
(require 'cffi)
(load (compile-file "example.lisp"))
(load (compile-file "example-clos.lisp"))

(open-shared-library "example.so")


(setf mys (make-instance 'Steven))
(setf myc (make-instance 'Clarissa))

(type-of mys)
(type-of myc)

;; working examples of clos method calls:
(the-class-clarissa-has-this-method myc 3)
(the-struct-steven-has-this-method  mys 3)

;; if you wanted to use straight function calls instead of the generic methods,
;; you'd have to get the correct ff-pointer to pass in, using slot-value.
(Steven_the_struct_Steven_has_this_method    (slot-value mys 'ff-pointer) 6)
(Clarissa_the_class_Clarissa_has_this_method (slot-value myc 'ff-pointer) 6)

(slot-value mys 'ff-pointer)
(slot-value myc 'ff-pointer)

;; getting a member variable
(_a mys)
(_a myc)

;; setting a member variable
(setf (_a mys) 88)
(setf (_a myc) 88)


