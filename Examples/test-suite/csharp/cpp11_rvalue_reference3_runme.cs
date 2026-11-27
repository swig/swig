using System;
using cpp11_rvalue_reference3Namespace;

public class cpp11_rvalue_reference3_runme {

  public static void Main() {
    check(6, cpp11_rvalue_reference3.funcref_takeit1(cpp11_rvalue_reference3.FUNCREF_DOUBLE, 3));
    check(8, cpp11_rvalue_reference3.funcref_takeit2(cpp11_rvalue_reference3.FUNCREF_DOUBLE, 4));
    check(10, cpp11_rvalue_reference3.funcref_takeit1(cpp11_rvalue_reference3.funcref_returnit1(), 5));
    check(12, cpp11_rvalue_reference3.funcref_takeit2(cpp11_rvalue_reference3.funcref_returnit2(), 6));
    try {
      cpp11_rvalue_reference3.funcref_takeit1(null, 1);
      throw new Exception("funcref_takeit1(null) did not throw");
    } catch (ArgumentNullException) {
    }
  }

  private static void check(int expected, int actual) {
    if (expected != actual)
      throw new Exception("expected " + expected + " but got " + actual);
  }
}
