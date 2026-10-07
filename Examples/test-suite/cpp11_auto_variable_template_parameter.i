%module cpp11_auto_variable_template_parameter

// An auto variable initialised by a non-type template parameter has the type the parameter is declared with.
%inline %{
template<int N> struct IntParm {
  static constexpr auto value = N;
};

template<const short N> struct ConstShortParm {
  static constexpr auto value = N;
};

// A conversion to a type template parameter is a value of that type, without the argument's cv-qualifiers.
template<typename T> struct TypeParm {
  static constexpr auto zero = T();
  static constexpr auto three = T(3);
  static constexpr auto four = T{4};
  auto made() const -> decltype(T()) { return T(); }
};
%}

%template(IntParm3) IntParm<3>;
%template(ConstShortParm4) ConstShortParm<4>;
%template(TypeParmDouble) TypeParm<double>;
%template(TypeParmConstShort) TypeParm<const short>;
