%module typemap_various

%typemap(in) SWIGTYPE "_this_will_not_compile_SWIGTYPE_"
%typemap(in) const SWIGTYPE & "_this_will_not_compile_const_SWIGTYPE_REF_"

%inline %{
template <class T> struct Foo {
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

