/* pointer-in-out.i --- Guile typemaps for passing -*- c -*- pointers indirectly 

   Copyright (C) 2001 Matthias Koeppe <mkoeppe@mail.math.uni-magdeburg.de>

   $Header$
*/

/* Here is a macro that will define typemaps for passing C pointers indirectly.
  
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
       becomes an extra return value.  (See the documentation on how
       to deal with multiple values.)
   
   func(int **BOTH)
   func(int **INOUT)

       This annotation combines INPUT and OUTPUT.

*/

%define TYPEMAP_POINTER_INPUT_OUTPUT(PTRTYPE, SCM_TYPE)

%typemap(in, doc="$NAME is of type <" #SCM_TYPE ">") PTRTYPE *INPUT(PTRTYPE temp)
{
    if (SWIG_Guile_GetPtr($input, (void **) &temp, $*descriptor)) {
	scm_wrong_type_arg(FUNC_NAME, $argnum, $input);
    }
    $1 = &temp;
}

%typemap(in, numinputs=0) PTRTYPE *OUTPUT(PTRTYPE temp) 
     "$1 = &temp;";

%typemap(argout, doc="<" #SCM_TYPE ">") PTRTYPE *OUTPUT
     "SWIG_APPEND_VALUE(SWIG_Guile_MakePtr(*$1, $*descriptor));"; 

%typemap(in) PTRTYPE *BOTH = PTRTYPE *INPUT;
%typemap(argout) PTRTYPE *BOTH = PTRTYPE *OUTPUT;
%typemap(in) PTRTYPE *INOUT = PTRTYPE *INPUT;
%typemap(argout) PTRTYPE *INOUT = PTRTYPE *OUTPUT;

/* As a special convenience measure, also attach docs involving
   SCM_TYPE to the standard pointer typemaps */

%typemap(in, doc="$NAME is of type <" #SCM_TYPE ">") PTRTYPE {
  if (SWIG_Guile_GetPtr($input, (void **) &$1, $descriptor))
    scm_wrong_type_arg(FUNC_NAME, $argnum, $input);
}

%typemap(out, doc="<" #SCM_TYPE ">") PTRTYPE {
    $result = SWIG_Guile_MakePtr ($1, $descriptor);
}

%enddef
