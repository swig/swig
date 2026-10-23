%module python_nondynamic_import_b

// Tests that a nondynamic class can derive from a nondynamic class defined in
// another module: each module defines its own metaclass for these classes, so
// the derived class must use the one inherited from its base class.
%pythonnondynamic;

%{
#include "python_nondynamic_import.h"
%}

%import "python_nondynamic_import_a.i"

struct Derived : Base {
  int b;
};

%inline %{
#ifdef SWIGPYTHON_BUILTIN
int is_python_builtin() { return 1; }
#else
int is_python_builtin() { return 0; }
#endif
%}
