%module cpp11_decltype_nontype_template_parameter

// A decltype naming a non-type template parameter names the type the parameter is declared with.
%inline %{
template<int N> struct IntParm {
  auto get() const -> decltype(N) { return N; }
  decltype(N) member = N;
  typedef decltype(N) value_type;
  value_type typedefed() const { return N; }
  int twice(decltype(N) x) const { return 2 * x; }
};

template<const long N> struct ConstLongParm {
  auto get() const -> decltype(N) { return N; }
};

template<char C> struct CharParm {
  auto get() const -> decltype(C) { return C; }
};

template<int N> auto int_function() -> decltype(N) { return N; }

template<typename T> struct MemberTemplate {
  template<int M> auto get() const -> decltype(M) { return M; }
};

template<class T> struct Holder { T t; };
template<int N> struct HolderParm {
  Holder<decltype(N)> held;
};
%}

// A decltype SWIG cannot deduce has the template argument substituted into it, so the wrapper still compiles.
#pragma SWIG nowarn=SWIGWARN_CPP11_DECLTYPE
%inline %{
template<int N> struct Undeduced {
  auto successor() const -> decltype(N + 1) { return N + 1; }
};
%}

%template(IntParm3) IntParm<3>;
%template(ConstLongParm4) ConstLongParm<4>;
%template(CharParmX) CharParm<'x'>;
%template(int_function5) int_function<5>;
%template(MemberTemplateInt) MemberTemplate<int>;
%extend MemberTemplate<int> { %template(get6) get<6>; }
%template(HolderInt) Holder<int>;
%template(HolderParm7) HolderParm<7>;
%template(Undeduced8) Undeduced<8>;
