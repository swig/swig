module preproc_constants_c_runme;

import core.stdc.config;
import preproc_constants_c.preproc_constants_c;

// Same as preproc_constants.i testcase, but bool types are int instead.
void main() {
  static assert(is(int == typeof(CONST_INT1())));
  static assert(is(int == typeof(CONST_INT2())));
  static assert(is(uint == typeof(CONST_UINT1())));
  static assert(is(uint == typeof(CONST_UINT2())));
  static assert(is(uint == typeof(CONST_UINT3())));
  static assert(is(uint == typeof(CONST_UINT4())));
  static assert(is(c_long == typeof(CONST_LONG1())));
  static assert(is(c_long == typeof(CONST_LONG2())));
  static assert(is(c_long == typeof(CONST_LONG3())));
  static assert(is(c_long == typeof(CONST_LONG4())));
  static assert(is(long == typeof(CONST_LLONG1())));
  static assert(is(long == typeof(CONST_LLONG2())));
  static assert(is(long == typeof(CONST_LLONG3())));
  static assert(is(long == typeof(CONST_LLONG4())));
  static assert(is(ulong == typeof(CONST_ULLONG1())));
  static assert(is(ulong == typeof(CONST_ULLONG2())));
  static assert(is(ulong == typeof(CONST_ULLONG3())));
  static assert(is(ulong == typeof(CONST_ULLONG4())));
  static assert(is(double == typeof(CONST_DOUBLE1())));
  static assert(is(double == typeof(CONST_DOUBLE2())));
  static assert(is(double == typeof(CONST_DOUBLE3())));
  static assert(is(double == typeof(CONST_DOUBLE4())));
  static assert(is(double == typeof(CONST_DOUBLE5())));
  static assert(is(double == typeof(CONST_DOUBLE6())));
  static assert(is(int == typeof(CONST_BOOL1())));
  static assert(is(int == typeof(CONST_BOOL2())));
  static assert(is(char == typeof(CONST_CHAR())));
  static assert(is(string == typeof(CONST_STRING1())));
  static assert(is(string == typeof(CONST_STRING2())));

  static assert(is(int == typeof(INT_AND_BOOL())));
//    static assert(is(int == typeof(INT_AND_CHAR())));
  static assert(is(int == typeof(INT_AND_INT())));
  static assert(is(uint == typeof(INT_AND_UINT())));
  static assert(is(c_long == typeof(INT_AND_LONG())));
  static assert(is(c_ulong == typeof(INT_AND_ULONG())));
  static assert(is(long == typeof(INT_AND_LLONG())));
  static assert(is(ulong == typeof(INT_AND_ULLONG())));
  static assert(is(int == typeof(BOOL_AND_BOOL())));

  static assert(is(int == typeof(EXPR_MULTIPLY())));
  static assert(is(int == typeof(EXPR_DIVIDE())));
  static assert(is(int == typeof(EXPR_PLUS())));
  static assert(is(int == typeof(EXPR_MINUS())));
  static assert(is(int == typeof(EXPR_LSHIFT())));
  static assert(is(int == typeof(EXPR_RSHIFT())));
  static assert(is(int == typeof(EXPR_LTE())));
  static assert(is(int == typeof(EXPR_GTE())));
  static assert(is(int == typeof(EXPR_INEQUALITY())));
  static assert(is(int == typeof(EXPR_EQUALITY())));
  static assert(is(int == typeof(EXPR_AND())));
  static assert(is(int == typeof(EXPR_XOR())));
  static assert(is(int == typeof(EXPR_OR())));
  static assert(is(int == typeof(EXPR_LAND())));
  static assert(is(int == typeof(EXPR_LOR())));
  static assert(is(double == typeof(EXPR_CONDITIONAL())));
}
