/* typemaps.i --- ocaml typemaps -*- c -*-
   Ocaml conversion by Art Yerkes, modified from mzscheme/typemaps.i
   Copyright 2000, 2001 Matthias Koeppe <mkoeppe@mail.math.uni-magdeburg.de>
   Based on code written by Oleg Tolmatcev.

   $Id$
*/

/* The Ocaml module handles all types uniformly via typemaps. Here
   are the definitions.  */

/* Pointers */

%typemap(ocaml,in) void * {
    $1 = caml_ptr_val($input,$descriptor);
}

%typemap(ocaml,varin) void * {
    $1 = ($ltype)caml_ptr_val($input,$descriptor);
}

%typemap(ocaml,in)  char *, signed char *, unsigned char *, const char *, const signed char *, const unsigned char * {
    $1 = ($ltype)caml_string_val($input);
}

%typemap(ocaml,varin)  char *, signed char *, unsigned char *, const char *, const signed char *, const unsigned char * {
    $1 = ($ltype)caml_string_val($input);
}

%typemap(ocaml,out) void * {
    $result = caml_val_ptr($1,$descriptor);
}

%typemap(ocaml,varout) void * {
    $result = caml_val_ptr($1,$descriptor);
}

%typemap(ocaml,out) char *, signed char *, unsigned char *, const char *, const signed char *, const unsigned char * {
    $result = caml_val_string($1);
}

%typemap(ocaml,varout) char *, signed char *, unsigned char *, const char *, const signed char *, const unsigned char * {
    $result = caml_val_string($1);
}

%typemap(ocaml,in) SWIGTYPE * {
    $1 = ($ltype)caml_ptr_val($input,$1_descriptor);
}

%typemap(ocaml,out) SWIGTYPE * {
    value *fromval = caml_named_value("create_$ntype_from_ptr");
    if( fromval ) {
	$result = callback(*fromval,caml_val_ptr((void *)$1,$1_descriptor));
    } else {
	$result = caml_val_ptr ((void *)$1,$1_descriptor);
    }
}

%typemap(ocaml,varin) SWIGTYPE * {
    $1 = ($ltype)caml_ptr_val($input,$1_descriptor);
}

%typemap(ocaml,varout) SWIGTYPE * {
    value *fromval = caml_named_value("create_$ntype_from_ptr");
    if( fromval ) {
	$result = callback(*fromval,caml_val_ptr((void *)$1,$1_descriptor));
    } else {
	$result = caml_val_ptr ((void *)$1,$1_descriptor);
    }
}

/* C++ References */

#ifdef __cplusplus

%typemap(ocaml,in) SWIGTYPE & {
    $1 = ($ltype) caml_ptr_val($input,$1_descriptor);
}

%typemap(ocaml,out) SWIGTYPE & {
    value *fromval = caml_named_value("create_$ntype_from_ptr");
    if( fromval ) {
	$result = callback(*fromval,caml_val_ptr((void *) $1,$1_descriptor));
    } else {
	$result = caml_val_ptr ((void *) $1,$1_descriptor);
    }
}

#if 0
%typemap(ocaml,argout) SWIGTYPE & {
    value *fromval = caml_named_value("create_$ntype_from_ptr");
    if( fromval ) {
	swig_result =
	    caml_list_append(swig_result,
			     callback(*fromval,caml_val_ptr((void *) $1,
							    $1_descriptor)));
    } else {
	swig_result =
	    caml_list_append(swig_result,
			     caml_val_ptr ((void *) $1,$1_descriptor));
    }
}
#endif

%typemap(ocaml,argout) const SWIGTYPE & { }

%typemap(ocaml,in) SWIGTYPE {
    $1 = *(($&1_ltype) caml_ptr_val($input,$&1_descriptor)) ;
}

%typemap(ocaml,out) SWIGTYPE {
    void *temp = new $ltype($1);
    value *fromval = caml_named_value("create_$ntype_from_ptr");
    *(($ltype *)temp) = $1;
    if( fromval ) {
	$result = callback(*fromval,caml_val_ptr((void *)temp,$&1_descriptor));
    } else {
	$result = caml_val_ptr ((void *)temp,$&1_descriptor);
    }
}

#else

%typemap(ocaml,in) SWIGTYPE {
    $1 = *(($&1_ltype) caml_ptr_val($input,$&1_descriptor)) ;
}

