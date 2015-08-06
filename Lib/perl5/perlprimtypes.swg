/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* bool */

%fragment(SWIG_From_frag(bool),"header") {
SWIGINTERNINLINE SV *
SWIG_From_dec(bool)(bool value)
{
  return boolSV(value);
}
}

%fragment(SWIG_AsVal_frag(bool),"header") {
SWIGINTERN int
SWIG_AsVal_dec(bool)(SV *obj, bool* val)
{
  if (val)
    *val = SvTRUE(obj);
  if (obj != &PL_sv_yes && obj != &PL_sv_no)
    return SWIG_AddCast(SWIG_OK);
  return SWIG_OK;
}
}


/* long */

%fragment(SWIG_From_frag(long),"header") {
SWIGINTERNINLINE SV *
SWIG_From_dec(long)(long value)
{
  if (IVSIZE < sizeof(value) && (value < IV_MIN || value > IV_MAX))
    return sv_2mortal(newSVpvf("%ld", value));
  return sv_2mortal(newSViv(value));
}
}

%fragment(SWIG_AsVal_frag(long),"header",
	  fragment="<limits.h>",
	  fragment=SWIG_AsVal_frag(long long)) {
SWIGINTERN int
SWIG_AsVal_dec(long)(SV *obj, long* val)
{
  long long v;
  int res = SWIG_AsVal(long long)(obj, &v);

  if (SWIG_IsOK(res)) {
    if (sizeof(v) > sizeof(*val) && (v < LONG_MIN || v > LONG_MAX))
      return SWIG_OverflowError;
    if (val)
      *val = (long)v;
  }
  return res;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long),"header") {
SWIGINTERNINLINE SV *
SWIG_From_dec(unsigned long)(unsigned long value)
{
  if (UVSIZE < sizeof(value) && value > UV_MAX)
    return sv_2mortal(newSVpvf("%lu", value));
  return sv_2mortal(newSVuv(value));
}
}

%fragment(SWIG_AsVal_frag(unsigned long),"header",
	  fragment="<limits.h>",
	  fragment=SWIG_AsVal_frag(unsigned long long)) {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long)(SV *obj, unsigned long *val) 
{
  unsigned long long v;
  int res = SWIG_AsVal(unsigned long long)(obj, &v);

  if (SWIG_IsOK(res)) {
    if (sizeof(v) > sizeof(*val) && v > ULONG_MAX)
      return SWIG_OverflowError;
    if (val)
      *val = (unsigned long)v;
  }
  return res;
}
}

/* long long */

%fragment(SWIG_From_frag(long long),"header",
	  fragment=SWIG_From_frag(long),
	  fragment="<stdio.h>") {
SWIGINTERNINLINE SV *
SWIG_From_dec(long long)(long long value)
{
  char temp[256];

  if (IVSIZE < sizeof(value) && (value < IV_MIN || value > IV_MAX))
    return sv_2mortal(newSVpvn(temp, snprintf(temp, sizeof(temp), "%lld", value)));
  return sv_2mortal(newSViv(value));
}
}

%fragment(SWIG_AsVal_frag(long long),"header",
	  fragment="<ctype.h>",
	  fragment="<limits.h>",
	  fragment="<stdlib.h>",
	  fragment="SWIG_CanCastAsInteger") {

SWIGINTERN int
SWIG_AsVal_dec(long long)(SV *obj, long long *val)
{
  int res = SWIG_OK;
  long long v;
  int try_nv = 0;

  if (SvIOK(obj)) {
    if (SvIsUV(obj)) {
      UV uv = SvUVX(obj);
      if (UVSIZE >= sizeof(v) && uv > LLONG_MAX)
        return SWIG_OverflowError;
      v = (long long)uv;
    } else {
      IV iv = SvIVX(obj);
      if (IVSIZE > sizeof(v) && (iv < LLONG_MIN || iv > LLONG_MAX))
        return SWIG_OverflowError;
      v = (long long)iv;
    }
  } else if(SvPOK(obj)) {
    STRLEN len = SvCUR(obj);
    char *endp, *str = SvPVX(obj);
    int err, oerr;

    /* strtoll has some edge cases we should avoid */
    if (len <= 0 || isspace(*str))
      return SWIG_TypeError;

    oerr = errno;
    errno = 0;
    v = strtoll(str, &endp, 0);
    err = errno;
    errno = oerr;

    if (errno == ERANGE)
      return SWIG_OverflowError;
    if (endp != str + len)
      try_nv = 1;
    else
      res = SWIG_AddCast(res);
  } else if(SvNOK(obj)) {
    try_nv = 1;
  } else {
    return SWIG_TypeError;
  }
  if(try_nv) {
      const double mant_max = 1LL << DBL_MANT_DIG;
      const double mant_min = -mant_max;
      double d;

      res = SWIG_AddCast(SWIG_AsVal(double)(obj,&d));
      if (!SWIG_IsOK(res) || !SWIG_CanCastAsInteger(&d, mant_min, mant_max))
        return SWIG_TypeError;
      v = (long long)d;
  }
  if (val)
    *val = v;
  return res;
}
}

