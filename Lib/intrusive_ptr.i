// intrusive_ptr namespaces could be boost or std or std::tr1
#if !defined(SWIG_INTRUSIVE_PTR_NAMESPACE)
# define SWIG_INTRUSIVE_PTR_NAMESPACE boost
#endif

#if defined(SWIG_INTRUSIVE_PTR_SUBNAMESPACE)
# define SWIG_INTRUSIVE_PTR_QNAMESPACE SWIG_INTRUSIVE_PTR_NAMESPACE::SWIG_INTRUSIVE_PTR_SUBNAMESPACE
#else
# define SWIG_INTRUSIVE_PTR_QNAMESPACE SWIG_INTRUSIVE_PTR_NAMESPACE
#endif

namespace SWIG_INTRUSIVE_PTR_NAMESPACE {
#if defined(SWIG_INTRUSIVE_PTR_SUBNAMESPACE)
  namespace SWIG_INTRUSIVE_PTR_SUBNAMESPACE {
#endif
    template <class T> class shared_ptr {
    };
    
    template <class T> class intrusive_ptr {
    };
#if defined(SWIG_INTRUSIVE_PTR_SUBNAMESPACE)
  }
#endif
}

%inline %{
  #include "boost/shared_ptr.hpp"
%}

%fragment("SWIG_intrusive_deleter", "header") {
template<class T> struct SWIG_intrusive_deleter
{
    void operator()(T * p)
    {
        if(p) intrusive_ptr_release(p);
    }
};
}

%fragment("SWIG_null_deleter", "header") {
struct SWIG_null_deleter {
  void operator() (void const *) const {
  }
};
%#define SWIG_NO_NULL_DELETER_0 , SWIG_null_deleter()
%#define SWIG_NO_NULL_DELETER_1
}

// Main user macro for defining intrusive_ptr typemaps for both const and non-const pointer types
// For plain classes, do not use for derived classes
%define SWIG_INTRUSIVE_PTR(PROXYCLASS, TYPE...)
SWIG_INTRUSIVE_PTR_TYPEMAPS(PROXYCLASS, , TYPE)
SWIG_INTRUSIVE_PTR_TYPEMAPS(PROXYCLASS, const, TYPE)
%enddef

// Main user macro for defining intrusive_ptr typemaps for both const and non-const pointer types
// For derived classes
%define SWIG_INTRUSIVE_PTR_DERIVED(PROXYCLASS, BASECLASSTYPE, TYPE...)
SWIG_INTRUSIVE_PTR_TYPEMAPS(PROXYCLASS, , TYPE)
SWIG_INTRUSIVE_PTR_TYPEMAPS(PROXYCLASS, const, TYPE)
%types(SWIG_INTRUSIVE_PTR_NAMESPACE::shared_ptr< TYPE > = SWIG_INTRUSIVE_PTR_NAMESPACE::shared_ptr< BASECLASSTYPE >) %{
  *newmemory = SWIG_CAST_NEW_MEMORY;
  return (void *) new SWIG_INTRUSIVE_PTR_NAMESPACE::shared_ptr< BASECLASSTYPE >(*(SWIG_INTRUSIVE_PTR_NAMESPACE::shared_ptr< TYPE > *)$from);
  %}
%extend TYPE {
  static SWIG_INTRUSIVE_PTR_NAMESPACE::shared_ptr< BASECLASSTYPE > SWIGSharedPtrUpcast(SWIG_INTRUSIVE_PTR_NAMESPACE::shared_ptr< TYPE > swigSharedPtrUpcast) {
    return swigSharedPtrUpcast;
  }
}
%enddef

// Extra user macro for including classes in intrusive_ptr typemaps for both const and non-const pointer types
// This caters for classes which cannot be wrapped by intrusive_ptrs but are still part of the class hierarchy
// For plain classes, do not use for derived classes
%define SWIG_INTRUSIVE_PTR_NO_WRAP(PROXYCLASS, TYPE...)
SWIG_INTRUSIVE_PTR_TYPEMAPS_NO_WRAP(PROXYCLASS, , TYPE)
SWIG_INTRUSIVE_PTR_TYPEMAPS_NO_WRAP(PROXYCLASS, const, TYPE)
%enddef

// Extra user macro for including classes in intrusive_ptr typemaps for both const and non-const pointer types
// This caters for classes which cannot be wrapped by intrusive_ptrs but are still part of the class hierarchy
// For derived classes
%define SWIG_INTRUSIVE_PTR_DERIVED_NO_WRAP(PROXYCLASS, BASECLASSTYPE, TYPE...)
SWIG_INTRUSIVE_PTR_TYPEMAPS_NO_WRAP(PROXYCLASS, , TYPE)
SWIG_INTRUSIVE_PTR_TYPEMAPS_NO_WRAP(PROXYCLASS, const, TYPE)
%types(SWIG_INTRUSIVE_PTR_NAMESPACE::shared_ptr< TYPE > = SWIG_INTRUSIVE_PTR_NAMESPACE::shared_ptr< BASECLASSTYPE >) %{
  *newmemory = SWIG_CAST_NEW_MEMORY;
  return (void *) new SWIG_INTRUSIVE_PTR_NAMESPACE::shared_ptr< BASECLASSTYPE >(*(SWIG_INTRUSIVE_PTR_NAMESPACE::shared_ptr< TYPE > *)$from);
  %}
%extend TYPE {
  static SWIG_INTRUSIVE_PTR_NAMESPACE::shared_ptr< BASECLASSTYPE > SWIGSharedPtrUpcast(SWIG_INTRUSIVE_PTR_NAMESPACE::shared_ptr< TYPE > swigSharedPtrUpcast) {
    return swigSharedPtrUpcast;
  }
}
%enddef


