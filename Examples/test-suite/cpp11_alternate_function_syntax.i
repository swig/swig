/* This testcase checks whether SWIG correctly uses the new alternate functions
   declarations and definitions introduced in C++11. */
%module cpp11_alternate_function_syntax

%inline %{
struct SomeStruct {
  int addNormal(int x, int y);
  auto addAlternate(int x, int y) -> int;
  auto addAlternateConst(int x, int y) const -> int;
  auto addAlternateNoExcept(int x, int y) noexcept -> int;
  auto addAlternateConstNoExcept(int x, int y) const noexcept -> int;
};
 
int SomeStruct::addNormal(int x, int y) { return x + y; }
auto SomeStruct::addAlternate(int x, int y) -> int { return x + y; }
auto SomeStruct::addAlternateConst(int x, int y) const -> int { return x + y; }
auto SomeStruct::addAlternateNoExcept(int x, int y) noexcept -> int { return x + y; }
auto SomeStruct::addAlternateConstNoExcept(int x, int y) const noexcept -> int { return x + y; }

%}
