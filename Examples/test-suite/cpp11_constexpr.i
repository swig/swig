/* This interface tests whether SWIG supports the new "constexpr" keyword
   introduced by C++11.
*/
%module cpp11_constexpr


%{
#if defined(__clang__)
#pragma clang diagnostic push
// Suppress: 'constexpr' non-static member function will not be implicitly 'const' in C++14; add 'const' to avoid a change in behavior
// For MMM() and NNN()
#pragma clang diagnostic ignored "-Wconstexpr-not-const"
// Suppress: mangled name of 'takeConstNoexceptPtr' will change in C++17 due to non-throwing exception specification in function signature
#pragma clang diagnostic ignored "-Wc++17-compat-mangling"
#endif

#include <limits>
%}

%ignore operator==(ConstExpressions,ConstExpressions);
%ignore operator!=(ConstExpressions,ConstExpressions);

%inline %{
#ifdef SWIG
#define TESTCONST const
#else
#define TESTCONST
#endif
constexpr int AAA = 10;
constexpr const int BBB = 20;
constexpr int CCC() { return 30; }
constexpr TESTCONST int DDD() { return 40; }

constexpr int XXX() { return 10; }
constexpr int YYY = XXX() + 100;

struct ConstExpressions {
  static constexpr const int JJJ = 100;
  static constexpr int KKK = 200;
  static const int LLL = 300;
  constexpr int MMM() { return 400; }
  constexpr TESTCONST int NNN() { return 500; }
  // Regression tests for support added in SWIG 3.0.4:
  static constexpr const int JJJ1 = 101;
  constexpr static int KKK1 = 201;
  // Regression tests for https://github.com/swig/swig/issues/284 :
  explicit constexpr ConstExpressions(int) { }
  constexpr explicit ConstExpressions(const char*) { }
  // Regression tests for  https://github.com/swig/swig/issues/2079 :
  constexpr friend bool operator==(ConstExpressions,ConstExpressions) { return true; }
  friend constexpr bool operator!=(ConstExpressions,ConstExpressions) { return false; }
};

int Array10[AAA];
int Array20[BBB];
int Array30[CCC()];
int Array40[DDD()];
int Array100[ConstExpressions::JJJ];
int Array200[ConstExpressions::KKK];
int Array300[ConstExpressions::LLL];
//int Array400[ConstExpressions::MMM()];
//int Array500[ConstExpressions::NNN()];

// Regression test for https://github.com/swig/swig/issues/2486 fixed in 4.2.0
// (the array size is constexpr in C++11):
unsigned char myarray[std::numeric_limits<unsigned char>::max()];
// Also check that `<(` and `)>` in the expression are handled, since these have
// special meanings for SWIG's type system.  SWIG should rewrite them as `< (`
// and `) >` here to avoid problems.
template<int N> constexpr int inc() { return N + 1; }
unsigned char myarray2[inc<(1)>()];

// Test handling of ID PERIOD ID in constant expressions (supported since 4.1.0).
struct A {
    int i;
};
constexpr A a{42};
constexpr int N = a.i;

// Regression test for https://github.com/swig/swig/issues/3127 fixed in 4.4.0:
#include <array>

constexpr std::size_t my_enum_size =
   sizeof(
    decltype(
      42
    )
  ) ? 1 + static_cast<std::size_t>(
    4
  ) : alignof(
    std::size_t
  );

std::array<bool, my_enum_size> do_something() {
  return std::array<bool, my_enum_size>{true,true,true,true,true};
}
%}

// Static constexpr member pointers initialised in the class keep the qualifiers of the type pointed to
%inline %{
struct MemberFuncs {
  short nonConstFunc(bool) { return 1; }
  short constFunc(bool) const { return 2; }
  short volatileFunc(bool) volatile { return 3; }
  short constRefFunc(bool) const & { return 4; }
  short constNoexceptFunc(bool) const noexcept { return 5; }
  const char *constStringFunc(bool) const { return "six"; }
  int data = 7;
};
typedef short (MemberFuncs::*ConstFuncPtr)(bool) const;
struct MemberPointerConstants {
  static constexpr short (MemberFuncs::*NonConstPtr)(bool) = &MemberFuncs::nonConstFunc;
  static constexpr short (MemberFuncs::*ConstPtr)(bool) const = &MemberFuncs::constFunc;
  static constexpr short (MemberFuncs::*VolatilePtr)(bool) volatile = &MemberFuncs::volatileFunc;
  static constexpr short (MemberFuncs::*ConstRefPtr)(bool) const & = &MemberFuncs::constRefFunc;
  static constexpr short (MemberFuncs::*ConstNoexceptPtr)(bool) const noexcept = &MemberFuncs::constNoexceptFunc;
  static constexpr const char *(MemberFuncs::*ConstStringPtr)(bool) const = &MemberFuncs::constStringFunc;
  static constexpr const int MemberFuncs::*ConstDataPtr = &MemberFuncs::data;
  static constexpr ConstFuncPtr TypedefPtr = &MemberFuncs::constFunc;
};
short takeNonConstPtr(short (MemberFuncs::*f)(bool)) { MemberFuncs m; return (m.*f)(true); }
short takeConstPtr(short (MemberFuncs::*f)(bool) const) { MemberFuncs m; return (m.*f)(true); }
short takeVolatilePtr(short (MemberFuncs::*f)(bool) volatile) { MemberFuncs m; return (m.*f)(true); }
short takeConstRefPtr(short (MemberFuncs::*f)(bool) const &) { MemberFuncs m; return (m.*f)(true); }
// extern "C" as C++17 changes the mangled name
extern "C" short takeConstNoexceptPtr(short (MemberFuncs::*f)(bool) const noexcept) { MemberFuncs m; return (m.*f)(true); }
// TODO: Fix the syntax error for a named parameter of this type
const char *takeConstStringPtr(const char *(MemberFuncs::*)(bool) const);
int takeConstDataPtr(const int MemberFuncs::*d) { MemberFuncs m; return m.*d; }
short takeTypedefPtr(ConstFuncPtr f) { MemberFuncs m; return (m.*f)(true); }
%}
%{
const char *takeConstStringPtr(const char *(MemberFuncs::*f)(bool) const) { MemberFuncs m; return (m.*f)(true); }
%}
