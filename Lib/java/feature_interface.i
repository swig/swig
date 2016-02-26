%define DECLARE_INTERFACE_(INTERFACE, CTYPE...)
%feature("interface", name="INTERFACE") CTYPE;
%typemap(jtype) CTYPE, CTYPE *, CTYPE *const&, CTYPE [], CTYPE & "long"
%typemap(jstype) CTYPE "$&interfacename"
%typemap(jstype) CTYPE *, CTYPE [], CTYPE & "$interfacename"
%typemap(jstype) CTYPE *const& "$*interfacename"
%typemap(javain) CTYPE, CTYPE & "$javainput." ## #INTERFACE ## "_SWIGInterfaceUpcast()"
%typemap(javain) CTYPE *, CTYPE *const&, CTYPE [] "($javainput == null) ? 0 : $javainput." ## #INTERFACE ## "_SWIGInterfaceUpcast()"
%typemap(javaout) CTYPE {
    return ($&interfacename)new $&javaclassname($jnicall, true);
  }
%typemap(javaout) CTYPE & {
    return ($interfacename)new $javaclassname($jnicall, $owner);
  }
%typemap(javaout) CTYPE *, CTYPE [] {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : ($interfacename)new $javaclassname(cPtr, $owner);
  }
%typemap(javaout) CTYPE *const& {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : ($interfacename)new $javaclassname(cPtr, $owner);
  }

%typemap(javadirectorin) CTYPE "($&interfacename)new $&javaclassname($jniinput, false)"
%typemap(javadirectorin) CTYPE & "($interfacename)new $javaclassname($jniinput, false)"
%typemap(javadirectorin) CTYPE *, CTYPE [] "($jniinput == 0) ? null : ($interfacename)new $javaclassname($jniinput, false)"
%typemap(javadirectorin) CTYPE *const& "($jniinput == 0) ? null : ($*interfacename)new $*javaclassname($jniinput, false)"
%typemap(javadirectorout) CTYPE, CTYPE *, CTYPE *const&, CTYPE [], CTYPE & "$javacall." ## #INTERFACE ## "_SWIGInterfaceUpcast()"
%typemap(directorin,descriptor="L$packagepath/$&interfacename;") CTYPE
%{ $input = 0;
   *(($&1_ltype*)&$input) = &$1; %}
%typemap(directorin,descriptor="L$packagepath/$interfacename;") CTYPE *, CTYPE []
%{ *(($&1_ltype)&$input) = ($1_ltype) $1; %}
%typemap(directorin,descriptor="L$packagepath/$interfacename;") CTYPE &
%{ *($&1_ltype)&$input = ($1_ltype) &$1; %}
%typemap(directorin,descriptor="L$packagepath/$*interfacename;") CTYPE *const&
%{ *($&1_ltype)&$input = ($1_ltype) &$1; %}

%typemap(javainterfacecode, declaration="  long " ## #INTERFACE ## "_SWIGInterfaceUpcast();\n", cptrmethod=#INTERFACE ## "_SWIGInterfaceUpcast") CTYPE %{
  public long INTERFACE##_SWIGInterfaceUpcast() {
    return $imclassname.$javaclazzname##INTERFACE##_SWIGInterfaceUpcast(swigCPtr);
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

