%module xxx

// Only an auto variable initialised by exactly a conversion to a type template parameter is deduced as that parameter.
template<class T> struct Expression {
  static constexpr auto sum = T(3) + 1;
  static constexpr auto braced_sum = T{} + 1;
};

%template(ExpressionInt) Expression<int>;
