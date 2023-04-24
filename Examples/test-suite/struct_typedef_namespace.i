%module typedefs

%inline 
%{
namespace nspace1 {
  typedef struct _AffineMatrix {
    int x, y, z;
  } AffineMatrix;

  struct _CacheView {
    int x;
  };
  typedef struct _CacheView CacheView;

  struct _Abstract {};
  typedef struct _Abstract Abstract;
}

using nspace1::AffineMatrix;
using nspace1::CacheView;
using nspace1::Abstract;

int fn1(AffineMatrix a) { return a.x; };
int fn2(CacheView a) { return a.x; };
int fn3(Abstract *a) { return 0; };
int fn4(const Abstract *a) { return 0; };
%}
