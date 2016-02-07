%define DECLARE_INTERFACE_(CTYPE, INTERFACE, IMPL)
%feature("interface", name = "INTERFACE", cptr = #INTERFACE ## "_getCPtr") CTYPE;
%typemap(jtype, nopgcpp="1") CTYPE, CTYPE *, CTYPE *const&, CTYPE [], CTYPE & "long"
%typemap(jstype) CTYPE, CTYPE *, CTYPE *const&, CTYPE [], CTYPE & "INTERFACE"
%typemap(javain) CTYPE, CTYPE & "$javainput." ## #INTERFACE ## "_getCPtr()"
%typemap(javain) CTYPE *, CTYPE *const&, CTYPE [] "($javainput == null) ? 0 : $javainput." ## #INTERFACE ## "_getCPtr()"
%typemap(javaout) CTYPE {
    return (INTERFACE)new IMPL($jnicall, true);
  }
%typemap(javaout) CTYPE & {
    return (INTERFACE)new IMPL($jnicall, $owner);
  }
%typemap(javaout) CTYPE *, CTYPE *const&, CTYPE [] {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : (INTERFACE)new IMPL(cPtr, $owner);
  }
%typemap(javadirectorin) CTYPE, CTYPE & "(INTERFACE)new IMPL($jniinput, false)"
%typemap(javadirectorin) CTYPE *, CTYPE *const&, CTYPE [] "($jniinput == 0) ? null : (INTERFACE)new IMPL($jniinput, false)"
%typemap(javadirectorout) CTYPE, CTYPE *, CTYPE *const&, CTYPE [], CTYPE & "$javacall." ## #INTERFACE ## "_getCPtr()"
SWIG_JAVABODY_PROXY(public, protected, CTYPE)
%enddef

%define DECLARE_INTERFACE_RENAME(CTYPE, INTERFACE, IMPL)
%rename (IMPL) CTYPE;
DECLARE_INTERFACE_(CTYPE, INTERFACE, IMPL)
%enddef

%define DECLARE_INTERFACE(CTYPE, INTERFACE)
DECLARE_INTERFACE_(CTYPE, INTERFACE, CTYPE)
%enddef

