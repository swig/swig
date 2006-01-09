/* File : example.i */
%module example
%{
/* Put headers and other declarations here */
#include "zlib.h"
%}

%include typemaps.i

%rename(VERSION) ZLIB_VERSION;
%rename(z_error) zError;
%apply char * { Bytef * };

/* Allow the sourceLen to be automatically filled in from the length
   of the 'source' string */
%typemap(in) (const Bytef *source, uLong sourceLen)
%{  if (!C_swig_is_string ($input)) {
    swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "Argument $input is not a string");
  }
  $2 = (uLong) C_header_size ($input);
  $1 = C_c_string ($input);
%}

/* Allocate space the size of which is determined by the Scheme
   integer argument, and make a temporary integer so we can set
   destLen. */
%typemap(in) (Bytef *dest, uLongf *destLen) (uLong len)
%{  if (!C_swig_is_fixnum ($input)) {
    swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "Argument $input is not a integer");
  }
  len = (uLong) C_unfix ($input);
  $2 = &len;
  $1 = (char *) malloc (*$2);
%}

/* Return the mutated string as a new object. */
%typemap(argout) (Bytef *dest, uLongf *destLen) 
(C_word *scmstr) 
%{  scmstr = C_alloc (C_SIZEOF_STRING (*$2));
  SWIG_APPEND_VALUE(C_string (&scmstr, *$2, $1));
  free ($1);
%}

%include "zconf.h"
%include "zlib.h"

/* Ignore destLen as an input argument, and make a temporary integer so
   we can set destLen. */
%typemap(numinputs=0) uLongf *destLen (uLong len)
"$1 = &len;";

/* Return a sized string as a new object. */
%typemap(argout)
(void *outstr, uLongf *destLen) (C_word *scmstr) 
%{  scmstr = C_alloc (C_SIZEOF_STRING (*$2));
  SWIG_APPEND_VALUE(C_string (&scmstr, *$2, $1));
%}

%inline %{
/* %inline blocks are seen by SWIG and are inserted into the header
   portion of example_wrap.c, so that they are also seen by the C
   compiler. */
int deflate_init(z_streamp strm, int level) {
  return deflateInit(strm,level); /* call macro */
}
int inflate_init(z_streamp strm) {
  return inflateInit(strm); /* call macro */
}
void* z_stream_save_next_out(z_streamp strm) {
  return (void*) strm->next_out;
}
void z_stream_get_next_chunk(z_streamp strm, void *outstr, uLongf *destLen) {
  *destLen = strm->next_out - (Bytef*)outstr;
}
%}

