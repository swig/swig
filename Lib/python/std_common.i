//
// Define or uncomment the following macro to instantiate by default
// all the basic std typemaps (std::pair<T,U>, std::vector<T>, etc)
// for all the primitive C++ types (int, double, etc).
//
// Note that this is equivalent to do something similar to
//
//   %template() std::vector<int>;
//
// but for all the std and basic C++ types, ie, no wrapping is
// generated for std::vector<int>, only the basic typemaps
// (in, out, typecheck, throw, input, etc.).
//
//#define SWIG_STD_DEFAULT_INSTANTIATION

// 
// Use the following macro to enable the generation of the comparison
// methods, ie, ==, !=, <=, >=, <,>, whenever is needed.
//
#define SWIG_STD_EXTEND_COMPARISON


//
// Use the following macro if you need the old common
// methods (SwigInt_FromBool,SwigNumber_Check,...).
//
// #define SWIG_STD_BACKWARD_COMP

//
// Common code for supporting the STD C++ namespace
//

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

%fragment("StdTraits","header") 
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
      if (res) {
	if (val) *val = p;
      } else {
	PyErr_Format(PyExc_TypeError, "a '%s *' is expected",
		     type_name<Type>());
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
	value_type *p = 0;
	int res = asptr(obj, &p);
	if (res && p) {
	  *val = *p;
	  if (res == SWIG_NEWOBJ) delete p;
	  return true;
	} else {
	  return false;
	}
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
    static value_type as(PyObject *obj, bool throw_error) {
      value_type v;
      if (!obj || !asval(obj, &v)) {
	std::string msg = "a value of type '";
	msg += swigpy::type_name<Type>();
	msg += "' is expected";
	if (!PyErr_Occurred()) {
	  PyErr_SetString(PyExc_TypeError, msg.c_str());
	}
	if (throw_error) throw std::invalid_argument(msg);
      }
      return v;
    }
  };

  template <class Type> 
  struct traits_as<Type, pointer_category>
  {
    typedef Type value_type;
    static value_type as(PyObject *obj, bool throw_error) {
      value_type *v = 0;
      int res = obj ? asptr(obj, &v) : 0;
      if (res) {
	if (res == SWIG_NEWOBJ) {
	  value_type r(*v);
	  delete v;
	  return r;
	} else {
	  return *v;
	}
      } else {
	std::string msg = "a value of type '";
	msg += swigpy::type_name<Type>();
	msg += "' is expected";
	if (!PyErr_Occurred()) {
	  PyErr_SetString(PyExc_TypeError, msg.c_str());
	}
	if (throw_error) throw std::invalid_argument(msg);
      }
    }
  };
    
  template <class Type>
  inline Type as(PyObject *obj, bool te = false) {
    return traits_as<Type, typename traits<Type>::category>::as(obj, te);
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
      return obj && asval(obj, (value_type *)(0));
    }
  };

  template <class Type> 
  struct traits_check<Type, pointer_category>
  {
    typedef Type value_type;
    static bool check(PyObject *obj) {
      return obj && asptr(obj, (value_type **)(0));
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
%fragment(SWIG_Traits_frag(__VA_ARGS__),"header",fragment="StdTraits") {
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
  for which the SWIG_AsVal and SWIG_From methods are already defined.
*/

%define %traits_ptypen(...)
  %fragment(SWIG_Traits_frag(__VA_ARGS__),"header",
	    fragment=SWIG_AsVal_frag(__VA_ARGS__),
	    fragment=SWIG_From_frag(__VA_ARGS__),
	    fragment="StdTraits") {
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
  Generate the typemaps for a class that has 'value' traits
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
  Generate the typemaps for a class that behaves more like a 'pointer' or
  plain wrapped Swigtype.
*/

%define %typemap_traits_ptr(Code,...)
  %typemap_asptrfrom(SWIG_arg(Code),
		     SWIG_arg(swigpy::asptr),
		     SWIG_arg(swigpy::from),
		     SWIG_arg(SWIG_Traits_frag(__VA_ARGS__)),
		     SWIG_arg(SWIG_Traits_frag(__VA_ARGS__)),
		     __VA_ARGS__);
%enddef


/*
  Equality methods
*/
%define %std_equal_methods(...)
%extend __VA_ARGS__ {
  bool operator == (const __VA_ARGS__& v) {
    return *self == v;
  }
  
  bool operator != (const __VA_ARGS__& v) {
    return *self != v;
  }  
}

%enddef

/*
  Order methods
*/

%define %std_order_methods(...)
%extend __VA_ARGS__ {
  bool operator > (const __VA_ARGS__& v) {
    return *self > v;
  }
  
  bool operator < (const __VA_ARGS__& v) {
    return *self < v;
  }

  bool operator >= (const __VA_ARGS__& v) {
    return *self >= v;
  }

  bool operator <= (const __VA_ARGS__& v) {
    return *self <= v;
  }
}
%enddef

#ifdef SWIG_STD_EXTEND_COMPARISON
%define %std_extcomp(Class,T)
  %apply_if(SWIG_EqualType(T), %std_equal_methods(std::Class<T >))
  %apply_if(SWIG_OrderType(T), %std_order_methods(std::Class<T >))
%enddef
%define %_std_extcomp_2(Class,T,U)
  %apply_if2(SWIG_EqualType(T),SWIG_EqualType(U),%std_equal_methods(std::Class<T,U >))
  %apply_if2(SWIG_OrderType(T),SWIG_EqualType(U),%std_order_methods(std::Class<T,U >))
%enddef
%define %std_extcomp_2(Class,T,...)
  %_std_extcomp_2(Class,T,__VA_ARGS__)
%enddef
#else
#define %std_extcomp(Class,...)
#define %std_extcomp_2(Class,...)
#endif

#ifdef SWIG_STD_DEFAULT_INSTANTIATION
#define %std_definst(Class,...) %template() std::Class< __VA_ARGS__ >;
#define %std_definst_2(Class,...) %template() std::Class< __VA_ARGS__ >;
#else
#define %std_definst(Class,...)
#define %std_definst_2(Class,...)
#endif


//
// Backward compatibility
//

#ifdef SWIG_STD_BACKWARD_COMP
%{
#include <string>
                                                                              
PyObject* SwigInt_FromBool(bool b) {
    return PyInt_FromLong(b ? 1L : 0L);
}
double SwigNumber_Check(PyObject* o) {
    return PyFloat_Check(o) || PyInt_Check(o) || PyLong_Check(o);
}
double SwigNumber_AsDouble(PyObject* o) {
    return PyFloat_Check(o) ? PyFloat_AsDouble(o)
        : (PyInt_Check(o) ?   double(PyInt_AsLong(o))
                            : double(PyLong_AsLong(o)));
}
PyObject* SwigString_FromString(const std::string& s) {
    return PyString_FromStringAndSize(s.data(),s.size());
}
std::string SwigString_AsString(PyObject* o) {
    return std::string(PyString_AsString(o));
}
%}

#endif
