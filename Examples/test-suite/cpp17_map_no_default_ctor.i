%module cpp17_map_no_default_ctor
// Tests c++17 insert_or_assign for std::map with no default constructor

%include <std_map.i>

%ignore NoDefaultConstructorStruct::operator<;
%inline %{
struct NoDefaultConstructorStruct final
{
	int value{0};
	NoDefaultConstructorStruct(int v) : value(v) {}
        bool operator<(const NoDefaultConstructorStruct& other) const { return value < other.value; }
};
using NoDefaultConstructorStructMap = std::map<int, NoDefaultConstructorStruct>;
%}

//%template(PairIntNoDefaultConstructorStruct) std::pair<const int, NoDefaultConstructorStruct>;
%template(NoDefaultConstructorStructMap) std::map<int, NoDefaultConstructorStruct>;
