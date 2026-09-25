%module cpp17_auto_nontype_template_parameter

// decltype of a 'template<auto N>' parameter, and an auto variable initialised by it, have the type of the template argument.
%inline %{
template<auto N> struct AutoParm {
  auto get() const -> decltype(N) { return N; }
  decltype(N) member = N;
  static constexpr auto value = N;
};

template<auto N> auto auto_function() -> decltype(N) { return N; }
%}

%template(AutoParmInt) AutoParm<3>;
%template(AutoParmChar) AutoParm<'c'>;
%template(AutoParmBool) AutoParm<true>;
%template(AutoParmUnsigned) AutoParm<7u>;
%template(auto_function_long) auto_function<8L>;
