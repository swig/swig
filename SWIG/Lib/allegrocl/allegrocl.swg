%wrapper %{
;; $Id$

(eval-when (compile eval)

;;; You can define your own identifier converter if you want.
;;; Use the -identifier-converter command line argument to
;;; specify its name. 
  
(defun identifier-convert-null (id &key type)
  (declare (ignore type))
  (intern id))

(defun identifier-convert-lispify (cname &key type)
  (assert (stringp cname))
  (if (eq type :constant)
      (setf cname (format nil "*~A*" cname)))
  (setf cname (replace-regexp cname "_" "-"))
  (let ((lastcase :other)
        newcase char res)
    (dotimes (n (length cname))
      (setf char (schar cname n))
      (if* (alpha-char-p char)
         then
              (setf newcase (if (upper-case-p char) :upper :lower))

              (when (or (and (eq lastcase :upper) (eq newcase :lower))
                        (and (eq lastcase :lower) (eq newcase :upper)))
                ;; case change... add a dash                                    
                (push #\- res)
                (setf newcase :other))

              (push (char-downcase char) res)

              (setf lastcase newcase)

         else
              (push char res)
              (setf lastcase :other)))
    (intern (coerce (nreverse res) 'string))))

(defmacro swig-defconstant (string value)
  (let ((symbol (funcall *swig-identifier-converter* string :type :constant)))
    `(eval-when (compile load eval)
       (defconstant ,symbol ,value)
       (export (quote ,symbol)))))

(defmacro swig-defun (name &rest rest)
  (let ((symbol (funcall *swig-identifier-converter* name :type :operator)))
    `(eval-when (compile load eval)
       (excl::compiler-let ((*record-xref-info* nil))
	 (ff:def-foreign-call ,symbol ,@rest)
	 (export (quote ,symbol))))))
    
    

) ;; eval-when
%}
