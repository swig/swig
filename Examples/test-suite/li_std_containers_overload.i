%module li_std_containers_overload

// Suppress warning that ought not to appear, but there is no easy fix
%warnfilter(SWIGWARN_LANG_OVERLOAD_SHADOW) VectorOverload;

%include <std_string.i>
%include <std_vector.i>

%inline %{
struct X {};
struct Y {};
%}

%template(VectorX) std::vector<X>;
%template(VectorY) std::vector<Y>;
%template(VectorString) std::vector<std::string>;
%template(VectorInt) std::vector<int>;

%inline %{
using namespace std;
string VectorOverload(vector<X> v) {
  return "vector<X>";
}
string VectorOverload(vector<Y> v) {
  return "vector<Y>";
}
string VectorOverload(vector<string> v) {
  return "vector<string>";
}
string VectorOverload(vector<int> v) {
  return "vector<int>";
}
%}
