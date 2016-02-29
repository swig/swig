%define DECLARE_INTERFACE_(INTERFACE, CTYPE...)
%feature("interface", name="INTERFACE") CTYPE;
//%feature("interface", name="%(rstrip:[Impl])s") CTYPE;
//%feature("interface", name="%(regex:/(.*)Impl$/\\1/)s") CTYPE;
%typemap(jtype) CTYPE, CTYPE *, CTYPE *const&, CTYPE [], CTYPE & "long"
%typemap(jstype) CTYPE "$&javainterfacename"
%typemap(jstype) CTYPE *, CTYPE [], CTYPE & "$javainterfacename"
%typemap(jstype) CTYPE *const& "$*javainterfacename"
%typemap(javain) CTYPE, CTYPE & "$javainput." ## #INTERFACE ## "_GetInterfaceCPtr()"
%typemap(javain) CTYPE *, CTYPE *const&, CTYPE [] "($javainput == null) ? 0 : $javainput." ## #INTERFACE ## "_GetInterfaceCPtr()"
%typemap(javaout) CTYPE {
    return ($&javainterfacename)new $&javaclassname($jnicall, true);
  }
%typemap(javaout) CTYPE & {
    return ($javainterfacename)new $javaclassname($jnicall, $owner);
  }
%typemap(javaout) CTYPE *, CTYPE [] {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : ($javainterfacename)new $javaclassname(cPtr, $owner);
  }
%typemap(javaout) CTYPE *const& {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : ($javainterfacename)new $javaclassname(cPtr, $owner);
  }

%typemap(javadirectorin) CTYPE "($&javainterfacename)new $&javaclassname($jniinput, false)"
%typemap(javadirectorin) CTYPE & "($javainterfacename)new $javaclassname($jniinput, false)"
%typemap(javadirectorin) CTYPE *, CTYPE [] "($jniinput == 0) ? null : ($javainterfacename)new $javaclassname($jniinput, false)"
%typemap(javadirectorin) CTYPE *const& "($jniinput == 0) ? null : ($*javainterfacename)new $*javaclassname($jniinput, false)"
%typemap(javadirectorout) CTYPE, CTYPE *, CTYPE *const&, CTYPE [], CTYPE & "$javacall." ## #INTERFACE ## "_GetInterfaceCPtr()"
%typemap(directorin,descriptor="L$packagepath/$&javainterfacename;") CTYPE
%{ $input = 0;
   *(($&1_ltype*)&$input) = &$1; %}
%typemap(directorin,descriptor="L$packagepath/$javainterfacename;") CTYPE *, CTYPE []
%{ *(($&1_ltype)&$input) = ($1_ltype) $1; %}
%typemap(directorin,descriptor="L$packagepath/$javainterfacename;") CTYPE &
%{ *($&1_ltype)&$input = ($1_ltype) &$1; %}
%typemap(directorin,descriptor="L$packagepath/$*javainterfacename;") CTYPE *const&
%{ *($&1_ltype)&$input = ($1_ltype) &$1; %}

%typemap(javainterfacecode, declaration="  long " ## #INTERFACE ## "_GetInterfaceCPtr();\n", cptrmethod=#INTERFACE ## "_GetInterfaceCPtr") CTYPE %{
  public long INTERFACE##_GetInterfaceCPtr() {
    return $imclassname.$javaclazzname##INTERFACE##_GetInterfaceCPtr(swigCPtr);
  }
%}
%enddef

%define DECLARE_INTERFACE_RENAME(INTERFACE, IMPL, CTYPE...)
%rename (IMPL) CTYPE;
DECLARE_INTERFACE_(INTERFACE, CTYPE)
%enddef

%define DECLARE_INTERFACE(INTERFACE, CTYPE...)
DECLARE_INTERFACE_(INTERFACE, CTYPE)
%enddef

