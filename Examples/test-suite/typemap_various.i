%module typemap_various

// %copyctor need to be disables since 'const SWIGTYPE &' is intended to generate errors
%nocopyctor;

%typemap(in) SWIGTYPE "_this_will_not_compile_SWIGTYPE_"
%typemap(in) const SWIGTYPE & "_this_will_not_compile_const_SWIGTYPE_REF_"

%inline %{
template <class T> struct Foo {
  Foo() {}
#ifdef SWIG
  // These typemaps should be used by foo1 and foo2
  %typemap(in) Foo<T>      "/*in typemap for Foo<T> */"
  %typemap(in) const Foo & "/*in typemap for const Foo&, with type T*/"
#endif
};
%}

%template(FooInt) Foo<int>;
%template() Foo<short>; // previously Foo<short> typemaps were being picked up for Python only

%inline %{
void foo1(Foo<int> f, const Foo<int>& ff) {}
void foo2(Foo<short> f, const Foo<short>& ff) {}
%}

#ifdef SWIGUTL
%typemap(ret) int Bar1::foo() { /* hello1 */ };
%typemap(ret) int Bar2::foo() { /* hello2 */ };
%typemap(ret) int foo() {/* hello3 */ };
#endif

%inline %{
  struct Bar1 {
    int foo() { return 1;}    
  };

  struct Bar2 {
    int foo() { return 1;}    
  };
%}



%newobject FFoo::Bar(bool) const ;
%typemap(newfree) char* Bar(bool)  {
   /* hello */ delete[] result;
}

%inline {
  class FFoo {
  public:
    char * Bar(bool b) const { return "x"; }
  };
}

