/* typemaps.i --- ocaml typemaps -*- c -*-
   Ocaml conversion by Art Yerkes, modified from mzscheme/typemaps.i
   Copyright 2000, 2001 Matthias Koeppe <mkoeppe@mail.math.uni-magdeburg.de>
   Based on code written by Oleg Tolmatcev.

   $Id$
*/

/* The Ocaml module handles all types uniformly via typemaps. Here
   are the definitions.  */

/* Pointers */

%typemap(in) SWIGTYPE * {
    void *v = SWIG_MustGetPtr($input, $descriptor, $argnum);
    $1 = ($ltype)(v) ;
}

%typemap(in) void * {
  $1 = SWIG_MustGetPtr($input, NULL, $argnum);
}

%typemap(varin) SWIGTYPE * {
    void *v = SWIG_MustGetPtr($input, $descriptor, 1);
    $1 = ($ltype)(v) ;
}

%typemap(varin) void * {
  $1 = SWIG_MustGetPtr($input, NULL, 1);
}

%typemap(out) SWIGTYPE * {
  extern value $delete_fn( value );
  $result = SWIG_MakePtr ((void *)$1, $descriptor, (void *)$delete_fn);
}

%typemap(varout) SWIGTYPE * {
  $result = SWIG_MakePtr ((void *)$1, $descriptor, NULL);
}

/* C++ References */

#ifdef __cplusplus

%typemap(in) SWIGTYPE & {
  $1 = ($ltype) SWIG_MustGetPtr($input, $descriptor, $argnum) ;
}

%typemap(out) SWIGTYPE & {
  $result = SWIG_MakePtr ((void *)& $1, $descriptor, NULL);
}

%typemap(in) SWIGTYPE {
  $1 = ($ltype) SWIG_MustGetPtr($input, $descriptor, $argnum) ;
}

%typemap(out) SWIGTYPE {
	extern value $delete_fn( value );
	$type *temp = new $type( $1 );
	$result = SWIG_MakePtr ((void *)temp, $descriptor, 
				(void *)$delete_fn );
}

#else

%typemap(in) SWIGTYPE {
  $1 = *(($&1_ltype) SWIG_MustGetPtr($input, $descriptor, $argnum)) ;
}

%typemap(out) SWIGTYPE {
        extern value $delete_fn( value );
	$ltype temp = calloc(1,sizeof($ltype));
	memcpy(temp,&$1,sizeof($ltype));
	$result = SWIG_MakePtr ((void *)temp, $descriptor, (void *)$delete_fn);
}

#endif

/* Arrays */

%typemap(in) SWIGTYPE[] {
    $1 = ($ltype) SWIG_MustGetPtr($input, $descriptor, $argnum);
}

%typemap(out) SWIGTYPE[] {
    $result = SWIG_MakePtr ($1, $descriptor, NULL);
}

/* Enums */
%typemap(in) enum SWIGTYPE {
    $1 = enum_to_int($input);
}

%typemap(varin) enum SWIGTYPE {
    $1 = enum_to_int($input);
}

%typemap(out) enum SWIGTYPE "$result = int_to_enum($1);";
%typemap(varout) enum SWIGTYPE "$result = int_to_enum($1);";

/* The SIMPLE_MAP macro below defines the whole set of typemaps needed
   for simple types. */

%define SIMPLE_MAP(C_NAME, C_TO_MZ, MZ_TO_C)
%typemap(in) C_NAME {
    $1 = MZ_TO_C($input);
}
%typemap(varin) C_NAME {
    $1 = MZ_TO_C($input);
}
%typemap(out) C_NAME {
    $result = C_TO_MZ($1);
}
%typemap(varout) C_NAME {
    $result = C_TO_MZ($1);
}
%typemap(in) C_NAME *INPUT (C_NAME temp) {
    temp = (C_NAME) MZ_TO_C($input);
    $1 = &temp;
}
%typemap(ignore) C_NAME *OUTPUT (C_NAME temp) {
    $1 = &temp;
}
%typemap(in) C_NAME *BOTH = C_NAME *INPUT;
//%typemap(argout) C_NAME *BOTH = C_NAME *OUTPUT;
%typemap(in) C_NAME *INOUT = C_NAME *INPUT;
//%typemap(argout) C_NAME *INOUT = C_NAME *OUTPUT;
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

%typemap(out) void "$result = Val_unit;";

/* Pass through value */

%typemap (in) value "$1=$input;";
%typemap (out) value "$result=$1;";
