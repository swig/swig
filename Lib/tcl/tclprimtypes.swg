/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* boolean */

%fragment(SWIG_From_frag(bool),"header") {
  %define_as(SWIG_From_dec(bool),           Tcl_NewBooleanObj)
}

%fragment(SWIG_AsVal_frag(bool),"header") {
SWIGINTERN int
SWIG_AsVal_dec(bool)(Tcl_Obj *obj, bool *val)
{
  int v;
  if (Tcl_GetBooleanFromObj(0, obj, &v) == TCL_OK) {
    if (val) *val = v ? true : false;
    return SWIG_OK;
  }
  return SWIG_TypeError;
}
}

/* long */

%fragment(SWIG_From_frag(long),"header",
	  fragment="<limits.h>") {
SWIGINTERNINLINE Tcl_Obj* 
SWIG_From_dec(long)(long value)
{
  if (((long) INT_MIN <= value) && (value <= (long) INT_MAX)) {
    return Tcl_NewIntObj(%numeric_cast(value,int));
  } else {
    return Tcl_NewLongObj(value);
  }
}
}

%fragment(SWIG_AsVal_frag(long),"header") {
SWIGINTERN int
SWIG_AsVal_dec(long)(Tcl_Obj *obj, long* val)
{
  long v;
  if (Tcl_GetLongFromObj(0,obj, &v) == TCL_OK) {
    if (val) *val = (long) v;
    return SWIG_OK;
  }
  return SWIG_TypeError;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long),"header",
	  fragment=SWIG_From_frag(long)) {
SWIGINTERNINLINE Tcl_Obj* 
SWIG_From_dec(unsigned long)(unsigned long value)
{
  if (value < (unsigned long) LONG_MAX) {
    return SWIG_From(long)(%numeric_cast(value, long));
  } else {
    char temp[256]; 
    snprintf(temp, sizeof(temp),"%lu", value);
    return Tcl_NewStringObj(temp,-1);
  }
}
}

%fragment(SWIG_AsVal_frag(unsigned long),"header") {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long)(Tcl_Obj *obj, unsigned long *val) {
  long v;
  if (Tcl_GetLongFromObj(0,obj, &v) == TCL_OK) {
    if (v > 0) {
      if (val) *val = (long) v;
      return SWIG_OK;
    } else {
      return SWIG_OverflowError;
    }
  } else {
    int len = 0;
    const char *nptr = Tcl_GetStringFromObj(obj, &len);
    if (nptr && len > 0) {
      char *endptr;
      unsigned long v = strtoul(nptr, &endptr,0);
      if (errno == ERANGE) {
	errno = 0;
	return SWIG_OverflowError;
      } else {
	if (*endptr == '\0') {
	  if (val) *val = v;
	  return SWIG_OK;
	}
      }
    }
  }
  
  return SWIG_TypeError;
}
}

/* long long */

%fragment(SWIG_From_frag(long long),"header",
	  fragment=SWIG_From_frag(long),
	  fragment="<limits.h>") {
SWIGINTERNINLINE Tcl_Obj* 
SWIG_From_dec(long long)(long long value)
{
  if (((long long) LONG_MIN <= value) && (value <= (long long) LONG_MAX)) {
    return SWIG_From(long)(%numeric_cast(value,long));
  } else {    
    char temp[256]; 
    snprintf(temp, sizeof(temp),"%lld", value);
    return Tcl_NewStringObj(temp,-1);
  }
}
}

%fragment(SWIG_AsVal_frag(long long),"header") {
SWIGINTERN int
SWIG_AsVal_dec(long long)(Tcl_Obj *obj, long long *val)
{
  long v;
  if (Tcl_GetLongFromObj(0,obj, &v) == TCL_OK) {
    if (val) *val = v;
    return SWIG_OK;
  } else {
    int len = 0;
    const char *nptr = Tcl_GetStringFromObj(obj, &len);
    if (nptr && len > 0) {
      char *endptr;
      long long v = strtoll(nptr, &endptr,0);
      if (errno == ERANGE) {
	errno = 0;
	return SWIG_OverflowError;
      } else {
	if (*endptr == '\0') {
	  if (val) *val = v;
	  return SWIG_OK;
	}
      }
    }
  }
  return SWIG_TypeError;
}
}

/* unsigned long long */

%fragment(SWIG_From_frag(unsigned long long),"header",
	  fragment=SWIG_From_frag(long long),
	  fragment="<limits.h>") {
SWIGINTERNINLINE Tcl_Obj* 
SWIG_From_dec(unsigned long long)(unsigned long long value)
{
  if (value < (unsigned long long) LONG_MAX) {
    return SWIG_From(long long)(%numeric_cast(value, long long));
  } else {
    char temp[256]; 
    snprintf(temp, sizeof(temp),"%llu", value);
    return Tcl_NewStringObj(temp,-1);
  }
}
}

%fragment(SWIG_AsVal_frag(unsigned long long),"header",
	  fragment=SWIG_AsVal_frag(unsigned long)) {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long long)(Tcl_Obj *obj, unsigned long long *val)
{
  long v;
  if (Tcl_GetLongFromObj(0,obj, &v) == TCL_OK) {
    if (v > 0) {
      if (val) *val = (long) v;
      return SWIG_OK;
    } else {
      return SWIG_OverflowError;
    }
  } else {
    int len = 0;
    const char *nptr = Tcl_GetStringFromObj(obj, &len);
    if (nptr && len > 0) {
      char *endptr;
      unsigned long long v = strtoull(nptr, &endptr,0);
      if (errno == ERANGE) {
	errno = 0;
	return SWIG_OverflowError;
      } else {
	if (*endptr == '\0') {
	  if (val) *val = v;
	  return SWIG_OK;
	}
      }
    }
  }
  return SWIG_TypeError;
}
}

/* double */

%fragment(SWIG_From_frag(double),"header") {
  %define_as(SWIG_From(double),         Tcl_NewDoubleObj)
}

%fragment(SWIG_AsVal_frag(double),"header") {
SWIGINTERN int
SWIG_AsVal_dec(double)(Tcl_Obj *obj, double *val)
{
  double v;
  if (Tcl_GetDoubleFromObj(0, obj, &v) == TCL_OK) {
    if (val) *val = v;
    return SWIG_OK;
  }
  return SWIG_TypeError;
}
}

