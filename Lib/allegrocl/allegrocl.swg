/* Define a C preprocessor symbol that can be used in interface files
   to distinguish between the SWIG language modules. */ 

#define SWIG_ALLEGRO_CL

#define %ffargs(...) %feature("ffargs", "1", ##__VA_ARGS__)
%ffargs(strings_convert="t");

/* typemaps for argument and result type conversions. */
%typemap(lin)	SWIGTYPE 	"(let (($out $in))\n  $body)";

%typemap(lout) bool, char, unsigned char, signed char,
               short, signed short, unsigned short,
               int, signed int, unsigned int,
               long, signed long, unsigned long,
               float, double, long double, char *, void *, void,
               enum SWIGTYPE    "$body";
%typemap(lout) SWIGTYPE[ANY], SWIGTYPE *,
               SWIGTYPE &       "(make-instance '$lclass :foreign-address $body)";
%typemap(lout) SWIGTYPE         "(let* ((address $body)\n         (ACL_result (make-instance '$lclass :foreign-address address)))\n    (unless (zerop address)\n      (excl:schedule-finalization ACL_result #'$ldestructor))\n    ACL_result)";

%typemap(lisptype) bool "boolean";
%typemap(lisptype) char "character";
%typemap(lisptype) unsigned char "integer";
%typemap(lisptype) signed char "integer";

%typemap(ffitype) bool ":int";
%typemap(ffitype) char ":char";
%typemap(ffitype) unsigned char ":unsigned-char";
%typemap(ffitype) signed char ":char";
%typemap(ffitype) short, signed short ":short";
%typemap(ffitype) unsigned short ":unsigned-short";
%typemap(ffitype) int, signed int ":int";
%typemap(ffitype) unsigned int ":unsigned-int";
%typemap(ffitype) long, signed long ":long";
%typemap(ffitype) unsigned long ":unsigned-long";
%typemap(ffitype) float ":float";
%typemap(ffitype) double ":double";
%typemap(ffitype) char * "(* :char)";
%typemap(ffitype) void * "(* :void)";
%typemap(ffitype) void ":void";
%typemap(ffitype) enum SWIGTYPE ":int";
%typemap(ffitype) SWIGTYPE & "(* :void)";

%typemap(ctype) bool                       "int";
%typemap(ctype) char, unsigned char, signed char,
                short, signed short, unsigned short,
                int, signed int, unsigned int,
                long, signed long, unsigned long,
                float, double, long double, char *, void *, void,
                enum SWIGTYPE, SWIGTYPE *,
                SWIGTYPE[ANY], SWIGTYPE &  "$1_ltype";
%typemap(ctype) SWIGTYPE                   "$&1_type";

%typemap(in) bool                          "$1 = (bool)$input;";
%typemap(in) char, unsigned char, signed char,
             short, signed short, unsigned short,
             int, signed int, unsigned int,
             long, signed long, unsigned long,
             float, double, long double, char *, void *, void,
             enum SWIGTYPE, SWIGTYPE *,
             SWIGTYPE[ANY], SWIGTYPE &     "$1 = $input;";
%typemap(in) SWIGTYPE                      "$1 = *$input;";

/* We don't need to do any actual C-side typechecking, but need to
   use the precedence values to choose which overloaded function
   interfaces to generate when conflicts arise. */

