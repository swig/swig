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

void checker() {
  SomeParms<int> spi;
  spi.primary_method();
  SomeParms<Pack<>> spp;
  spp.partial_method();
  SomeParms<Pack<std::string>> sps;
  sps.partial_method("hello");
  SomeParms<Pack<int, double>> spid;
  spid.partial_method(10, 11.1);
}
%}

%template(SomeParmsInt) SomeParms<int>;

%template(PackIntNoParms) Pack<>;
%template(SomeParmsNoParms) SomeParms<Pack<>>;

%template(PackIntString) Pack<std::string>;
%template(SomeParmsString) SomeParms<Pack<std::string>>;

%template(PackIntDouble) Pack<int, double>;
%template(SomeParmsIntDouble) SomeParms<Pack<int, double>>;
