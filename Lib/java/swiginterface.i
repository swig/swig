/* -----------------------------------------------------------------------------
 * swiginterface.i
 *
 * SWIG interface feature and typemaps implementation providing:
 *   %interface
 *   %interface_impl
 *   %interface_custom
 * ----------------------------------------------------------------------------- */

%define INTERFACE_TYPEMAPS(CTYPE...)
%typemap(jstype) CTYPE "$&javainterfacename"
%typemap(javain) CTYPE "$javainput.$&interfacename_GetInterfaceCPtr()"
%typemap(javain) CTYPE & "$javainput.$interfacename_GetInterfaceCPtr()"
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(jtype) CTYPE, CTYPE *, CTYPE *const&, CTYPE [], CTYPE & "long"
%typemap(jstype) CTYPE *, CTYPE [], CTYPE & "$javainterfacename"
%typemap(jstype) CTYPE *const& "$*javainterfacename"
%typemap(javain) CTYPE *, CTYPE [] "($javainput == null) ? 0 : $javainput.$interfacename_GetInterfaceCPtr()"
%typemap(javain) CTYPE *const& "($javainput == null) ? 0 : $javainput.$*interfacename_GetInterfaceCPtr()"
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
    return (cPtr == 0) ? null : ($*javainterfacename)new $*javaclassname(cPtr, $owner);
  }

%typemap(javadirectorin) CTYPE "($&javainterfacename)new $&javaclassname($jniinput, true)"
%typemap(javadirectorin) CTYPE & "($javainterfacename)new $javaclassname($jniinput, false)"
%typemap(javadirectorin) CTYPE *, CTYPE [] "($jniinput == 0) ? null : ($javainterfacename)new $javaclassname($jniinput, false)"
%typemap(javadirectorin) CTYPE *const& "($jniinput == 0) ? null : ($*javainterfacename)new $*javaclassname($jniinput, false)"
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(jtype) CTYPE, CTYPE *, CTYPE *const&, CTYPE [], CTYPE & "Long"
%typemap(jstype) CTYPE *, CTYPE [] "$javainterfacename?"
%typemap(jstype) CTYPE & "$javainterfacename"
%typemap(jstype) CTYPE *const& "$*javainterfacename?"
%typemap(javain) CTYPE *, CTYPE [] "if ($javainput == null) 0L else $javainput.$interfacename_GetInterfaceCPtr()"
%typemap(javain) CTYPE *const& "if ($javainput == null) 0L else $javainput.$*interfacename_GetInterfaceCPtr()"
%typemap(javaout) CTYPE {
    return $&javaclassname($jnicall, true)
  }
%typemap(javaout) CTYPE & {
    return $javaclassname($jnicall, $owner)
  }
%typemap(javaout) CTYPE *, CTYPE [] {
    val cPtr = $jnicall
    return if (cPtr == 0L) null else $javaclassname(cPtr, $owner)
  }
%typemap(javaout) CTYPE *const& {
    val cPtr = $jnicall
    return if (cPtr == 0L) null else $*javaclassname(cPtr, $owner)
  }

%typemap(javadirectorin) CTYPE "$&javaclassname($jniinput, true)"
%typemap(javadirectorin) CTYPE & "$javaclassname($jniinput, false)"
%typemap(javadirectorin) CTYPE *, CTYPE [] "if ($jniinput == 0L) null else $javaclassname($jniinput, false)"
%typemap(javadirectorin) CTYPE *const& "if ($jniinput == 0L) null else $*javaclassname($jniinput, false)"
#endif /* SWIGJAVA_TARGET */
%typemap(javadirectorout) CTYPE "$javacall.$&interfacename_GetInterfaceCPtr()"
%typemap(javadirectorout) CTYPE *, CTYPE [], CTYPE & "$javacall.$interfacename_GetInterfaceCPtr()"
%typemap(javadirectorout) CTYPE *const& "$javacall.$*interfacename_GetInterfaceCPtr()"
%typemap(directorin,descriptor="L$packagepath/$&javainterfacename;") CTYPE
%{ $input = 0;
   *(($&1_ltype*)&$input) = new $1_ltype(SWIG_STD_MOVE($1)); %}
%typemap(directorin,descriptor="L$packagepath/$javainterfacename;") CTYPE *, CTYPE []
%{ *(($&1_ltype)&$input) = ($1_ltype) $1; %}
%typemap(directorin,descriptor="L$packagepath/$javainterfacename;") CTYPE &
%{ *($&1_ltype)&$input = ($1_ltype) &$1; %}
%typemap(directorin,descriptor="L$packagepath/$*javainterfacename;") CTYPE *const&
%{ *($&1_ltype)&$input = ($1_ltype) &$1; %}

#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javainterfacecode, declaration="  long $interfacename_GetInterfaceCPtr();\n", cptrmethod="$interfacename_GetInterfaceCPtr") CTYPE %{
  public long $interfacename_GetInterfaceCPtr() {
    return $imclassname.$javaclazzname$interfacename_GetInterfaceCPtr(swigCPtr);
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javainterfacecode, declaration="  fun $interfacename_GetInterfaceCPtr(): Long\n", cptrmethod="$interfacename_GetInterfaceCPtr") CTYPE %{
  override fun $interfacename_GetInterfaceCPtr(): Long {
    return $imclassname.$javaclazzname$interfacename_GetInterfaceCPtr(swigCPtr)
  }
%}
#endif /* SWIGJAVA_TARGET */
%enddef

%define %interface(CTYPE...)
%feature("interface", name="%sSwigInterface") CTYPE;
INTERFACE_TYPEMAPS(CTYPE)
%enddef

%define %interface_impl(CTYPE...)
%rename("%sSwigImpl") CTYPE;
%feature("interface", name="%(rstrip:[SwigImpl])s") CTYPE;
INTERFACE_TYPEMAPS(CTYPE)
%enddef

%define %interface_custom(PROXY, INTERFACE, CTYPE...)
%rename(PROXY) CTYPE;
%feature("interface", name=INTERFACE) CTYPE;
INTERFACE_TYPEMAPS(CTYPE)
%enddef

%define %interface_additional(PROXY, INTERFACE, ADDITIONAL, CTYPE...)
%rename(PROXY) CTYPE;
%feature("interface", name=INTERFACE, additional=ADDITIONAL) CTYPE;
INTERFACE_TYPEMAPS(CTYPE)
%enddef
