// This could be predefined in e.g. our own boost_shared_ptr.i
#ifndef SWIG_SHARED_PTR_NAMESPACE
#define SWIG_SHARED_PTR_NAMESPACE std
#endif

%define SWIG_SHARED_PTR_TYPEMAPS(CONST, TYPE...)

%naturalvar TYPE;
%naturalvar SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;

// Replace the default "delete arg1" with the code destroying the smart pointer itself instead.
%feature("unref") TYPE "(void)arg1; delete smartarg1;"

// All smart pointers look like normal objects to the code using the interface.
%typemap(ctype) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >&,
                SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >*
                "$typemap(ctype, TYPE)";

// Typemap for smart pointer type itself.
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
  "$result = new $1_ltype($1);"

// And for the plain type.
%typemap(in) CONST TYPE (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr<CONST TYPE > *)$input;
  if (!smartarg || !smartarg->get()) {
    SWIG_exception(SWIG_RuntimeError, "$1_type value is null");
    return $null;
  }
  $1 = **smartarg;%}
%typemap(out) CONST TYPE %{
  $result = (SwigObj*) new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr<CONST TYPE >(new $1_ltype($1));%}

// Plain type pointer.
%typemap(in) CONST TYPE * (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr<CONST TYPE > *)$input;
  $1 = (TYPE *)(smartarg ? smartarg->get() : 0);%}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE * %{
  $result = $1 ? (SwigObj*) new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr<CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner) : 0;%}

// Plain type references.
%typemap(in) CONST TYPE & (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr<CONST TYPE > *)$input;
  if (!smartarg || !smartarg->get()) {
    SWIG_exception(SWIG_RuntimeError, "$1_type reference is null");
    return $null;
  }
  $1 = (TYPE *)smartarg->get();%}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE & %{
  $result = (SwigObj*) new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr<CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner);%}

%enddef

%include <shared_ptr.i>
