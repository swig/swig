/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

%typemap(in) (const void *BYTES, size_t LENGTH) (void *buf = NULL, int alloc = 0) {
  Tcl_Size len = 0;
  Tcl_Obj **listobjv;
  if (Tcl_ListObjGetElements(interp, $input, &len, &listobjv) == TCL_ERROR) {
    %argument_fail(SWIG_ERROR, "$type", $symname, $argnum);
  }
  if (len > 0) {
    Tcl_Size i;
    unsigned char *cbuf = %new_array(len, unsigned char);
    if (cbuf == NULL) {
      %argument_fail(SWIG_ERROR, "$type", $symname, $argnum);
    }
    for (i = 0; i < len; i++) {
      int val;
      if (Tcl_GetSizeIntFromObj(interp, listobjv[i], &val) == TCL_ERROR) {
        %argument_fail(SWIG_ERROR, "$type", $symname, $argnum);
      }
      cbuf[i] = (unsigned char)val;
    }
    alloc = SWIG_NEWOBJ;
    buf = (void *)cbuf;
  }
  $1 = %reinterpret_cast(buf, $1_ltype);
  $2 = %numeric_cast(len, $2_ltype);
}

%typemap(freearg,noblock=1,match="in") (const void *BYTES, size_t LENGTH) {
  if (alloc$argnum == SWIG_NEWOBJ) {
    %delete_array((%reinterpret_cast(buf$argnum, unsigned char *)));
  }
}

%{
SWIGINTERNINLINE Tcl_Obj *SWIG_CreateIntList(Tcl_Interp *interp, const void *bytes, size_t len) {
  size_t i;
  unsigned char *cbuf = NULL;
  Tcl_Obj *ret = Tcl_GetObjResult(interp);
  if (bytes != NULL) {
    cbuf = (unsigned char *)bytes;
  } else {
    len = 0;
  }
  for (i = 0; i < len; i++) {
    Tcl_ListObjAppendElement(interp, ret, Tcl_NewSizeIntObj(cbuf[i]));
  }
  return ret;
}
%}

%typemap(directorin,noblock=1) (const void *BYTES, size_t LENGTH) {
  $input = SWIG_CreateIntList(interp, $1, $2);
}

%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }

%include <typemaps/cdata_begin.swg>

%typemap(out,noblock=1) SWIGCDATA {
  %set_output(SWIG_CreateIntList(interp, $1.data, (size_t)($1.len)));
}

%include <typemaps/cdata_end.swg>
