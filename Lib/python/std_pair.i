%include std_common.i

%{
#include <utility>
%}

%fragment("StdPairTraits","header",
	  fragment="traits",fragment="PyObject_var") {
  namespace swigpy {
    template <class T, class U >
    struct traits_asval<std::pair<T,U> >  {
      typedef std::pair<T,U> value_type;
      typedef T first_type;
      typedef U second_type;

      static int asval(PyObject *obj, value_type *val) {
	if (PySequence_Check(obj) && (PySequence_Size(obj) == 2)) {
	  swigpy::PyObject_var first = PySequence_GetItem(obj,0);
	  swigpy::PyObject_var second = PySequence_GetItem(obj,1);
	  first_type *pfirst = val ? &(val->first) : 0;
	  second_type *psecond = val ? &(val->second) : 0;	  
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
      typedef std::pair<T,U> value_type;
      static PyObject *from(const value_type& val) {
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

    %typemap_traits_ptr(SWIG_CCode(PAIR), std::pair<T,U >);

    T first;
    U second;
  };

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

    %typemap_traits_ptr(SWIG_CCode(PAIR), std::pair<T,U* >);

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

    %typemap_traits_ptr(SWIG_CCode(PAIR), std::pair<T*,U >);

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

    %typemap_traits_ptr(SWIG_CCode(PAIR), std::pair<T*,U* >);

    T* first;
    U* second;
  };

}

/*
  Pairs for all the C++ types
*/
#define std_pair_ptypen(...) %template() std::pair< __VA_ARGS__ >;

%apply_cpptypes_2(std_pair_ptypen);
