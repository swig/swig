/* -----------------------------------------------------------------------------
 * dswigtype.swg
 *
 * Typemaps for non-primitive types (C/C++ classes and structs).
 * ----------------------------------------------------------------------------- */

%typemap(cwtype) SWIGTYPE "void *"
%typemap(dwtype) SWIGTYPE "void*"
%typemap(dptype) SWIGTYPE "$&dclassname"

%typemap(cwtype) SWIGTYPE [] "void *"
%typemap(dwtype) SWIGTYPE [] "void*"
%typemap(dptype) SWIGTYPE [] "$dclassname"

%typemap(cwtype) SWIGTYPE * "void *"
%typemap(dwtype) SWIGTYPE * "void*"
%typemap(dptype, nativepointer="$dptype") SWIGTYPE * "$dclassname"

%typemap(cwtype) SWIGTYPE & "void *"
%typemap(dwtype) SWIGTYPE & "void*"
%typemap(dptype) SWIGTYPE & "$dclassname"

%typemap(cwtype) SWIGTYPE *const& "void *"
%typemap(dwtype) SWIGTYPE *const& "void*"
%typemap(dptype) SWIGTYPE *const& "$*dclassname"

%typecheck(SWIG_TYPECHECK_POINTER)
    SWIGTYPE,
    SWIGTYPE *,
    SWIGTYPE &,
    SWIGTYPE [],
    SWIGTYPE *const&
  ""


/*
 * By-value conversion typemaps (parameter is converted to a pointer).
 */

%typemap(in, canthrow=1) SWIGTYPE ($&1_type argp)
%{ argp = ($&1_ltype)$input;
   if (!argp) {
     SWIG_DSetPendingException(SWIG_DIllegalArgumentException, "Attempt to dereference null $1_type");
     return $null;
   }
   $1 = *argp; %}

%typemap(out) SWIGTYPE
#ifdef __cplusplus
%{ $result = new $1_ltype((const $1_ltype &)$1); %}
#else
{
  $&1_ltype $1ptr = ($&1_ltype) malloc(sizeof($1_ltype));
  memmove($1ptr, &$1, sizeof($1_type));
  $result = $1ptr;
}
#endif

%typemap(directorin) SWIGTYPE
  "$input = (void *)&$1;"
%typemap(directorout) SWIGTYPE
%{ if (!$input) {
     SWIG_DSetPendingException(SWIG_DIllegalArgumentException, "Unexpected null return for type $1_type");
     return $null;
   }
   $result = *($&1_ltype)$input; %}

%typemap(ddirectorin) SWIGTYPE "new $&dclassname($winput, false)"
%typemap(ddirectorout) SWIGTYPE "$&dclassname.swigGetCPtr($dpcall)"

%typemap(din) SWIGTYPE "$&dclassname.swigGetCPtr($dinput)"
%typemap(dout, excode=SWIGEXCODE) SWIGTYPE {
  $&dclassname ret = new $&dclassname($wcall, true);$excode
  return ret;
}


/*
 * Pointer conversion typemaps.
 */

%typemap(in) SWIGTYPE * "$1 = ($1_ltype)$input;"
%typemap(out) SWIGTYPE * "$result = (void *)$1;"

%typemap(directorin) SWIGTYPE *
  "$input = (void *) $1;"
%typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) SWIGTYPE *
  "$result = ($1_ltype)$input;"

%typemap(ddirectorin,
  nativepointer="cast($dptype)$winput"
) SWIGTYPE * "($winput is null) ? null : new $dclassname($winput, false)"

%typemap(ddirectorout,
  nativepointer="cast(void*)$dpcall"
) SWIGTYPE * "$dclassname.swigGetCPtr($dpcall)"

%typemap(din,
  nativepointer="cast(void*)$dinput"
) SWIGTYPE * "$dclassname.swigGetCPtr($dinput)"

%typemap(dout, excode=SWIGEXCODE,
  nativepointer="{\n  auto ret = cast($dptype)$wcall;$excode\n  return ret;\n}"
) SWIGTYPE * {
  void* cPtr = $wcall;
  $dclassname ret = (cPtr is null) ? null : new $dclassname(cPtr, $owner);$excode
  return ret;
}

// Use the same typemaps for const pointers.
%apply SWIGTYPE * { SWIGTYPE *const }


/*
 * Reference conversion typemaps.
 */

%typemap(in, canthrow=1) SWIGTYPE & %{ $1 = ($1_ltype)$input;
  if (!$1) {
    SWIG_DSetPendingException(SWIG_DIllegalArgumentException, "$1_type type is null");
    return $null;
  } %}
%typemap(out) SWIGTYPE & "$result = (void *)$1;"

%typemap(directorin) SWIGTYPE &
  "$input = ($1_ltype) &$1;"
%typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) SWIGTYPE &
%{ if (!$input) {
     SWIG_DSetPendingException(SWIG_DIllegalArgumentException, "Unexpected null return for type $1_type");
     return $null;
   }
   $result = ($1_ltype)$input; %}

%typemap(ddirectorin) SWIGTYPE & "new $dclassname($winput, false)"
%typemap(ddirectorout) SWIGTYPE & "$dclassname.swigGetCPtr($dpcall)"

%typemap(din) SWIGTYPE & "$dclassname.swigGetCPtr($dinput)"
%typemap(dout, excode=SWIGEXCODE) SWIGTYPE & {
  $dclassname ret = new $dclassname($wcall, $owner);$excode
  return ret;
}


/*
 * Array conversion typemaps.
 */

%typemap(in) SWIGTYPE [] %{ $1 = ($1_ltype)$input; %}
%typemap(out) SWIGTYPE [] %{ $result = $1; %}

%typemap(din) SWIGTYPE [] "$dclassname.swigGetCPtr($dinput)"
%typemap(dout, excode=SWIGEXCODE) SWIGTYPE [] {
  void* cPtr = $wcall;
  $dclassname ret = (cPtr is null) ? null : new $dclassname(cPtr, $owner);$excode
  return ret;
}

// Treat references to arrays like like references to a single element.
%apply SWIGTYPE & { SWIGTYPE ((&)[ANY]) }


/*
 * Pointer reference conversion typemaps.
 */

%typemap(in) SWIGTYPE *const& ($*1_ltype temp = 0)
%{ temp = ($*1_ltype)$input;
   $1 = ($1_ltype)&temp; %}
%typemap(out) SWIGTYPE *const&
%{ $result = (void *)*$1; %}

%typemap(din) SWIGTYPE *const& "$*dclassname.swigGetCPtr($dinput)"
%typemap(dout, excode=SWIGEXCODE) SWIGTYPE *const& {
  void* cPtr = $wcall;
  $*dclassname ret = (cPtr is null) ? null : new $*dclassname(cPtr, $owner);$excode
  return ret;
}
