/* typemaps.i --- mzscheme typemaps -*- c -*-
   Copyright 2000, 2001 Matthias Koeppe <mkoeppe@mail.math.uni-magdeburg.de>
   Based on code written by Oleg Tolmatcev.

   $Id$
*/

/* The MzScheme module handles all types uniformly via typemaps. Here
   are the definitions.  */

/* Pointers */

%typemap(in) SWIGPOINTER * {
  $target = ($ltype) SWIG_MustGetPtr($source, $descriptor, $argnum);
}

%typemap(in) void * {
  $target = SWIG_MustGetPtr($source, NULL, $argnum);
}

%typemap(varin) SWIGPOINTER * {
  $target = ($ltype) SWIG_MustGetPtr($source, $descriptor, $argnum);
}

%typemap(varin) void * {
  $target = SWIG_MustGetPtr($source, NULL, $argnum);
}

%typemap(out) SWIGPOINTER * {
  $target = SWIG_MakePtr ($source, $descriptor);
}
    
%typemap(varout) SWIGPOINTER * {
  $target = SWIG_MakePtr ($source, $descriptor);
}

/* C++ References */

#ifdef __cplusplus

%typemap(in) SWIGREFERENCE & { 
  $target = ($ltype) SWIG_MustGetPtr($source, $descriptor, $argnum);
}

%typemap(out) SWIGREFERENCE & {
  $target = SWIG_MakePtr ($source, $descriptor);
}

#endif

/* Arrays */

%typemap(in) SWIGARRAY[] {
  $target = ($ltype) SWIG_MustGetPtr($source, $descriptor, $argnum);
}

%typemap(out) SWIGARRAY[] {
  $target = SWIG_MakePtr ($source, $descriptor);
}

/* The SIMPLE_MAP macro below defines the whole set of typemaps needed
   for simple types. */

%define SIMPLE_MAP(C_NAME, MZ_PREDICATE, MZ_TO_C, C_TO_MZ, MZ_NAME)
%typemap(in) C_NAME, C_NAME const {
    if (!MZ_PREDICATE($source))
	scheme_wrong_type("$name", "MZ_NAME", $argnum, argc, argv);
    $target = MZ_TO_C($source);
}
%typemap(varin) C_NAME, C_NAME const {
    if (!MZ_PREDICATE($source))
	scheme_wrong_type("$name", "MZ_NAME", $argnum, argc, argv);
    $target = MZ_TO_C($source);
}
%typemap(out) C_NAME, C_NAME const {
    $target = C_TO_MZ($source);
}
%typemap(varout) C_NAME, C_NAME const {
    $target = C_TO_MZ($source);
}
%typemap(in) C_NAME *INPUT (C_NAME temp) {
    temp = (C_NAME) MZ_TO_C($source);
    $target = &temp;
}
%typemap(ignore) C_NAME *OUTPUT (C_NAME temp) {
    $target = &temp;
}
%typemap(argout) C_NAME *OUTPUT {
    Scheme_Object *s;
    s = C_TO_MZ(*$target);
    SWIG_APPEND_VALUE(s);
}
%typemap(in) C_NAME *BOTH = C_NAME *INPUT;
%typemap(argout) C_NAME *BOTH = C_NAME *OUTPUT;
%typemap(in) C_NAME *INOUT = C_NAME *INPUT;
%typemap(argout) C_NAME *INOUT = C_NAME *OUTPUT;
%enddef

SIMPLE_MAP(bool, SCHEME_BOOLP, SCHEME_TRUEP,
	   mzswig_make_boolean, boolean);
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

%typemap(out) void "$target = scheme_void;";

/* Pass through Scheme_Object * */

%typemap (in) Scheme_Object * "$target=$source;";
%typemap (out) Scheme_Object * "$target=$source;";

