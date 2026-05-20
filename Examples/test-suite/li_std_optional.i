%module li_std_optional

#if defined(SWIGPYTHON) || defined(SWIGGO) || defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGLUA) || defined(SWIGPHP) || defined(SWIGRUBY)

%include <std_optional.i>

%template(OptionalInt) std::optional<int>;
%template(OptionalDouble) std::optional<double>;

%inline %{

  std::optional<int> make_optional(int val) {
    return std::optional<int>(val);
  }

  std::optional<int> make_empty_optional() {
    return std::optional<int>();
  }

  int optional_value_or(std::optional<int> opt, int fallback) {
    return opt.value_or(fallback);
  }

  double optional_passthrough(std::optional<int> by_val,
                              const std::optional<double>& by_const_ref) {
    double result = 0.0;
    if (by_val.has_value()) result += by_val.value();
    if (by_const_ref.has_value()) result += by_const_ref.value();
    return result;
  }
%}

#endif
