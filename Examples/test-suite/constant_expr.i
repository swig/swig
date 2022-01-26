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

%}
