//
// Use the following macro with modern STL implementations
//
//#define SWIG_STD_MODERN_STL
//
// Use this to deactive the previous definition, when using gcc-2.95
// or similar old compilers.
//
//#define SWIG_STD_NOMODERN_STL

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
// Use the following macro to enable the generation of the
// comparison methods, ie, ==, !=, <=, >=, <,>, whenever is needed,
// for the primitive types (int,double, etc.)
//
//#define SWIG_STD_EXTEND_COMPARISON


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
  namespace swigpy {
    struct PyObject_var {
      PyObject* ptr;
      PyObject_var(PyObject* obj = 0) : ptr(obj) { }      
      ~PyObject_var() { if (ptr) Py_DECREF(ptr); }      
      operator PyObject*() { return ptr; }
    };
  }
%}

%fragment("StdTraits","header") 
%{
namespace swigpy {  
  /*
    type categories
  */
  struct pointer_category { };  
  struct value_category { };

  /*
    General traits that provides type_name and type_info
  */
  template <class Type> struct traits { };

  template <class Type>
  inline const char* type_name() {
    return traits<Type>::type_name();
  }

  template <class Type> 
  struct traits_info {
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
    Partial specialization for pointers
  */
  template <class Type> struct traits <Type *> {
    typedef pointer_category category;
    static std::string make_ptr_name(const char* name) {
      std::string ptrname = name;
      ptrname += " *";
      return ptrname;
    }    
    static const char* type_name() {
      static std::string name = make_ptr_name(swigpy::type_name<Type>());
      return name.c_str();
    }
  };

  /*
    Traits that provides the from method
  */
  template <class Type> struct traits_from_ptr {
    static PyObject *from(Type *val, int owner = 0) {
      return SWIG_NewPointerObj(val, type_info<Type>(), owner);
    }
  };

  template <class Type> struct traits_from {
    static PyObject *from(const Type& val) {
      return traits_from_ptr<Type>::from(new Type(val), 1);
    }
  };

  template <class Type> struct traits_from<Type *> {
    static PyObject *from(Type* val) {
      return traits_from_ptr<Type>::from(val, 0);
    }
  };

  template <class Type>
  inline PyObject *from(const Type& val) {
    return traits_from<Type>::from(val);
  }

  template <class Type>
  inline PyObject *from_ptr(Type* val, int owner) {
    return traits_from_ptr<Type>::from(val, owner);
  }

  /*
    Traits that provides the asval/as/check method
  */
  template <class Type>
  struct traits_asptr {   
    static int asptr(PyObject *obj, Type **val) {
      Type *p;
      int res = (SWIG_ConvertPtr(obj, (void**)&p, type_info<Type>(), 0) != -1) 
	? SWIG_OLDOBJ : 0;
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
  struct noconst_traits {
    typedef Type noconst_type;
  };

  template <class Type>
  struct noconst_traits<const Type> {
    typedef Type noconst_type;
  };
  
  template <class Type> 
  struct traits_asval {
    static bool asval(PyObject *obj, Type *val) {
      if (val) {
	Type *p = 0;
	int res = asptr(obj, &p);
	if (res && p) {
	  typedef typename noconst_traits<Type>::noconst_type noconst_type;
	  *(const_cast<noconst_type*>(val)) = *p;
	  if (res == SWIG_NEWOBJ) delete p;
	  return true;
	} else {
	  return false;
	}
      } else {
	return asptr(obj, (Type **)(0));
      }
    }
  };

  template <class Type> struct traits_asval<Type*> {
    static bool asval(PyObject *obj, Type **val) {
      if (val) {
	Type *p = 0;
	int res = asptr(obj, &p);
	if (res) {
	  typedef typename noconst_traits<Type*>::noconst_type noconst_type;
	  *(const_cast<noconst_type*>(val)) = p;
	  return true;
	} else {
	  return false;
	}
      } else {
	return asptr(obj, (Type **)(0));
      }
    }
  };
  
  template <class Type>
  inline bool asval(PyObject *obj, Type *val) {
    return traits_asval<Type>::asval(obj, val);
  }

  template <class Type, class Category> 
  struct traits_as { };

  template <class Type> 
  struct traits_as<Type, value_category> {
    static Type as(PyObject *obj, bool throw_error) {
      Type v;
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
  struct traits_as<Type, pointer_category> {
    static Type as(PyObject *obj, bool throw_error) {
      Type *v = 0;
      int res = (obj ? asptr(obj, &v) : 0) && v;
      if (res) {
	if (res == SWIG_NEWOBJ) {
	  Type r(*v);
	  delete v;
	  return r;
	} else {
	  return *v;
	}
      } else {
	// Uninitialized return value, no Type() constructor required.
	static Type *v_def = (Type*) malloc(sizeof(Type));
	std::string msg = "a value of type '";
	msg += swigpy::type_name<Type>();
	msg += "' is expected";
	if (!PyErr_Occurred()) {
	  PyErr_SetString(PyExc_TypeError, msg.c_str());
	}
	if (throw_error) throw std::invalid_argument(msg);
	return *v_def;
      }
    }
  };
    
  template <class Type>
  inline Type as(PyObject *obj, bool te = false) {
    return traits_as<Type, typename traits<Type>::category>::as(obj, te);
  }

  template <class Type, class Category> 
  struct traits_check { };

  template <class Type> 
  struct traits_check<Type, value_category> {
    static bool check(PyObject *obj) {
      return obj && asval(obj, (Type *)(0));
    }
  };

  template <class Type> 
  struct traits_check<Type, pointer_category> {
    static bool check(PyObject *obj) {
      return obj && asptr(obj, (Type **)(0));
    }
  };

  template <class Type>
  inline bool check(PyObject *obj) {
    return traits_check<Type, typename traits<Type>::category>::check(obj);
  }
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
      return SWIG_AsVal(__VA_ARGS__)(obj, val);
    }
  };
  template <>  struct traits_from<__VA_ARGS__ > {
    typedef __VA_ARGS__ value_type;
    static PyObject *from(const value_type& val) {
      return SWIG_From(__VA_ARGS__)(val);
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

/*
  Comparison methods
*/

%define %std_comp_methods(...)
%std_equal_methods(__VA_ARGS__ )
%std_order_methods(__VA_ARGS__ )
%enddef

#if defined(SWIG_STD_EXTEND_COMPARISON)
%define %std_extcomp(Class,T)
  %evalif(SWIG_EqualType(T), %std_equal_methods(std::Class<T >))
  %evalif(SWIG_OrderType(T), %std_order_methods(std::Class<T >))
%enddef
%define %_std_extcomp_2(Class,T,U)
  %evalif_2(SWIG_EqualType(T),SWIG_EqualType(U),%std_equal_methods(std::Class<T,U >))
  %evalif_2(SWIG_OrderType(T),SWIG_EqualType(U),%std_order_methods(std::Class<T,U >))
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

/* ------------------------------------------------------------
 * equal and order types definition.
 * these are needed to decide when we the comparison
 * operators ==, !=, <=, etc, can be used.
 * ------------------------------------------------------------ */

/* the operators ==, != can used with these types */
%swig_equal_type(bool);
%swig_equal_type(std::complex<float>);
%swig_equal_type(std::complex<double>);

/* the operators <,>,<=,=> can used with these types */
%swig_order_type(signed char);
%swig_order_type(unsigned char);
%swig_order_type(short);
%swig_order_type(unsigned short);
%swig_order_type(int);
%swig_order_type(unsigned int);
%swig_order_type(long);
%swig_order_type(unsigned long);
%swig_order_type(long long);
%swig_order_type(unsigned long long);
%swig_order_type(float);
%swig_order_type(double);
%swig_order_type(char);
%swig_order_type(wchar_t);
%swig_order_type(std::string);
%swig_order_type(std::basic_string<char>);
%swig_order_type(std::wstring);
%swig_order_type(std::basic_string<wchar_t>);

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
