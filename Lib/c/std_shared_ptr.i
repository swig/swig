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

// Typemap for smart pointer type itself: these are somewhat special because we represent empty shared pointers as null pointers at C level because there is
// no advantage in using a non-null pointer in this case, while testing for NULL is much simpler than testing whether a shared pointer is empty.
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > empty) %{
  $1 = $input ? *(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr<CONST TYPE>*)$input : empty; %}

%typemap(in) const SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >& (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > empty) %{
  $1 = $input ? (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr<CONST TYPE>*)$input : &empty; %}

// Note that "&" here is required because "$1" ends up being SwigValueWrapper and not the shared pointer itself. This is wrong and should be fixed by disabling
// the use of SwigValueWrapper for shared pointers entirely, as it's never needed for them.
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > %{  $result = (&$1 ? new $1_ltype($1) : 0); %}

// Use of "*" here is due to the fact that "$1" is a pointer, but we want to test the smart pointer itself.
%typemap(out) const SWIG_SHARED_PTR_QNAMESPACE::shared_ptr<CONST TYPE>& %{  $result = (*$1 ? $1 : 0); %}

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

// Allow creating null shared pointers and testing them for validity.
%typemap(cxxcode) TYPE %{
  static $cxxclassname null() { return $cxxclassname{($cclassptrname)nullptr, false}; }
  explicit operator bool() const { return swig_self_ != nullptr; }
%}

// This is required to handle overloads on shared_ptr/normal type correctly.
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER, equivalent="TYPE *")
  TYPE CONST,
  TYPE CONST &,
  TYPE CONST *,
  TYPE *CONST&,
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
  ""

%enddef

%include <shared_ptr.i>
