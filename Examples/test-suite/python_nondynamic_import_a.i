%module python_nondynamic_import_a

%pythonnondynamic;

%{
#include "python_nondynamic_import.h"
%}

struct Base {
  int a;
};
