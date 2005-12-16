/*
  Pairs
*/
%include <pycontainer.swg>

%fragment("StdPairTraits","header",fragment="StdTraits") {
  namespace swig {
    template <class T, class U >
    struct traits_asptr<std::pair<T,U> >  {
      typedef std::pair<T,U> value_type;

      static int get_pair(PyObject* first, PyObject* second,
			  std::pair<T,U> **val) 
      {
	if (val) {
	  value_type *vp = %new_instance(std::pair<T,U>);
	  T *pfirst = &(vp->first);
	  U *psecond = &(vp->second);
	  if ((swig::asval((PyObject*)first, pfirst) == SWIG_OK) 
	      && (swig::asval((PyObject*)second, psecond) == SWIG_OK)) {
	    *val = vp;
	    return SWIG_NEWOBJ;
	  } else {
	    %delete(vp);
	    return SWIG_BADOBJ;
	  }
	} else {
	  T *pfirst = 0;
	  U *psecond = 0;
	  if ((swig::asval((PyObject*)first, pfirst) == SWIG_OK) 
	      && (swig::asval((PyObject*)second, psecond) == SWIG_OK)) {
	    return SWIG_NEWOBJ;
	  } else {
	    return SWIG_BADOBJ;
	  }
	}	
      }
      
      static int asptr(PyObject *obj, std::pair<T,U> **val) {
	int res = SWIG_BADOBJ;
	if (PyTuple_Check(obj)) {
	  if (PyTuple_GET_SIZE(obj) == 2) {
	    res = get_pair(PyTuple_GET_ITEM(obj,0),PyTuple_GET_ITEM(obj,1), val);
	  }
	} else if (PySequence_Check(obj)) {
	  if (PySequence_Size(obj) == 2) {
	    swig::PyObject_var first = PySequence_GetItem(obj,0);
	    swig::PyObject_var second = PySequence_GetItem(obj,1);
	    res = get_pair(first, second, val);
	  }
	} else {
	  value_type *p;
	  if (SWIG_ConvertPtr(obj,(void**)&p,swig::type_info<value_type>(),0) == SWIG_OK) {
	    if (val) *val = p;
	    res = SWIG_OLDOBJ;
	  }	  
	}
	if ((res == SWIG_BADOBJ) && val) {
	  PyErr_Format(PyExc_TypeError, "a %s is expected", swig::type_name<value_type>());
	}
	return res;
      }
    };

    template <class T, class U >
    struct traits_from<std::pair<T,U> >   {
      static PyObject *from(const std::pair<T,U>& val) {
	PyObject* obj = PyTuple_New(2);
	PyTuple_SetItem(obj,0,swig::from(val.first));
	PyTuple_SetItem(obj,1,swig::from(val.second));
	return obj;
      }
    };
  }
}

%define %swig_pair_methods(pair...)
%extend {      
%pythoncode {
def __len__(self):
  return 2
def __getitem__(self, index):
  if not (index % 2): 
    return self.first
  else:
    return self.second
def __setitem__(self, index, val):
  if not (index % 2): 
    self.first = val
  else:
    self.second = val
def __repr__(self):
  return str((self.first, self.second))
}
}
%enddef


%include <std/std_pair.i>

