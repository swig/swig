%module cpp0x_alternate_function_syntax

%inline %{
struct SomeStruct {
  auto FuncName(int x, int y) -> int;
};
 
auto SomeStruct::FuncName(int x, int y) -> int {
  return x + y;
}
%}
