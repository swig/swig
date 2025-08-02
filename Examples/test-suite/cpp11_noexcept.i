%module cpp11_noexcept

%ignore NoExceptAbstract::operator std::string;
%ignore NoExceptAbstract::operator int;
%ignore NoExceptClass(NoExceptClass&&);
%rename(Assignment) NoExceptClass::operator=;

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

// Regression tests for #2087 (noexcept on a function pointer parameter type).
//
// FIXME: We've only fixed `noexcept` on parameter types which are function
// pointers to parse - the generated code has `noexcept` in the wrong place
// and won't compile so for now we only check SWIG can parse this.
%ignore f2087a;
%ignore f2087b;
void f2087a(int (*g)() noexcept) { (void)g; }
void f2087b(int const (*g)() noexcept) { (void)g; }
