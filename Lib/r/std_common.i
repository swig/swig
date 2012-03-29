%include <rstdcommon.swg>
%include <std/std_common.i>

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
    static int asval(SEXP obj, value_type *val) { 
      return SWIG_AsVal(Type)(obj, val);
    }
  };
  template <>  struct traits_from<Type > {
    typedef Type value_type;
    static SEXP from(const value_type& val) {
      return SWIG_From(Type)(val);
    }
  };
}
}
%enddef

//
// Generates the traits for all the known primitive
// C++ types (int, double, ...)
//
%apply_cpptypes(%traits_ptypen);

