/* Check that SWIG_FromUint8Array and SWIG_ToUint8Array reach the C
   compiler rather than being consumed by the SWIG preprocessor.

   A typemap delimited with %{ ... %} is not macro expanded by SWIG, so the macro
   names below survive into the generated wrapper, and the generated code only
   compiles if the library defines them for the C compiler too.

   The function are used by Javascript for the Uint8Array type. */

%module javascript_uint8array_fragment

/* Include Javascript Uint8Array functions */
%include "javascriptuint8array.swg"

%wrapper %{
/* Code inserted verbatim like this is not macro expanded by SWIG either, so
   SWIG_FromUint8Array and SWIG_ToUint8Array have to be usable by the C compiler.
   The typemaps go through these aliases so that %set_output and other SWIG macros
   can still be used.
   These SWIG macros are not expanded inside a verbatim delimited typemap
   either */
#define swig_fromuint8array(a, b, c, d) SWIG_FromUint8Array(a, b, c, d)
#define swig_touint8array(a, b) SWIG_ToUint8Array(a, b)
%}

%typemap(in,noblock=0,fragment="SWIG_FromUint8Array") (const void *data, size_t len) (void *buf = NULL, int alloc = 0) {
  size_t len = 0;
  int res = swig_fromuint8array($input, &buf, &len, &alloc);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res,"$type",$symname, $argnum);
  }
  $1 = %reinterpret_cast(buf, $1_ltype);
  $2 = %numeric_cast(len, $2_ltype);
}

%typemap(freearg,noblock=1,match="in") (const void *data, size_t len) {
  if (alloc$argnum == SWIG_NEWOBJ) {
    %delete_array((%reinterpret_cast(buf$argnum, unsigned char *)));
  }
}

%typemap(out,noblock=1,fragment="SWIG_ToUint8Array") struct data_t {
  %set_output(swig_touint8array($1.data, $1.len));
}

/* Only the functions are wrapped - the struct is deliberately not exposed, so
   that the in and out typemaps above are the only thing under test. */
%{

struct data_t {
  size_t len;
  void* data;
};

struct data_t getData()
{
  static struct data_t r = { 5, (void*)"\x1\x2\x3\x4\x5" };
  return r;
}

int verifyData(const void *data, size_t len) {
  unsigned char *ptr = (unsigned char *)data;
  return ptr != NULL && len == 5 &&
    ptr[0] == 5  && ptr[1] == 4  &&
    ptr[2] == 3  && ptr[3] == 2  &&
    ptr[4] == 1;
}

%}

struct data_t getData();
int verifyData(const void *data, size_t len);