/* unsigned long long */

%fragment(SWIG_From_frag(unsigned long long),"header",
	  fragment=SWIG_From_frag(long long),
	  fragment="<stdio.h>") {
SWIGINTERNINLINE SV *
SWIG_From_dec(unsigned long long)(unsigned long long value)
{
  char temp[256];

  if (UVSIZE < sizeof(value) && value > UV_MAX)
    return sv_2mortal(newSVpvn(temp, snprintf(temp, sizeof(temp), "%llu", value)));
  return sv_2mortal(newSVuv(value));
}
}

%fragment(SWIG_AsVal_frag(unsigned long long),"header",
	  fragment="<ctype.h>",
	  fragment="<limits.h>",
	  fragment="<stdlib.h>",
	  fragment="SWIG_CanCastAsInteger") {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long long)(SV *obj, unsigned long long *val)
{
  int res = SWIG_OK;
  unsigned long long v;
  int try_nv = 0;

  if (SvIOK(obj)) {
    if (SvIsUV(obj)) {
      UV uv = SvUVX(obj);
      if (UVSIZE > sizeof(v) && uv > ULLONG_MAX)
        return SWIG_OverflowError;
      v = (unsigned long long)uv;
    } else {
      IV iv = SvIVX(obj);
      if (iv < 0 || (IVSIZE > sizeof(v) && iv > ULLONG_MAX))
        return SWIG_OverflowError;
      v = (unsigned long long)iv;
    }
  } else if(SvPOK(obj)) {
    STRLEN len = SvCUR(obj);
    char *endp, *str = SvPVX(obj);
    int err, oerr;

    /* strtoull has some edge cases we should avoid */
    if (len <= 0 || isspace(*str) || *str == '-')
      return SWIG_TypeError;

    oerr = errno;
    errno = 0;
    v = strtoull(str, &endp, 0);
    err = errno;
    errno = oerr;

    if (errno == ERANGE)
      return SWIG_OverflowError;
    if (endp != str + len)
      try_nv = 1;
    else
      res = SWIG_AddCast(res);
  } else if(SvNOK(obj)) {
    try_nv = 1;
  } else {
    return SWIG_TypeError;
  }
  if(try_nv) {
    const double mant_max = 1LL << DBL_MANT_DIG;
    double d;

    res = SWIG_AddCast(SWIG_AsVal(double)(obj, &d));
    if (!SWIG_IsOK(res) || !SWIG_CanCastAsInteger(&d, 0, mant_max))
      return SWIG_TypeError;
    v = (unsigned long long)d;
  }
  if (val)
    *val = v;
  return res;
}
}

/* double */

%fragment(SWIG_From_frag(double),"header") {
SWIGINTERNINLINE SV *
SWIG_From_dec(double)(double value)
{
  return sv_2mortal(newSVnv(value));
}
}

%fragment(SWIG_AsVal_frag(double),"header",
	  fragment="<ctype.h>",
	  fragment="<stdlib.h>") {
SWIGINTERN int
SWIG_AsVal_dec(double)(SV *obj, double *val)
{

  int res = SWIG_OK;
  double v;

  if (SvNIOK(obj)) {
    v = (double)SvNV(obj);
  } else if (SvPOK(obj)) {
    STRLEN len = SvCUR(obj);
    char *endp, *str = SvPVX(obj);
    int err, oerr;

    /* strtod has some edge cases we should avoid */
    if (len <= 0 || isspace(*str))
      return SWIG_TypeError;

    oerr = errno;
    errno = 0;
    v = strtod(str, &endp);
    err = errno;
    errno = oerr;

    if (errno == ERANGE)
      return SWIG_OverflowError;
    if (endp != str + len)
      return SWIG_TypeError;
    res = SWIG_AddCast(res);
  } else {
    return SWIG_TypeError;
  }
  if (val)
    *val = v;
  return res;
}
}
