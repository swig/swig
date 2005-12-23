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

%fragment(SWIG_AsVal_frag(long),"header",
	  fragment=SWIG_AsVal_frag(double)) {
SWIGINTERN int
SWIG_AsVal_dec(long)(SV *obj, long* val)
{
  if (SvIOK(obj)) {
    if (val) *val = SvIV(obj);
    return SWIG_OK;
  } else {
    int dispatch = 0;
    const char *nptr = SvPV(obj, PL_na);
    if (nptr) {
      char *endptr;
      long v = strtol(nptr, &endptr,0);
      if (errno == ERANGE) {
	errno = 0;
	return SWIG_OverflowError;
      } else {
	if (*endptr == '\0') {
	  if (val) *val = v;
	  return SWIG_AddCast(SWIG_OK);
	}
      }
    }
    if (!dispatch) {
      double d;
      int res = SWIG_AsVal(double)(obj,&d);
      if (SWIG_IsOK(res)) {
	if (LONG_MIN <= d && d <= LONG_MAX) {
	  double rd = rint(d);
	  if (errno) {
	    errno = 0;
	  } else {
	    if (rd == d) {
	      if (val) *val = (long)(rd);
	      return SWIG_AddCast(res);
	    }
	  }
	}
      }
    }
  }
  return SWIG_TypeError;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long),"header",
	  fragment=SWIG_AsVal_frag(double)) {
SWIGINTERNINLINE SV *
SWIG_From_dec(unsigned long)(unsigned long value)
{    
  SV *obj = sv_newmortal();
  sv_setuv(obj, (UV) value);
  return obj;
}
}

%fragment(SWIG_AsVal_frag(unsigned long),"header",
	  fragment=SWIG_AsVal_frag(double)) {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long)(SV *obj, unsigned long *val) 
{
  if (SvUOK(obj)) {
    if (val) *val = SvUV(obj);
    return SWIG_OK;
  } else  if (SvIOK(obj)) {
    long v = SvIV(obj);
    if (v >= 0) {
      if (val) *val = v;
      return SWIG_OK;
    } else {
      return SWIG_OverflowError;
    }
  } else {
    int dispatch = 0;
    const char *nptr = SvPV(obj, PL_na);
    if (nptr) {
      char *endptr;
      unsigned long v = strtoul(nptr, &endptr,0);
      if (errno == ERANGE) {
	errno = 0;
	return SWIG_OverflowError;
      } else {
	if (*endptr == '\0') {
	  if (val) *val = v;
	  return SWIG_AddCast(SWIG_OK);
	}
      }
    }
    if (!dispatch) {
      double d;
      int res = SWIG_AsVal(double)(obj,&d);
      if (SWIG_IsOK(res) && (d >= 0)) {
	if (d <= ULONG_MAX) {
	  double rd = rint(d);
	  if (errno) {
	    errno = 0;
	  } else {
	    if (rd == d) {
	      if (val) *val = (long)(rd);
	      return SWIG_AddCast(res);
	    }
	  }
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

%fragment(SWIG_AsVal_frag(long long),"header",
	  fragment=SWIG_AsVal_frag(double),
	  fragment="<limits.h>") {

SWIGINTERN int
SWIG_AsVal_dec(long long)(SV *obj, long long *val)
{
  if (SvIOK(obj)) {
    if (val) *val = SvIV(obj);
    return SWIG_OK;
  } else {
    int dispatch = 0;
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
	  return SWIG_AddCast(SWIG_OK);
	}
      }
    }
    if (!dispatch) {
      double d;
      int res = SWIG_AsVal(double)(obj,&d);
      if (SWIG_IsOK(res)) {
	if (LLONG_MIN <= d && d <= LLONG_MAX) {
	  double rd = rint(d);
	  if (errno) {
	    errno = 0;
	  } else {
	    if (rd == d) {
	      if (val) *val = (long long)(rd);
	      return SWIG_AddCast(res);
	    }
	  }
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

%fragment(SWIG_AsVal_frag(unsigned long long),"header",
	  fragment=SWIG_AsVal_frag(double),
	  fragment="<limits.h>") {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long long)(SV *obj, unsigned long long *val)
{ 
  if (SvUOK(obj)) {
    if (val) *val = SvUV(obj);
    return SWIG_OK;
  } else {
    int dispatch = 0;
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
	  return SWIG_AddCast(SWIG_OK);
	}
      }
    }
    if (!dispatch) {
      double d;
      int res = SWIG_AsVal(double)(obj,&d);
      if (SWIG_IsOK(res) && (d >=0 )) {
	if (d <= ULLONG_MAX) {
	  double rd = rint(d);
	  if (errno) {
	    errno = 0;
	  } else {
	    if (rd == d) {
	      if (val) *val = (unsigned long long)(rd);
	      return SWIG_AddCast(res);
	    }
	  }
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
  } else if (SvIOK(obj)) {
    if (val) *val = SvIV(obj);
    return SWIG_AddCast(SWIG_OK);
  } else {
    const char *nptr = SvPV(obj, PL_na);
    if (nptr) {
      char *endptr;
      double v = strtod(nptr, &endptr);
      if (errno == ERANGE) {
	errno = 0;
	return SWIG_OverflowError;
      } else {
	if (*endptr == '\0') {
	  if (val) *val = v;
	  return SWIG_AddCast(SWIG_OK);
	}
      }
    }
  }
  return SWIG_TypeError;
}
}
