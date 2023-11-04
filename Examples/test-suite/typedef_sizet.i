%module typedef_sizet

#ifdef SWIGFORTRAN
// Avoid shadowing intrinsic size
%rename("identity_size") size;
#endif

typedef unsigned long long size_t;
%inline %{
size_t size(size_t x) {return x; }
%}
