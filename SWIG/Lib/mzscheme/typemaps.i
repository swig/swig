/* typemaps.i --- mzscheme typemaps -*- c -*-
   Copyright 2000, 2001 Matthias Koeppe <mkoeppe@mail.math.uni-magdeburg.de>
   Based on code written by Oleg Tolmatcev.

   $Id$
*/

/* The MzScheme module handles all types uniformly via typemaps. Here
   are the definitions.  */

/* Pointers */

%typemap(in) SWIGTYPE * {
  $1 = ($ltype) SWIG_MustGetPtr($input, $descriptor, $argnum);
}

%typemap(in) void * {
  $1 = SWIG_MustGetPtr($input, NULL, $argnum);
}

%typemap(varin) SWIGTYPE * {
  $1 = ($ltype) SWIG_MustGetPtr($input, $descriptor, 1);
}

%typemap(varin) void * {
  $1 = SWIG_MustGetPtr($input, NULL, 1);
}

%typemap(out) SWIGTYPE * {
  $result = SWIG_MakePtr ($1, $descriptor);
}

%typemap(out) SWIGTYPE *DYNAMIC {
  swig_type_info *ty = SWIG_TypeDynamicCast($1_descriptor,(void **) &$1);
  $result = SWIG_MakePtr ($1, ty);
}
    
%typemap(varout) SWIGTYPE * {
  $result = SWIG_MakePtr ($1, $descriptor);
}

/* C++ References */

#ifdef __cplusplus

%typemap(in) SWIGTYPE & { 
  $1 = ($ltype) SWIG_MustGetPtr($input, $descriptor, $argnum);
}

%typemap(out) SWIGTYPE & {
  $result = SWIG_MakePtr ($1, $descriptor);
}

%typemap(out) SWIGTYPE &DYNAMIC {
  swig_type_info *ty = SWIG_TypeDynamicCast($1_descriptor,(void **) &$1);
  $result = SWIG_MakePtr ($1, ty);
}

#endif

/* Arrays */

%typemap(in) SWIGTYPE[] {
  $1 = ($ltype) SWIG_MustGetPtr($input, $descriptor, $argnum);
}

%typemap(out) SWIGTYPE[] {
  $result = SWIG_MakePtr ($1, $descriptor);
}

/* Enums */
%typemap(in) enum SWIGTYPE {
  if (!SCHEME_INTP($input)) 
      scheme_wrong_type("$name", "integer", $argnum, argc, argv);
  $1 = SCHEME_INT_VAL($input);
}

%typemap(varin) enum SWIGTYPE {
  if (!SCHEME_INTP($input)) 
      scheme_wrong_type("$name", "integer", 1, argc, argv);
  $1 = SCHEME_INT_VAL($input);
}

%typemap(out) enum SWIGTYPE "$result = scheme_make_integer_value($1);";
%typemap(varout) enum SWIGTYPE "$result = scheme_make_integer_value($1);";

/* The SIMPLE_MAP macro below defines the whole set of typemaps needed
   for simple types. */

%define SIMPLE_MAP(C_NAME, MZ_PREDICATE, MZ_TO_C, C_TO_MZ, MZ_NAME)
%typemap(in) C_NAME {
    if (!MZ_PREDICATE($input))
	scheme_wrong_type("$name", "MZ_NAME", $argnum, argc, argv);
    $1 = MZ_TO_C($input);
}
%typemap(varin) C_NAME {
    if (!MZ_PREDICATE($input))
	scheme_wrong_type("$name", "MZ_NAME", 1, argc, argv);
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
%typemap(argout) C_NAME *OUTPUT {
    Scheme_Object *s;
    s = C_TO_MZ(*$1);
    SWIG_APPEND_VALUE(s);
}
%typemap(in) C_NAME *BOTH = C_NAME *INPUT;
%typemap(argout) C_NAME *BOTH = C_NAME *OUTPUT;
%typemap(in) C_NAME *INOUT = C_NAME *INPUT;
%typemap(argout) C_NAME *INOUT = C_NAME *OUTPUT;
%enddef

SIMPLE_MAP(bool, SCHEME_BOOLP, SCHEME_TRUEP,
	   swig_make_boolean, boolean);
SIMPLE_MAP(char, SCHEME_CHARP, SCHEME_CHAR_VAL,
	   scheme_make_character, character);
SIMPLE_MAP(unsigned char, SCHEME_CHARP, SCHEME_CHAR_VAL,
	   scheme_make_character, character);
SIMPLE_MAP(int, SCHEME_INTP, SCHEME_INT_VAL,
	   scheme_make_integer_value, integer);
SIMPLE_MAP(short, SCHEME_INTP, SCHEME_INT_VAL,
	   scheme_make_integer_value, integer);
SIMPLE_MAP(long, SCHEME_INTP, SCHEME_INT_VAL,
	   scheme_make_integer_value, integer);
SIMPLE_MAP(ptrdiff_t, SCHEME_INTP, SCHEME_INT_VAL,
	   scheme_make_integer_value, integer);
SIMPLE_MAP(unsigned int, SCHEME_INTP, SCHEME_INT_VAL,
	   scheme_make_integer_value_from_unsigned, integer);
SIMPLE_MAP(unsigned short, SCHEME_INTP, SCHEME_INT_VAL,
	   scheme_make_integer_value_from_unsigned, integer);
SIMPLE_MAP(unsigned long, SCHEME_INTP, SCHEME_INT_VAL,
	   scheme_make_integer_value_from_unsigned, integer);
SIMPLE_MAP(size_t, SCHEME_INTP, SCHEME_INT_VAL,
	   scheme_make_integer_value_from_unsigned, integer);
SIMPLE_MAP(float, SCHEME_REALP, scheme_real_to_double,
	   scheme_make_double, real);
SIMPLE_MAP(double, SCHEME_REALP, scheme_real_to_double,
	   scheme_make_double, real);
SIMPLE_MAP(char *, SCHEME_STRINGP, SCHEME_STR_VAL, 
	   scheme_make_string_without_copying, string);
SIMPLE_MAP(const char *, SCHEME_STRINGP, SCHEME_STR_VAL, 
	   scheme_make_string_without_copying, string);

/* Void */

%typemap(out) void "$result = scheme_void;";

/* Pass through Scheme_Object * */

%typemap (in) Scheme_Object * "$1=$input;";
%typemap (out) Scheme_Object * "$result=$1;";


