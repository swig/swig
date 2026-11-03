/* -----------------------------------------------------------------------------
 * dmemberfunctionpointers.swg
 *
 * Typemaps for member function pointers.
 * ----------------------------------------------------------------------------- */


%typemap(ctype) SWIGTYPE (CLASS::*) "char *"
%typemap(imtype) SWIGTYPE (CLASS::*) "char*"
%typemap(dtype) SWIGTYPE (CLASS::*) "$dclassname"

%typemap(ctype) SWIGTYPE (CLASS::*const&) "char *"
%typemap(imtype) SWIGTYPE (CLASS::*const&) "char*"
%typemap(dtype) SWIGTYPE (CLASS::*const&) "$*dclassname"

%typecheck(SWIG_TYPECHECK_POINTER)
  SWIGTYPE (CLASS::*),
  SWIGTYPE (CLASS::*const&)
  ""


/*
 * Conversion generation typemaps.
 */

%typemap(in, fragment="SWIG_UnPackData") SWIGTYPE (CLASS::*) %{
  $1 = 0;
  if ($input) {
    SWIG_UnpackData($input, (void *)&$1, sizeof($1));
  }
%}
%typemap(out, fragment="SWIG_PackData") SWIGTYPE (CLASS::*) %{
  if ($1) {
    char buf[128];
    char *data = SWIG_PackData(buf, (void *)&$1, sizeof($1));
    *data = '\0';
    $result = SWIG_d_string_callback(buf);
  }
%}

%typemap(directorin, fragment="SWIG_PackData") SWIGTYPE (CLASS::*) %{
  $input = 0;
  if ($1) {
    char buf[128];
    char *data = SWIG_PackData(buf, (void *)&$1, sizeof($1));
    *data = '\0';
    $input = SWIG_d_string_callback(buf);
  }
%}
%typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG, fragment="SWIG_UnPackData") SWIGTYPE (CLASS::*) %{
  if ($input) {
    SWIG_UnpackData($input, (void *)&$result, sizeof($result));
  }
%}

%typemap(ddirectorin) SWIGTYPE (CLASS::*)
  "($winput is null) ? null : new $dclassname($winput, false)"
%typemap(ddirectorout) SWIGTYPE (CLASS::*) "$dclassname.swigGetCMemberPtr($dcall)"

%typemap(din) SWIGTYPE (CLASS::*) "$dclassname.swigGetCMemberPtr($dinput)"
%typemap(dout, excode=SWIGEXCODE) SWIGTYPE (CLASS::*) {
  char* cMemberPtr = $imcall;
  $dclassname ret = (cMemberPtr is null) ? null : new $dclassname(cMemberPtr, $owner);$excode
  return ret;
}

/*
 * Member pointer reference conversion typemaps.
 */

%typemap(in, fragment="SWIG_UnPackData") (SWIGTYPE (CLASS::*const&)) ($*1_ltype temp = 0) %{
  if ($input) {
    SWIG_UnpackData($input, (void *)&temp, sizeof(temp));
  }
  $1 = &temp;
%}
%typemap(out, fragment="SWIG_PackData") SWIGTYPE (CLASS::*const&) %{
  if (*$1) {
    char buf[128];
    char *data = SWIG_PackData(buf, (void *)$1, sizeof(*$1));
    *data = '\0';
    $result = SWIG_d_string_callback(buf);
  }
%}

%typemap(directorin, fragment="SWIG_PackData") SWIGTYPE (CLASS::*const&) %{
  $input = 0;
  if ($1) {
    char buf[128];
    char *data = SWIG_PackData(buf, (void *)&$1, sizeof($1));
    *data = '\0';
    $input = SWIG_d_string_callback(buf);
  }
%}
%typemap(directorout, warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG, fragment="SWIG_UnPackData") SWIGTYPE (CLASS::*const&) %{
  static SwigTypeIdentity< $*1_ltype >::type swig_temp;
  swig_temp = 0;
  if ($input) {
    SWIG_UnpackData($input, (void *)&swig_temp, sizeof(swig_temp));
  }
  $result = &swig_temp;
%}

%typemap(ddirectorin) SWIGTYPE (CLASS::*const&)
  "($winput is null) ? null : new $*dclassname($winput, false)"
%typemap(ddirectorout) SWIGTYPE (CLASS::*const&) "$*dclassname.swigGetCMemberPtr($dcall)"

%typemap(din) SWIGTYPE (CLASS::*const&) "$*dclassname.swigGetCMemberPtr($dinput)"
%typemap(dout, excode=SWIGEXCODE) SWIGTYPE (CLASS::*const&) {
  char* cMemberPtr = $imcall;
  $*dclassname ret = (cMemberPtr is null) ? null : new $*dclassname(cMemberPtr, $owner);$excode
  return ret;
}

%apply SWIGTYPE (CLASS::*) { SWIGTYPE (CLASS::*const) }

/*
 * Helper functions to pack/unpack arbitrary binary data (member function
 * pointers in this case) into a string.
 */

%fragment("SWIG_PackData", "header") {
/* Pack binary data into a string */
SWIGINTERN char * SWIG_PackData(char *c, void *ptr, size_t sz) {
  static const char hex[17] = "0123456789abcdef";
  const unsigned char *u = (unsigned char *) ptr;
  const unsigned char *eu =  u + sz;
  for (; u != eu; ++u) {
    unsigned char uu = *u;
    *(c++) = hex[(uu & 0xf0) >> 4];
    *(c++) = hex[uu & 0xf];
  }
  return c;
}
}

%fragment("SWIG_UnPackData", "header") {
/* Unpack binary data from a string */
SWIGINTERN const char * SWIG_UnpackData(const char *c, void *ptr, size_t sz) {
  unsigned char *u = (unsigned char *) ptr;
  const unsigned char *eu = u + sz;
  for (; u != eu; ++u) {
    char d = *(c++);
    unsigned char uu;
    if ((d >= '0') && (d <= '9'))
      uu = ((d - '0') << 4);
    else if ((d >= 'a') && (d <= 'f'))
      uu = ((d - ('a'-10)) << 4);
    else
      return (char *) 0;
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu |= (d - '0');
    else if ((d >= 'a') && (d <= 'f'))
      uu |= (d - ('a'-10));
    else
      return (char *) 0;
    *u = uu;
  }
  return c;
}
}
