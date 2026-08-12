/* This testcase checks whether SWIG correctly uses the new alternate functions
   declarations and definitions introduced in C++11. */
%module cpp11_alternate_function_syntax

#ifdef SWIGC
// SWIG/C doesn't currently support wrapping pointer to member.
%ignore addAlternateMemberPtrParm(int x, int (SomeStruct::*mp)(int, int));
%ignore addAlternateMemberPtrConstParm(int x, int (SomeStruct::*mp)(int, int) const) const;
// SWIG/C doesn't currently support wrapping rvalue reference return types.
%ignore SomeStruct::output(short);
#endif

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

  // These return types didn't parse in SWIG < 4.3.0 (#3031)
  auto output_rvalueref() -> Hello&&;
  auto output_constref() -> const Hello&;
  enum E { A, B };
  auto output_enum() -> enum E { return A; }

  // Pointer and primitive reference return types
  auto output_ptr() -> Hello*;
  auto output_constptr() -> const Hello*;
  auto int_ptr() -> int*;
  auto int_ptr_ptr() -> int**;
  auto int_ref() -> int&;
  auto int_constref() -> const int&;
  auto int_rvalueref() -> int&&;
  auto hello_const() -> const Hello;
  auto int_constptr() -> int* const&;
  auto void_ptr() -> void*;
  auto array_ref() -> int(&)[3];
  auto fn_ptr() -> int(*)(int);
  auto member_ptr() -> int (SomeStruct::*)(int, int);

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
auto SomeStruct::output_rvalueref() -> Hello&& { static Hello h; return std::move(h); }
auto SomeStruct::output_constref() -> const Hello& { static Hello h; return h; }

static int global_int = 11;
static int global_array[3] = { 1, 2, 3 };
static int doubler(int x) { return 2 * x; }

auto SomeStruct::output_ptr() -> Hello* { static Hello h; return &h; }
auto SomeStruct::output_constptr() -> const Hello* { static Hello h; return &h; }
auto SomeStruct::int_ptr() -> int* { return &global_int; }
auto SomeStruct::int_ptr_ptr() -> int** { static int *p = &global_int; return &p; }
auto SomeStruct::int_ref() -> int& { return global_int; }
auto SomeStruct::int_constref() -> const int& { return global_int; }
auto SomeStruct::int_rvalueref() -> int&& { return std::move(global_int); }
auto SomeStruct::hello_const() -> const Hello { static Hello h; return h; }
auto SomeStruct::int_constptr() -> int* const& { static int* const p = &global_int; return p; }
auto SomeStruct::void_ptr() -> void* { return &global_int; }
auto SomeStruct::array_ref() -> int(&)[3] { return global_array; }
auto SomeStruct::fn_ptr() -> int(*)(int) { return doubler; }
auto SomeStruct::member_ptr() -> int (SomeStruct::*)(int, int) { return &SomeStruct::addNormal; }

%}