/* predefined precedence values

Symbolic Name                   Precedence Value
------------------------------  ------------------
SWIG_TYPECHECK_POINTER           0  
SWIG_TYPECHECK_VOIDPTR           10 
SWIG_TYPECHECK_BOOL              15 
SWIG_TYPECHECK_UINT8             20 
SWIG_TYPECHECK_INT8              25 
SWIG_TYPECHECK_UINT16            30 
SWIG_TYPECHECK_INT16             35 
SWIG_TYPECHECK_UINT32            40 
SWIG_TYPECHECK_INT32             45 
SWIG_TYPECHECK_UINT64            50 
SWIG_TYPECHECK_INT64             55 
SWIG_TYPECHECK_UINT128           60 
SWIG_TYPECHECK_INT128            65 
SWIG_TYPECHECK_INTEGER           70 
SWIG_TYPECHECK_FLOAT             80 
SWIG_TYPECHECK_DOUBLE            90 
SWIG_TYPECHECK_COMPLEX           100 
SWIG_TYPECHECK_UNICHAR           110 
SWIG_TYPECHECK_UNISTRING         120 
SWIG_TYPECHECK_CHAR              130 
SWIG_TYPECHECK_STRING            140 
SWIG_TYPECHECK_BOOL_ARRAY        1015 
SWIG_TYPECHECK_INT8_ARRAY        1025 
SWIG_TYPECHECK_INT16_ARRAY       1035 
SWIG_TYPECHECK_INT32_ARRAY       1045 
SWIG_TYPECHECK_INT64_ARRAY       1055 
SWIG_TYPECHECK_INT128_ARRAY      1065 
SWIG_TYPECHECK_FLOAT_ARRAY       1080 
SWIG_TYPECHECK_DOUBLE_ARRAY      1090 
SWIG_TYPECHECK_CHAR_ARRAY        1130 
SWIG_TYPECHECK_STRING_ARRAY      1140
*/

%typecheck(SWIG_TYPECHECK_BOOL) bool { $1 = 1; };
%typecheck(SWIG_TYPECHECK_CHAR) char { $1 = 1; };
%typecheck(SWIG_TYPECHECK_FLOAT) float { $1 = 1; };
%typecheck(SWIG_TYPECHECK_DOUBLE) double { $1 = 1; };
%typecheck(SWIG_TYPECHECK_STRING) char * { $1 = 1; };
%typecheck(SWIG_TYPECHECK_INTEGER)
                    unsigned char, signed char,
                    short, signed short, unsigned short,
                    int, signed int, unsigned int,
                    long, signed long, unsigned long,
                    enum SWIGTYPE { $1 = 1; };
%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE *, SWIGTYPE &,
                                   SWIGTYPE[ANY], SWIGTYPE { $1 = 1; };

/* This maps C/C++ types to Lisp classes for overload dispatch */

%typemap(lispclass) bool "t";
%typemap(lispclass) char "character";
%typemap(lispclass) unsigned char, signed char,
                    short, signed short, unsigned short,
                    int, signed int, unsigned int,
                    long, signed long, unsigned long,
                    enum SWIGTYPE       "integer";
%typemap(lispclass) float "single-float";
%typemap(lispclass) double "double-float";
%typemap(lispclass) char * "string";

%typemap(out) bool                          "$result = (int)$1;";
%typemap(out) char, unsigned char, signed char,
              short, signed short, unsigned short,
              int, signed int, unsigned int,
              long, signed long, unsigned long,
              float, double, long double, char *, void *, void,
              enum SWIGTYPE, SWIGTYPE *,
              SWIGTYPE[ANY], SWIGTYPE &    "$result = $1;";
#ifdef __cplusplus
%typemap(out) SWIGTYPE                     "$result = new $1_type($1);";
#else
%typemap(out) SWIGTYPE {
  $result = ($&1_ltype) malloc(sizeof($1_type));
  memmove($result, &$1, sizeof($1_type));
}
#endif

//////////////////////////////////////////////////////////////
// UCS-2 string conversion

// should this be SWIG_TYPECHECK_CHAR?
%typecheck(SWIG_TYPECHECK_UNICHAR) wchar_t { $1 = 1; };

%typemap(in)        wchar_t "$1 = $input;";
%typemap(lin)       wchar_t "(let (($out (char-code $in)))\n  $body)";
%typemap(lin)       wchar_t* "(excl:with-native-string ($out $in
:external-format #+little-endian :fat-le #-little-endian :fat)\n
$body)"

