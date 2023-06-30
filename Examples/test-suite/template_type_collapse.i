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

