%define %fortran_typemap_complex(CPPTYPE, CONSTRUCT_CPPTYPE, CTYPE, FKIND)

%fragment("SWIG_complex_"{CTYPE}, "header", noblock=1) {
#ifdef __cplusplus
extern "C" {
#endif
typedef struct {
  CTYPE real;
  CTYPE imag;
} SwigComplex_ ## CTYPE;
#ifdef __cplusplus
}
#endif

SWIGINTERN SwigComplex_ ## CTYPE SWIG_create_complex_ ## CTYPE(CTYPE real, CTYPE imag) {
  SwigComplex_ ## CTYPE result;
  result.real = real;
  result.imag = imag;
  return result;
}
}

struct SwigComplex_ ## CTYPE;

%fortran_intrinsic(SwigComplex_ ## CTYPE, complex, FKIND)
%fortran_apply_typemaps(SwigComplex_ ## CTYPE, CPPTYPE)

// _Complex and std::complex are required to have the same layout as
// struct { double real, imag; };, so array interfaces should be equivalent
%apply SwigComplex_ ## CTYPE { CPPTYPE };
%apply SwigComplex_ ## CTYPE[] { CPPTYPE[] };
%apply SwigComplex_ ## CTYPE ARRAY[] { CPPTYPE ARRAY[] };
%apply SwigComplex_ ## CTYPE[ANY] { CPPTYPE[ANY] };

%typemap(ctype, in="SwigComplex_" #CTYPE "*", null="SWIG_create_complex_" #CTYPE "(0, 0)", fragment="SWIG_complex_"{CTYPE}, noblock=1) CPPTYPE {
  SwigComplex_ ## CTYPE
}
%typemap(in, noblock=1) CPPTYPE {
  $1 = CONSTRUCT_CPPTYPE($input->real, $input->imag);
}
%typemap(out, noblock=1) CPPTYPE&
{$result = (SwigComplex_ ## CTYPE*)($1);}

%apply CPPTYPE { const CPPTYPE& };
%typemap(in, noblock=1) const CPPTYPE& ($*1_ltype temp) {
  temp = CONSTRUCT_CPPTYPE($input->real, $input->imag);
  $1 = &temp;
}
%enddef // %fortran_typemap_complex

#ifdef __cplusplus
%include <std_complex.i>
#else
%{
#ifdef __STDC_NO_COMPLEX__
#error "This generated file requires C complex number support"
#endif
%}
%include <ccomplex.i>
#endif

