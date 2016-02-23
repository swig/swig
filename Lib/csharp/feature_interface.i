%define DECLARE_INTERFACE_(INTERFACE, IMPL, CTYPE...)
%feature("interface", name="INTERFACE") CTYPE;
%typemap(cstype) CTYPE, CTYPE *, CTYPE [], CTYPE &, CTYPE *const& "INTERFACE"
%typemap(csin) CTYPE, CTYPE & "$csinput.SWIGInterfaceUpcast()"
%typemap(csin) CTYPE *, CTYPE *const&, CTYPE [] "$csinput == null ? new global::System.Runtime.InteropServices.HandleRef(null, global::System.IntPtr.Zero) : $csinput.SWIGInterfaceUpcast()"
%typemap(csout, excode=SWIGEXCODE) CTYPE {
    IMPL ret = new IMPL($imcall, true);$excode
    return (INTERFACE)ret;
  }
%typemap(csout, excode=SWIGEXCODE) CTYPE & {
    IMPL ret = new IMPL($imcall, $owner);$excode
    return (INTERFACE)ret;
  }
%typemap(csout, excode=SWIGEXCODE) CTYPE *, CTYPE *const&, CTYPE [] {
    global::System.IntPtr cPtr = $imcall;
    IMPL ret = (cPtr == global::System.IntPtr.Zero) ? null : new IMPL(cPtr, $owner);$excode
    return (INTERFACE)ret;
  }
%typemap(csdirectorin) CTYPE, CTYPE & "(INTERFACE)new IMPL($iminput, false)"
%typemap(csdirectorin) CTYPE *, CTYPE *const&, CTYPE [] "($iminput == global::System.IntPtr.Zero) ? null : (INTERFACE)new IMPL($iminput, false)"
%typemap(csdirectorout) CTYPE, CTYPE *, CTYPE *const&, CTYPE [], CTYPE & "$cscall.SWIGInterfaceUpcast()"
%typemap(csinterfacecode, declaration="  [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]\n  global::System.Runtime.InteropServices.HandleRef SWIGInterfaceUpcast();\n", cptrmethod="$interfacename_SWIGInterfaceUpcast") CTYPE %{
  [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]
  global::System.Runtime.InteropServices.HandleRef $interfacename.SWIGInterfaceUpcast() {
    return new global::System.Runtime.InteropServices.HandleRef(($interfacename)this, $imclassname.$csclazzname$interfacename_SWIGInterfaceUpcast(swigCPtr.Handle));
  }
%}
%enddef

%define DECLARE_INTERFACE_RENAME(INTERFACE, IMPL, CTYPE...)
%rename (IMPL) CTYPE;
DECLARE_INTERFACE_(INTERFACE, IMPL, CTYPE)
%enddef

%define DECLARE_INTERFACE(INTERFACE, CTYPE...)
DECLARE_INTERFACE_(INTERFACE, CTYPE, CTYPE)
%enddef

