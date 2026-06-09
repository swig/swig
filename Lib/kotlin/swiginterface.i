/* -----------------------------------------------------------------------------
 * swiginterface.i
 *
 * SWIG interface feature and typemaps implementation providing:
 *   %interface
 *   %interface_impl
 *   %interface_custom
 * ----------------------------------------------------------------------------- */

%define INTERFACE_TYPEMAPS(CTYPE...)
%typemap(ktype) CTYPE, CTYPE *, CTYPE *const&, CTYPE [], CTYPE & "Long"
%typemap(kstype) CTYPE "$&kotlininterfacename"
%typemap(kstype) CTYPE *, CTYPE [] "$kotlininterfacename?"
%typemap(kstype) CTYPE & "$kotlininterfacename"
%typemap(kstype) CTYPE *const& "$*kotlininterfacename?"
%typemap(kin) CTYPE "$kotlininput.$&interfacename_GetInterfaceCPtr()"
%typemap(kin) CTYPE & "$kotlininput.$interfacename_GetInterfaceCPtr()"
%typemap(kin) CTYPE *, CTYPE [] "if ($kotlininput == null) 0L else $kotlininput.$interfacename_GetInterfaceCPtr()"
%typemap(kin) CTYPE *const& "if ($kotlininput == null) 0L else $kotlininput.$*interfacename_GetInterfaceCPtr()"
%typemap(kout) CTYPE {
    return $&kotlinclassname($jnicall, true)
  }
%typemap(kout) CTYPE & {
    return $kotlinclassname($jnicall, $owner)
  }
%typemap(kout) CTYPE *, CTYPE [] {
    val cPtr = $jnicall
    return if (cPtr == 0L) null else $kotlinclassname(cPtr, $owner)
  }
%typemap(kout) CTYPE *const& {
    val cPtr = $jnicall
    return if (cPtr == 0L) null else $*kotlinclassname(cPtr, $owner)
  }

%typemap(kdirectorin) CTYPE "$&kotlinclassname($jniinput, true)"
%typemap(kdirectorin) CTYPE & "$kotlinclassname($jniinput, false)"
%typemap(kdirectorin) CTYPE *, CTYPE [] "if ($jniinput == 0L) null else $kotlinclassname($jniinput, false)"
%typemap(kdirectorin) CTYPE *const& "if ($jniinput == 0L) null else $*kotlinclassname($jniinput, false)"
%typemap(kdirectorout) CTYPE "$kotlincall.$&interfacename_GetInterfaceCPtr()"
%typemap(kdirectorout) CTYPE *, CTYPE [], CTYPE & "$kotlincall.$interfacename_GetInterfaceCPtr()"
%typemap(kdirectorout) CTYPE *const& "$kotlincall.$*interfacename_GetInterfaceCPtr()"
%typemap(directorin,descriptor="L$packagepath/$&kotlininterfacename;") CTYPE
%{ $input = 0;
   *(($&1_ltype*)&$input) = new $1_ltype(SWIG_STD_MOVE($1)); %}
%typemap(directorin,descriptor="L$packagepath/$kotlininterfacename;") CTYPE *, CTYPE []
%{ *(($&1_ltype)&$input) = ($1_ltype) $1; %}
%typemap(directorin,descriptor="L$packagepath/$kotlininterfacename;") CTYPE &
%{ *($&1_ltype)&$input = ($1_ltype) &$1; %}
%typemap(directorin,descriptor="L$packagepath/$*kotlininterfacename;") CTYPE *const&
%{ *($&1_ltype)&$input = ($1_ltype) &$1; %}

%typemap(kinterfacecode, declaration="  fun $interfacename_GetInterfaceCPtr(): Long\n", cptrmethod="$interfacename_GetInterfaceCPtr") CTYPE %{
  override fun $interfacename_GetInterfaceCPtr(): Long {
    return $imclassname.$kotlinclazzname$interfacename_GetInterfaceCPtr(swigCPtr)
  }
%}
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
