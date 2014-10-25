/* -----------------------------------------------------------------------------
 * enums.swg
 *
 * Include this file in order for C/C++ enums to be wrapped by Python classes.
 * ----------------------------------------------------------------------------- */

%clear enum SWIGTYPE;
%clear const enum SWIGTYPE&;
%clear const enum SWIGTYPE&&;

// In contrast to standard constcode typemap, this one creates new copy of the
// object. We have to do this, as our $value may be a symbol representing enum
// value, which has no adress (so usual method with %as_voidptr, would not
// work). We could still use %as_voidptr(...) when $value is a C++ variable
// (wrapped with %constant, for example), but at this moment I have no idea of
// how to distinguish both cases.
%typemap(constcode,noblock=1) enum SWIGTYPE {
  %set_constant("$symname", SWIG_NewPointerObj(%new_copy($value, $type), $&descriptor, %newpointer_flags));
}

#define %pythonenumstrong %feature("python:enum:strong")
#define %pythonenumscoped %feature("python:enum:scoped")
#define %pythonenumclass %feature("python:enum",strong=1,scoped=1)