%typemap(out)       wchar_t "$result = $1;";
%typemap(lout)      wchar_t "(code-char $body)";
%typemap(lout)      wchar_t* "(excl:native-to-string $body
:external-format #+little-endian :fat-le #-little-endian :fat)";

%typemap(ffitype)   wchar_t ":unsigned-short";
%typemap(lisptype)  wchar_t "";
%typemap(ctype)     wchar_t "wchar_t";
%typemap(lispclass) wchar_t "character";
%typemap(lispclass) wchar_t* "string";
//////////////////////////////////////////////////////////////

/* name conversion for overloaded operators. */
#ifdef __cplusplus
%rename(__add__)	     *::operator+;
%rename(__pos__)	     *::operator+();
%rename(__pos__)	     *::operator+() const;

%rename(__sub__)	     *::operator-;
%rename(__neg__)	     *::operator-() const;
%rename(__neg__)	     *::operator-();

%rename(__mul__)	     *::operator*;
%rename(__deref__)	     *::operator*();
%rename(__deref__)	     *::operator*() const;

%rename(__div__)	     *::operator/;
%rename(__mod__)	     *::operator%;
%rename(__logxor__)	     *::operator^;
%rename(__logand__)	     *::operator&;
%rename(__logior__)	     *::operator|;
%rename(__lognot__)	     *::operator~();
%rename(__lognot__)	     *::operator~() const;

%rename(__not__)	     *::operator!();
%rename(__not__)	     *::operator!() const;

%rename(__assign__)	     *::operator=;

%rename(__add_assign__)      *::operator+=;
%rename(__sub_assign__)	     *::operator-=;
%rename(__mul_assign__)	     *::operator*=;
%rename(__div_assign__)	     *::operator/=;
%rename(__mod_assign__)	     *::operator%=;
%rename(__logxor_assign__)   *::operator^=;
%rename(__logand_assign__)   *::operator&=;
%rename(__logior_assign__)   *::operator|=;

%rename(__lshift__)	     *::operator<<;
%rename(__lshift_assign__)   *::operator<<=;
%rename(__rshift__)	     *::operator>>;
%rename(__rshift_assign__)   *::operator>>=;

%rename(__eq__)		     *::operator==;
%rename(__ne__)		     *::operator!=;
%rename(__lt__)		     *::operator<;
%rename(__gt__)		     *::operator>;
%rename(__lte__)	     *::operator<=;
%rename(__gte__)	     *::operator>=;

%rename(__and__)	     *::operator&&;
%rename(__or__)		     *::operator||;

%rename(__preincr__)	     *::operator++();
%rename(__postincr__)	     *::operator++(int);
%rename(__predecr__)	     *::operator--();
%rename(__postdecr__)	     *::operator--(int);

%rename(__comma__)	     *::operator,();
%rename(__comma__)	     *::operator,() const;

%rename(__member_ref__)      *::operator->;
%rename(__member_func_ref__) *::operator->*;

%rename(__funcall__)	     *::operator();
%rename(__aref__)	     *::operator[];
#endif

