/*
 * cstring.i
 * $Header$
 *
 * Author(s): David Beazley (beazley@cs.uchicago.edu)
 *
 * This file provides typemaps and macros for dealing with various forms
 * of C character string handling.   The primary use of this module
 * is in returning character data that has been allocated or changed in
 * some way.
 */

%include <pytuplehlp.swg>

/* %cstring_input_binary(TYPEMAP, SIZE)
 * 
 * Macro makes a function accept binary string data along with
 * a size.
 */

%define %cstring_input_binary(TYPEMAP, SIZE)
%apply (char *STRING, int LENGTH) { (TYPEMAP, SIZE) };
%enddef

/*
 * %cstring_bounded_output(TYPEMAP, MAX)
 *
 * This macro is used to return a NULL-terminated output string of
 * some maximum length.  For example:
 *
 *     %cstring_bounded_output(char *outx, 512);
 *     void foo(char *outx) {
 *         sprintf(outx,"blah blah\n");
 *     }
 *
 */

%define %cstring_bounded_output(TYPEMAP,MAX)
%typemap(in,numinputs=0) TYPEMAP(char temp[MAX+1]) {
   $1 = ($1_ltype) temp;
}
%typemap(argout,fragment="t_output_helper") TYPEMAP {
   PyObject *o;
   $1[MAX] = 0;
   o = PyString_FromString($1);
   $result = t_output_helper($result,o);
}
%enddef

/*
 * %cstring_chunk_output(TYPEMAP, SIZE)
 *
 * This macro is used to return a chunk of binary string data.
 * Embedded NULLs are okay.  For example:
 *
 *     %cstring_chunk_output(char *outx, 512);
 *     void foo(char *outx) {
 *         memmove(outx, somedata, 512);
 *     }
 *
 */

%define %cstring_chunk_output(TYPEMAP,SIZE)
%typemap(in,numinputs=0) TYPEMAP(char temp[SIZE]) {
   $1 = ($1_ltype) temp;
}
%typemap(argout,fragment="t_output_helper") TYPEMAP {
   PyObject *o = PyString_FromStringAndSize($1,SIZE);
   $result = t_output_helper($result,o);
}
%enddef

/*
 * %cstring_bounded_mutable(TYPEMAP, SIZE)
 *
 * This macro is used to wrap a string that's going to mutate.
 *
 *     %cstring_bounded_mutable(char *in, 512);
 *     void foo(in *x) {
 *         while (*x) {
 *            *x = toupper(*x);
 *            x++;
 *         }
 *     }
 *
 */


%define %cstring_bounded_mutable(TYPEMAP,MAX)
%typemap(in) TYPEMAP(char temp[MAX+1]) {
   char *t = PyString_AsString($input);
   if (SWIG_arg_fail($argnum)) SWIG_fail;
   strncpy(temp,t,MAX);
   $1 = ($1_ltype) temp;
}
%typemap(argout,fragment="t_output_helper") TYPEMAP {
   PyObject *o;
   $1[MAX] = 0;
   o = PyString_FromString($1);
   $result = t_output_helper($result,o);
}
%enddef

/*
 * %cstring_mutable(TYPEMAP [, expansion])
 *
 * This macro is used to wrap a string that will mutate in place.
 * It may change size up to a user-defined expansion. 
 *
 *     %cstring_mutable(char *in);
 *     void foo(in *x) {
 *         while (*x) {
 *            *x = toupper(*x);
 *            x++;
 *         }
 *     }
 *
 */

%define %cstring_mutable(TYPEMAP,...)
%typemap(in) TYPEMAP {
   char *t = PyString_AsString($input);
   int   n = PyString_Size($input);
   if (SWIG_arg_fail($argnum)) SWIG_fail;
   $1 = ($1_ltype) t;
#if #__VA_ARGS__ == ""
#ifdef __cplusplus
   $1 = ($1_ltype) new char[n+1];
#else
   $1 = ($1_ltype) malloc(n+1);
#endif
#else
#ifdef __cplusplus
   $1 = ($1_ltype) new char[n+1+__VA_ARGS__];
#else
   $1 = ($1_ltype) malloc(n+1+__VA_ARGS__);
#endif
#endif
   memmove($1,t,n);
   $1[n] = 0;
}

