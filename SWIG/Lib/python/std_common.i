//
// Python implementation

%include pyptrtypes.swg
%{
#include <string>
#include <stdexcept>
%}


%apply size_t { std::size_t };
%apply ptrdiff_t { std::ptrdiff_t }

%fragment("PyObject_var","header") 
%{
  namespace swigpy 
  {
    struct PyObject_var 
    {
      PyObject* ptr;
      PyObject_var(PyObject* obj = 0)
	: ptr(obj)
      {
      }
      
      ~PyObject_var()
      {
	if (ptr) Py_DECREF(ptr);
      }
      
      operator PyObject*() 
      {
	return ptr;
      }
    };
  }
%}

%fragment("traits","header") 
%{
namespace swigpy {  
  /*
    General traits that provides type_name and type_info
  */
  template <class Type> struct traits
  {
  };
  /*
    type category
  */
  struct pointer_category
  {
  };
  
  struct value_category
  {
  };
  

  template <class Type>
  inline const char* type_name() {
    return traits<Type>::type_name();
  }

  template <class Type> 
  struct traits_info
  {
    static swig_type_info *type_query(std::string name) {
      name += " *";
      return SWIG_TypeQuery(name.c_str());
    }
    
    static swig_type_info *type_info() {
      static swig_type_info *info = type_query(type_name<Type>());
      return info;
    }
  };

  template <class Type>
  inline swig_type_info *type_info() {
    return traits_info<Type>::type_info();
  }

  /*
    Traits that provides the from method
  */
  template <class Type> struct traits_from {
    typedef Type value_type;
    static PyObject *from(value_type *val, int owner = 0) {
      return SWIG_NewPointerObj(val, type_info<value_type>(), owner);
    }

    static PyObject *from(const value_type& val) {
      return traits_from<Type>::from(new value_type(val), 1);
    }
  };

  template <class Type>
  inline PyObject *from(const Type& val) {
    return traits_from<Type>::from(val);
  }

  template <class Type>
  inline PyObject *from(Type* val, int owner = 0) {
    return traits_from<Type>::from(val, owner);
  }

  /*
    Traits that provides the asval/as/check method
  */

  template <class Type>
  struct traits_asptr {   
    typedef Type value_type;
    static int asptr(PyObject *obj, value_type **val) {
      value_type *p;
      int res = (SWIG_ConvertPtr(obj, (void**)&p, 
				 type_info<value_type>(), 0) != -1) ? 1 : 0;
      if (val) {
	if (res) {
	  *val = p;
	} else {
	  PyErr_Format(PyExc_TypeError, "a '%s *' is expected",
		       type_name<Type>());
	}
      }
      return res;
    }
  }; 

  template <class Type>
  inline int asptr(PyObject *obj, Type **vptr) {
    return traits_asptr<Type>::asptr(obj, vptr);
  }

  template <class Type> 
  struct traits_asval
  {
    typedef Type value_type;
    static bool asval(PyObject *obj, value_type *val) {
      if (val) {
	value_type *p;
	int res = asptr(obj, &p);
	if (res) {
	  *val = *p;
	  if (res > 1) delete p;
	}
	return res;
      } else {
	return asptr(obj, (value_type **)(0));
      }
    }
  };

  template <class Type>
  inline bool asval(PyObject *obj, Type *val) {
    return traits_asval<Type>::asval(obj, val);
  }


  template <class Type, class Category> 
  struct traits_as
  {
  };

  template <class Type> 
  struct traits_as<Type, value_category>
  {
    typedef Type value_type;
    static value_type as(PyObject *obj) {
      value_type v;
      if (!asval(obj, &v)) {
	std::string msg= "a value of type '";
	msg += swigpy::type_name<Type>();
	msg += "' is expected";
	if (!PyErr_Occurred()) {
	  PyErr_SetString(PyExc_TypeError, msg.c_str());
	}
	throw std::invalid_argument(msg);
      }
      return v;
    }
  };

  template <class Type> 
  struct traits_as<Type, pointer_category>
  {
    typedef Type value_type;
    static value_type as(PyObject *obj) {
      value_type *v = 0;
      int res = asptr(obj, &v);
      if (res) {
	if (res > 1) {
	  value_type r(*v);
	  delete v;
	  return r;
	} else {
	  return *v;
	}
      } else {
	std::string msg= "a value of type '";
	msg += swigpy::type_name<Type>();
	msg += "' is expected";
	if (!PyErr_Occurred()) {
	  PyErr_SetString(PyExc_TypeError, msg.c_str());
	}
	throw std::invalid_argument(msg);
      }
    }
  };
    
  template <class Type>
  inline Type as(PyObject *obj) {
    return traits_as<Type, typename traits<Type>::category>::as(obj);
  }

  template <class Type, class Category> 
  struct traits_check
  {
  };

  template <class Type> 
  struct traits_check<Type, value_category>
  {
    typedef Type value_type;
    static bool check(PyObject *obj) {
      return asval(obj, (value_type *)(0));
    }
  };

  template <class Type> 
  struct traits_check<Type, pointer_category>
  {
    typedef Type value_type;
    static bool check(PyObject *obj) {
      return asptr(obj, (value_type **)(0));
    }
  };

  template <class Type>
  inline bool check(PyObject *obj) {
    return traits_check<Type, typename traits<Type>::category>::check(obj);
  }

  /*
    Partial specialization for pointers
  */
  template <class Type> struct traits <Type *> {
    typedef pointer_category category;

    static std::string make_ptr_name(const char* name) 
    {
      std::string ptrname = name;
      ptrname += " *";
      return ptrname;
    }
    
    static const char* type_name() 
    {
      static std::string name = make_ptr_name(swigpy::type_name<Type>());
      return name.c_str();
    }
  };

}
%}

