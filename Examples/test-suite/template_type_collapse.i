%module template_type_collapse

// Not attempted yet: reference collapsing

// Tests merging multiple const when instantiating template types
%inline %{
template <typename T> struct Conster { 
  const T *constptr;
  Conster() : constptr() {}
  void cccc1(T const& t) {}
  void cccc2(const T& t) {}
  void cccc3(const T t) {}
  void cccc4(T const t) {}
};
template <typename T> struct DerivedConster : Conster<const T> {
  const T& dddd(const T& t) {
    return t;
  }
};
%}
%template(ConsterInt) Conster<const int>;
%template(DerivedConsterInt) DerivedConster<const int>;

// The qualifiers merge into 'const volatile int &' in any combination, so these typemaps are used
%apply const int & { const volatile int & }
%typemap(in, numinputs=0) const volatile int & (int temp) "temp = 42; $1 = &temp;"
%inline %{
template <typename T> struct Volatiler {
  int take_const(const T &t) { return t; }
  int take_volatile(volatile T &t) { return t; }
};
%}
%template(VolatilerConstInt) Volatiler<const int>;
%template(VolatilerVolatileInt) Volatiler<volatile int>;
%template(VolatilerConstVolatileInt) Volatiler<const volatile int>;
