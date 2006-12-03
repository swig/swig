/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * attribute.swg
 *
 * Attribute implementation
 * ----------------------------------------------------------------------------- */

/*
  The following macros convert a pair of set/get methods
  into a "native" attribute.

  Use %attribute when you have a pair of get/set methods
  like in:

      %attribute(A, int, a, get_a, set_a);
      				      
      struct A			      
      {    				      
        int get_a() const; 		      
        void set_a(int aa); 		      
      };				      

  If you don't provide a 'set' method, a 'read-only' attribute
  is generated, ie, like in:

      %attribute(A, int, c, get_c);


  Use %attribute_ref when you have const/non-const reference
  access methods, like in:

      %attribute_ref(A, int, b);	   
      				   
      struct A			   
      {    				   
        const int& b() const; 	   
        int& b(); 			   
      };				   
      				   
      %attribute_ref(B, int, c);	   
      				   
      struct B			   
      {    				   
        int& c(); 			   
      };                               

  You can also use

      %attribute_ref(class, type, refname, attr);
  
  if the internal C++ reference methods have a different name from the
  attribute you want.
  
  Then you can use the instances like:

      x = A() 			     
      x.a = 3        # calls A::set_a    
      print x.a      # calls A::get_a    
      				     
      x.b = 3        # calls A::b()      
      print x.b      # calls A::b() const

  NOTE: remember that if the type contains commas, such as
  'std::pair<int,int>', you need to use the macro like:

  %attribute_ref(A, %arg(std::pair<int,int>), pval);

  where %arg() 'normalize' the type to be understood as a single
  argument, otherwise the macro will get confused (see the 'cpp'
  documentation).

*/

#ifndef %attribute_exception
#define %attribute_exception(code,msg) SWIG_exception_fail(code,msg)
#endif

//
// Define SWIG_ATTRIBUTE_TEMPLATE if you want to use templates.
//
//#define SWIG_ATTRIBUTE_TEMPLATE


#if defined(__cplusplus) && defined(SWIG_ATTRIBUTE_TEMPLATE)
%define %_attribute(Class, Wrap, type, attr, getcode, setcode) 
%extend Class {
  type attr;
}
%{
  template <class C> inline
    type Wrap ##_## attr ## _get(const C* _t)
    { return getcode; }

  template <class C> inline
    type Wrap ##_## attr ## _get(C* _t)
    { return getcode; }

  template <class C> inline
    void Wrap ##_## attr ## _set(C* _t, type _val)
    { setcode; }
%}
%enddef

#else

%define %_attribute(Class, Wrap, type, attr, getcode, setcode) 
%extend Class {
  type attr;
}
%{
#define Wrap ##_## attr ## _get(_t) getcode
#define Wrap ##_## attr ## _set(_t, _val) setcode
%}
%enddef
#endif
//
// Internal versions, need Wrap name
//

%define %attribute_T(Class, Wrap, type, attr, get, set...) 
%ignore Class::get;
#if #set != ""
  %ignore Class::set;
  %_attribute(%arg(Class), Wrap, %arg(type),
	      attr, _t->get(), _t->set(_val)) 
#else
  %_attribute(%arg(Class), Wrap, %arg(type),
	      attr, _t->get(), 
	      %attribute_exception(SWIG_AttributeError,"read-only  'attr' attribute");)
#endif
%enddef


%define %_attribute_ref_T(Class, Wrap, type, refname, attr) 
%ignore Class::refname();
%ignore Class::refname() const;
%_attribute(%arg(Class), Wrap, %arg(type),
	    attr, _t->refname(), _t->refname() = _val) 
%enddef

%define %attribute_ref_T(Class, Wrap, type, refname, attr...) 
#if #attr == ""
  %_attribute_ref_T(%arg(Class), Wrap, %arg(type), refname, refname) 
#else
  %_attribute_ref_T(%arg(Class), Wrap, %arg(type), refname, attr)
#endif
%enddef

//
// User versions
//

%define %attribute(Class, type, attr, get, set...)
 %attribute_T(%arg(Class), %mangle(Class), %arg(type), attr, get, set)
%enddef

%define %attribute_ref(Class, type, refname, _Type...)
 %attribute_ref_T(%arg(Class), %mangle(Class), %arg(type), refname, _Type)
%enddef