/*
  Generate the traits for a swigtype
*/

%define %traits_swigtype(...)
%fragment(SWIG_Traits_frag(__VA_ARGS__),"header",fragment="traits") {
  namespace swigpy {
    template <>  struct traits<__VA_ARGS__ > {
      typedef pointer_category category;
      static const char* type_name() { return  #__VA_ARGS__; }
    };
  }
}
%enddef

/*
  Generate the traits for a 'primitive' type, such as 'double',
  for which the SWIG_AsVal and SWIG_From method are already defined.
*/

%define %traits_ptypen(...)
  %fragment(SWIG_Traits_frag(__VA_ARGS__),"header",
	    fragment=SWIG_AsVal_frag(__VA_ARGS__),
	    fragment=SWIG_From_frag(__VA_ARGS__),
	    fragment="traits") {
  namespace swigpy {
    template <> struct traits<__VA_ARGS__ > {
      typedef value_category category;
      static const char* type_name() { return  #__VA_ARGS__; }
    };
    
    template <>  struct traits_asval<__VA_ARGS__ > {   
      typedef __VA_ARGS__ value_type;
      static int asval(PyObject *obj, value_type *val) { 
	return SWIG_AsVal_meth(__VA_ARGS__)(obj, val);
      }
    };
    
    template <>  struct traits_from<__VA_ARGS__ > {
      typedef __VA_ARGS__ value_type;
      static PyObject *from(const value_type& val) {
	return SWIG_From_meth(__VA_ARGS__)(val);
      }
    };
  }
 }
%enddef

%apply_cpptypes(%traits_ptypen);

/*
  Generate the typemaps for a class which the traits are 
  already defined
*/

%define %typemap_traits(Code,...)
  %typemap_ascheckfrom(SWIG_arg(Code),
		       SWIG_arg(swigpy::as<__VA_ARGS__ >),
		       SWIG_arg(swigpy::check<__VA_ARGS__ >),
		       SWIG_arg(swigpy::from),
		       SWIG_arg(SWIG_Traits_frag(__VA_ARGS__)),
		       SWIG_arg(SWIG_Traits_frag(__VA_ARGS__)),
		       SWIG_arg(SWIG_Traits_frag(__VA_ARGS__)),
		       __VA_ARGS__);
%enddef

/*
  Generate the typemaps for a class that behaves more like
  a ptr or plain wrapped Swigtype.
*/

%define %typemap_traits_ptr(Code,...)
  %typemap_asptrfrom(SWIG_arg(Code),
		     SWIG_arg(swigpy::asptr),
		     SWIG_arg(swigpy::from),
		     SWIG_arg(SWIG_Traits_frag(__VA_ARGS__)),
		     SWIG_arg(SWIG_Traits_frag(__VA_ARGS__)),
		     __VA_ARGS__);
%enddef

