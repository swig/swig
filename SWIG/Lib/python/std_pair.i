/*
  Pairs
*/
%include <pycontainer.swg>

%fragment("StdPairTraits","header",
	  fragment="StdTraits",fragment="PyObject_var") {
  namespace swig {
    template <class T, class U >
    struct traits_asptr<std::pair<T,U> >  {
      static int asptr(PyObject *obj, std::pair<T,U> **val) {
	typedef std::pair<T,U> value_type;
	if (PySequence_Check(obj) && (PySequence_Size(obj) == 2)) {
	  swig::PyObject_var first = PySequence_GetItem(obj,0);
	  swig::PyObject_var second = PySequence_GetItem(obj,1);
	  T *pfirst = 0;
	  U *psecond = 0;
	  if (val) {
	    *val = new std::pair<T,U>;
	    pfirst = &((*val)->first);
	    psecond = &((*val)->second);
	  }	  
	  if (swig::asval(first,pfirst) && swig::asval(second,psecond)) {
	    return SWIG_NEWOBJ;
	  } else {
	    delete *val;
	  }
	} else {
	  value_type *p;
	  if (SWIG_ConvertPtr(obj,(void**)&p,
			      swig::type_info<value_type>(),0) != -1) {
	    if (val) *val = p;
	    return SWIG_OLDOBJ;
	  }
	}
	if (val) {
	  PyErr_Format(PyExc_TypeError, "a %s is expected", 
		       swig::type_name<value_type>());
	}
	return 0;
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

