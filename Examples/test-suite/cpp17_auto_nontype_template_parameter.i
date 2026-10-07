%module cpp17_auto_nontype_template_parameter

// decltype of a 'template<auto N>' parameter, and an auto variable initialised by it, have the type of the template argument.
%inline %{
template<auto N> struct AutoParm {
  auto get() const -> decltype(N) { return N; }
  decltype(N) member = N;
  static constexpr auto value = N;
};

template<auto N> auto auto_function() -> decltype(N) { return N; }

// The address of a variable is a pointer, with or without parentheses round the variable's name.
template<auto P> struct AddressParm {
  auto get() const -> decltype(P) { return P; }
};
int address_target = 4;
int paren_address_target = 5;
int address_value(int *p) { return *p; }
%}

%template(AutoParmInt) AutoParm<3>;
%template(AutoParmChar) AutoParm<'c'>;
%template(AutoParmBool) AutoParm<true>;
%template(AutoParmUnsigned) AutoParm<7u>;
%template(auto_function_long) auto_function<8L>;
%template(AddressParmPlain) AddressParm<&address_target>;
%template(AddressParmParen) AddressParm<&(paren_address_target)>;
