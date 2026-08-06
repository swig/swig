%module swift_import_inherit_b

// Derived module: imports the base module and derives a class whose constructor
// is inherited across the module boundary.  Without cross-module override
// detection the generated Swift "init(id:)" would be emitted without "override"
// and fail to compile against the imported base.

%import(module="swift_import_inherit_a") "swift_import_inherit_a.h"

%{
#include "swift_import_inherit_b.h"
%}

%include "swift_import_inherit_b.h"
