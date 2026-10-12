%module clientdata_teardown_a

%{
#include "clientdata_teardown.h"
%}

%import "clientdata_teardown_b.i"

%inline %{
int use_counted(Counted *c) { return c ? c->get() : -1; }
%}
