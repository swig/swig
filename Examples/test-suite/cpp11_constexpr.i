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
#endif

#include <limits>
%}

%ignore operator==(ConstExpressions,ConstExpressions);
%ignore operator!=(ConstExpressions,ConstExpressions);

%inline %{
#ifdef SWIG
#define SWIGTESTCONST const
#else
#define SWIGTESTCONST
#endif
constexpr int AAA = 10;
constexpr const int BBB = 20;
constexpr int CCC() { return 30; }
constexpr SWIGTESTCONST int DDD() { return 40; }

constexpr int XXX() { return 10; }
constexpr int YYY = XXX() + 100;

struct ConstExpressions {
  static constexpr const int JJJ = 100;
  static constexpr int KKK = 200;
  static const int LLL = 300;
  constexpr int MMM() { return 400; }
  constexpr SWIGTESTCONST int NNN() { return 500; }
  // Regression tests for support added in SWIG 3.0.4:
  static constexpr const int JJJ1 = 101;
  constexpr static int KKK1 = 201;
  // Regression tests for https://github.com/swig/swig/issues/284 :
  explicit constexpr ConstExpressions(int) { }
  constexpr explicit ConstExpressions(double) { }
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
template<int N> constexpr int inc() { return N + 1; };
unsigned char myarray2[inc<(1)>()];

// Test handling of ID PERIOD ID in constant expressions (supported since 4.1.0).
struct A {
    int i;
};
constexpr A a{42};
constexpr int N = a.i;
%}
