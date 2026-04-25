/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

%include <javascriptuint8array.swg>

%typemap(in,noblock=0,fragment="SWIG_FromUint8Array") (const void *BYTES, size_t LENGTH) (void *buf = 0, int alloc = 0) {
  size_t len;
  int res = SWIG_FromUint8Array($input, &buf, &len, &alloc);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res,"$type",$symname, $argnum);
  }
  $1 = %reinterpret_cast(buf, $1_ltype);
  $2 = %numeric_cast(len, $2_ltype);
}

/* buffer is allocated with 'unsigned char' type! */
%typemap(freearg,noblock=1,match="in") (const void *BYTES, size_t LENGTH) {
  if (alloc$argnum == SWIG_NEWOBJ) {
    %delete_array((%reinterpret_cast(buf$argnum, unsigned char *)));
  }
}

%typemap(directorin,noblock=1,fragment="SWIG_ToUint8Array") (const void *BYTES, size_t LENGTH) {
  $input = SWIG_ToUint8Array($1, $2);
}

%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }

%include <typemaps/cdata_begin.swg>

%typemap(out,noblock=1,fragment="SWIG_ToUint8Array") SWIGCDATA {
  %set_output(SWIG_ToUint8Array($1.data, $1.len));
}

%include <typemaps/cdata_end.swg>
