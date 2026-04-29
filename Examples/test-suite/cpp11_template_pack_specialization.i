%module cpp11_template_pack_specialization

%include <std_string.i>

%inline %{
#include <string>
template <typename...> struct Pack {};

template <typename T>       struct SomeParms {
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
