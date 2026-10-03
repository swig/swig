/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */


// boolean

%fragment(SWIG_From_frag(bool),"header") {
SWIGINTERNINLINE mxArray*
  SWIG_From_dec(bool)(bool value)
{
  return mxCreateLogicalScalar(value);
}
}

%fragment(SWIG_AsVal_frag(bool),"header",
	  fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN int
SWIG_AsVal_dec(bool)(mxArray* pm, bool *val)
{
   if(!mxIsLogicalScalar(pm)) return SWIG_TypeError;
   if (val) *val = mxIsLogicalScalarTrue(pm);
   return SWIG_OK;
}
}

// long

%fragment(SWIG_From_frag(long),"header") {
  SWIGINTERNINLINE mxArray* SWIG_From_dec(long)  (long value)
    {
      mxArray* out = mxCreateNumericMatrix(1,1,mxINT64_CLASS,mxREAL);
      *((int64_T*)mxGetData(out)) = (int64_T)value;
      return out;
    }
}


%fragment(SWIG_AsVal_frag(long),"header") {
SWIGINTERN int SWIG_AsVal_dec(long)(mxArray *pm, long *val) {
  int64_T signed_value = 0;
  uint64_T unsigned_value = 0;
  int is_unsigned = 0;
  if (mxGetNumberOfElements(pm) != 1 || mxIsComplex(pm) || mxIsSparse(pm)) return SWIG_TypeError;
  switch (mxGetClassID(pm)) {
  case mxINT8_CLASS: signed_value = *(int8_T *)mxGetData(pm); break;
  case mxUINT8_CLASS: unsigned_value = *(uint8_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxINT16_CLASS: signed_value = *(int16_T *)mxGetData(pm); break;
  case mxUINT16_CLASS: unsigned_value = *(uint16_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxINT32_CLASS: signed_value = *(int32_T *)mxGetData(pm); break;
  case mxUINT32_CLASS: unsigned_value = *(uint32_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxINT64_CLASS: signed_value = *(int64_T *)mxGetData(pm); break;
  case mxUINT64_CLASS: unsigned_value = *(uint64_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxDOUBLE_CLASS:
  case mxSINGLE_CLASS: {
    double value = mxGetScalar(pm);
    if (value != floor(value)) return SWIG_TypeError;
    if (value < (double)LONG_MIN || value >= -(double)LONG_MIN) return SWIG_OverflowError;
    if (val) *val = (long)value;
    return SWIG_OK;
  }
  default: return SWIG_TypeError;
  }
  if (is_unsigned) {
    if (unsigned_value > (uint64_T)LONG_MAX) return SWIG_OverflowError;
    if (val) *val = (long)unsigned_value;
  } else {
    if (signed_value < (int64_T)LONG_MIN || signed_value > (int64_T)LONG_MAX) return SWIG_OverflowError;
    if (val) *val = (long)signed_value;
  }
  return SWIG_OK;
}
}
// unsigned long

%fragment(SWIG_From_frag(unsigned long),"header") {
  SWIGINTERNINLINE mxArray* SWIG_From_dec(unsigned long)  (unsigned long value)
    {
      mxArray* out = mxCreateNumericMatrix(1,1,mxUINT64_CLASS,mxREAL);
      *((uint64_T*)mxGetData(out)) = (uint64_T)value;
      return out;
    }
}


%fragment(SWIG_AsVal_frag(unsigned long),"header") {
SWIGINTERN int SWIG_AsVal_dec(unsigned long)(mxArray *pm, unsigned long *val) {
  int64_T signed_value = 0;
  uint64_T unsigned_value = 0;
  int is_unsigned = 0;
  if (mxGetNumberOfElements(pm) != 1 || mxIsComplex(pm) || mxIsSparse(pm)) return SWIG_TypeError;
  switch (mxGetClassID(pm)) {
  case mxINT8_CLASS: signed_value = *(int8_T *)mxGetData(pm); break;
  case mxUINT8_CLASS: unsigned_value = *(uint8_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxINT16_CLASS: signed_value = *(int16_T *)mxGetData(pm); break;
  case mxUINT16_CLASS: unsigned_value = *(uint16_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxINT32_CLASS: signed_value = *(int32_T *)mxGetData(pm); break;
  case mxUINT32_CLASS: unsigned_value = *(uint32_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxINT64_CLASS: signed_value = *(int64_T *)mxGetData(pm); break;
  case mxUINT64_CLASS: unsigned_value = *(uint64_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxDOUBLE_CLASS:
  case mxSINGLE_CLASS: {
    double value = mxGetScalar(pm);
    if (value != floor(value)) return SWIG_TypeError;
    if (value < (double)0 || value >= (double)ULONG_MAX + 1.0) return SWIG_OverflowError;
    if (val) *val = (unsigned long)value;
    return SWIG_OK;
  }
  default: return SWIG_TypeError;
  }
  if (is_unsigned) {
    if (unsigned_value > (uint64_T)ULONG_MAX) return SWIG_OverflowError;
    if (val) *val = (unsigned long)unsigned_value;
  } else {
    if (signed_value < 0 || (uint64_T)signed_value > (uint64_T)ULONG_MAX) return SWIG_OverflowError;
    if (val) *val = (unsigned long)signed_value;
  }
  return SWIG_OK;
}
}
// long long

%fragment(SWIG_From_frag(long long),"header") {
  SWIGINTERNINLINE mxArray* SWIG_From_dec(long long)  (long long value)
    {
      mxArray* out = mxCreateNumericMatrix(1,1,mxINT64_CLASS,mxREAL);
      *((int64_T*)mxGetData(out)) = (int64_T)value;
      return out;
    }
}


%fragment(SWIG_AsVal_frag(long long),"header") {
SWIGINTERN int SWIG_AsVal_dec(long long)(mxArray *pm, long long *val) {
  int64_T signed_value = 0;
  uint64_T unsigned_value = 0;
  int is_unsigned = 0;
  if (mxGetNumberOfElements(pm) != 1 || mxIsComplex(pm) || mxIsSparse(pm)) return SWIG_TypeError;
  switch (mxGetClassID(pm)) {
  case mxINT8_CLASS: signed_value = *(int8_T *)mxGetData(pm); break;
  case mxUINT8_CLASS: unsigned_value = *(uint8_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxINT16_CLASS: signed_value = *(int16_T *)mxGetData(pm); break;
  case mxUINT16_CLASS: unsigned_value = *(uint16_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxINT32_CLASS: signed_value = *(int32_T *)mxGetData(pm); break;
  case mxUINT32_CLASS: unsigned_value = *(uint32_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxINT64_CLASS: signed_value = *(int64_T *)mxGetData(pm); break;
  case mxUINT64_CLASS: unsigned_value = *(uint64_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxDOUBLE_CLASS:
  case mxSINGLE_CLASS: {
    double value = mxGetScalar(pm);
    if (value != floor(value)) return SWIG_TypeError;
    if (value < (double)LLONG_MIN || value >= -(double)LLONG_MIN) return SWIG_OverflowError;
    if (val) *val = (long long)value;
    return SWIG_OK;
  }
  default: return SWIG_TypeError;
  }
  if (is_unsigned) {
    if (unsigned_value > (uint64_T)LLONG_MAX) return SWIG_OverflowError;
    if (val) *val = (long long)unsigned_value;
  } else {
    if (signed_value < (int64_T)LLONG_MIN || signed_value > (int64_T)LLONG_MAX) return SWIG_OverflowError;
    if (val) *val = (long long)signed_value;
  }
  return SWIG_OK;
}
}
%fragment(SWIG_From_frag(unsigned long long),"header") {
  SWIGINTERNINLINE mxArray* SWIG_From_dec(unsigned long long)  (unsigned long long value)
    {
      mxArray* out = mxCreateNumericMatrix(1,1,mxUINT64_CLASS,mxREAL);
      *((uint64_T*)mxGetData(out)) = (uint64_T)value;
      return out;
    }
}

%fragment(SWIG_AsVal_frag(unsigned long long),"header") {
SWIGINTERN int SWIG_AsVal_dec(unsigned long long)(mxArray *pm, unsigned long long *val) {
  int64_T signed_value = 0;
  uint64_T unsigned_value = 0;
  int is_unsigned = 0;
  if (mxGetNumberOfElements(pm) != 1 || mxIsComplex(pm) || mxIsSparse(pm)) return SWIG_TypeError;
  switch (mxGetClassID(pm)) {
  case mxINT8_CLASS: signed_value = *(int8_T *)mxGetData(pm); break;
  case mxUINT8_CLASS: unsigned_value = *(uint8_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxINT16_CLASS: signed_value = *(int16_T *)mxGetData(pm); break;
  case mxUINT16_CLASS: unsigned_value = *(uint16_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxINT32_CLASS: signed_value = *(int32_T *)mxGetData(pm); break;
  case mxUINT32_CLASS: unsigned_value = *(uint32_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxINT64_CLASS: signed_value = *(int64_T *)mxGetData(pm); break;
  case mxUINT64_CLASS: unsigned_value = *(uint64_T *)mxGetData(pm); is_unsigned = 1; break;
  case mxDOUBLE_CLASS:
  case mxSINGLE_CLASS: {
    double value = mxGetScalar(pm);
    if (value != floor(value)) return SWIG_TypeError;
    if (value < (double)0 || value >= (double)ULLONG_MAX + 1.0) return SWIG_OverflowError;
    if (val) *val = (unsigned long long)value;
    return SWIG_OK;
  }
  default: return SWIG_TypeError;
  }
  if (is_unsigned) {
    if (unsigned_value > (uint64_T)ULLONG_MAX) return SWIG_OverflowError;
    if (val) *val = (unsigned long long)unsigned_value;
  } else {
    if (signed_value < 0 || (uint64_T)signed_value > (uint64_T)ULLONG_MAX) return SWIG_OverflowError;
    if (val) *val = (unsigned long long)signed_value;
  }
  return SWIG_OK;
}
}
// double

%fragment(SWIG_From_frag(double),"header") {
  SWIGINTERNINLINE mxArray* SWIG_From_dec(double)  (double value)
    {
      return mxCreateDoubleScalar(value);
    }
}


%fragment(SWIG_AsVal_frag(double),"header") {
  SWIGINTERN int SWIG_AsVal_dec(double)(mxArray* pm, double* val)
    {
      if(!mxIsNumeric(pm) || mxIsComplex(pm) || mxGetNumberOfElements(pm)!=1) return SWIG_TypeError;
      if (val) *val = mxGetScalar(pm);
      return SWIG_OK;
    }
}

// const char* (strings)

%fragment("SWIG_AsCharPtrAndSize","header") {
SWIGINTERN int
SWIG_AsCharPtrAndSize(mxArray* pm, char** cptr, size_t* psize, int *alloc)
{
  int is_binary = alloc && SWIG_IsBinaryStr(*alloc);
  size_t len, i;
  const mxChar *data;
  if (!mxIsChar(pm) || (mxGetNumberOfElements(pm) != 0 && mxGetM(pm) != 1))
    return SWIG_TypeError;
  len = mxGetNumberOfElements(pm);
  if (len > ((size_t)-1) / 2 - 1) return SWIG_OverflowError;
  data = mxGetChars(pm);
  for (i = 0; i < len; ++i)
    if (data[i] > 255) return SWIG_TypeError;
  if (cptr) {
    if (!alloc) return SWIG_TypeError;
    *cptr = %new_array(len + 1, char);
    for (i = 0; i < len; ++i) (*cptr)[i] = (char)data[i];
    (*cptr)[len] = 0;
    *alloc = SWIG_NEWOBJ;
  }
  if (psize) *psize = is_binary ? len : len + 1;
  return SWIG_OK;
}
}

%fragment("SWIG_FromCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
%#define SWIG_FromBinaryCharPtrAndSize(carray, size, flags) SWIG_FromCharPtrAndSize(carray, size)
SWIGINTERNINLINE mxArray*
SWIG_FromCharPtrAndSize(const char* carray, size_t size)
{
   mwSize dims[2] = {1,(mwSize)size};
   mxArray* ret = mxCreateCharArray((mwSize)2,dims);
   if(!ret) SWIG_Matlab_ErrorId("SWIG:FromCharPtrAndSize","mxCreateCharArray failed");
   mxChar *ret_data = (mxChar *)mxGetData(ret);
   size_t i;
   for(i=0; i<size; ++i) ret_data[i] = (unsigned char)carray[i];
   return ret;
}
}



%fragment("SWIG_AsWCharPtrAndSize", "header", fragment="<wchar.h>") {
SWIGINTERN int
SWIG_AsWCharPtrAndSize(mxArray *pm, wchar_t **cptr, size_t *psize, int *alloc) {
  size_t len, i;
  const mxChar *data;
  if (!mxIsChar(pm) || (mxGetNumberOfElements(pm) && mxGetM(pm) != 1)) return SWIG_TypeError;
  len = mxGetNumberOfElements(pm);
  if (len > ((size_t)-1) / (2 * sizeof(wchar_t)) - 1) return SWIG_OverflowError;
  data = mxGetChars(pm);
  if (cptr) {
    if (!alloc) return SWIG_TypeError;
    *cptr = %new_array(len + 1, wchar_t);
    for (i = 0; i < len; ++i) {
%#ifdef HAVE_OCTAVE
      (*cptr)[i] = (unsigned char)data[i];
%#else
      (*cptr)[i] = data[i];
%#endif
    }
    (*cptr)[len] = 0;
    *alloc = SWIG_NEWOBJ;
  }
  if (psize) *psize = len + 1;
  return SWIG_OK;
}
}

%fragment("SWIG_FromWCharPtrAndSize", "header", fragment="<wchar.h>") {
SWIGINTERNINLINE mxArray *
SWIG_FromWCharPtrAndSize(const wchar_t *data, size_t size) {
  mwSize dims[2] = {1, (mwSize)size};
  mxArray *result = mxCreateCharArray(2, dims);
  mxChar *out = mxGetChars(result);
  size_t i;
  for (i = 0; i < size; ++i) {
    if ((unsigned long)data[i] > (sizeof(mxChar) == 1 ? 255UL : 65535UL)) {
      mxDestroyArray(result);
      SWIG_Matlab_ErrorId("SWIG:ValueError", "wide character exceeds the target character range");
      return 0;
    }
    out[i] = (mxChar)data[i];
  }
  return result;
}
}
