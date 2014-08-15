// Pairs

%include <matlabstdcommon.swg>

//#define SWIG_STD_PAIR_ASVAL

%fragment("StdPairTraits","header",fragment="StdTraits") {
  namespace swig {
#ifdef SWIG_STD_PAIR_ASVAL
    template <class T, class U >
    struct traits_asval<std::pair<T,U> >  {
      typedef std::pair<T,U> value_type;

      static int get_pair(mxArray* first, mxArray* second,
			  std::pair<T,U> *val)
      {
	if (val) {
	  T *pfirst = &(val->first);
	  int res1 = swig::asval(first, pfirst);
	  if (!SWIG_IsOK(res1))
	    return res1;
	  U *psecond = &(val->second);
	  int res2 = swig::asval(second, psecond);
	  if (!SWIG_IsOK(res2))
	    return res2;
	  return res1 > res2 ? res1 : res2;
	} else {
	  T *pfirst = 0;
	  int res1 = swig::asval(first, pfirst);
	  if (!SWIG_IsOK(res1))
	    return res1;
	  U *psecond = 0;
	  int res2 = swig::asval((mxArray*)second, psecond);
	  if (!SWIG_IsOK(res2))
	    return res2;
	  return res1 > res2 ? res1 : res2;
	}
      }

      static int asval(mxArray* obj, std::pair<T,U> *val) {
	if (mxGetClassID(obj)==mxCELL_CLASS) {
          mxArray* c0 = mxGetCell(obj,0);
          mxArray* c1 = mxGetCell(obj,1);
	  if (c0==0 || c1==0) {
            SWIG_Error(SWIG_SystemError,"pair from Cell array requires at least two elements");
	    return SWIG_ERROR;
	  }
	  return get_pair(c0,c1,val);
	} else {
	  value_type *p;
	  int res = SWIG_ConvertPtr(obj,(void**)&p,swig::type_info<value_type>(),0);
	  if (SWIG_IsOK(res) && val)
	    *val = *p;
	  return res;
	}
	return SWIG_ERROR;
      }
    };

#else
    template <class T, class U >
    struct traits_asptr<std::pair<T,U> >  {
      typedef std::pair<T,U> value_type;

      static int get_pair(mxArray* first, mxArray* second,
			  std::pair<T,U> **val) 
      {
	if (val) {
	  value_type *vp = %new_instance(std::pair<T,U>);
	  T *pfirst = &(vp->first);
	  int res1 = swig::asval(first, pfirst);
	  if (!SWIG_IsOK(res1))
	    return res1;
	  U *psecond = &(vp->second);
	  int res2 = swig::asval(second, psecond);
	  if (!SWIG_IsOK(res2))
	    return res2;
	  *val = vp;
	  return SWIG_AddNewMask(res1 > res2 ? res1 : res2);
	} else {
	  T *pfirst = 0;
	  int res1 = swig::asval(first, pfirst);
	  if (!SWIG_IsOK(res1))
	    return res1;
	  U *psecond = 0;
	  int res2 = swig::asval(second, psecond);
	  if (!SWIG_IsOK(res2))
	    return res2;
	  return res1 > res2 ? res1 : res2;
	}
	return SWIG_ERROR;
      }

      static int asptr(mxArray* obj, std::pair<T,U> **val) {
	if (mxGetClassID(obj)==mxCELL_CLASS) {
          mxArray* c0 = mxGetCell(obj,0);
          mxArray* c1 = mxGetCell(obj,1);
	  if (c0==0 || c1==0) {
            SWIG_Error(SWIG_SystemError,"pair from Cell array requires at least two elements");
	    return SWIG_ERROR;
	  }
	  return get_pair(c0,c1,val);
	} else {
	  value_type *p;
	  int res = SWIG_ConvertPtr(obj,(void**)&p,swig::type_info<value_type>(),0);
	  if (SWIG_IsOK(res) && val)
	    *val = p;
	  return res;
	}
	return SWIG_ERROR;
      }
    };

#endif
    template <class T, class U >
    struct traits_from<std::pair<T,U> >   {
      static mxArray* from(const std::pair<T,U>& val) {
	mxArray* c = mxCreateCellMatrix(1,2);
        mxSetCell(c,0,swig::from(val.first));
        mxSetCell(c,1,swig::from(val.second));
	return c;
      }
    };
  }
}

%define %swig_pair_methods(pair...)
%enddef

%include <std/std_pair.i>

