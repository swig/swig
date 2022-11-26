%module cpp11_template_parameters_decltype

%include <std_string.i>
%include <std_vector.i>
%include <std_pair.i>

#pragma SWIG nowarn=SWIGWARN_CPP11_DECLTYPE

#if 0
// to fix (non-template expression equivalent to template expression further down):
%inline %{
#include <utility>
#include <vector>
  void f(bool c = std::is_constructible<std::string, decltype(std::declval<std::vector<std::pair<int, int>>>().begin()->first)>::value) {}
%}
#endif

%inline %{
// Github issue #1590
struct Converter {
  std::string to_json() const { return std::string(); }
};
struct Json {
  Json(std::string s) {}
  template < class T, class = decltype(&T::to_json) >
    Json(const T & t) : Json(t.to_json()) {}

// Github issue #1589
// To fix
#if !defined(SWIG)
  // Implicit constructor: map-like objects (std::map, std::unordered_map, etc)
  template <class M, typename std::enable_if<
      std::is_constructible<std::string, decltype(std::declval<M>().begin()->first)>::value,
      int>::type = 0>
          Json(const M & m) : Json(object(m.begin(), m.end())) {}
#endif
};
%}

// %template(Json) Json::Json<Converter>; // not working
%template(Json) Json::Json<Converter, std::string>; // workaround


%inline %{
// Github issue #1589
template <decltype(true) X = true>
void A() { }
%}

// %template(A) A<>; // not working
%template(A) A<true>; // workaround
