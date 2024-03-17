%module cpp11_using_typedef_struct

%inline 
%{
namespace nspace1 {
  typedef struct _xAffineMatrix {
    int x, y, z;
  } AffineMatrix;

  struct xCacheView {
    int x;
  };
  typedef struct xCacheView CacheView;

  struct _xAbstract;
  typedef struct _xAbstract Abstract;
}

using nspace1::AffineMatrix;
using nspace1::CacheView;
// Check that `typename` disambiguator parses.  Regression test for
// https://github.com/swig/swig/issues/1032 fixed in SWIG 4.2.0.
// Note: `typename` is not needed here, but should be accepted.
using typename nspace1::Abstract;

void _internal(const Abstract *) {}

int fn1(AffineMatrix a) { return a.x; };
int fn2(CacheView a) { return a.x; };
int fn3(Abstract *a) { _internal(a); return 0; };
int fn4(const Abstract *a) { _internal(a); return 0; };
%}
