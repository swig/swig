/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* boolean */

%fragment(SWIG_From_frag(bool),"header") {
SWIGINTERNINLINE
void *SWIG_From_dec(bool)(bool value)
{
	duk_push_boolean(ctx, value);
	return duk_get_heapptr(ctx, -1);
}
}

%fragment(SWIG_AsVal_frag(bool),"header",
          fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN
int SWIG_AsVal_dec(bool)(void *obj, bool *val)
{
	duk_idx_t idx = duk_push_pointer(ctx, obj);
	if (!duk_is_boolean(ctx, idx)) {
		return SWIG_ERROR;
	}
	/* FIXME: This seems a bit broken. */
  if (val) {
		*val = duk_to_boolean(ctx, obj);
	}
  return SWIG_OK;
}
}

/* int */

%fragment(SWIG_From_frag(int),"header") {
SWIGINTERNINLINE void *
  SWIG_From_dec(int)(int value)
{
	duk_idx_t idx = duk_push_int(ctx, value);
	return duk_get_heapptr(ctx, idx);
}
}

/* long */

%fragment(SWIG_From_frag(long),"header") {
SWIGINTERNINLINE void *
SWIG_From_dec(long)(long value)
{
	duk_idx_t idx = duk_push_number((duk_double_t)val);
	return duk_get_heapptr(ctx, idx);
}
}

%fragment(SWIG_AsVal_frag(long),"header",
          fragment="SWIG_CanCastAsInteger") {
SWIGINTERN int
SWIG_AsVal_dec(long)(void *obj, long *val)
{
	duk_idx_t idx = duk_push_heapptr(ctx, obj);
  if (!duk_is_number(ctx, idx)) {
    return SWIG_TypeError;
  }
  if(val) *val = (long)duk_get_number(ctx,idx);

  return SWIG_OK;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long),"header",
          fragment=SWIG_From_frag(long)) {
SWIGINTERNINLINE void *
SWIG_From_dec(unsigned long)(unsigned long value)
{
  return (value > LONG_MAX) ?
    JSValueMakeNumber(context, value) : JSValueMakeNumber(context, %numeric_cast(value,long));
}
}

%fragment(SWIG_AsVal_frag(unsigned long),"header",
          fragment="SWIG_CanCastAsInteger") {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long)(void *obj, unsigned long *val)
{
  long longVal;
	duk_idx_t idx = duk_push_heapptr(ctx, obj);
  if(!duk_is_number(ctx, idx)) {
    return SWIG_TypeError;
  }

  longVal = (long)duk_get_number(ctx, idx);

  if(longVal < 0) {
      return SWIG_OverflowError;
  }

  if(val) *val = longVal;

  return SWIG_OK;
}
}

/* long long */
// Note: these are copied from 'long' and probably need fixing

%fragment(SWIG_From_frag(long long),"header",
    fragment=SWIG_From_frag(long),
    fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERNINLINE JSValueRef
SWIG_From_dec(long long)(long long value)
{
	/* TODO Coerce to pointer. */
  return duk_to_number(ctx, value);
}
%#endif
}

%fragment(SWIG_AsVal_frag(long long),"header",
    fragment=SWIG_AsVal_frag(long),
    fragment="SWIG_CanCastAsInteger",
    fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERN int
SWIG_AsVal_dec(long long)(void *obj, long long* val)
{
	duk_idx_t idx = duk_push_heapptr(ctx, obj);
	if (!duk_is_number(ctx, idx)) {
    return SWIG_TypeError;
  }
  if(val) *val = (long long)duk_get_number(context, obj, NULL);

  return SWIG_OK;
}
%#endif
}

/* unsigned long long */
// Note: these are copied from 'unsigned long' and probably need fixing

%fragment(SWIG_From_frag(unsigned long long),"header",
	  fragment=SWIG_From_frag(long long),
	  fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERN void *
SWIG_From_dec(unsigned long long)(unsigned long long value)
{
  return (value > LONG_MAX) ?
    JSValueMakeNumber(ctx, value) : JSValueMakeNumber(context, %numeric_cast(value,long));
}
%#endif
}

%fragment(SWIG_AsVal_frag(unsigned long long),"header",
    fragment=SWIG_AsVal_frag(unsigned long),
    fragment="SWIG_CanCastAsInteger",
   fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERN int
SWIG_AsVal_dec(unsigned long long)(JSValueRef obj, unsigned long long *val)
{
  long long longVal;
  if(!duk_is_number(ctx, obj)) {
    return SWIG_TypeError;
  }

  longVal = (unsigned long long) JSValueToNumber(ctx, obj, NULL);

  if(longVal < 0) {
      return SWIG_OverflowError;
  }

  if(val) *val = longVal;

  return SWIG_OK;
}
%#endif
}

/* double */

%fragment(SWIG_From_frag(double),"header") {
SWIGINTERN void *
SWIG_From_dec(double) (double val)
{
	duk_to_number(ctx, val);
  return JSValueMakeNumber(context, val);
}
}

%fragment(SWIG_AsVal_frag(double),"header") {
SWIGINTERN int
SWIG_AsVal_dec(double)(JSValueRef obj, double *val)
{
  if(!duk_is_number(ctx, obj)) {
    return SWIG_TypeError;
  }
  if(val) *val = JSValueToNumber(context, obj, NULL);

  return SWIG_OK;
}
}
