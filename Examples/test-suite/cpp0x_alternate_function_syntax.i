%module cpp0x_alternate_function_syntax

%inline %{
struct SomeStruct {
  int addNormal(int x, int y);
  auto addAlternate(int x, int y) -> int;
};
 
auto SomeStruct::addAlternate(int x, int y) -> int {
  return x + y;
}

int SomeStruct::addNormal(int x, int y) {
  return x + y;
}
%}
