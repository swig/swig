%module complextest_c

%include <complex.i>

/* NOTE: SWIG's parser defines 'complex' as a builtin, whereas it should define
 * _Complex and then have `ccomplex.i` add `#define complex _Complex`. */

%inline
{
  double _Complex Conj(double _Complex a)
  {
    return conj(a);
  }

  /* complex should alias to _Complex when including <complex.h> */
  double complex Conj2(double complex a)
  {
    return conj(a);
  }


  float _Complex Conjf(float _Complex a)
  {
    return conj(a);
  }
}