%typemap(ocaml,out) SWIGTYPE {
    void *temp = calloc(1,sizeof($ltype));
    value *fromval = caml_named_value("create_$ntype_from_ptr");
    *(($ltype *)temp) = $1;
    if( fromval ) {
	$result = callback(*fromval,caml_val_ptr((void *)temp,$&1_descriptor));
    } else {
	$result = caml_val_ptr ((void *)temp,$&1_descriptor);
    }
}

%apply SWIGTYPE { const SWIGTYPE & };

#endif

/* Arrays */

/* Enums */
%typemap(ocaml,in) enum SWIGTYPE {
    $1 = ($type)caml_long_val_full($input,"$type_marker");
}

%typemap(ocaml,varin) enum SWIGTYPE {
    $1 = ($type)caml_long_val_full($input,"$type_marker");
}

%typemap(ocaml,out) enum SWIGTYPE "$result = callback2(*caml_named_value(SWIG_MODULE \"_int_to_enum\"),*caml_named_value(\"$type_marker\"),Val_int($1));"
%typemap(ocaml,varout) enum SWIGTYPE "$result = callback2(*caml_named_value(SWIG_MODULE \"_int_to_enum\"),*caml_named_value(\"$type_marker\"),Val_int($1));"

/* The SIMPLE_MAP macro below defines the whole set of typemaps needed
   for simple types. */

%define SIMPLE_MAP(C_NAME, C_TO_MZ, MZ_TO_C)
%typemap(in) C_NAME {
    $1 = MZ_TO_C($input);
}
%typemap(varin) C_NAME {
    $1 = MZ_TO_C($input);
}
%typemap(memberin) C_NAME {
    $1 = MZ_TO_C($input);
}
%typemap(out) C_NAME {
    $result = C_TO_MZ($1);
}
%typemap(varout) C_NAME {
    $result = C_TO_MZ($1);
}
%typemap(memberout) C_NAME {
    $resunt = C_TO_MZ($1);
}
%typemap(in) C_NAME *INPUT ($*1_ltype temp) {
    temp = ($*1_ltype) MZ_TO_C($input);
    $1 = &temp;
}
%typemap(in,numinputs=0) C_NAME *OUTPUT ($*1_ltype temp) {
    $1 = &temp;
}
%typemap(argout) C_NAME *OUTPUT {
    swig_result = caml_list_append(swig_result,C_TO_MZ((long)*$1));
}
%typemap(in) C_NAME & ($*1_ltype temp) {
    temp = ($*1_ltype) MZ_TO_C($input);
    $1 = &temp;
}
%typemap(argout) C_NAME & {
    swig_result = caml_list_append(swig_result,C_TO_MZ((long)*$1));
}
%enddef

SIMPLE_MAP(bool, caml_val_bool, caml_long_val);
SIMPLE_MAP(oc_bool, caml_val_bool, caml_long_val);
SIMPLE_MAP(char, caml_val_char, caml_long_val);
SIMPLE_MAP(unsigned char, caml_val_uchar, caml_long_val);
SIMPLE_MAP(int, caml_val_int, caml_long_val);
SIMPLE_MAP(short, caml_val_short, caml_long_val);
SIMPLE_MAP(wchar_t, caml_val_short, caml_long_val);
SIMPLE_MAP(long, caml_val_long, caml_long_val);
SIMPLE_MAP(ptrdiff_t, caml_val_int, caml_long_val);
SIMPLE_MAP(unsigned int, caml_val_uint, caml_long_val);
SIMPLE_MAP(unsigned short, caml_val_ushort, caml_long_val);
SIMPLE_MAP(unsigned long, caml_val_ulong, caml_long_val);
SIMPLE_MAP(size_t, caml_val_int, caml_long_val);
SIMPLE_MAP(float, caml_val_float, caml_double_val);
SIMPLE_MAP(double, caml_val_double, caml_double_val);
SIMPLE_MAP(long long,caml_val_ulong,caml_long_val);
SIMPLE_MAP(unsigned long long,caml_val_ulong,caml_long_val);

/* Void */

%typemap(out) void "$result = Val_unit;";

/* Pass through value */

%typemap (in) value "$1=$input;";
%typemap (out) value "$result=$1;";
