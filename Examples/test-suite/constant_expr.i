%module constant_expr;
/* Tests of constant expressions (C++ version). */

%include "constant_expr_c.i"

%inline %{

// Testcase from https://sourceforge.net/p/swig/bugs/1139/
template<typename Tp>
struct SizeInfo {
enum {
isLarge = (sizeof(Tp)>sizeof(void*)),
isPointer = false
};
};

/* Regression test for #300, fixed in 4.1.0.
 *
 * Now `9%a` without a space after the `%` is handled as a modulus operator,
 * but it gave a cryptic `Syntax error in input(1)` before SWIG 3.0.4, and from
 * SWIG 3.0.4 until 4.1.0, `Unknown directive '%a'`.
 */
int a;
int test2(int b = 9%a) { return b; }

/* Example from manual, adapted to avoid C++11 requirement. */
namespace fakestd {
  template<typename T, unsigned N>
  class array {
      T a[N];
    public:
      array() {}
  };
}
void bar(fakestd::array<int, (1<2? 100 : 50)> *x) { }

%}

// Regression test for #2919, fixed in 4.3.0.
//
// sizeof() didn't work on complex expressions or types.
//
// This is just a parsing test for SWIG as it uses C++11 features.
#include <type_traits>
template <typename T>
class InternalHelper {
public:
// Original source: https://github.com/protocolbuffers/protobuf/blob/v20.2/src/google/protobuf/arena.h#L449-L458
    template <typename U>
    static char DestructorSkippable(const typename U::DestructorSkippable_*);
    template <typename U>
    static double DestructorSkippable(...);

    typedef std::integral_constant<
        bool, sizeof(DestructorSkippable<T>(static_cast<const T*>(0))) ==
                      sizeof(char) ||
                  std::is_trivially_destructible<T>::value>
        is_destructor_skippable;

    // This is nonsensical, but provides a regression test for this not working with alignof() either.
    typedef std::integral_constant<
        bool, alignof(DestructorSkippable<T>(static_cast<const T*>(0))) ==
                      alignof(char) ||
                  std::is_trivially_destructible<T>::value>
        test_alignof_too;
};

%constant int WSTRING_LIT_LEN1 = (sizeof(L"1234")/sizeof(wchar_t) - 1);
%constant int WSTRING_LIT_LEN2 = (sizeof(L"12" L"34")/sizeof(wchar_t) - 1);
