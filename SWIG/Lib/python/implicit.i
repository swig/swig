%include std_common.i

/*
  The %implict macro allows a SwigType to be accepted
  as an input parameter and use its implicit constructors when needed.


  %implicit(A, int, double, B);

  %inline 
  {
    struct B { };  
    struct A
    {
      int ii;
      A(int i) { ii = 1; }
      A(double d) { ii = 2; }
      A(const B& b) { ii = 3; }
    };
  
    int get(A a) { return a.ii; }
  }

  Here, you can call 'get' as 

    get(1)    ==> get(A(1))
    get(2.0)  ==> get(A(2.0))
    get(B())  ==> get(A(B()))

   and swig will construct an 'A' temporal variable using the
   corresponding implicit constructor.


  The plain implicit macro takes care of simple type list. If it doesn't
  work because you are passing template types with commas, then use
  the %implicit_{1,2,3} versions, and the SWIG_arg macro.

*/


%define %implicit_type(...)
%traits_swigtype(__VA_ARGS__);
%enddef

%define %implicit_frag(...) ,fragment=SWIG_Traits_frag(__VA_ARGS__) %enddef

%define %implicit_code(...)
  if (swigpy::check<__VA_ARGS__ >(obj)) {
    if (val) *val = new value_type(swigpy::as<__VA_ARGS__ >(obj));
    return 2;
  }
%enddef

/* implicit */

%define %implicit(Type, ...)

%formacro_1(%implicit_type,__VA_ARGS__);

%fragment(SWIG_Traits_frag(Type),"header",
	  fragment="traits"
          %formacro_1(%implicit_frag,__VA_ARGS__)) %{
namespace swigpy {
  template <>  struct traits<Type > {   
    typedef pointer_category category;
    static const char* type_name() { return "Type"; }
  };
   
  template <> struct traits_asptr< Type > {
  typedef Type value_type;
  static int asptr(PyObject *obj, value_type **val) { 
    Type *vptr;
    static swig_type_info* desc = SWIG_TypeQuery("Type *");
    if ((SWIG_ConvertPtr(obj, (void **)&vptr, desc, 0) != -1)) {
      if (val) *val = vptr;
      return 1;
    } else {
      if (PyErr_Occurred()) PyErr_Clear();
      %formacro_1(%implicit_code,__VA_ARGS__)
    }
    if (val) {
      PyErr_SetString(PyExc_TypeError, "a " "Type" " is expected");
    }
    return 0;
  }
 };
}
%}

%typemap_traits_ptr(SWIG_CCode(POINTER),Type);
%enddef

/* implicit_1 */


%define %implicit_1(Type, Imp1)
%traits_swigtype(Imp1);

%fragment(SWIG_Traits_frag(Type),"header",
	  fragment="traits",
	  fragment=SWIG_Traits_frag(Imp1)) %{
namespace swigpy {
  template <>  struct traits< Type > {   
    typedef pointer_category category;
    static const char* type_name() { return "Type"; }
  };
   
  template <> struct traits_asptr< Type > {   
  typedef Type value_type;
  static int asptr(PyObject *obj, value_type **val) { 
    Type *vptr;
    static swig_type_info* desc = SWIG_TypeQuery("Type *");
    if ((SWIG_ConvertPtr(obj, (void **)&vptr, desc, 0) != -1)) {
      if (val) *val = vptr;
      return 1;
    } else {
      if (PyErr_Occurred()) PyErr_Clear();
      %implicit_code(Imp1);
    }
    if (val) {
      PyErr_SetString(PyExc_TypeError, "a " "Type" " is expected");
    }
    return 0;
  }
 };
}
%}

%typemap_traits_ptr(SWIG_CCode(POINTER),Type);

%enddef

/* implicit_2 */

%define %implicit_2(Type, Imp1, Imp2)
%traits_swigtype(Imp1);
%traits_swigtype(Imp2);

%fragment(SWIG_Traits_frag(Type),"header",
	  fragment="traits",
	  fragment=SWIG_Traits_frag(Imp1),
	  fragment=SWIG_Traits_frag(Imp2)) %{
namespace swigpy {
  template <>  struct traits< Type > {   
    typedef pointer_category category;
    static const char* type_name() { return "Type"; }
  };

  template <> struct traits_asptr< Type > {   
  typedef Type value_type;
  static int asptr(PyObject *obj, value_type **val) { 
    Type *vptr;
    static swig_type_info* desc = SWIG_TypeQuery("Type *");
    if ((SWIG_ConvertPtr(obj, (void **)&vptr, desc, 0) != -1)) {
      if (val) *val = vptr;
      return 1;
    } else {
      if (PyErr_Occurred()) PyErr_Clear();
      %implicit_code(Imp1);
      %implicit_code(Imp2);
    }
    if (val) {
      PyErr_SetString(PyExc_TypeError, "a " "Type" " is expected");
    }
    return 0;
  }
 };
}
%}

%typemap_traits_ptr(SWIG_CCode(POINTER),Type);
%enddef


/* implicit_3 */

%define %implicit_3(Type, Imp1, Imp2, Imp3)
%traits_swigtype(Imp1);
%traits_swigtype(Imp2);
%traits_swigtype(Imp3);

%fragment(SWIG_Traits_frag(Type),"header",
	  fragment="traits",
	  fragment=SWIG_Traits_frag(Imp1),
	  fragment=SWIG_Traits_frag(Imp2),
	  fragment=SWIG_Traits_frag(Imp3)) %{
namespace swigpy {
  template <>  struct traits< Type > {   
    typedef pointer_category category;
    static const char* type_name() { return "Type"; }
  };

  template <> struct traits_asptr< Type > {   
    typedef Type value_type;
    static int asptr(PyObject *obj, value_type **val) { 
    Type *vptr;
    static swig_type_info* desc = SWIG_TypeQuery("Type *");
    if ((SWIG_ConvertPtr(obj, (void **)&vptr, desc, 0) != -1)) {
      if (val) *val = vptr;
      return 1;
    } else {
      if (PyErr_Occurred()) PyErr_Clear();
      %implicit_code(Imp1);
      %implicit_code(Imp2);
      %implicit_code(Imp3);
    }
    if (val) {
      PyErr_SetString(PyExc_TypeError, "a " "Type" " is expected");
    }
    return 0;
  }
 };
}
%}

%typemap_traits_ptr(SWIG_CCode(POINTER),Type);
%enddef
