%module swift_import_inherit_a

// Base module for the swift_import_inherit cross-module test: a class with a
// parameterized constructor that a class in another module derives from.

%{
#include "swift_import_inherit_a.h"
%}

%include "swift_import_inherit_a.h"
