%module li_std_tuple

#if defined(SWIGPYTHON) || defined(SWIGGO) || defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGLUA) || defined(SWIGPHP) || defined(SWIGRUBY)

%include <std_tuple.i>

%template(IntDoubleTuple) std::tuple<int, double>;
%template(DoubleTuple) std::tuple<double>;

%inline %{

  double sum_pair_values(std::tuple<int, double> t) {
    return std::get<0>(t) + std::get<1>(t);
  }

  std::tuple<int, double> make_int_double(int a, double b) {
    return std::make_tuple(a, b);
  }

  std::tuple<int, double> pass_tuples(
    std::tuple<int, double> by_val,
    const std::tuple<int, double>& by_const_ref
  ) {
    return std::make_tuple(
      std::get<0>(by_val) + std::get<0>(by_const_ref),
      std::get<1>(by_val) + std::get<1>(by_const_ref)
    );
  }
%}

#endif
