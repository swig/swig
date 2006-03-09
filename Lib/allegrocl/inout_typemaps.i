/* inout_typemaps.i

   Support for INPUT, OUTPUT, and INOUT typemaps. OUTPUT variables are returned
   as multiple values.

*/


%define INOUT_TYPEMAP(type_)
// OUTPUT map.
%typemap(lin,numinputs=0) type_ *OUTPUT
%{
  (let (($out (ff:allocate-fobject '$*in_fftype :c)))
     $body
     (push (ff:fslot-value-typed '$*in_fftype :c $out) ACL_result)
     (ff:free-fobject $out))
%}

// INPUT map.
%typemap(in) type_ *INPUT, type_ &INPUT
%{ $1 = &$input; %}

%typemap(ctype) type_ *INPUT, type_ &INPUT "$*1_ltype";


// INOUT map.
%typemap(lin,numinputs=1) type_ *INOUT, type_ &INOUT
%{
  (let (($out (ff:allocate-fobject '$*in_fftype :c)))
     (setf (ff:fslot-value-typed '$*in_fftype :c $out) $in)
     $body
     (push (ff:fslot-value-typed $*in_fftype :c $out) ACL_result)
     (ff:free-fobject $out))
%}

%enddef

// $in, $out, $lclass,
// $in_fftype, $*in_fftype

INOUT_TYPEMAP(int);
INOUT_TYPEMAP(short);
INOUT_TYPEMAP(long);
INOUT_TYPEMAP(unsigned int);
INOUT_TYPEMAP(unsigned short);
INOUT_TYPEMAP(unsigned long);
INOUT_TYPEMAP(char);
INOUT_TYPEMAP(bool);
INOUT_TYPEMAP(float);
INOUT_TYPEMAP(double);
// long long support not yet complete
// INOUT_TYPEMAP(long long);
// INOUT_TYPEMAP(unsigned long long);

