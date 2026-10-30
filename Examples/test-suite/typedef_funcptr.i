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

struct OpHolder {
    static FnPtr_int_td static_fn;
    FnPtr_int_td member_fn;
    FnPtr_name_td name_fn;
    OpHolder() : member_fn(addf), name_fn(namef) {}
    FnPtr_int_td get_member_op() const { return member_fn; }
    int (*get_static_op())(int, int) { return static_fn; }
};
FnPtr_int_td OpHolder::static_fn = subf;
%}

%constant int     addf(int x, int y);
%constant Integer subf(Integer x, Integer y);
