;;; This is the union runtime testcase. It ensures that values within a
;;; union embedded within a struct can be set and read correctly.

;; Create new instances of SmallStruct and BigStruct for later use
(define small (unions:new-SmallStruct))
(unions:SmallStruct-jill-set small 200)

(define big (unions:new-BigStruct))
(unions:BigStruct-smallstruct-set big small)
(unions:BigStruct-jack-set big 300)

;; Use SmallStruct then BigStruct to setup EmbeddedUnionTest.
;; Ensure values in EmbeddedUnionTest are set correctly for each.
(define eut (unions:new-EmbeddedUnionTest))

;; First check the SmallStruct in EmbeddedUnionTest
(unions:EmbeddedUnionTest-number-set eut 1)
(unions:EmbeddedUnionTest-uni-small-set (unions:EmbeddedUnionTest-uni-get eut)
				 small)
(let ((Jill1 (unions:SmallStruct-jill-get
	      (unions:EmbeddedUnionTest-uni-small-get
	       (unions:EmbeddedUnionTest-uni-get eut)))))
  (if (not (= Jill1 200))
      (begin
	(display "Runtime test 1 failed.")
	(exit 1))))

(let ((Num1 (unions:EmbeddedUnionTest-number-get eut)))
  (if (not (= Num1 1))
      (begin
	(display "Runtime test 2 failed.")
	(exit 1))))

;; that should do

(exit 0)
