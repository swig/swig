%include std_common.i

%{
#include <utility>
%}

%fragment("StdPairTraits","header",
	  fragment="StdTraits",fragment="PyObject_var") {
  namespace swigpy {
    template <class T, class U >
    struct traits_asval<std::pair<T,U> >  {
      static int asval(PyObject *obj, std::pair<T,U> *val) {
	typedef std::pair<T,U> value_type;
	if (PySequence_Check(obj) && (PySequence_Size(obj) == 2)) {
	  swigpy::PyObject_var first = PySequence_GetItem(obj,0);
	  swigpy::PyObject_var second = PySequence_GetItem(obj,1);
	  T *pfirst = val ? &(val->first) : 0;
	  U *psecond = val ? &(val->second) : 0;	  
	  if (swigpy::asval(first,pfirst) && swigpy::asval(second,psecond)) {
	    return 1;
	  }
	} else {
	  value_type *p;
	  if (SWIG_ConvertPtr(obj,(void**)&p,
			      swigpy::type_info<value_type>(),0) != -1) {
	    if (val) *val = *p;
	    return 1;
	  }
	}
	if (val) {
	  PyErr_Format(PyExc_TypeError, "a %s is expected", 
		       swigpy::type_name<value_type>());
	}
	return 0;
      }
    };

    template <class T, class U >
    struct traits_from<std::pair<T,U> >   {
      static PyObject *from(const std::pair<T,U>& val) {
	PyObject* obj = PyTuple_New(2);
	PyTuple_SetItem(obj,0,swigpy::from(val.first));
	PyTuple_SetItem(obj,1,swigpy::from(val.second));
	return obj;
      }
    };
  }
 }

namespace std {
  template <class T, class U > struct pair {      
    typedef T fisrt_type;
    typedef U second_type;
    
    %traits_swigtype(T);
    %traits_swigtype(U);
      
    %fragment(SWIG_Traits_frag(std::pair<T,U >), "header",
	      fragment=SWIG_Traits_frag(T),
	      fragment=SWIG_Traits_frag(U),
	      fragment="StdPairTraits") {
      namespace swigpy {
	template <>  struct traits<std::pair<T,U > > {
	  typedef value_category category;
	  static const char* type_name() {
	    return "std::pair<" #T "," #U " >";
	  }
	};
      }
    }

    %typemap_traits(SWIG_CCode(PAIR), std::pair<T,U >);

    pair();
    pair(const T& __a, const U& __b);
    pair(const pair& __p);

    T first;
    U second;

    %extend
    {      
      %pythoncode {
	def __repr__(self):
	  return "(%s, %s)" %(str(self.first),str(self.second))
      }
    }    
  };

  // ***
  // The following specializations should dissapear or get 
  // simplified when a 'const SWIGTYPE*&' can be defined
  // ***
  template <class T, class U > struct pair<T, U*> {      
    typedef T fisrt_type;
    typedef U* second_type;
    
    %traits_swigtype(T);
      
    %fragment(SWIG_Traits_frag(std::pair<T,U* >), "header",
	      fragment=SWIG_Traits_frag(T),
	      fragment="StdPairTraits") {
      namespace swigpy {
	template <>  struct traits<std::pair<T,U* > > {
	  typedef value_category category;
	  static const char* type_name() {
	    return "std::pair<" #T "," #U " * >";
	  }
	};
      }
    }

    %typemap_traits(SWIG_CCode(PAIR), std::pair<T,U* >);

    pair();
    pair(const T& __a, U* __b);
    pair(const pair& __p);

    T first;
    U* second;
  };

  template <class T, class U > struct pair<T*, U> {      
    typedef T* fisrt_type;
    typedef U second_type;
    
    %traits_swigtype(U);
      
    %fragment(SWIG_Traits_frag(std::pair<T*,U >), "header",
	      fragment=SWIG_Traits_frag(U),
	      fragment="StdPairTraits") {
      namespace swigpy {
	template <>  struct traits<std::pair<T*,U > > {
	  typedef value_category category;
	  static const char* type_name() {
	    return "std::pair<" #T *"," #U " >";
	  }
	};
      }
    }

    %typemap_traits(SWIG_CCode(PAIR), std::pair<T*,U >);

    pair();
    pair(T* __a, const U& __b);
    pair(const pair& __p);

    T* first;
    U second;
  };

  template <class T, class U > struct pair<T*, U*> {
    typedef T* fisrt_type;
    typedef U* second_type;
      
    %fragment(SWIG_Traits_frag(std::pair<T*,U* >), "header",
	      fragment="StdPairTraits") {
      namespace swigpy {
	template <>  struct traits<std::pair<T*,U* > > {
	  typedef value_category category;
	  static const char* type_name() {
	    return "std::pair<" #T *"," #U " * >";
	  }
	};
      }
    }

    %typemap_traits(SWIG_CCode(PAIR), std::pair<T*,U* >);

    pair();
    pair(T* __a, U* __b);
    pair(const pair& __p);

    T* first;
    U* second;
  };

}

%define %std_pair_ptypen(...) 
  %std_extcomp_2(pair, __VA_ARGS__);
  %std_definst_2(pair, __VA_ARGS__);
%enddef

#if defined(SWIG_STD_EXTEND_COMPARISON) || defined(SWIG_STD_DEFAULT_INSTANTIATION)
%apply_cpptypes_2(%std_pair_ptypen);
#endif
