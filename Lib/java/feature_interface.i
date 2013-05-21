%define DECLARE_INTERFACE_(CTYPE, INTERFACE, IMPL)
%feature("interface", name = "INTERFACE", cptr = #INTERFACE ## "_getCPtr") CTYPE;
%typemap(jstype) CTYPE*, const CTYPE& "INTERFACE"
%typemap(jtype, nopgcpp="1") CTYPE*, const CTYPE& "long"
%typemap(javadirectorout) CTYPE*, const CTYPE& "$javacall." ## #INTERFACE ## "_getCPtr()"
%typemap(javadirectorin) CTYPE*, const CTYPE&
%{
  long cPtr = $jniinput;
	return (cPtr == 0) ? null : (INTERFACE)new IMPL(cPtr,false)
%}
%typemap(javain) CTYPE*, const CTYPE& "$javainput." ## #INTERFACE ## "_getCPtr()"
%typemap(javaout) CTYPE*, const CTYPE&
{ 
  long cPtr = $jnicall;
  return (cPtr == 0) ? null : (INTERFACE)new IMPL(cPtr,true); 
}
SWIG_JAVABODY_PROXY(public, protected, CTYPE)
%enddef

%define DECLARE_INTERFACE_RENAME(CTYPE, INTERFACE, IMPL)
%rename (IMPL) CTYPE;
DECLARE_INTERFACE_(CTYPE, INTERFACE, IMPL)
%enddef

%define DECLARE_INTERFACE(CTYPE, INTERFACE)
DECLARE_INTERFACE_(CTYPE, INTERFACE, CTYPE)
%enddef

