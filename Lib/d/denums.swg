/* -----------------------------------------------------------------------------
 * denums.swg
 *
 * Typemaps for enumerations.
 * ----------------------------------------------------------------------------- */


/*
 * Typemaps for enumeration types.
 */

%typemap(cwtype) enum SWIGTYPE "int"
%typemap(dwtype) enum SWIGTYPE "int"
%typemap(dptype, cprimitive="1") enum SWIGTYPE "$dclassname"

%typecheck(SWIG_TYPECHECK_POINTER) enum SWIGTYPE ""

%typemap(in) enum SWIGTYPE %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE %{ $result = $1; %}

%typemap(directorout) enum SWIGTYPE %{ $result = ($1_ltype)$input; %}
%typemap(directorin) enum SWIGTYPE "$input = $1;"
%typemap(ddirectorin) enum SWIGTYPE "cast($dclassname)$winput"
%typemap(ddirectorout) enum SWIGTYPE "cast(int)$dpcall"

%typemap(din) enum SWIGTYPE "cast(int)$dinput"
%typemap(dout, excode=SWIGEXCODE) enum SWIGTYPE {
  $dclassname ret = cast($dclassname)$wcall;$excode
  return ret;
}


/*
 * Typemaps for (const) references to enumeration types.
 */

%typemap(cwtype) const enum SWIGTYPE & "int"
%typemap(dwtype) const enum SWIGTYPE & "int"
%typemap(dptype) const enum SWIGTYPE & "$*dclassname"

%typecheck(SWIG_TYPECHECK_POINTER) const enum SWIGTYPE & ""

%typemap(in) const enum SWIGTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input;
   $1 = &temp; %}
%typemap(out) const enum SWIGTYPE & %{ $result = *$1; %}

%typemap(directorin) const enum SWIGTYPE & "$input = $1_name;"
%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const enum SWIGTYPE &
%{ static $*1_ltype temp = ($*1_ltype)$input;
   $result = &temp; %}

%typemap(ddirectorin) const enum SWIGTYPE & "cast($*dclassname)$winput"
%typemap(ddirectorout) const enum SWIGTYPE & "cast(int)$dpcall"

%typemap(din) const enum SWIGTYPE & "cast(int)$dinput"
%typemap(dout, excode=SWIGEXCODE) const enum SWIGTYPE & {
  $*dclassname ret = cast($*dclassname)$wcall;$excode
  return ret;
}
