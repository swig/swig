%module kotlin_std_map

// Regression test for the Kotlin std::map wrapper:
//  - the containsKey/get/remove overrides take nullable keys, matching the
//    java.util.AbstractMap declarations they override
//  - a by-value std::map member is exposed as a non-null property that can be
//    used directly as a Kotlin Map

%include <std_string.i>
%include <std_map.i>

%template(StringStringMap) std::map<std::string, std::string>;

%inline %{
struct MapHolder {
  std::map<std::string, std::string> metadata;
};
%}
