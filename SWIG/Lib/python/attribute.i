%{
#include <stdio.h>
%}

/*
  Attribute implementation using JOHN E LENZ ideas.

  The following macros convert a pair of set/get methods
  into a "native" python attribute.

  Use %attribute when you have a pair of get/set methods
  like in:

  %attribute(A, int, a, get_a, set_a);

  struct A
  {    
    int get_a() const 
    {
      return _a;
    }
    
    void set_a(int aa) 
    {
      _a = aa;
    }
  };

  If you don't provide a 'set' method, a 'read-only' attribute
  is generated, ie, like in:

  %attribute(A, int, c, get_c);


  Use %attribute_ref when you have const/non-const reference
  access methods, like in:

  %attribute_ref(A, int, b);

  struct A
  {    
    const int& b() const 
    {
      return _b;
    }
    
    int& b() 
    {
      return _b;
    }
  };

  You can also use

  %attribute_ref(class, type, pyattr, cppame);
  
  if the internal C++ reference methods have a different
  name from the python attribute you want.
  
  Then you can use the instances like:

  x = A() 
  x.a = 3        # calls A::set_a
  print x.a      # calls A::get_a 

  x.b = 3        # calls A::b() 
  print x.b      # calls A::b() const
  
*/


%define %_attribute(Class, type, attr, getcode, setcode) 
%extend Class {
  type attr;
}
%{
#define Class ##_## attr ## _get(_t) getcode
#define Class ##_## attr ## _set(_t, _val) setcode
%}
%enddef

%define %attribute(Class, type, attr, get, ...) 
%ignore Class::get;
#if #__VA_ARGS__ != ""
  %ignore Class::__VA_ARGS__;
  %_attribute(SWIG_arg(Class), SWIG_arg(type),
	      attr, _t->get(), _t->__VA_ARGS__(_val)) 
#else
  %_attribute(SWIG_arg(Class), SWIG_arg(type),
	      attr, _t->get(), 
	      fprintf(stderr,"'attr' is a read-only attribute"))
#endif
%enddef

%define %_attribute_ref(Class, type, attr, ref_name) 
%ignore Class::ref_name();
%ignore Class::ref_name() const;
%_attribute(SWIG_arg(Class), SWIG_arg(type),
	    attr, _t->ref_name(), _t->ref_name() = _val) 
%enddef

%define %attribute_ref(Class, type, attr, ...) 
#if #__VA_ARGS__ == ""
%_attribute_ref(SWIG_arg(Class), SWIG_arg(type), attr, attr) 
#else
%_attribute_ref(SWIG_arg(Class), SWIG_arg(type), attr, __VA_ARGS__)
#endif
%enddef
