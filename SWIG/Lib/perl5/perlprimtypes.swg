/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* long */

%fragment(SWIG_From_frag(long),"header") {
SWIGINTERNINLINE SV *
SWIG_From_dec(long)(long value)
{    
  SV *obj = sv_newmortal();
  sv_setiv(obj, (IV) value);
  return obj;
}
}

%fragment(SWIG_AsVal_frag(long),"header") {
SWIGINTERN int
SWIG_AsVal_dec(long)(SV *obj, long* val)
{
  if (SvIOK(obj)) {
    if (val) *val = SvIV(obj);
    return SWIG_OK;
  }
  return SWIG_TypeError;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long),"header") {
SWIGINTERNINLINE SV *
SWIG_From_dec(unsigned long)(unsigned long value)
{    
  SV *obj = sv_newmortal();
  sv_setuv(obj, (UV) value);
  return obj;
}
}

%fragment(SWIG_AsVal_frag(unsigned long),"header") {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long)(SV *obj, unsigned long *val) 
{
  if (SvUOK(obj)) {
    if (val) *val = SvUV(obj);
    return SWIG_OK;
  } else  if (SvIOK(obj)) {
    long v = SvIV(obj);
    if (v > 0) {
      if (val) *val = v;
      return SWIG_OK;
    } else {
      return SWIG_OverflowError;
    }
  }
  return SWIG_TypeError;
}
}

/* long long */

%fragment(SWIG_From_frag(long long),"header",
	  fragment=SWIG_From_frag(long),
	  fragment="<limits.h>") {
SWIGINTERNINLINE SV *
SWIG_From_dec(long long)(long long value)
{
  if (((long long) LONG_MIN <= value) && (value <= (long long) LONG_MAX)) {
    return SWIG_From(long)(%numeric_cast(value,long));
  } else {    
    char temp[256]; 
    SV *obj = sv_newmortal();
    snprintf(temp, sizeof(temp),"%lld", value);
    sv_setpv(obj, temp);
    return obj;
  }
}
}

%fragment(SWIG_AsVal_frag(long long),"header") {
SWIGINTERN int
SWIG_AsVal_dec(long long)(SV *obj, long long *val)
{
  if (SvIOK(obj)) {
    if (val) *val = SvIV(obj);
    return SWIG_OK;
  } else {
    const char *nptr = SvPV(obj, PL_na);
    if (nptr) {
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
SWIGINTERNINLINE SV *
SWIG_From_dec(unsigned long long)(unsigned long long value)
{
  if (value < (unsigned long long) LONG_MAX) {
    return SWIG_From(long long)(%numeric_cast(value, long long));
  } else {
    char temp[256]; 
    SV *obj = sv_newmortal();
    snprintf(temp, sizeof(temp),"%llu", value);
    sv_setpv(obj, temp);
    return obj;
  }
}
}

%fragment(SWIG_AsVal_frag(unsigned long long),"header") {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long long)(SV *obj, unsigned long long *val)
{ 
  if (SvUOK(obj)) {
    if (val) *val = SvUV(obj);
    return SWIG_OK;
  } else {
    const char *nptr = SvPV(obj, PL_na);
    if (nptr) {
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
SWIGINTERNINLINE SV *
SWIG_From_dec(double)(double value)
{    
  SV *obj = sv_newmortal();
  sv_setnv(obj, value);
  return obj;
}
}

%fragment(SWIG_AsVal_frag(double),"header") {
SWIGINTERN int
SWIG_AsVal_dec(double)(SV *obj, double *val)
{
  if (SvNIOK(obj)) {
    if (val) *val = SvNV(obj);
    return SWIG_OK;
  } 

  return SWIG_TypeError;
}
}
