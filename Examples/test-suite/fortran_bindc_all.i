%module fortran_bindc_all

%{
#include <stdlib.h>
%}

// Give *all* types the struct typemap by default
%fortranbindc_type(SWIGTYPE);
// Apply the "bindc" feature to everything
%fortranbindc "1";

// XXX Ideally %ignore should be applied to DBmrgtree...
%ignore _DBmrgtree;
// ... because the typemap does
%apply void * {DBmrgtree*};
// (although fully specifying does as well)
%apply void * { struct _DBmrgtree* };


%inline %{
typedef struct _DBmrgtree {
    int should_be_ignored[sizeof(double)];
} DBmrgtree;

void do_something(DBmrgtree* dbm) { dbm->should_be_ignored[1] = 2; }
void do_something_else(struct _DBmrgtree* dbm) { dbm->should_be_ignored[1] = 2; }
%}
