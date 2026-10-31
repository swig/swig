%module grouping

%inline %{

typedef int Integer;

int (test1)(int x) {
   return x;
}

int *(test2)(int x) {
    static int y;
    y = x;
    return &y;
}

int test3 = 37;

typedef Integer (UnaryOp)(Integer);

Integer do_unary(Integer x, UnaryOp *f) {
   return (*f)(x);
}

int negate(int x) {
   return -x;
}

%}

// More function names in parentheses
%inline %{
namespace GroupingSpace {
  struct Number {
    int value;
  };
}

GroupingSpace::Number (test4)(int x) {
  GroupingSpace::Number n;
  n.value = x;
  return n;
}

int (test5)(int x = 37) {
  return x;
}

template<typename T> T (test6)(T x) {
  return x;
}

struct MemberGrouping {
  int (method1)(int x) {
    return x;
  }
  static int (method2)(int x) {
    return x;
  }
  int (method3)(int x = 37) const {
    return x;
  }
};
%}

%template(test6) test6<int>;

%constant UnaryOp *NEGATE = negate;
