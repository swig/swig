%module cpp11_auto_variable_template_parameter

// An auto variable initialised by a non-type template parameter has the type the parameter is declared with.
%inline %{
template<int N> struct IntParm {
  static constexpr auto value = N;
};

template<const short N> struct ConstShortParm {
  static constexpr auto value = N;
};
%}

%template(IntParm3) IntParm<3>;
%template(ConstShortParm4) ConstShortParm<4>;
