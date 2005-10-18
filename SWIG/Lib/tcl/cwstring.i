/*
 * cstring.i
 * $Header$
 *

 * This file provides typemaps and macros for dealing with various forms
 * of C character string handling.   The primary use of this module
 * is in returning character data that has been allocated or changed in
 * some way.
 */

/*
 * %cwstring_input_binary(TYPEMAP, SIZE)
 * 
 * Macro makes a function accept binary string data along with
 * a size.
 */

/*
 * %cwstring_bounded_output(TYPEMAP, MAX)
 *
 * This macro is used to return a NULL-terminated output string of
 * some maximum length.  For example:
 *
 *     %cwstring_bounded_output(wchar_t *outx, 512);
 *     void foo(wchar_t *outx) {
 *         sprintf(outx,"blah blah\n");
 *     }
 *
 */

/*
 * %cwstring_chunk_output(TYPEMAP, SIZE)
 *
 * This macro is used to return a chunk of binary string data.
 * Embedded NULLs are okay.  For example:
 *
 *     %cwstring_chunk_output(wchar_t *outx, 512);
 *     void foo(wchar_t *outx) {
 *         memmove(outx, somedata, 512);
 *     }
 *
 */

/*
 * %cwstring_bounded_mutable(TYPEMAP, SIZE)
 *
 * This macro is used to wrap a string that's going to mutate.
 *
 *     %cwstring_bounded_mutable(wchar_t *in, 512);
 *     void foo(in *x) {
 *         while (*x) {
 *            *x = toupper(*x);
 *            x++;
 *         }
 *     }
 *
 */

/*
 * %cwstring_mutable(TYPEMAP [, expansion])
 *
 * This macro is used to wrap a string that will mutate in place.
 * It may change size up to a user-defined expansion. 
 *
 *     %cwstring_mutable(wchar_t *in);
 *     void foo(in *x) {
 *         while (*x) {
 *            *x = toupper(*x);
 *            x++;
 *         }
 *     }
 *
 */

/*
 * %cwstring_output_maxsize(TYPEMAP, SIZE)
 *
 * This macro returns data in a string of some user-defined size.
 *
 *     %cwstring_output_maxsize(wchar_t *outx, int max) {
 *     void foo(wchar_t *outx, int max) {
 *         sprintf(outx,"blah blah\n");
 *     }
 */

/*
 * %cwstring_output_withsize(TYPEMAP, SIZE)
 *
 * This macro is used to return wchar_tacter data along with a size
 * parameter.
 *
 *     %cwstring_output_maxsize(wchar_t *outx, int *max) {
 *     void foo(wchar_t *outx, int *max) {
 *         sprintf(outx,"blah blah\n");
 *         *max = strlen(outx);  
 *     }
 */
 
/*
 * %cwstring_output_allocate(TYPEMAP, RELEASE)
 *
 * This macro is used to return wchar_tacter data that was
 * allocated with new or malloc.
 *
 *     %cwstring_output_allocated(wchar_t **outx, free($1));
 *     void foo(wchar_t **outx) {
 *         *outx = (wchar_t *) malloc(512);
 *         sprintf(outx,"blah blah\n");
 *     }
 */

/*
 * %cwstring_output_allocate_size(TYPEMAP, SIZE, RELEASE)
 *
 * This macro is used to return wchar_tacter data that was
 * allocated with new or malloc.
 *
 *     %cwstring_output_allocated(wchar_t **outx, int *sz, free($1));
 *     void foo(wchar_t **outx, int *sz) {
 *         *outx = (wchar_t *) malloc(512);
 *         sprintf(outx,"blah blah\n");
 *         *sz = strlen(outx);
 *     }
 */


%include <typemaps/cstring.swg>
%include <pywstrings.swg>

%typemap_cstrings(%cwstring,
		  wchar_t,
		  SWIG_AsWCharPtr,
		  SWIG_AsWCharPtrAndSize,
		  SWIG_FromWCharPtr,
		  SWIG_FromWCharArray);

