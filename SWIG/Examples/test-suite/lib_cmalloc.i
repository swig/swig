%module lib_cmalloc

%include "cmalloc.i"

%allocators(int);
%allocators(double);
%allocators(void);
%allocators(int *, intp);
