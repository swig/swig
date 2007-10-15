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
  attribute you want. There's an inconsistency here (retained for 
  compatibility): when using %attribute_ref, the C++ symbol name comes 
  before the attribute name, but when you use %attribute, the attribute 
  name comes before the C++ symbol names. 
  
  Now you can use the attributes like so:

      x = A() 			     
      x.a = 3        # calls A::set_a    
      print x.a      # calls A::get_a    
      				     
      x.b = 3        # calls A::b()      
      print x.b      # calls A::b() const

  Use %attribute2 instead of %attribute to indicate that reference-pointer 
  translation is required. You use %attribute2 instead of %attribute in 
  cases like this:
 
  %attribute2(MyClass, MyFoo, Foo, GetFoo, SetFoo);
  %inline %{
    struct MyFoo { 
      int x;
    };
    class MyClass {
      MyFoo foo;
    public:
      MyFoo& GetFoo() { return foo; }
      void SetFoo(const MyFoo& other) { foo = other; }
    };
  %} 

  Here, the data type of the property is a wrapped type (MyFoo) and on the 
  C++ side it is passed by reference. The problem is that the SWIG wrapper will 
  pass around a pointer (MyFoo *) which is not compatible with the reference 
  type of the accessors (MyFoo &). Therefore, if you use %attribute, you'll get 
  an error from your C/C++ compiler. %attribute2 translates between a pointer 
  and a reference to eliminate the error. In case you're confused, I'll make it 
  simple: just use %attribute at first, but if the C/C++ compiler gives an error 
  while compiling the wrapper, try %attribute2 instead.

  NOTE: remember that if the type contains commas, such as 'std::pair<int,int>', 
  you need to use the macro like:

  %attribute_ref(A, %arg(std::pair<int,int>), pval);

  where %arg() 'normalizes' the type to be understood as a single
  argument, otherwise the macro will get confused by the comma (see the 
  'cpp' documentation).
*/

//
// Define SWIG_ATTRIBUTE_TEMPLATE if you want to use templates instead of macros for the C++ get and set wrapper methods
//
//#define SWIG_ATTRIBUTE_TEMPLATE

%define %attribute_custom(Class, AttributeType, AttributeName, GetMethod, SetMethod, GetMethodCall, SetMethodCall)
  %ignore Class::GetMethod();
  %ignore Class::GetMethod() const;
  #if #SetMethod != #AttributeName
    %ignore Class::SetMethod;
  #endif
  %extend Class {
    AttributeType AttributeName;
  }
#if defined(__cplusplus) && defined(SWIG_ATTRIBUTE_TEMPLATE)
  %{
    template < class C > inline AttributeType %mangle(Class) ##_## AttributeName ## _get(const C* self_) {
      return GetMethodCall;
    }
    template < class C > inline AttributeType %mangle(Class) ##_## AttributeName ## _get(C* self_) {
      return GetMethodCall;
    }
    template < class C > inline void %mangle(Class) ##_## AttributeName ## _set(C* self_, AttributeType val_) {
      SetMethodCall;
    }
  %}
#else
  %{
    #define %mangle(Class) ##_## AttributeName ## _get(self_) GetMethodCall
    #define %mangle(Class) ##_## AttributeName ## _set(self_, val_) SetMethodCall
  %}
#endif
%enddef

%define %attribute_readonly(Class, AttributeType, AttributeName, GetMethod, GetMethodCall)
  %ignore Class::GetMethod();
  %ignore Class::GetMethod() const;
  %immutable Class::AttributeName;
  %extend Class {
    AttributeType AttributeName;
  }
#if defined(__cplusplus) && defined(SWIG_ATTRIBUTE_TEMPLATE)
  %{
    template < class C > inline AttributeType %mangle(Class) ##_## AttributeName ## _get(const C* self_) {
      return GetMethodCall;
    }
    template < class C > inline AttributeType %mangle(Class) ##_## AttributeName ## _get(C* self_) {
      return GetMethodCall;
    }
  %}
#else
  %{
    #define %mangle(Class) ##_## AttributeName ## _get(self_) GetMethodCall
  %}
#endif
%enddef

%define %attribute(Class, AttributeType, AttributeName, GetMethod, SetMethod...)
  #if #SetMethod != ""
    %attribute_custom(Class, AttributeType, AttributeName, GetMethod, SetMethod, self_->GetMethod(), self_->SetMethod(val_))
  #else
    %attribute_readonly(Class, AttributeType, AttributeName, GetMethod, self_->GetMethod())
  #endif
%enddef

%define %attribute2(Class, AttributeType, AttributeName, GetMethod, SetMethod...)
  #if #SetMethod != ""
    %attribute_custom(Class, AttributeType, AttributeName, GetMethod, SetMethod, &self_->GetMethod(), self_->SetMethod(*val_))
  #else
    %attribute_readonly(Class, AttributeType, AttributeName, GetMethod, &self_->GetMethod())
  #endif
%enddef

%define %attribute_ref(Class, AttributeType, Accessor, AttributeName...)
  #if #AttributeName != ""
    %attribute_custom(Class, AttributeType, AttributeName, Accessor, Accessor, self_->Accessor(), self_->Accessor() = val_)
  #else
    %attribute_custom(Class, AttributeType, Accessor, Accessor, Accessor, self_->Accessor(), self_->Accessor() = val_)
  #endif
%enddef

%define %attribute2_ref(Class, AttributeType, Accessor, AttributeName...)
  #if #AttributeName != ""
    %attribute_custom(Class, AttributeType, AttributeName, Accessor, Accessor, &self_->Accessor(), self_->Accessor() = *val_)
  #else
    %attribute_custom(Class, AttributeType, Accessor, Accessor, Accessor, &self_->Accessor(), self_->Accessor() = *val_)
  #endif
%enddef
