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

// The qualifiers merge into 'const volatile int &' in any combination, so this typemap is used
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

// The qualifiers of 'const T &' qualify the elements of an array T, as for a typedef of an array, so these typemaps are used
%typemap(in, numinputs=0) const int (&)[ANY] (int temp[$1_dim0]) "temp[0] = 42; $1 = &temp;"
%typemap(in, numinputs=0) const volatile int (&)[ANY] (int temp[$1_dim0]) "temp[0] = 43; $1 = &temp;"
%inline %{
template <typename T> struct Arrayer {
  int take_const(const T &t) { return t[0]; }
};
%}
%template(ArrayerInt3) Arrayer<int [3]>;
%template(ArrayerConstInt3) Arrayer<const int [3]>;
%template(ArrayerVolatileInt3) Arrayer<volatile int [3]>;
