/* pointer-in-out.i --- Guile typemaps for passing -*- c -*- pointers indirectly 

   Copyright (C) 2001 Matthias Koeppe <mkoeppe@mail.math.uni-magdeburg.de>

   $Header$
*/

/* Here is a macro that will define typemaps for converting between C
   arrays and Scheme lists or vectors when passing arguments to the C
   function.
  
   TYPEMAP_POINTER_INPUT_OUTPUT(PTRTYPE, SCM_TYPE)

   Supported calling conventions (in this example, PTRTYPE is int *):

   func(int **INPUT)

       Scheme wrapper will take one argument, a wrapped C pointer.
       The address of a variable containing this pointer will be
       passed to the function.

   func(int **OUTPUT)

       Scheme wrapper will take no arguments.  The address of an int *
       variable will be passed to the function.  The function is
       expected to modify the variable; its value is wrapped and
       becomes an extra return value.  (See Doc/internals.html on how
       to deal with multiple values.)
   
   func(int **BOTH)

       This annotation combines INPUT and OUTPUT.

*/

%define TYPEMAP_POINTER_INPUT_OUTPUT(PTRTYPE, SCM_TYPE)

%typemap(in) PTRTYPE *INPUT(PTRTYPE temp)
{
    if (SWIG_Guile_GetPtr($source, (void **) &temp, $*descriptor)) {
	scm_wrong_type_arg(FUNC_NAME, $argnum, $source);
    }
    $target = &temp;
}
%typemap(indoc) PTRTYPE *INPUT "($arg <SCM_TYPE>)";

%typemap(ignore) PTRTYPE *OUTPUT(PTRTYPE temp) 
     "$target = &temp;";

%typemap(argout) PTRTYPE *OUTPUT
     "SWIG_APPEND_VALUE(SWIG_Guile_MakePtr(*$target, $*descriptor));"; 

%typemap(argoutdoc) PTRTYPE *OUTPUT "<SCM_TYPE>";

%typemap(in) PTRTYPE *BOTH = PTRTYPE *INPUT;
%typemap(argout) PTRTYPE *BOTH = PTRTYPE *OUTPUT;
%typemap(argoutdoc) PTRTYPE *BOTH = PTRTYPE *OUTPUT;
%typemap(in) PTRTYPE *INOUT = PTRTYPE *INPUT;
%typemap(argout) PTRTYPE *INOUT = PTRTYPE *OUTPUT;
%typemap(argoutdoc) PTRTYPE *INOUT = PTRTYPE *OUTPUT;

/* As a special convenience measure, also attach docs involving
   SCM_TYPE to the standard pointer typemaps */

%typemap(indoc) PTRTYPE "<($arg <SCM_TYPE>)>";
%typemap(outdoc) PTRTYPE "<SCM_TYPE>";

%enddef
