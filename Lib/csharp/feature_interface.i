%define DECLARE_INTERFACE_(INTERFACE, CTYPE...)
%feature("interface", name="INTERFACE") CTYPE;
%typemap(cstype) CTYPE "$&interfacename"
%typemap(cstype) CTYPE *, CTYPE [], CTYPE & "$interfacename"
%typemap(cstype) CTYPE *const& "$*interfacename"
%typemap(csin) CTYPE, CTYPE & "$csinput.SWIGInterfaceUpcast()"
%typemap(csin) CTYPE *, CTYPE *const&, CTYPE [] "$csinput == null ? new global::System.Runtime.InteropServices.HandleRef(null, global::System.IntPtr.Zero) : $csinput.SWIGInterfaceUpcast()"
%typemap(csout, excode=SWIGEXCODE) CTYPE {
    $&csclassname ret = new $&csclassname($imcall, true);$excode
    return ($&interfacename)ret;
  }
%typemap(csout, excode=SWIGEXCODE) CTYPE & {
    $csclassname ret = new $csclassname($imcall, $owner);$excode
    return ($interfacename)ret;
  }
%typemap(csout, excode=SWIGEXCODE) CTYPE *, CTYPE [] {
    global::System.IntPtr cPtr = $imcall;
    $csclassname ret = (cPtr == global::System.IntPtr.Zero) ? null : new $csclassname(cPtr, $owner);$excode
    return ($interfacename)ret;
  }
%typemap(csout, excode=SWIGEXCODE) CTYPE *const& {
    global::System.IntPtr cPtr = $imcall;
    $*csclassname ret = (cPtr == global::System.IntPtr.Zero) ? null : new $*csclassname(cPtr, $owner);$excode
    return ($*interfacename)ret;
  }
%typemap(csdirectorin) CTYPE "($&interfacename)new $&csclassname($iminput, false)"
%typemap(csdirectorin) CTYPE & "($interfacename)new $csclassname($iminput, false)"
%typemap(csdirectorin) CTYPE *, CTYPE [] "($iminput == global::System.IntPtr.Zero) ? null : ($interfacename)new $csclassname($iminput, false)"
%typemap(csdirectorin) CTYPE *const& "($iminput == global::System.IntPtr.Zero) ? null : ($*interfacename)new $*csclassname($iminput, false)"
%typemap(csdirectorout) CTYPE, CTYPE *, CTYPE *const&, CTYPE [], CTYPE & "$cscall.SWIGInterfaceUpcast()"
%typemap(csinterfacecode, declaration="  [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]\n  global::System.Runtime.InteropServices.HandleRef SWIGInterfaceUpcast();\n", cptrmethod=#INTERFACE##"_SWIGInterfaceUpcast") CTYPE %{
  [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]
  global::System.Runtime.InteropServices.HandleRef INTERFACE.SWIGInterfaceUpcast() {
    return new global::System.Runtime.InteropServices.HandleRef(this, $imclassname.$csclazzname##INTERFACE##_SWIGInterfaceUpcast(swigCPtr.Handle));
  }
%}
%enddef

%define DECLARE_INTERFACE_RENAME(INTERFACE, IMPL, CTYPE...)
%rename (IMPL) CTYPE;
DECLARE_INTERFACE_(INTERFACE, CTYPE)
%enddef

%define DECLARE_INTERFACE(INTERFACE, CTYPE...)
DECLARE_INTERFACE_(INTERFACE, CTYPE, CTYPE)
%enddef

