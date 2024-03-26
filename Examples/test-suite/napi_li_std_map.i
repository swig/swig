// Node-API specific implementations
// (with copy-conversion)
%module napi_li_std_map

/* --- std::map --- */
%include "std_map.i"

// for valueAverage & stringifyKeys
%apply(std::map INPUT)               { std::map m };

// for populate
%apply(std::map &OUTPUT)             { std::map &m };

%include "li_std_map.i"

// https://github.com/mmomtchev/swig/issues/44
%typemap(out) std::map<std::string, bool> = std::map RETURN;
%inline {
std::map<std::string, bool> return_map() {
  return { {"a", true}, {"b", false} };
}
}

// https://github.com/mmomtchev/swig/issues/43
%typemap(out) std::map<std::string, std::map<std::string, bool>> = std::map RETURN;
%inline {
std::map<std::string, std::map<std::string, bool>> return_map_map() {
  return { {"map", { {"a", true}, {"b", false} } } };
}
}
