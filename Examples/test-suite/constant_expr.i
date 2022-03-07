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
 * Now `a%b` without a space after the `%` is handled as a modulus operator,
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
