%module lib_cpointer
%include "cpointer.i"

%pointer_functions(int,intp);
%pointer_class(double,doublep);
%pointer_cast(int, unsigned int, int_to_uint);

