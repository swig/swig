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
}

using nspace1::AffineMatrix;
using nspace1::CacheView;

int fn1(AffineMatrix a) { return a.x; };
int fn2(CacheView a) { return a.x; };
%}