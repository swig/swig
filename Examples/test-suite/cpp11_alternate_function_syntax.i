/* This testcase checks whether SWIG correctly uses the new alternate functions
   declarations and definitions introduced in C++11. */
%module cpp11_alternate_function_syntax

%inline %{
struct Hello {};

struct SomeStruct {
  int addNormal(int x, int y);
  auto addAlternate(int x, int y) -> int;
  auto addAlternateConst(int x, int y) const -> int;
  auto addAlternateNoExcept(int x, int y) noexcept -> int;
  auto addAlternateConstNoExcept(int x, int y) const noexcept -> int;
  auto addAlternateMemberPtrParm(int x, int (SomeStruct::*mp)(int, int)) -> int;
  auto addAlternateMemberPtrConstParm(int x, int (SomeStruct::*mp)(int, int) const) const -> int;

  // Returning a reference didn't parse in SWIG < 4.1.0 (#231)
  auto output() -> Hello&;

  virtual auto addFinal(int x, int y) const noexcept -> int final { return x + y; }
  virtual ~SomeStruct() = default;
};
 
int SomeStruct::addNormal(int x, int y) { return x + y; }
auto SomeStruct::addAlternate(int x, int y) -> int { return x + y; }
auto SomeStruct::addAlternateConst(int x, int y) const -> int { return x + y; }
auto SomeStruct::addAlternateNoExcept(int x, int y) noexcept -> int { return x + y; }
auto SomeStruct::addAlternateConstNoExcept(int x, int y) const noexcept -> int { return x + y; }
auto SomeStruct::addAlternateMemberPtrParm(int x, int (SomeStruct::*mp)(int, int)) -> int {
  return 100*x + (this->*mp)(x, x);
}
auto SomeStruct::addAlternateMemberPtrConstParm(int x, int (SomeStruct::*mp)(int, int) const) const -> int {
  return 1000*x + (this->*mp)(x, x);
}
auto SomeStruct::output() -> Hello& { static Hello h; return h; }

%}
