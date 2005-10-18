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

/*
 * %cstring_input_binary(TYPEMAP, SIZE)
 * 
 * Macro makes a function accept binary string data along with
 * a size.
 */

/*
 * %cstring_bounded_output(TYPEMAP, MAX)
 *
 * This macro is used to return a NULL-terminated output string of
 * some maximum length.  For example:
 *
 *     %cstring_bounded_output(Char *outx, 512);
 *     void foo(Char *outx) {
 *         sprintf(outx,"blah blah\n");
 *     }
 *
 */

/*
 * %cstring_chunk_output(TYPEMAP, SIZE)
 *
 * This macro is used to return a chunk of binary string data.
 * Embedded NULLs are okay.  For example:
 *
 *     %cstring_chunk_output(Char *outx, 512);
 *     void foo(Char *outx) {
 *         memmove(outx, somedata, 512);
 *     }
 *
 */

/*
 * %cstring_bounded_mutable(TYPEMAP, SIZE)
 *
 * This macro is used to wrap a string that's going to mutate.
 *
 *     %cstring_bounded_mutable(Char *in, 512);
 *     void foo(in *x) {
 *         while (*x) {
 *            *x = toupper(*x);
 *            x++;
 *         }
 *     }
 *
 */

/*
 * %cstring_mutable(TYPEMAP [, expansion])
 *
 * This macro is used to wrap a string that will mutate in place.
 * It may change size up to a user-defined expansion. 
 *
 *     %cstring_mutable(Char *in);
 *     void foo(in *x) {
 *         while (*x) {
 *            *x = toupper(*x);
 *            x++;
 *         }
 *     }
 *
 */

/*
 * %cstring_output_maxsize(TYPEMAP, SIZE)
 *
 * This macro returns data in a string of some user-defined size.
 *
 *     %cstring_output_maxsize(Char *outx, int max) {
 *     void foo(Char *outx, int max) {
 *         sprintf(outx,"blah blah\n");
 *     }
 */

/*
 * %cstring_output_withsize(TYPEMAP, SIZE)
 *
 * This macro is used to return Character data along with a size
 * parameter.
 *
 *     %cstring_output_maxsize(Char *outx, int *max) {
 *     void foo(Char *outx, int *max) {
 *         sprintf(outx,"blah blah\n");
 *         *max = strlen(outx);  
 *     }
 */
 
/*
 * %cstring_output_allocate(TYPEMAP, RELEASE)
 *
 * This macro is used to return Character data that was
 * allocated with new or malloc.
 *
 *     %cstring_output_allocated(Char **outx, free($1));
 *     void foo(Char **outx) {
 *         *outx = (Char *) malloc(512);
 *         sprintf(outx,"blah blah\n");
 *     }
 */

/*
 * %cstring_output_allocate_size(TYPEMAP, SIZE, RELEASE)
 *
 * This macro is used to return Character data that was
 * allocated with new or malloc.
 *
 *     %cstring_output_allocated(Char **outx, int *sz, free($1));
 *     void foo(Char **outx, int *sz) {
 *         *outx = (Char *) malloc(512);
 *         sprintf(outx,"blah blah\n");
 *         *sz = strlen(outx);
 *     }
 */

%include <typemaps/cstring.swg>
%include <tclstrings.swg>

%typemap_cstrings(%cstring,
		  char,
		  SWIG_AsCharPtr,
		  SWIG_AsCharPtrAndSize,
		  SWIG_FromCharPtr,
		  SWIG_FromCharPtrAndSize);

