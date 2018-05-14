%module cpp17_nspace_nested_namespaces

#if defined(SWIGJAVA)
SWIG_JAVABODY_PROXY(public, public, SWIGTYPE)
#endif

// nspace feature only supported by these languages
#if defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGD) || defined(SWIGLUA) || defined(SWIGJAVASCRIPT)
%nspace;
#endif


%include "cpp17_nested_namespaces.i"
