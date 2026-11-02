// Tests typedef through function pointers

%module typedef_funcptr

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) addf; /* Ruby, wrong constant name */
%warnfilter(SWIGWARN_RUBY_WRONG_NAME) subf; /* Ruby, wrong constant name */

%{
int addf(int x, int y) {
   return x+y;
}
int subf(int x, int y) {
   return x-y;
}
const char *namef(int i) {
   return i == 1 ? "one" : "many";
}
%}

%inline %{
typedef int Integer;

extern "C"
Integer do_op(Integer x, Integer y, Integer (*op)(Integer, Integer)) {
    return (*op)(x,y);
}

typedef int (*FnPtr_int_td)(int, int);
int do_op_typedef_int(int x, int y, FnPtr_int_td op) {
    return (*op)(x,y);
}

typedef Integer (*FnPtr_Integer_td)(Integer, Integer);
Integer do_op_typedef_Integer(Integer x, Integer y, FnPtr_Integer_td op) {
    return (*op)(x,y);
}

FnPtr_int_td get_op_typedef_int(int subtract) {
    return subtract ? subf : addf;
}

// A function pointer called twice and two function pointer parameters of the same type
int do_op_twice(int x, int y, FnPtr_int_td op) {
    return (*op)((*op)(x, y), y);
}
int do_two_ops(int x, int y, int (*op1)(int, int), int (*op2)(int, int)) {
    return (*op1)(x, y) * 10 + (*op2)(x, y);
}
int (*get_op(int subtract))(int, int) {
    return subtract ? subf : addf;
}

// Function pointers with a const return type
typedef const char *(*FnPtr_name_td)(int);
const char *do_name(int i, const char *(*namer)(int)) {
    return (*namer)(i);
}
const char *do_name_typedef(int i, FnPtr_name_td namer) {
    return (*namer)(i);
}
const char *(*get_name_op())(int) {
    return namef;
}
// Differs from FnPtr_name_td only in the const of the return type
char *do_name_modify(int i, char *(*namer)(int)) {
    char *name = (*namer)(i);
    if (name)
        name[0] = 'N';
    return name;
}

struct OpHolder {
    static FnPtr_int_td static_fn;
    FnPtr_int_td member_fn;
    FnPtr_name_td name_fn;
    OpHolder() : member_fn(addf), name_fn(namef) {}
    FnPtr_int_td get_member_op() const { return member_fn; }
    int (*get_static_op())(int, int) { return static_fn; }
    int (*const get_const_member_op() const)(int, int) { return member_fn; }
};
FnPtr_int_td OpHolder::static_fn = subf;

// References and pointers to function pointers
void set_op_ref(FnPtr_int_td &op, int subtract) {
    op = subtract ? subf : addf;
}
void set_op_ptr(FnPtr_int_td *op, int subtract) {
    *op = subtract ? subf : addf;
}
int do_op_ref(int x, int y, int (*&op)(int, int)) {
    return (*op)(x,y);
}
int do_op_const_ref(int x, int y, const FnPtr_int_td &op) {
    return (*op)(x,y);
}
FnPtr_int_td &get_op_ref() {
    static FnPtr_int_td op = addf;
    return op;
}
const FnPtr_int_td &static_op_const_ref = OpHolder::static_fn;
const FnPtr_int_td &get_op_const_ref() {
    return OpHolder::static_fn;
}

// Const function pointers
int do_op_const(int x, int y, int (*const op)(int, int)) {
    return (*op)(x,y);
}
int do_op_typedef_const(int x, int y, const FnPtr_int_td op) {
    return (*op)(x,y);
}
int (*const get_const_op(int subtract))(int, int) {
    return subtract ? subf : addf;
}

// Function pointers using a class or an enum in a namespace
namespace FuncPtrNS {
struct Point {
    int x;
};
enum Shade { Light, Dark };
}
int point_x(FuncPtrNS::Point *p) {
    return p->x;
}
FuncPtrNS::Shade invert(FuncPtrNS::Shade s) {
    return s == FuncPtrNS::Light ? FuncPtrNS::Dark : FuncPtrNS::Light;
}
int do_point(FuncPtrNS::Point *p, int (*getter)(FuncPtrNS::Point *)) {
    return (*getter)(p);
}
FuncPtrNS::Shade do_shade(FuncPtrNS::Shade s, FuncPtrNS::Shade (*shader)(FuncPtrNS::Shade)) {
    return (*shader)(s);
}
int (*get_point_getter())(FuncPtrNS::Point *) {
    return point_x;
}
FuncPtrNS::Shade (*get_shader())(FuncPtrNS::Shade) {
    return invert;
}
%}

%constant int     addf(int x, int y);
%constant Integer subf(Integer x, Integer y);
