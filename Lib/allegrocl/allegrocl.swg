%wrapper %{
;; allegrocl.swg
;; $Id$

(eval-when (compile eval)

  ;; Customize this (in your swig interface definition file, not here)
  ;; if you want to change how the name is defined in Lisp.  This
  ;; function will be called at least twice per symbol, so keep this
  ;; in mind if your customized function has side effects.

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



    ) ;; eval-when
%}
