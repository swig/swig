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

// Test handling of ID PERIOD ID in constant expressions (supported since 4.1.0).
struct A {
    int i;
};
constexpr A a{42};
const int N = a.i;

%}
