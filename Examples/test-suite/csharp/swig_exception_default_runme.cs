using System;
using swig_exception_defaultNamespace;

public class runme
{
  static void Main()
  {
    if (swig_exception_default.positive_only(1) != 1)
      throw new Exception("positive_only(1) failed");
    try {
      swig_exception_default.positive_only(0);
      throw new Exception("positive_only(0) did not throw");
    } catch (ArgumentOutOfRangeException) {
    }

    if (swig_exception_default.positive_result(1) != 1)
      throw new Exception("positive_result(1) failed");
    try {
      swig_exception_default.positive_result(0);
      throw new Exception("positive_result(0) did not throw");
    } catch (ArgumentOutOfRangeException) {
    }
  }
}