%insert("lisphead") %{
;; $Id$

(eval-when (compile eval)

;;; You can define your own identifier converter if you want.
;;; Use the -identifier-converter command line argument to
;;; specify its name.

(eval-when (:compile-toplevel :load-toplevel :execute)
   (defparameter *swig-export-list* nil))

(defun read-symbol-from-string (string)
  (multiple-value-bind (result position)
      (read-from-string string nil "eof" :preserve-whitespace t)
    (if (and (symbolp result) (eql position (length string)))
        result
        (intern string))))

(defun full-name (id type arity class)
  (case type
    (:getter (format nil "~@[~A_~]~A" class id))
    (:constructor (format nil "new_~A~@[~A~]" id arity))
    (:destructor (format nil "delete_~A" id))
    (:type (format nil "ff_~A" id))
    (:ff-operator (format nil "ffi_~A" id))
    (otherwise (format nil "~@[~A_~]~A~@[~A~]"
                       class id arity))))
  
(defun identifier-convert-null (id &key type class arity)
  (if (eq type :setter)
      `(setf ,(identifier-convert-null
               id :type :getter :class class :arity arity))
      (read-symbol-from-string (full-name id type arity class))))

(defun identifier-convert-lispify (cname &key type class arity)
  (assert (stringp cname))
  (when (eq type :setter)
    (return-from identifier-convert-lispify
      `(setf ,(identifier-convert-lispify
               cname :type :getter :class class :arity arity))))
  (setq cname (full-name cname type arity class))
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
    (read-symbol-from-string (coerce (nreverse res) 'string))))

(defun id-convert-and-export (name &rest kwargs)
  (multiple-value-bind (symbol package)
      (apply *swig-identifier-converter* name kwargs)
    (let ((args (list (if (consp symbol) (cadr symbol) symbol)
                      (or package *package*))))
      (apply #'export args)
      (pushnew args swig::*swig-export-list*))
    symbol))

(defmacro swig-insert-id (name namespace &key (type :type) class)
  `(let ((*package* (find-package ,(package-name-for-namespace namespace))))
    (id-convert-and-export ,name :type ,type :class ,class)))

(defmacro swig-defconstant (string value)
  (let ((symbol (id-convert-and-export string :type :constant)))
    `(eval-when (compile load eval)
       (defconstant ,symbol ,value))))

(defun maybe-reorder-args (funcname arglist)
  ;; in the foreign setter function the new value will be the last argument
  ;; in Lisp it needs to be the first
  (if (consp funcname)
      (append (last arglist) (butlast arglist))
      arglist))

(defun maybe-return-value (funcname arglist)
  ;; setf functions should return the new value
  (when (consp funcname)
    `(,(if (consp (car arglist))
           (caar arglist)
           (car arglist)))))

(defun swig-anyvarargs-p (arglist)
  (member :SWIG__varargs_ arglist))

(defmacro swig-defun ((name &optional (mangled-name name)
                            &key (type :operator) class arity)
                      ffargs kwargs
		      &body body)
  (let* ((symbol (id-convert-and-export name :type type
                          :arity arity :class class))
         (mangle (if* (eq name mangled-name)
                      then (id-convert-and-export 
				    (cond ((eq type :setter) (format nil "~A-set" name))
					  ((eq type :getter) (format nil "~A-get" name))
					  (t name))
				    :type :ff-operator :arity arity :class class)
                      else (intern mangled-name)))
         (defun-args (maybe-reorder-args
                      symbol
		      (mapcar #'car (and (not (equal ffargs '(:void)))
					      ffargs))
                      ))
	 )
    (when (swig-anyvarargs-p ffargs)
      (setq ffargs '()))
    `(eval-when (compile load eval)
       (excl::compiler-let ((*record-xref-info* nil))
         (ff:def-foreign-call (,mangle ,mangled-name) ,ffargs ,@kwargs))
       (macrolet ((swig-ff-call (&rest args)
                    (cons ',mangle args)))
         (defun ,symbol ,defun-args
           ,@body
           ,@(maybe-return-value symbol defun-args))))))

(defmacro swig-defmethod ((name &optional (mangled-name name)
                           &key (type :operator) class arity)
                          ffargs kwargs
                          &body body)
  (let* ((symbol (id-convert-and-export name :type type
                          :arity arity :class class))
         (mangle (intern mangled-name))
         (defmethod-args (maybe-reorder-args
                          symbol
                          (unless (equal ffargs '(:void))
                            (loop for (name dispatch) in ffargs
                                  collect `(,name ,dispatch)))))
         (ffargs (if (equal ffargs '(:void))
                     ffargs
                     (loop for (name nil . ffi) in ffargs
                           collect `(,name ,@ffi)))))
    `(eval-when (compile load eval)
       (excl::compiler-let ((*record-xref-info* nil))
         (ff:def-foreign-call (,mangle ,mangled-name) ,ffargs ,@kwargs))
       (macrolet ((swig-ff-call (&rest args)
                    (cons ',mangle args)))
         (defmethod ,symbol ,defmethod-args
           ,@body
           ,@(maybe-return-value symbol defmethod-args))))))

(defmacro swig-dispatcher ((name &key (type :operator) class arities))
  (let ((symbol (id-convert-and-export name
                         :type type :class class)))
    `(eval-when (compile load eval)
       (defun ,symbol (&rest args)
         (case (length args)
           ,@(loop for arity in arities
                   for symbol-n = (id-convert-and-export name
                                           :type type :class class :arity arity)
                   collect `(,arity (apply #',symbol-n args)))
	   (t (error "No applicable wrapper-methods for foreign call ~a with args ~a of classes ~a" ',symbol args (mapcar #'(lambda (x) (class-name (class-of x))) args)))
	   )))))

(defmacro swig-def-foreign-stub (name)
  (let ((lsymbol (id-convert-and-export name :type :class))
	(symbol (id-convert-and-export name :type :type)))
    `(eval-when (compile load eval)
	(ff:def-foreign-type ,symbol (:class ))
	(defclass ,lsymbol (ff:foreign-pointer) ()))))

(defmacro swig-def-foreign-class (name supers &rest rest)
  (let ((lsymbol (id-convert-and-export name :type :class))
	(symbol (id-convert-and-export name :type :type)))
    `(eval-when (compile load eval)
       (ff:def-foreign-type ,symbol ,@rest)
       (defclass ,lsymbol ,supers
	 ((foreign-type :initform ',symbol :initarg :foreign-type
			:accessor foreign-pointer-type))))))

(defmacro swig-def-foreign-type (name &rest rest)
  (let ((symbol (id-convert-and-export name :type :type)))
    `(eval-when (compile load eval)
       (ff:def-foreign-type ,symbol ,@rest))))

(defmacro swig-def-synonym-type (synonym of ff-synonym)
  `(eval-when (compile load eval)
     (setf (find-class ',synonym) (find-class ',of))
     (ff:def-foreign-type ,ff-synonym (:struct ))))

(defun package-name-for-namespace (namespace)
  (list-to-delimited-string
   (cons *swig-module-name*
         (mapcar #'(lambda (name)
                     (string
                      (funcall *swig-identifier-converter*
                               name
                               :type :namespace)))
                 namespace))
   "."))

(defmacro swig-defpackage (namespace)
  (let* ((parent-namespaces (maplist #'reverse (cdr (reverse namespace))))
         (parent-strings (mapcar #'package-name-for-namespace
                                 parent-namespaces))
         (string (package-name-for-namespace namespace)))
    `(eval-when (compile load eval)
      (defpackage ,string
        (:use :common-lisp :ff :swig :excl
              ,@parent-strings ,*swig-module-name*)))))

(defmacro swig-in-package (namespace)
  `(eval-when (compile load eval)
    (in-package ,(package-name-for-namespace namespace))))

(defmacro swig-defvar (name mangled-name &key type)
  (let ((symbol (id-convert-and-export name :type type)))
    `(eval-when (compile load eval)
      (ff:def-foreign-variable (,symbol ,mangled-name)))))

) ;; eval-when

(eval-when (compile eval)
  (flet ((starts-with-p (str prefix)
           (and (>= (length str) (length prefix))
                (string= str prefix :end1 (length prefix)))))
    (export (loop for sym being each present-symbol of *package*
                  when (or (starts-with-p (symbol-name sym) (symbol-name :swig-))
                           (starts-with-p (symbol-name sym) (symbol-name :identifier-convert-)))
                  collect sym))))

(in-package #.*swig-module-name*)

%}



%{

#ifdef __cplusplus
#  define EXTERN   extern "C"
#else
#  define EXTERN   extern
#endif

#define EXPORT   EXTERN SWIGEXPORT

#include <string.h>
#include <stdlib.h>
%}
