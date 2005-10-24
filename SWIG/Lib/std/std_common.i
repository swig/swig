//
// Use the following macro with modern STL implementations
//
//#define SWIG_STD_MODERN_STL
//
// Use this to deactive the previous definition, when using gcc-2.95
// or similar old compilers.
//
//#define SWIG_STD_NOMODERN_STL

// Here, we identify compilers we now have problems with STL.
%{
  
#if defined(__SUNPRO_CC) 
#define SWIG_STD_NOASSIGN_STL
#define SWIG_STD_NOINSERT_TEMPLATE_STL
#endif


#if defined(__GNUC__)
#  if __GNUC__ == 2 && __GNUC_MINOR <= 96
#     define SWIG_STD_NOMODERN_STL
#  endif
#endif


%}

//
// Common code for supporting the STD C++ namespace
//

%{
#include <string>
#include <stdexcept>
%}



%fragment("StdTraitsCommon","header") 
%{
namespace swig {  
  template <class Type>
  struct noconst_traits {
    typedef Type noconst_type;
  };

  template <class Type>
  struct noconst_traits<const Type> {
    typedef Type noconst_type;
  };

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
    return traits<typename noconst_traits<Type >::noconst_type >::type_name();
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
      static std::string name = make_ptr_name(swig::type_name<Type>());
      return name.c_str();
    }
  };

  template <class Type, class Category> 
  struct traits_as { };
 
  template <class Type, class Category> 
  struct traits_check { };

}
%}
 
/*
  Generate the traits for a swigtype
*/

%define %traits_swigtype(Type...)
%fragment(SWIG_Traits_frag(Type),"header",fragment="StdTraits") {
  namespace swig {
    template <>  struct traits<Type > {
      typedef pointer_category category;
      static const char* type_name() { return  #Type; }
    };
  }
}
%enddef


/*
  Generate the traits for a 'primitive' type, such as 'double',
  for which the SWIG_AsVal and SWIG_From methods are already defined.
*/

%define %traits_ptypen(Type...)
  %fragment(SWIG_Traits_frag(Type),"header",
	    fragment=SWIG_AsVal_frag(Type),
	    fragment=SWIG_From_frag(Type),
	    fragment="StdTraits") {
namespace swig {
  template <> struct traits<Type > {
    typedef value_category category;
    static const char* type_name() { return  #Type; }
  };  
  template <>  struct traits_asval<Type > {   
    typedef Type value_type;
    static int asval(PyObject *obj, value_type *val) { 
      return SWIG_AsVal(Type)(obj, val);
    }
  };
  template <>  struct traits_from<Type > {
    typedef Type value_type;
    static PyObject *from(const value_type& val) {
      return SWIG_From(Type)(val);
    }
  };
}
}
%enddef

/*
  Generate the typemaps for a class that has 'value' traits
*/

%define %typemap_traits(Code,Type...)
  %typemaps_asvalfrom(%arg(Code),
		     %arg(swig::asval<Type >),
		     %arg(swig::from),
		     %arg(SWIG_Traits_frag(Type)),
		     %arg(SWIG_Traits_frag(Type)),
		     Type);
%enddef

/*
  Generate the typemaps for a class that behaves more like a 'pointer' or
  plain wrapped Swigtype.
*/

%define %typemap_traits_ptr(Code,Type...)
  %typemaps_asptrfrom(%arg(Code),
		     %arg(swig::asptr),
		     %arg(swig::from),
		     %arg(SWIG_Traits_frag(Type)),
		     %arg(SWIG_Traits_frag(Type)),
		     Type);
%enddef


/*
  Equality methods
*/
%define %std_equal_methods(Type...)
%extend Type {
  bool operator == (const Type& v) {
    return *self == v;
  }
  
  bool operator != (const Type& v) {
    return *self != v;
  }  
}

%enddef

/*
  Order methods
*/

%define %std_order_methods(Type...)
%extend Type {
  bool operator > (const Type& v) {
    return *self > v;
  }
  
  bool operator < (const Type& v) {
    return *self < v;
  }

  bool operator >= (const Type& v) {
    return *self >= v;
  }

  bool operator <= (const Type& v) {
    return *self <= v;
  }
}
%enddef

/*
  Comparison methods
*/

%define %std_comp_methods(Type...)
%std_equal_methods(Type )
%std_order_methods(Type )
%enddef


