%define DECLARE_INTERFACE_(CTYPE, INTERFACE, IMPL)
%feature("interface", name = "INTERFACE", cptr = "GetCPtr") CTYPE;
%typemap(cstype) CTYPE, CTYPE *, CTYPE [], CTYPE &, CTYPE *const& "INTERFACE"
%typemap(csin) CTYPE, CTYPE & "$csinput.GetCPtr()"
%typemap(csin) CTYPE *, CTYPE *const&, CTYPE [] "$csinput == null ? new HandleRef(null, IntPtr.Zero) : $csinput.GetCPtr()"
%typemap(csout, excode=SWIGEXCODE) CTYPE {
    IMPL ret = new IMPL($imcall, true);$excode
    return (INTERFACE)ret;
  }
%typemap(csout, excode=SWIGEXCODE) CTYPE & {
    IMPL ret = new IMPL($imcall, $owner);$excode
    return (INTERFACE)ret;
  }
%typemap(csout, excode=SWIGEXCODE) CTYPE *, CTYPE *const&, CTYPE [] {
    IntPtr cPtr = $imcall;
    IMPL ret = (cPtr == IntPtr.Zero) ? null : new IMPL(cPtr, $owner);$excode
    return (INTERFACE)ret;
  }
%typemap(csdirectorin) CTYPE, CTYPE & "(INTERFACE)new IMPL($iminput, false)"
%typemap(csdirectorin) CTYPE *, CTYPE *const&, CTYPE [] "($iminput == IntPtr.Zero) ? null : (INTERFACE)new IMPL($iminput, false)"
%typemap(csdirectorout) CTYPE, CTYPE *, CTYPE *const&, CTYPE [], CTYPE & "$cscall.GetCPtr()"
%enddef

%define DECLARE_INTERFACE_RENAME(CTYPE, INTERFACE, IMPL)
%rename (IMPL) CTYPE;
DECLARE_INTERFACE_(CTYPE, INTERFACE, IMPL)
%enddef

%define DECLARE_INTERFACE(CTYPE, INTERFACE)
DECLARE_INTERFACE_(CTYPE, INTERFACE, CTYPE)
%enddef

