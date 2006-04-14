/* Define a C preprocessor symbol that can be used in interface files
   to distinguish between the SWIG language modules. */ 

#define SWIG_CFFI

/* Typespecs for basic types. */

%typemap(cin) void ":void";

%typemap(cin) char ":char";
%typemap(cin) char * ":string";
%typemap(cin) unsigned char ":unsigned-char";
%typemap(cin) signed char ":char";

%typemap(cin) short ":short";
%typemap(cin) signed short ":short";
%typemap(cin) unsigned short ":unsigned-short";

%typemap(cin) int ":int";
%typemap(cin) signed int ":int";
%typemap(cin) unsigned int ":unsigned-int";

%typemap(cin) long ":long";
%typemap(cin) signed long ":long";
%typemap(cin) unsigned long ":unsigned-long";

%typemap(cin) float ":float";
%typemap(cin) double ":double";
%typemap(cin) SWIGTYPE ":pointer";

%typemap(cout) void ":void";

%typemap(cout) char ":char";
%typemap(cout) char * ":string";
%typemap(cout) unsigned char ":unsigned-char";
%typemap(cout) signed char ":char";

%typemap(cout) short ":short";
%typemap(cout) signed short ":short";
%typemap(cout) unsigned short ":unsigned-short";

%typemap(cout) int ":int";
%typemap(cout) signed int ":int";
%typemap(cout) unsigned int ":unsigned-int";

%typemap(cout) long ":long";
%typemap(cout) signed long ":long";
%typemap(cout) unsigned long ":unsigned-long";

%typemap(cout) float ":float";
%typemap(cout) double ":double";
%typemap(cout) SWIGTYPE ":pointer";


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

%typemap(out) bool                          "$result = (int)$1;";
%typemap(out) char, unsigned char, signed char,
              short, signed short, unsigned short,
              int, signed int, unsigned int,
              long, signed long, unsigned long,
              float, double, long double, char *, void *, void,
              enum SWIGTYPE, SWIGTYPE *,
              SWIGTYPE[ANY], SWIGTYPE &    "$result = $1;";
%typemap(out) SWIGTYPE                     "$result = new $1_type($1);";


%{

#ifdef __cplusplus
#  define EXTERN   extern "C"
#else
#  define EXTERN   extern
#endif

#define EXPORT   EXTERN SWIGEXPORT

#include <string.h>
%}

%insert("swiglisp") %{
;;;SWIG wrapper code starts here

(cl:defmacro defanonenum (&body enums)
   "Converts anonymous enums to defconstants."
  `(cl:progn ,@(cl:loop for value in enums
                        for index = 0 then (cl:1+ index)
                        when (cl:listp value) do (cl:setf index (cl:second value)
                                                          value (cl:first value))
                        collect `(cl:defconstant ,value ,index))))

(cl:eval-when (:compile-toplevel :load-toplevel)
  (cl:unless (cl:fboundp 'swig-lispify)
    (cl:defun swig-lispify (name flag cl:&optional (package cl:*package*))
      (cl:labels ((helper (lst last rest cl:&aux (c (cl:car lst)))
                    (cl:cond
                      ((cl:null lst)
                       rest)
                      ((cl:upper-case-p c)
                       (helper (cl:cdr lst) 'upper
                               (cl:case last
                                 ((lower digit) (cl:list* c #\- rest))
                                 (cl:t (cl:cons c rest)))))
                      ((cl:lower-case-p c)
                       (helper (cl:cdr lst) 'lower (cl:cons (cl:char-upcase c) rest)))
                      ((cl:digit-char-p c)
                       (helper (cl:cdr lst) 'digit 
                               (cl:case last
                                 ((upper lower) (cl:list* c #\- rest))
                                 (cl:t (cl:cons c rest)))))
                      ((cl:char-equal c #\_)
                       (helper (cl:cdr lst) '_ (cl:cons #\- rest)))
                      (cl:t
                       (cl:error "Invalid character: ~A" c)))))
        (cl:let ((fix (cl:case flag
                        ((constant enumvalue) "+")
                        (variable "*")
                        (cl:t ""))))
          (cl:intern
           (cl:concatenate
            'cl:string
            fix
            (cl:nreverse (helper (cl:concatenate 'cl:list name) cl:nil cl:nil))
            fix)
           package))))))

;;;SWIG wrapper code ends here
%}
