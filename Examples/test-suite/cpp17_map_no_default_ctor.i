%module cpp17_map_no_default_ctor
// Tests c++17 insert_or_assign for std::map with no default constructor

%include <std_map.i>

%inline %{
struct NoDefaultConstructorStruct final
{
	int value{0};
	NoDefaultConstructorStruct(int v) : value(v) {}
};
using NoDefaultConstructorStructMap = std::map<int, NoDefaultConstructorStruct>;
%}

%template(NoDefaultConstructorStructMap) std::map<int, NoDefaultConstructorStruct>;
