/* This testcase checks whether Swig correctly uses the new alternate functions
   declarations and definitions introduced in C++0x. */
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
