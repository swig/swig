/* typemaps.i --- guile-specific typemaps -*- c -*-
   Copyright (C) 2000 Matthias Koeppe <mkoeppe@mail.math.uni-magdeburg.de>

   $Header$  */

/* Basic types */

%define SIMPLE_MAP(C_NAME, SCM_TO_C, C_TO_SCM, SCM_NAME)
 %typemap (guile, in)          C_NAME "$target = SCM_TO_C($source);";
 %typemap (guile, varin)       C_NAME "$target = SCM_TO_C($source);";
 %typemap (guile, out)         C_NAME "$target = C_TO_SCM($source);";
 %typemap (guile, varout)      C_NAME "$target = C_TO_SCM($source);";
 %typemap (guile, indoc)       C_NAME "($arg <SCM_NAME>)";
 %typemap (guile, varindoc)    C_NAME "($arg <SCM_NAME>)";
 %typemap (guile, outdoc)      C_NAME "<SCM_NAME>";
 %typemap (guile, varoutdoc)   C_NAME "<SCM_NAME>";
 %typemap (guile, in)          C_NAME *INPUT (C_NAME temp)
 "temp = (C_NAME) C_TO_SCM($source); $target = &temp;"
 %typemap (guile, indoc)       C_NAME *INPUT "($arg <SCM_NAME>)";
 %typemap (guile, ignore)      C_NAME *OUTPUT (C_NAME temp)
 "$target = &temp;"
 %typemap (guile, argout)      C_NAME *OUTPUT
 "GUILE_APPEND_RESULT(C_TO_SCM(*$target));";
 %typemap (guile, argoutdoc)   C_NAME *OUTPUT "($arg <SCM_NAME>)";
 %typemap (guile, in)          C_NAME *BOTH = C_NAME *INPUT;
 %typemap (guile, indoc)       C_NAME *BOTH = C_NAME *INPUT;
 %typemap (guile, argout)      C_NAME *BOTH = C_NAME *OUTPUT;
 %typemap (guile, argoutdoc)   C_NAME *BOTH = C_NAME *OUTPUT;
%enddef
 
 SIMPLE_MAP(bool, gh_scm2bool, gh_bool2scm, boolean);
 SIMPLE_MAP(char, GSWIG_scm2char, gh_char2scm, char);
 SIMPLE_MAP(unsigned char, GSWIG_scm2char, gh_char2scm, char);
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
 SIMPLE_MAP(char *, GSWIG_scm2str, gh_str02scm, string);

/* GSWIG_scm2str makes a malloc'ed copy of the string, so get rid of it after
   the function call. */

%typemap (guile, freearg) char * "if ($target) scm_must_free($target);";

/* Void */

%typemap (guile, out) void "gswig_result = GH_UNSPECIFIED;";
%typemap (guile, outdoc) void "";

/* typemaps.i ends here */
