/* inout_typemaps.i

   Support for INPUT, OUTPUT, and INOUT typemaps. OUTPUT variables are returned
   as multiple values.

*/


%define INOUT_TYPEMAP(type_, OUTresult_, INbind_)
// OUTPUT map.
%typemap(lin,numinputs=0) type_ *OUTPUT, type_ &OUTPUT
%{(let (($out (ff:allocate-fobject '$*in_fftype :c)))
     $body
     OUTresult_
     (ff:free-fobject $out)) %}

// INPUT map.
%typemap(in) type_ *INPUT, type_ &INPUT
%{ $1 = &$input; %}

%typemap(ctype) type_ *INPUT, type_ &INPUT "$*1_ltype";


// INOUT map.
%typemap(lin,numinputs=1) type_ *INOUT, type_ &INOUT
%{(let (($out (ff:allocate-fobject '$*in_fftype :c)))
     INbind_
     $body
     OUTresult_
     (ff:free-fobject $out)) %}

%enddef

// $in, $out, $lclass,
// $in_fftype, $*in_fftype

INOUT_TYPEMAP(int,
	      (push (ff:fslot-value-typed (quote $*in_fftype) :c $out) ACL_result),
	      (setf (ff:fslot-value-typed (quote $*in_fftype) :c $out) $in));
INOUT_TYPEMAP(short,
	      (push (ff:fslot-value-typed (quote $*in_fftype) :c $out) ACL_result),
	      (setf (ff:fslot-value-typed (quote $*in_fftype) :c $out) $in));
INOUT_TYPEMAP(long,
	      (push (ff:fslot-value-typed (quote $*in_fftype) :c $out) ACL_result),
	      (setf (ff:fslot-value-typed (quote $*in_fftype) :c $out) $in));
INOUT_TYPEMAP(unsigned int,
	      (push (ff:fslot-value-typed (quote $*in_fftype) :c $out) ACL_result),
	      (setf (ff:fslot-value-typed (quote $*in_fftype) :c $out) $in));
INOUT_TYPEMAP(unsigned short,
	      (push (ff:fslot-value-typed (quote $*in_fftype) :c $out) ACL_result),
	      (setf (ff:fslot-value-typed (quote $*in_fftype) :c $out) $in));
INOUT_TYPEMAP(unsigned long,
	      (push (ff:fslot-value-typed (quote $*in_fftype) :c $out) ACL_result),
	      (setf (ff:fslot-value-typed (quote $*in_fftype) :c $out) $in));
INOUT_TYPEMAP(char,
	      (push (ff:fslot-value-typed (quote $*in_fftype) :c $out) ACL_result),
	      (setf (ff:fslot-value-typed (quote $*in_fftype) :c $out) $in));
INOUT_TYPEMAP(float,
	      (push (ff:fslot-value-typed (quote $*in_fftype) :c $out) ACL_result),
	      (setf (ff:fslot-value-typed (quote $*in_fftype) :c $out) $in));
INOUT_TYPEMAP(double,
	      (push (ff:fslot-value-typed (quote $*in_fftype) :c $out) ACL_result),
	      (setf (ff:fslot-value-typed (quote $*in_fftype) :c $out) $in));
INOUT_TYPEMAP(bool,
	      (push (not (zerop (ff:fslot-value-typed (quote $*in_fftype) :c $out)))
		    ACL_result),
	      (setf (ff:fslot-value-typed (quote $*in_fftype) :c $out) (if $in 1 0)));

%typemap(lisptype) bool *INPUT, bool &INPUT "boolean";

// long long support not yet complete
// INOUT_TYPEMAP(long long);
// INOUT_TYPEMAP(unsigned long long);

