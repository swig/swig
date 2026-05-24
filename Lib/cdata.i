/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

/* 'alloc' is seeded with 'SWIG_BINARYSTR' so 'SWIG_AsCharPtrAndSize' treats the input as
   raw bytes (no Unicode translation, exact length); it overwrites 'alloc' on return. */
%typemap(in,noblock=0,fragment="SWIG_AsCharPtrAndSize") (const void *BYTES, size_t LENGTH) (int res, void *buf = 0, size_t len = 0, int alloc = SWIG_BINARYSTR) {
  res = SWIG_AsCharPtrAndSize($input, (char **)&buf, &len, &alloc);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res,"$type",$symname, $argnum);
  }
  $1 = %reinterpret_cast(buf, $1_ltype);
  $2 = %numeric_cast(len, $2_ltype);
}

%typemap(freearg,noblock=1,match="in") (const void *BYTES, size_t LENGTH) {
  if (alloc$argnum == SWIG_NEWOBJ) {
    %delete_array((char*)(buf$argnum));
  }
}

%typemap(directorin,noblock=1,fragment="SWIG_FromCharPtrAndSize") (const void *BYTES, size_t LENGTH) {
  if ($1 && $2 > 0) {
    $input = SWIG_FromBinaryCharPtrAndSize((const char*)$1, (size_t)$2, SWIG_BINARYSTR);
  } else {
    $input = SWIG_FromBinaryCharPtrAndSize("", 0, SWIG_BINARYSTR);
  }
}

%typemap(in) (void *BYTES, size_t LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(freearg) (void *BYTES, size_t LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(directorin) (void *BYTES, size_t LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(in) (const void *BYTES, int LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(freearg) (const void *BYTES, int LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(directorin) (const void *BYTES, int LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(in) (void *BYTES, int LENGTH) = (const void *BYTES, int LENGTH);
%typemap(freearg) (void *BYTES, int LENGTH) = (const void *BYTES, int LENGTH);
%typemap(directorin) (void *BYTES, int LENGTH) = (const void *BYTES, int LENGTH);
%typemap(in) (const void *indata, size_t inlen) = (const void *BYTES, size_t LENGTH);
%typemap(freearg) (const void *indata, size_t inlen) = (const void *BYTES, size_t LENGTH);
%typemap(directorin) (const void *indata, size_t inlen) = (const void *BYTES, size_t LENGTH);
#define SWIG_CDATA_APPLIED

%include <typemaps/cdata_begin.swg>

%typemap(out,noblock=1,fragment="SWIG_FromCharPtrAndSize") SWIGCDATA {
  %set_output(SWIG_FromBinaryCharPtrAndSize($1.data,(size_t)($1.len), SWIG_BINARYSTR));
}

%include <typemaps/cdata_end.swg>
