/* typemaps.i --- guile-specific typemaps -*- c -*-
   Copyright (C) 2000 Matthias Koeppe <mkoeppe@mail.math.uni-magdeburg.de>

   $Header$  */

/* (11/24/2001) Note to Matthias:

   I've replaced all of the documentation related typemaps (indoc, varindoc, outdoc, argoutdoc, ...)
   with a typemap parameter of "doc".  For example:

   %typemap(in, doc="<integer>") int {
      ...
   }

   This is somewhat more sane to handle when multi-argument typemaps are used.  For example:

   %typemap(in, doc="<buffer>") (char *data, int len) {
       ...
   }

   See guile.cxx for details of how the typemap parameters actually get accessed.

   Also, it's no longer necessary to specify typemaps for 'const' qualifiers.  They
   now get matched against non-const versions.

   Feel free to delete this comment after you've read it.

                         --- Dave
*/

/* Pointers */

%typemap(in) SWIGTYPE * {
  if (SWIG_Guile_GetPtr($input, (void **) &$1, $descriptor))
    scm_wrong_type_arg(FUNC_NAME, $argnum, $input);
}

%typemap(in) void * {
  if (SWIG_Guile_GetPtr($input, (void **) &$1, NULL))
    scm_wrong_type_arg(FUNC_NAME, $argnum, $input);
}

%typemap(varin) SWIGTYPE * {
  if (SWIG_Guile_GetPtr($input, (void **) &$1, $descriptor))
    scm_wrong_type_arg(FUNC_NAME, 1, $input);
}

%typemap(varin) void * {
  if (SWIG_Guile_GetPtr($input, (void **) &$1, NULL))
    scm_wrong_type_arg(FUNC_NAME, 1, $input);
}

%typemap(out) SWIGTYPE * {
    $result = SWIG_Guile_MakePtr ($1, $descriptor);
}
    
%typemap(varout) SWIGTYPE * {
    $result = SWIG_Guile_MakePtr ($1, $descriptor);
}

/* Pass-by-value */

%typemap(in) SWIGTYPE($&1_ltype argp) {
  if (SWIG_Guile_GetPtr($input, (void **) &argp, $1_descriptor))
    scm_wrong_type_arg(FUNC_NAME,$argnum,$input);
  $1 = *argp;
}

%typemap(varin) SWIGTYPE {
  $&1_ltype argp;
  if (SWIG_Guile_GetPtr($input, (void **) &argp, $1_descriptor))
    scm_wrong_type_arg(FUNC_NAME,1,$input);
  $1 = *argp;
}

%typemap(out) SWIGTYPE 
#ifdef __cplusplus
{
  $&1_ltype resultptr;
  resultptr = new $1_ltype($1);
  $result =  SWIG_Guile_MakePtr (resultptr, $&1_descriptor);
} 
#else
{
  $&1_ltype resultptr;
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  $result = SWIG_Guile_MakePtr(resultptr, $&1_descriptor);
}
#endif

%typemap(varout) SWIGTYPE 
#ifdef __cplusplus
{
  $&1_ltype resultptr;
  resultptr = new $1_ltype($1);
  $result =  SWIG_Guile_MakePtr (resultptr, $&1_descriptor);
} 
#else
{
  $&1_ltype resultptr;
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  $result = SWIG_Guile_MakePtr(resultptr, $&1_descriptor);
}
#endif

/* C++ References */

#ifdef __cplusplus

%typemap(in) SWIGTYPE & {
  if (SWIG_Guile_GetPtr($input, (void **) &$1, $descriptor)!=0)
    scm_wrong_type_arg(FUNC_NAME, $argnum, $input);
}

%typemap(out) SWIGTYPE & {
  $result = SWIG_Guile_MakePtr ($1, $descriptor);
}

#endif

/* Arrays */

%typemap(in) SWIGTYPE[] {
  if (SWIG_Guile_GetPtr($input, (void **) &$1, $descriptor)!=0)
    scm_wrong_type_arg(FUNC_NAME, $argnum, $input);
}

%typemap(out) SWIGTYPE[] {
  $result = SWIG_Guile_MakePtr ($1, $descriptor);
}

/* Enums */

