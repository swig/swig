;; -*- buffer-read-only: t -*- vi: set ro:
;; This file was created automatically by SWIG.
;; Don't modify this file, modify the SWIG interface instead.
(cond-expand ((or chicken-compile-shared shared)) (else (declare (unit simple))))

(declare 
    (hide swig-init)
    (foreign-declare "C_extern void simple_swig_init(int,C_word,C_word) C_noret;"))
(define swig-init (##core#primitive "simple_swig_init"))
(swig-init)


(declare 
 (foreign-declare "C_extern int   simple_swig_num_types (void);")
 (foreign-declare "C_extern char* simple_swig_type_name (int);")
 (foreign-declare "C_extern void* simple_swig_type_ptr (int);")
 (foreign-declare "C_extern char* simple_swig_type_str (int);")
 (foreign-declare "C_extern void  simple_swig_type_tag (int, C_word);"))
(define-record swig-simple-tag class name ptr str)
(define-record-printer (swig-simple-tag tag out)
 (fprintf out "#<tag ~S>(~A)" (swig-simple-tag-str tag) 
  (swig-simple-tag-ptr tag)))
(define swig-simple-tag-num 
 ((foreign-lambda int "simple_swig_num_types")))
(define swig-simple-tags (make-vector swig-simple-tag-num #f))
(letrec
 ((gen
   (lambda (l i)
    (if (= i 0) (cons 0 l) (gen (cons i l) (- i 1))))))
 (let ((indices (if (<= swig-simple-tag-num 0) (quote ())
		 (gen (quote ()) (- swig-simple-tag-num 1)))))
  (for-each 
   (lambda (index)
    (let 
     ((tag
       (make-swig-simple-tag 
	1000 
	((foreign-lambda
	  c-string "simple_swig_type_name" int) index)
	((foreign-lambda
	  c-pointer "simple_swig_type_ptr" int) index)
	((foreign-lambda
	  c-string "simple_swig_type_str" int) index))))
     (vector-set! swig-simple-tags index tag)
     ((foreign-lambda void "simple_swig_type_tag"
       int scheme-object) index tag)))
   indices)))


