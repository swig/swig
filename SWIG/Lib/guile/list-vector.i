/* list-vector.i --- Guile typemaps for converting between -*- c -*- arrays
		     and Scheme lists or vectors  

   Copyright (C) 2001 Matthias Koeppe <mkoeppe@mail.math.uni-magdeburg.de>

   $Header$
*/

/* Here is a macro that will define typemaps for converting between C
   arrays and Scheme lists or vectors when passing arguments to the C
   function.

   TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(C_TYPE, SCM_TO_C, C_TO_SCM, SCM_TYPE)
   
   Supported calling conventions:

   func(int VECTORLENINPUT, [const] C_TYPE *VECTORINPUT)  or
   func([const] C_TYPE *VECTORINPUT, int VECTORLENINPUT)

       Scheme wrapper will take one argument, a vector.  A temporary C
       array of elements of type C_TYPE will be allocated and filled
       with the elements of the vectors, converted to C with the
       SCM_TO_C function.  Length and address of the array are passed
       to the C function.

       SCM_TYPE is used to describe the Scheme type of the elements in
       the Guile procedure documentation.
   
   func(int LISTLENINPUT, [const] C_TYPE *LISTINPUT) or
   func([const] C_TYPE *LISTINPUT, int LISTLENINPUT)

       Likewise, but the Scheme wrapper will take one argument, a list.

   func(int *VECTORLENOUTPUT, C_TYPE **VECTOROUTPUT) or
   func(C_TYPE **VECTOROUTPUT, int *VECTORLENOUTPUT)

       Scheme wrapper will take no arguments.  Addresses of an integer
       and a C_TYPE * variable will be passed to the C function.  The
       C function is expected to return address and length of a
       freshly allocated array of elements of type C_TYPE through
       these pointers.  The elements of this array are converted to
       Scheme with the C_TO_SCM function and returned as a Scheme
       vector. 

       If the function has a void return value, the vector constructed
       by this typemap becomes the return value of the Scheme wrapper.
       Otherwise, the function returns multiple values.  (See
       Doc/internals.html on how to deal with multiple values.)

   func(int *LISTLENOUTPUT, C_TYPE **LISTOUTPUT) or
   func(C_TYPE **LISTOUTPUT, int *LISTLENOUTPUT)

       Likewise, but the Scheme wrapper will return a list instead of
       a vector.

   Multiple parallel lists and vectors (sharing one length argument
   each) are also supported.  */

%define TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(C_TYPE, SCM_TO_C, C_TO_SCM, SCM_TYPE)

  /* input */
     
     /* We make use of the new multi-dispatch typemaps here. */
     
     %typemap(in, doc="($arg <vector of <" #SCM_TYPE ">>)")
       (int VECTORLENINPUT, C_TYPE *VECTORINPUT)
     {
       SCM_VALIDATE_VECTOR($argnum, $input);
       $1 = gh_vector_length($input);
       if ($1 > 0) {
	 int i;
	 $2 = SWIG_malloc(sizeof(C_TYPE) * $1);
	 for (i = 0; i<$1; i++) {
	   SCM elt = gh_vector_ref($input, gh_int2scm(i));
	   $2[i] = SCM_TO_C(elt);
	 }
       }
       else $2 = NULL;
     }
	 
     %typemap(in, doc="($arg <list of <" #SCM_TYPE ">>)")
       (int LISTLENINPUT, C_TYPE *LISTINPUT)
     {
       SCM_VALIDATE_LIST($argnum, $input);
       $1 = gh_length($input);
       if ($1 > 0) {
	 int i;
	 SCM rest;
	 $2 = SWIG_malloc(sizeof(C_TYPE) * $1);
	 for (i = 0, rest = $input;
	      i<$1;
	      i++, rest = gh_cdr(rest)) {
	   SCM elt = gh_car(rest);
	   $2[i] = SCM_TO_C(elt);
	 }
       }
       else $2 = NULL;
     }

     /* Do not check for NULL pointers (override checks). */

     %typemap(check) C_TYPE *VECTORINPUT, 
		     const C_TYPE *VECTORINPUT,
		     C_TYPE *LISTINPUT, 
		     const C_TYPE *LISTINPUT
       "/* no check for NULL pointer */";

     /* Discard the temporary array after the call. */

     %typemap(freearg) C_TYPE *VECTORINPUT, 
		       const C_TYPE *VECTORINPUT,
		       C_TYPE *LISTINPUT, 
		       const C_TYPE *LISTINPUT
       {if ($1!=NULL) SWIG_free($1);}

  /* output */

     /* First we make temporary variables ARRAYLENTEMP and ARRAYTEMP,
	whose addresses we pass to the C function.  We ignore both
	arguments for Scheme. */

     %typemap(ignore) (int *VECTORLENOUTPUT, C_TYPE **VECTOROUTPUT)
                        (int arraylentemp, C_TYPE *arraytemp),
                      (int *LISTLENOUTPUT, C_TYPE **LISTOUTPUT)
                        (int arraylentemp, C_TYPE *arraytemp)
     %{
       $1 = &arraylentemp;
       $2 = &arraytemp;
     %}

     /* In the ARGOUT typemaps, we convert the array into a vector or
        a list and append it to the results. */

     %typemap(argout, doc="($arg <vector of <" #SCM_TYPE ">>)") 
          (int *VECTORLENOUTPUT, C_TYPE **VECTOROUTPUT)
     {
       int i;
       SCM res = gh_make_vector(gh_int2scm(*$1),
				SCM_BOOL_F);
       for (i = 0; i<*$1; i++) {
	 SCM elt = C_TO_SCM((*$2)[i]);
	 gh_vector_set_x(res, gh_int2scm(i), elt);
       }
       if (*$2!=NULL) free(*$2);
       SWIG_APPEND_VALUE(res);
     }

     %typemap(argout, doc="($arg <list of <" #SCM_TYPE ">>)")
          (int *LISTLENOUTPUT, C_TYPE **LISTOUTPUT)
     {
       int i;
       SCM res = SCM_EOL;
       for (i = (*$1) - 1; i>=0; i--) {
	 SCM elt = C_TO_SCM((*$2)[i]);
	 res = gh_cons(elt, res);
       }
       if (*$2!=NULL) free(*$2);
       SWIG_APPEND_VALUE(res);
     }

%enddef

/* We use the macro to define typemaps for some standard types. */

TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(bool, gh_scm2bool, gh_bool2scm, boolean);
TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(char, gh_scm2char, gh_char2scm, char);
TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(unsigned char, gh_scm2char, gh_char2scm, char);
TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(int, gh_scm2int, gh_int2scm, integer);
TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(short, gh_scm2int, gh_int2scm, integer);
TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(long, gh_scm2long, gh_long2scm, integer);
TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(ptrdiff_t, gh_scm2long, gh_long2scm, integer);
TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(unsigned int, gh_scm2ulong, gh_ulong2scm, integer);
TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(unsigned short, gh_scm2ulong, gh_ulong2scm, integer);
TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(unsigned long, gh_scm2ulong, gh_ulong2scm, integer);
TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(size_t, gh_scm2ulong, gh_ulong2scm, integer);
TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(float, gh_scm2double, gh_double2scm, real);
TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(double, gh_scm2double, gh_double2scm, real);
TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(char *, SWIG_scm2str, gh_str02scm, string);
TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(const char *, SWIG_scm2str, gh_str02scm, string);

