%module cpp11_template_function_overload_kind

// %template instantiates only the function template overloads whose template parameters take the template arguments

%inline %{
template<typename T, typename U = int> int dflt(T) { return 1; }
template<typename T> int dflt(T, T) { return 2; }

template<typename T, int N = 3> int value_default(T) { return N; }

// A member function template default naming a template parameter of the class template
template<typename T> struct DefaultHolder {
  template<typename U, typename V = T> V convert(U u) { return (V)u; }
};

template<typename... Ts> int pack() { return 10 + (int)sizeof...(Ts); }
template<int... Ns> int pack() { return 20 + (int)sizeof...(Ns); }

template<typename T, int... Ns> int mixed() { return 30 + (int)sizeof...(Ns); }
template<int N, typename... Ts> int mixed() { return 40 + (int)sizeof...(Ts); }
%}

%template(dflt_int) dflt<int>;
%template(value_default_int) value_default<int>;
%template(value_default_int_4) value_default<int, 4>;

%template(DefaultHolderInt) DefaultHolder<int>;
%extend DefaultHolder<int> {
  %template(convert_double) convert<double>;
}

%template(pack_types) pack<int, double>;
%template(pack_values) pack<1, 2, 3>;

%template(mixed_type_first) mixed<int, 1, 2>;
%template(mixed_value_first) mixed<1, int, double, short>;
