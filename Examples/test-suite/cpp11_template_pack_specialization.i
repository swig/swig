%module cpp11_template_pack_specialization

%include <std_string.i>

%inline %{
#include <string>
template <typename...> struct Pack {};

template <typename T>  struct SomeParms {
  void primary_method() {}
};

template <typename... ARGS> struct SomeParms<Pack<ARGS...>> {
  void partial_method(ARGS...) {}
};

template <typename T> struct SomeParms2 {
  void primary2_method() {}
};

template <typename A, typename... ARGS> struct SomeParms2<Pack<A, ARGS...>> {
  void partial2_methodA(ARGS...) {}
  void partial2_methodB(A, ARGS...) {}
  void partial2_methodC(A) {}
};

void checker() {
  SomeParms<int> spi;
  spi.primary_method();
  SomeParms<Pack<>> spp;
  spp.partial_method();
  SomeParms<Pack<std::string>> sps;
  sps.partial_method("hello");
  SomeParms<Pack<int, double>> spid;
  spid.partial_method(10, 11.1);
  SomeParms2<Pack<int>> sp2i;
  sp2i.partial2_methodC(20);
  SomeParms2<Pack<int, double>> sp2id;
  sp2id.partial2_methodA(11.1);
  sp2id.partial2_methodB(55, 11.1);
  sp2id.partial2_methodC(55);
  SomeParms2<Pack<int, double, float>> sp2idf;
  sp2idf.partial2_methodA(11.1, 22.2f);
  sp2idf.partial2_methodB(55, 11.1, 22.2f);
  sp2idf.partial2_methodC(55);
}
%}

%template(SomeParmsInt) SomeParms<int>;

%template(PackIntNoParms) Pack<>;
%template(SomeParmsNoParms) SomeParms<Pack<>>;

%template(PackIntString) Pack<std::string>;
%template(SomeParmsString) SomeParms<Pack<std::string>>;

%template(PackIntDouble) Pack<int, double>;
%template(SomeParmsIntDouble) SomeParms<Pack<int, double>>;

%template(SomeParms2PackInt) SomeParms2<Pack<int>>;
%template(SomeParms2PackIntDouble) SomeParms2<Pack<int, double>>;
%template(SomeParms2PackIntDoubleFloat) SomeParms2<Pack<int, double, float>>;


%rename(call) *::operator();

%inline %{
// StdFunction is similar to std::function
template <typename T> struct StdFunction {
  void primary_function() {}
};

template <typename RET, typename... ARGS> class StdFunction<RET(ARGS...)> {
public:
  using result_type = RET;

  StdFunction() = default;

  RET call_operator(ARGS... args) const {
    return operator() (args...);
  }
  RET operator()(ARGS... args) const {
    if constexpr (sizeof...(args) == 0)
      return RET();
    else
      return (... + args); // Unpacks as (arg1 + (arg2 + arg3...))
  }
};
%}

%inline %{
bool function_checker() {
  bool okay = true;
  StdFunction<int(int, int)> f_int;

  int result = f_int(10, 20);
  okay = result == 30;

  result = f_int.call_operator(20, 30);
  okay = okay && result == 50;

  // Zero parameters - returns int{} == 0
  StdFunction<int()> f_int0;
  okay = okay && f_int0() == 0;
  okay = okay && f_int0.call_operator() == 0;

  // Single parameter - the unary fold yields the single arg
  StdFunction<int(int)> f_int1;
  okay = okay && f_int1(7) == 7;
  okay = okay && f_int1.call_operator(7) == 7;

  // Different result/argument types
  StdFunction<double(double, double)> f_double;
  okay = okay && f_double(1.5, 2.25) == 3.75;
  okay = okay && f_double.call_operator(1.5, 2.25) == 3.75;

  StdFunction<std::string(std::string, std::string)> f_string;
  okay = okay && f_string(std::string("ab"), std::string("cd")) == std::string("abcd");
  okay = okay && f_string.call_operator(std::string("ab"), std::string("cd")) == std::string("abcd");

  // Mixed argument types (int + double promotes to double; assigned back to int)
  StdFunction<int(int, double, int)> f_mixed;
  okay = okay && f_mixed(1, 2.0, 3) == 6;
  okay = okay && f_mixed.call_operator(1, 2.0, 3) == 6;

  return okay;
}
%}

%template(StdFunctionVoid) StdFunction<int()>;
%template(StdFunctionInt) StdFunction<int(int)>;
%template(StdFunctionIntInt) StdFunction<int(int, int)>;
%template(StdFunctionDoubleDouble) StdFunction<double(double, double)>;
%template(StdFunctionStringString) StdFunction<std::string(std::string, std::string)>;
%template(StdFunctionMixed) StdFunction<int(int, double, int)>;
