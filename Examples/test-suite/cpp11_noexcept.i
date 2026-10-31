%module cpp11_noexcept

%include <std_string.i>

%ignore NoExceptAbstract::operator std::string;
%ignore NoExceptAbstract::operator int;
%ignore NoExceptClass(NoExceptClass&&);
%rename(Assignment) NoExceptClass::operator=;

%{
#if defined(__clang__)
// Suppress: mangled name of 'f2087a' will change in C++17 due to non-throwing exception specification in function signature
#pragma clang diagnostic ignored "-Wc++17-compat-mangling"
#endif
%}

%{
extern "C" void global_noexcept(int, bool) noexcept {}
%}
%inline %{
#include <string>

extern "C" void global_noexcept(int, bool) noexcept;
extern "C" void global_noexcept2(int, bool) noexcept {}

struct NoExceptClass {
  static const bool VeryTrue = true;

  NoExceptClass() noexcept {}
  NoExceptClass(const NoExceptClass&) noexcept {}
  NoExceptClass(NoExceptClass&&) noexcept {}
  NoExceptClass& operator=(const NoExceptClass&) noexcept { return *this; }
  virtual ~NoExceptClass() noexcept {}

  void noex0() noexcept {}
  void noex1() noexcept(sizeof(int) == 4) {}
  void noex2() noexcept(true) {}
  void noex3() noexcept(false) {}
  void noex4() noexcept(VeryTrue) {}

  template<typename T> void template_noexcept(T) noexcept {}

  void noo1() const noexcept {}
  static void noo2() noexcept {}
  virtual void noo3() const noexcept {}

// Workaround clang 10.0.1 -std=c++17 linker error (oddly for Java and not Python):
// Undefined symbols for architecture x86_64: "___cxa_deleted_virtual", referenced from: vtable for NoExceptClass
#if !(defined(__clang__) && __cplusplus >= 201703L)
  virtual void noo4() const noexcept = delete;
  virtual void noo5() const throw() = delete;
#endif
};

struct NoExceptAbstract {
  virtual void noo4() const noexcept = 0;
  virtual ~NoExceptAbstract() noexcept = 0;
  // Regression test for https://github.com/swig/swig/issues/2474
  virtual explicit operator std::string() const noexcept = 0;
  explicit virtual operator int() const noexcept = 0;
};

struct NoExceptDefaultDelete {
  template<typename T> NoExceptDefaultDelete(T) noexcept = delete;
  NoExceptDefaultDelete() noexcept = default;
  NoExceptDefaultDelete(const NoExceptDefaultDelete&) noexcept = delete;
  NoExceptDefaultDelete(NoExceptDefaultDelete&&) = delete;
  NoExceptDefaultDelete& operator=(const NoExceptDefaultDelete&) = delete;
  ~NoExceptDefaultDelete() noexcept = default;
};

%}

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW0() throw()
%{
#define TESTCASE_THROW0()
%}

// Member functions returning a pointer to a function, the exception specification goes inside the parentheses
%inline %{
std::string noexceptAddOne(int i) { return std::to_string(i + 1); }
std::string noexceptCallStringFunc(std::string (*f)(int), int i) { return f(i); }
struct NoExceptFuncPtrReturn {
  std::string (*ptr1() noexcept)(int) { return noexceptAddOne; }
  std::string (*ptr2() const noexcept)(int) { return noexceptAddOne; }
  std::string (*ptr3() noexcept(true))(int) { return noexceptAddOne; }
  std::string (*ptr4() TESTCASE_THROW0())(int) { return noexceptAddOne; }
  std::string (*ptr5() const TESTCASE_THROW0())(int) { return noexceptAddOne; }
};
%}

// Regression tests for #2087 (noexcept on a function pointer parameter type), extern "C" as C++17 changes their mangled names
%inline %{
extern "C" void f2087a(int (*g)() noexcept) { (void)g; }
extern "C" void f2087b(int const (*g)() noexcept) { (void)g; }
%}

// noexcept on the type of the function pointed to, not on the declared function
%inline %{
int noexceptAddTwo(int i) noexcept { return i + 2; }
int noexceptCallIntFunc(int (*f)(int), int i) { return f(i); }
int (*noexceptGetAddTwo())(int) noexcept { return noexceptAddTwo; }
extern "C" int noexceptCallNoExceptFunc(int (*f)(int) noexcept, int i) { return f(i); }
struct NoExceptFuncPtrMember {
  int (*ptr)(int) noexcept;
  NoExceptFuncPtrMember() : ptr(noexceptAddTwo) {}
};
std::string (*noexceptGetAddOne() noexcept)(int) { return noexceptAddOne; }
std::string (*(*noexceptGetGetter())() noexcept)(int) { return noexceptGetAddOne; }
%}
