%module python_annotations_import_b

// Tests that $pytypename on a class defined in an imported module expands to a
// module-qualified name (python_annotations_import_a.Klass), not a bare "Klass".
// See getProxyClassLocalName() in Source/Modules/python.cxx.
//
// NOTE: these are plain modules (no %module(package=...)). A packaged module cannot be
// used here because the test harness has no package-directory scaffolding to import one
// at runtime, so a packaged multi-module Python test cannot run a runme. This test
// therefore checks the module-name qualification but not the package prefix
// (Package.module.Class), which is verified manually.
%feature("python:annotations", "typing");

%{
#include "python_annotations_import.h"
%}

%import(module="python_annotations_import_a") "python_annotations_import_a.i"

// Opt in to a proxy-name annotation for the imported class, exercising $pytypename
// across a cross-module %import.
%typemap(pytyping) Klass * "typing.Optional[$pytypename]";

%inline %{
#ifdef SWIGPYTHON_BUILTIN
int is_python_builtin() { return 1; }
#else
int is_python_builtin() { return 0; }
#endif

#if defined SWIGPYTHON_FASTPROXY
int is_python_fastproxy() { return 1; }
#else
int is_python_fastproxy() { return 0; }
#endif

void use_imported(Klass *k) { (void)k; }
%}
