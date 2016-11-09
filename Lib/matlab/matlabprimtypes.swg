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
  SWIGINTERN int SWIG_AsVal_dec(long)(mxArray* pm, long* val)
    {
      if(mxGetNumberOfElements(pm)!=1) return SWIG_TypeError;
      switch(mxGetClassID(pm)){
      case mxINT8_CLASS:
        if(val) *val = (long)(*(int8_T*)mxGetData(pm)); break;
      case mxUINT8_CLASS:
        if(val) *val = (long)(*(uint8_T*)mxGetData(pm)); break;
      case mxINT16_CLASS:
        if(val) *val = (long)(*(int16_T*)mxGetData(pm)); break;
      case mxUINT16_CLASS:
        if(val) *val = (long)(*(uint16_T*)mxGetData(pm)); break;
      case mxINT32_CLASS:
        if(val) *val = (long)(*(int32_T*)mxGetData(pm)); break;
      case mxUINT32_CLASS:
        if(val) *val = (long)(*(uint32_T*)mxGetData(pm)); break;
      case mxINT64_CLASS:
        if(val) *val = (long)(*(int64_T*)mxGetData(pm)); break;
      case mxUINT64_CLASS: 
        if(val) *val = (long)(*(uint64_T*)mxGetData(pm)); break;
      case mxDOUBLE_CLASS:
      {
	double v=mxGetScalar(pm);
	if(v!=floor(v)) return SWIG_TypeError;
        if(val) *val = (long)v;
        break;
      }
      default: return SWIG_TypeError;
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
  SWIGINTERN int SWIG_AsVal_dec(unsigned long)(mxArray* pm, unsigned long* val)
    {
      if(mxGetNumberOfElements(pm)!=1) return SWIG_TypeError;
      switch(mxGetClassID(pm)){
      case mxINT8_CLASS:
        if(val) *val = (unsigned long)(*(int8_T*)mxGetData(pm)); break;
      case mxUINT8_CLASS:
        if(val) *val = (unsigned long)(*(uint8_T*)mxGetData(pm)); break;
      case mxINT16_CLASS:
        if(val) *val = (unsigned long)(*(int16_T*)mxGetData(pm)); break;
      case mxUINT16_CLASS:
        if(val) *val = (unsigned long)(*(uint16_T*)mxGetData(pm)); break;
      case mxINT32_CLASS:
        if(val) *val = (unsigned long)(*(int32_T*)mxGetData(pm)); break;
      case mxUINT32_CLASS:
        if(val) *val = (unsigned long)(*(uint32_T*)mxGetData(pm)); break;
      case mxINT64_CLASS:
        if(val) *val = (unsigned long)(*(int64_T*)mxGetData(pm)); break;
      case mxUINT64_CLASS: 
        if(val) *val = (unsigned long)(*(uint64_T*)mxGetData(pm)); break;
      case mxDOUBLE_CLASS:
      {
	double v=mxGetScalar(pm);
	if(v!=floor(v)) return SWIG_TypeError;
        if(val) *val = (unsigned long)v;
        break;
      }
      default: return SWIG_TypeError;
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
  SWIGINTERN int SWIG_AsVal_dec(long long)(mxArray* pm, long long* val)
    {
      if(mxGetNumberOfElements(pm)!=1) return SWIG_TypeError;
      switch(mxGetClassID(pm)){
      case mxINT8_CLASS:
        if(val) *val = (long long)(*(int8_T*)mxGetData(pm)); break;
      case mxUINT8_CLASS:
        if(val) *val = (long long)(*(uint8_T*)mxGetData(pm)); break;
      case mxINT16_CLASS:
        if(val) *val = (long long)(*(int16_T*)mxGetData(pm)); break;
      case mxUINT16_CLASS:
        if(val) *val = (long long)(*(uint16_T*)mxGetData(pm)); break;
      case mxINT32_CLASS:
        if(val) *val = (long long)(*(int32_T*)mxGetData(pm)); break;
      case mxUINT32_CLASS:
        if(val) *val = (long long)(*(uint32_T*)mxGetData(pm)); break;
      case mxINT64_CLASS:
        if(val) *val = (long long)(*(int64_T*)mxGetData(pm)); break;
      case mxUINT64_CLASS: 
        if(val) *val = (long long)(*(uint64_T*)mxGetData(pm)); break;
      case mxDOUBLE_CLASS:
      {
	double v=mxGetScalar(pm);
	if(v!=floor(v)) return SWIG_TypeError;
        if(val) *val = (long long)v;
        break;
      }
      default: return SWIG_TypeError;
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
  SWIGINTERN int SWIG_AsVal_dec(unsigned long long)(mxArray* pm, unsigned long long* val)
    {
      if(mxGetNumberOfElements(pm)!=1) return SWIG_TypeError;
      switch(mxGetClassID(pm)){
      case mxINT8_CLASS:
        if(val) *val = (unsigned long long)(*(int8_T*)mxGetData(pm)); break;
      case mxUINT8_CLASS:
        if(val) *val = (unsigned long long)(*(uint8_T*)mxGetData(pm)); break;
      case mxINT16_CLASS:
        if(val) *val = (unsigned long long)(*(int16_T*)mxGetData(pm)); break;
      case mxUINT16_CLASS:
        if(val) *val = (unsigned long long)(*(uint16_T*)mxGetData(pm)); break;
      case mxINT32_CLASS:
        if(val) *val = (unsigned long long)(*(int32_T*)mxGetData(pm)); break;
      case mxUINT32_CLASS:
        if(val) *val = (unsigned long long)(*(uint32_T*)mxGetData(pm)); break;
      case mxINT64_CLASS:
        if(val) *val = (unsigned long long)(*(int64_T*)mxGetData(pm)); break;
      case mxUINT64_CLASS: 
        if(val) *val = (unsigned long long)(*(uint64_T*)mxGetData(pm)); break;
      case mxDOUBLE_CLASS:
      {
	double v=mxGetScalar(pm);
	if(v!=floor(v)) return SWIG_TypeError;
        if(val) *val = (unsigned long long)v;
        break;
      }
      default: return SWIG_TypeError;
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
      if(!mxIsDouble(pm) || mxGetNumberOfElements(pm)!=1) return SWIG_TypeError;
      if (val) *val = mxGetScalar(pm);
      return SWIG_OK;
    }
}

// const char* (strings)

%fragment("SWIG_AsCharPtrAndSize","header") {
SWIGINTERN int
SWIG_AsCharPtrAndSize(mxArray* pm, char** cptr, size_t* psize, int *alloc)
{
  if(!mxIsChar(pm) || (mxGetNumberOfElements(pm) != 0 && mxGetM(pm)!=1)) return SWIG_TypeError;
  size_t len=mxGetN(pm);
  static char buf[256];
  int flag = mxGetString(pm,buf,(mwSize)sizeof(buf));
  if(flag) return SWIG_TypeError;

  if (alloc) {
    *cptr = %new_copy_array(buf, len + 1, char);
    *alloc = SWIG_NEWOBJ;
  } else if (cptr)
    *cptr = buf;
  if (psize)
    *psize = len + 1;
  return SWIG_OK;
}
}

%fragment("SWIG_FromCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
SWIGINTERNINLINE mxArray*
SWIG_FromCharPtrAndSize(const char* carray, size_t size)
{
   mwSize dims[2] = {1,(mwSize)size};
   mxArray* ret = mxCreateCharArray((mwSize)2,dims);
   if(!ret) mexErrMsgIdAndTxt("SWIG:FromCharPtrAndSize","mxCreateCharArray failed");
   mxChar *ret_data = (mxChar *)mxGetData(ret);
   size_t i;
   for(i=0; i<size; ++i) ret_data[i] = carray[i];
   return ret;  
}
}