%typemap(argout,fragment="t_output_helper") TYPEMAP {
   PyObject *o;
   o = PyString_FromString($1);
   $result = t_output_helper($result,o);
#ifdef __cplusplus
   delete[] $1;
#else
   free($1);
#endif
}
%enddef

/*
 * %cstring_output_maxsize(TYPEMAP, SIZE)
 *
 * This macro returns data in a string of some user-defined size.
 *
 *     %cstring_output_maxsize(char *outx, int max) {
 *     void foo(char *outx, int max) {
 *         sprintf(outx,"blah blah\n");
 *     }
 */

%define %cstring_output_maxsize(TYPEMAP, SIZE)
%typemap(in) (TYPEMAP, SIZE) {
   $2 = PyInt_AsLong($input);
   if (SWIG_arg_fail($argnum)) SWIG_fail;
#ifdef __cplusplus
   $1 = ($1_ltype) new char[$2+1];
#else
   $1 = ($1_ltype) malloc($2+1);
#endif
}
%typemap(argout,fragment="t_output_helper") (TYPEMAP,SIZE) {
   PyObject *o;
   o = PyString_FromString($1);
   $result = t_output_helper($result,o);
#ifdef __cplusplus
   delete [] $1;
#else
   free($1);
#endif
}
%enddef

/*
 * %cstring_output_withsize(TYPEMAP, SIZE)
 *
 * This macro is used to return character data along with a size
 * parameter.
 *
 *     %cstring_output_maxsize(char *outx, int *max) {
 *     void foo(char *outx, int *max) {
 *         sprintf(outx,"blah blah\n");
 *         *max = strlen(outx);  
 *     }
 */

%define %cstring_output_withsize(TYPEMAP, SIZE)
%typemap(in) (TYPEMAP, SIZE) {
   int n = PyInt_AsLong($input);
   if (SWIG_arg_fail($argnum)) SWIG_fail;
#ifdef __cplusplus
   $1 = ($1_ltype) new char[n+1];
   $2 = ($2_ltype) new $*2_ltype;
#else
   $1 = ($1_ltype) malloc(n+1);
   $2 = ($2_ltype) malloc(sizeof($*2_ltype));
#endif
   *$2 = n;
}
%typemap(argout,fragment="t_output_helper") (TYPEMAP,SIZE) {
   PyObject *o;
   o = PyString_FromStringAndSize($1,*$2);
   $result = t_output_helper($result,o);
#ifdef __cplusplus
   delete [] $1;
   delete $2;
#else
   free($1);
   free($2);
#endif
}
%enddef

/*
 * %cstring_output_allocate(TYPEMAP, RELEASE)
 *
 * This macro is used to return character data that was
 * allocated with new or malloc.
 *
 *     %cstring_output_allocated(char **outx, free($1));
 *     void foo(char **outx) {
 *         *outx = (char *) malloc(512);
 *         sprintf(outx,"blah blah\n");
 *     }
 */

%define %cstring_output_allocate(TYPEMAP, RELEASE)
%typemap(in,numinputs=0) TYPEMAP($*1_ltype temp = 0) {
   $1 = &temp;
}

%typemap(argout,fragment="t_output_helper") TYPEMAP {
   if (*$1) {
      PyObject *o = PyString_FromString(*$1);
      RELEASE;
      $result = t_output_helper($result,o);
   }
}
%enddef

/*
 * %cstring_output_allocate_size(TYPEMAP, SIZE, RELEASE)
 *
 * This macro is used to return character data that was
 * allocated with new or malloc.
 *
 *     %cstring_output_allocated(char **outx, int *sz, free($1));
 *     void foo(char **outx, int *sz) {
 *         *outx = (char *) malloc(512);
 *         sprintf(outx,"blah blah\n");
 *         *sz = strlen(outx);
 *     }
 */

%define %cstring_output_allocate_size(TYPEMAP, SIZE, RELEASE)
%typemap(in,numinputs=0) (TYPEMAP, SIZE) ($*1_ltype temp = 0, $*2_ltype tempn) {
   $1 = &temp;
   $2 = &tempn;
}

%typemap(argout,fragment="t_output_helper")(TYPEMAP,SIZE) {
   if (*$1) {
      PyObject *o = PyString_FromStringAndSize(*$1,*$2);
      RELEASE;
      $result = t_output_helper($result,o);
   }
}
%enddef






