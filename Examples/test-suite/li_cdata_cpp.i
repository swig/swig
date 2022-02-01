%module li_cdata_cpp

%include <cdata.i>

%cdata(int);
%cdata(double);

%{
#include <stdlib.h>
%}

void *malloc(size_t size);
