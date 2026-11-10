%module ccomplextest

/* Octave, Ruby, C# and Guile support only C++ complex interfcae */
#if !defined(SWIGC) && !defined(SWIGJAVA) && !defined(SWIGOCAML) && !defined(SWIGPERL) && !defined(SWIGR) && !defined(SWIGSCILAB) && !defined(SWIGTCL) && !defined(SWIGD) && !defined(SWIGGO) && !defined(SWIGLUA) && !defined(SWIGPHP) && !defined(SWIGOCTAVE) && !defined(SWIGRUBY) && !defined(SWIGCSHARP) && !defined(SWIGGUILE)
%include <complex.i>
#else
/* C support _Complex only! */
#define complex _Complex
#endif

%{
#include <complex.h>

#if defined __STDC_VERSION__ && __STDC_VERSION__ >= 199901L && !defined __STDC_NO_COMPLEX__
#define HAS_C99_COMPLEX_FOR_TESTING 1
#elif defined __cplusplus
#define HAS_C99_COMPLEX_FOR_TESTING 1
/*
 * JavaScript may use C++.
 * We need to explicitly declare the C complex functions we use!
 * creal() and cimag() are used and declared in the ccomplex.i interface!
 */
extern "C" {double _Complex conj(double _Complex);float _Complex conjf(float _Complex);}
#else
/* c99 complex not supported - super hack tests to just test plain floating point numbers */
/* some pre c99 compilers (gcc-4.x) don't define _Complex but do define complex */
#define _Complex
#if !defined(complex)
#  define complex
#endif
#define conj
#define conjf
#define creal
#define cimag
#if defined(I)
#  undef I
#  define I 1
#endif
#define HAS_C99_COMPLEX_FOR_TESTING 0
#endif
%}

%inline %{
static const float _Complex CPLX_CONSTANT_ = 0;
%}
%constant CPLX_CONSTANT = CPLX_CONSTANT_;

%inline
{
  int has_c99_complex(void) {
    return HAS_C99_COMPLEX_FOR_TESTING;
  }

  complex double Conj(complex double a)
  {
    return conj(a);
  }


  complex float Conjf(complex float a)
  {
    return conjf(a);
  }


  double complex Conj1(double complex a)
  {
    return conj(a);
  }


  float complex Conjf1(float complex a)
  {
    return conjf(a);
  }


  _Complex double Conj2(_Complex double a)
  {
    return conj(a);
  }


  _Complex float Conjf2(_Complex float a)
  {
    return conjf(a);
  }


  double _Complex Conj3(double _Complex a)
  {
    return conj(a);
  }


  float _Complex Conjf3(float _Complex a)
  {
    return conjf(a);
  }

  float _Complex getComplexConstant()
  {
    return CPLX_CONSTANT_;
  }
}
