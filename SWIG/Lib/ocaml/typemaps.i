/* typemaps.i --- ocaml typemaps -*- c -*-
   Ocaml conversion by Art Yerkes, modified from mzscheme/typemaps.i
   Copyright 2000, 2001 Matthias Koeppe <mkoeppe@mail.math.uni-magdeburg.de>
   Based on code written by Oleg Tolmatcev.

   $Id$
*/

/* The Ocaml module handles all types uniformly via typemaps. Here
   are the definitions.  */

/* Pointers */

%typemap(ocaml,in) SWIGTYPE * {
    $1 = ($ltype)SWIG_MustGetPtr($input, $descriptor, $argnum);
}

%typemap(ocaml,out) SWIGTYPE * {
    extern value $delete_fn( value );
    $result = SWIG_MakePtr ((void *)$1, 
			    $descriptor, (void *)$delete_fn);
}

%typemap(ocaml,varin) SWIGTYPE * {
    $1 = ($ltype)SWIG_MustGetPtr($input, $descriptor, 1);
}

%typemap(ocaml,varout) SWIGTYPE * {
    $result = SWIG_MakePtr ((void *)$1, $descriptor, NULL);
}

%typemap(ocaml,in) void * {
    $1 = ($ltype)SWIG_MustGetPtr($input, NULL, $argnum);
}

%typemap(ocaml,varin) void * {
    $1 = ($ltype)SWIG_MustGetPtr($input, NULL, $argnum);
}

%typemap(ocaml,out) void * {
    $result = SWIG_MakePtr((void *)$1, $descriptor, NULL);
}

%typemap(ocaml,varout) void * {
    $result = SWIG_MakePtr((void *)$1, $descriptor, NULL);
}

/* C++ References */

#ifdef __cplusplus

%typemap(ocaml,in) SWIGTYPE & {
  $1 = ($ltype) SWIG_MustGetPtr($input, $descriptor, $argnum) ;
}

%typemap(ocaml,out) SWIGTYPE & {
  $result = SWIG_MakePtr ((void *)& $1, $descriptor, NULL);
}

%typemap(ocaml,in) SWIGTYPE {
  $1 = *(($&1_type) SWIG_MustGetPtr($input, $descriptor, $argnum)) ;
}

%typemap(ocaml,out) SWIGTYPE {
    extern value $delete_fn( value );
    $&1_type temp = new $type( $1 );
    $result = SWIG_MakePtr ((void *)temp, $descriptor, 
			    (void *)$delete_fn );
}

#else

%typemap(ocaml,in) SWIGTYPE {
    $1 = *(($&1_ltype) SWIG_MustGetPtr($input, $descriptor, $argnum)) ;
}

%typemap(ocaml,out) SWIGTYPE {
    extern value $delete_fn( value );
    $&1_type temp = calloc(1,sizeof($ltype));
    memcpy(temp,(char *)&$1,sizeof($ltype));
    $result = SWIG_MakePtr ((void *)temp, $descriptor, (void *)$delete_fn);
}

#endif

/* Arrays */

%typemap(ocaml,in) SWIGTYPE[] {
    $1 = ($ltype) SWIG_MustGetPtr($input, $descriptor, $argnum);
}

%typemap(ocaml,out) SWIGTYPE[] {
    $result = SWIG_MakePtr ($1, $descriptor, NULL);
}

/* Enums */
%typemap(ocaml,in) enum SWIGTYPE {
    $1 = enum_to_int("$type_to_int",$input);
}

%typemap(ocaml,varin) enum SWIGTYPE {
    $1 = enum_to_int("$type_to_int",$input);
}

%typemap(ocaml,out) enum SWIGTYPE "$result = int_to_enum(\"int_to_$type\",$1);";
%typemap(ocaml,varout) enum SWIGTYPE "$result = int_to_enum(\"int_to_$type\",$1);";

/* The SIMPLE_MAP macro below defines the whole set of typemaps needed
   for simple types. */

%define SIMPLE_MAP(C_NAME, C_TO_MZ, MZ_TO_C)
%typemap(ocaml,in) C_NAME {
    $1 = MZ_TO_C($input);
}
%typemap(ocaml,varin) C_NAME {
    $1 = MZ_TO_C($input);
}
%typemap(ocaml,out) C_NAME {
    $result = C_TO_MZ($1);
}
%typemap(ocaml,varout) C_NAME {
    $result = C_TO_MZ($1);
}
%typemap(ocaml,in) C_NAME *INPUT (C_NAME temp) {
    temp = (C_NAME) MZ_TO_C($input);
    $1 = &temp;
}
%typemap(ocaml,ignore) C_NAME *OUTPUT (C_NAME temp) {
    $1 = &temp;
}
%typemap(ocaml,argout) C_NAME *OUTPUT {
    *$arg = *$input;
}
%enddef

SIMPLE_MAP(oc_bool, Val_bool, Int_val);
SIMPLE_MAP(bool, Val_bool, Int_val);
SIMPLE_MAP(char, Val_int, Int_val);
SIMPLE_MAP(unsigned char, Val_int, Int_val);
SIMPLE_MAP(int, Val_int, Int_val);
SIMPLE_MAP(short, Val_int, Int_val);
SIMPLE_MAP(long, copy_int64, Int64_val);
SIMPLE_MAP(ptrdiff_t, copy_int32, Int32_val);
SIMPLE_MAP(unsigned int, copy_int32, Int32_val);
SIMPLE_MAP(unsigned short, Val_int, Int_val);
SIMPLE_MAP(unsigned long, copy_int64, Int64_val);
SIMPLE_MAP(size_t, Val_int, Int_val);
SIMPLE_MAP(float, copy_double, Double_val);
SIMPLE_MAP(double, copy_double, Double_val);
SIMPLE_MAP(char *, copy_string, String_val);
SIMPLE_MAP(const char *, copy_string, String_val);
SIMPLE_MAP(long long,copy_int64,Int64_val);
SIMPLE_MAP(unsigned long long,copy_int64,Int64_val);

/* Void */

%typemap(ocaml,out) void "$result = Val_unit;";

/* Pass through value */

%typemap (ocaml,in) value "$1=$input;";
%typemap (ocaml,out) value "$result=$1;";