%typemap(in)     enum SWIGTYPE "$1 = gh_scm2int($input);";
%typemap(varin)  enum SWIGTYPE "$1 = gh_scm2int($input);";
%typemap(out)    enum SWIGTYPE "$result = gh_int2scm($1);";
%typemap(varout) enum SWIGTYPE "$result = gh_int2scm($1);";

/* The SIMPLE_MAP macro below defines the whole set of typemaps needed
   for simple types. */

%define SIMPLE_MAP(C_NAME, SCM_TO_C, C_TO_SCM, SCM_NAME)
 %typemap (in,     doc="($name <" #SCM_NAME ">)")      C_NAME {$1 = SCM_TO_C($input);}
 %typemap (varin,  doc="(new-value <" #SCM_NAME ">)")  C_NAME {$1 = SCM_TO_C($input);}
 %typemap (out,    doc="<" #SCM_NAME ">")              C_NAME {$result = C_TO_SCM($1);}
 %typemap (varout, doc="<" #SCM_NAME ">")              C_NAME {$result = C_TO_SCM($1);}
 %typemap (in, doc="($name <" #SCM_NAME ">)") C_NAME *INPUT(C_NAME temp) {
   temp = (C_NAME) SCM_TO_C($input); $1 = &temp;
 }
 %typemap (ignore)      C_NAME *OUTPUT (C_NAME temp)
   {$1 = &temp;}
 %typemap (argout,doc="($name <" #SCM_NAME ">)") C_NAME *OUTPUT
   {SWIG_APPEND_VALUE(C_TO_SCM(*$1));}

 %typemap (in)          C_NAME *BOTH = C_NAME *INPUT;
 %typemap (argout)      C_NAME *BOTH = C_NAME *OUTPUT;
 %typemap (in)          C_NAME *INOUT = C_NAME *INPUT;
 %typemap (argout)      C_NAME *INOUT = C_NAME *OUTPUT;
%enddef

 SIMPLE_MAP(bool, gh_scm2bool, gh_bool2scm, boolean);
 SIMPLE_MAP(char, gh_scm2char, gh_char2scm, char);
 SIMPLE_MAP(unsigned char, gh_scm2char, gh_char2scm, char);
 SIMPLE_MAP(int, gh_scm2int, gh_int2scm, integer);
 SIMPLE_MAP(short, gh_scm2int, gh_int2scm, integer);
 SIMPLE_MAP(long, gh_scm2long, gh_long2scm, integer);
 SIMPLE_MAP(ptrdiff_t, gh_scm2long, gh_long2scm, integer);
 SIMPLE_MAP(unsigned int, gh_scm2ulong, gh_ulong2scm, integer);
 SIMPLE_MAP(unsigned short, gh_scm2ulong, gh_ulong2scm, integer);
 SIMPLE_MAP(unsigned long, gh_scm2ulong, gh_ulong2scm, integer);
 SIMPLE_MAP(size_t, gh_scm2ulong, gh_ulong2scm, integer);
 SIMPLE_MAP(float, gh_scm2double, gh_double2scm, real);
 SIMPLE_MAP(double, gh_scm2double, gh_double2scm, real);
 SIMPLE_MAP(char *, SWIG_scm2str, gh_str02scm, string);
 SIMPLE_MAP(const char *, SWIG_scm2str, gh_str02scm, string);

/* GSWIG_scm2str makes a malloc'ed copy of the string, so get rid of it after
   the function call. */

%typemap (freearg) char * "if ($1) scm_must_free($1);";
%typemap (freearg) char **OUTPUT, char **BOTH "if (*$1) scm_must_free(*$1);"

/* But this shall not apply if we try to pass a single char by
   reference. */

%typemap (freearg) char *OUTPUT, char *BOTH "";

/* If we set a string variable, delete the old result first. */

%typemap (varin) char * {
    if ($1) free($1);
    $1 = SWIG_scm2str($input);
}

/* Void */

%typemap (out,doc="") void "gswig_result = GH_UNSPECIFIED;";

/* SCM is passed through */

typedef unsigned long SCM;
%typemap (in) SCM "$1=$input;";
%typemap (out) SCM "$result=$1;";

/* Some ANSI C typemaps */

%apply long { size_t };

/* typemaps.i ends here */





