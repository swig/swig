%module xxx
// This is a copy of Examples/test-suite/cpp11_template_parameters_decltype
%inline %{
// Github issue #1589
template <decltype(true) X = true>
void A() { }
%}

// %template(A) A<>; // not working
%template(A) A<true>; // workaround


%include <std_string.i>
%include <std_vector.i>
%include <std_map.i>

//#pragma SWIG nowarn=SWIGWARN_CPP11_DECLTYPE

%{
// Simple implementation of helper functions required in test below
std::string array(std::vector<std::string>::const_iterator begin, std::vector<std::string>::const_iterator end) {
  return "not implemented";
}
std::string object(std::map<std::string, std::string>::const_iterator begin, std::map<std::string, std::string>::const_iterator end) {
  return "not implemented";
}
%}

%inline %{
#include <iostream>

// Github issue #1590
struct Converter {
  std::string to_json() const { return std::string(); }
};
struct Json {
  int ctor;
  Json(std::string s) : ctor(0) {}
  template < class T, class = decltype(&T::to_json) >
    Json(const T & t) : Json(t.to_json()) { ctor = 1; }

// Github issue #1589
  // Implicit constructor: map-like objects (std::map, std::unordered_map, etc)
  template <class M, typename std::enable_if<
      std::is_constructible<std::string, decltype(std::declval<M>().begin()->first)>::value,
      int>::type = 0>
          Json(const M & m) : Json(object(m.begin(), m.end())) { ctor = 2; }
  // Implicit constructor: vector-like objects (std::list, std::vector, std::set, etc)
  template <class V, typename std::enable_if<
      std::is_constructible<Json, decltype(*std::declval<V>().begin())>::value,
          int>::type = 0>
  Json(const V & v) : Json(array(v.begin(), v.end())) { ctor = 3; }

  // Same sort of thing as constructors above but for a member function
  int mmm(std::string s) { return 100; }
  template < class T, class = decltype(&T::to_json) >
    int mmm(const T & t) { return 101; }
  template <class M, typename std::enable_if<
    std::is_constructible<std::string, decltype(std::declval<M>().begin()->first)>::value,
    int>::type = 0>
      int mmm(const M & m) { return 102; }
  template <class V, typename std::enable_if<
    std::is_constructible<Json, decltype(*std::declval<V>().begin())>::value,
    int>::type = 0>
      int mmm(const V & v) { return 103; }
};

void tester(bool show) {
  // Example usage from c++
  if (show) {
    Json json0(std::string("hi"));
    Converter converter;
    std::cout << "json0 " << json0.ctor << std::endl;
    Json json1 = Json(converter);
    std::cout << "json1 " << json1.ctor << std::endl;
    std::map<std::string, std::string> myStringStringMap;
    Json json2 = Json(myStringStringMap);
    std::cout << "json2 " << json2.ctor << std::endl;
    std::vector<std::string> myVectorString;
    Json json3 = Json(myVectorString);
    std::cout << "json3 " << json3.ctor << std::endl;

    std::cout << "json0.mmm " << json0.mmm("bye") << std::endl;
    std::cout << "json1.mmm " << json1.mmm(converter) << std::endl;
    std::cout << "json2.mmm " << json2.mmm(myStringStringMap) << std::endl;
    std::cout << "json3.mmm " << json3.mmm(myVectorString) << std::endl;
  }
}
%}

%template(VectorString) std::vector<std::string>;
%template(MapStringString) std::map<std::string, std::string>;

// There is quite a bit of inconsistency about providing or not providing default
// template parameters that needs investigating. Below is a combination that works.

// Note that instantiating the two Json constructors (or the two mmm methods) that
// use enable_if is ambiguous given the enable_if is not evaluated by SWIG.

// %template(Json) Json::Json<Converter>; // not working
%template(Json) Json::Json<Converter, std::string>; // workaround
%template(Json) Json::Json<std::map<std::string, std::string>, 0>;
%template(Json) Json::Json<std::vector<std::string>, 0>;

%template(mmm) Json::mmm<Converter, std::string>;
%template(mmm) Json::mmm<std::map<std::string, std::string>, 0>;
%template(mmm) Json::mmm<std::vector<std::string>, 0>;
