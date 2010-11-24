/* -----------------------------------------------------------------------------
 * dvoid.swg
 *
 * Typemaps for handling void function return types and empty parameter lists.
 * ----------------------------------------------------------------------------- */

%typemap(cwtype) void "void"
%typemap(dwtype) void "void"
%typemap(dptype, cprimitive="1") void "void"

%typemap(out, null="") void ""
%typemap(ddirectorin) void "$winput"
%typemap(ddirectorout) void "$dpcall"
%typemap(directorin) void ""

%typemap(dout, excode=SWIGEXCODE) void {
  $wcall;$excode
}
