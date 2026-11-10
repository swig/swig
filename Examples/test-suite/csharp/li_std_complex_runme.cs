using System;
using li_std_complexNamespace;

public class li_std_complex_runme {
  public static void Main() {
    System.Numerics.Complex c = li_std_complex.createComplex(6, 8);
    if (li_std_complex.getReal(c) !=  6) throw new Exception("getReal failed");
    if (li_std_complex.getImaginary(c) != 8) throw new Exception("getImaginary failed");
    if (li_std_complex.getMagnitude(c) != 10) throw new Exception("getMagnitude failed");

    // double to float downcast works as we do not overflow float
    if (li_std_complex.getRealFlt(c) != 6) throw new Exception("getRealFlt of double failed");
    if (li_std_complex.getImaginaryFlt(c) != 8) throw new Exception("getImaginaryFlt of double failed");
    if (li_std_complex.getMagnitudeFlt(c) != 10) throw new Exception("getMagnitudeFlt of double failed");

    System.Numerics.Complex f = li_std_complex.createComplexFlt(6, 8);
    if (li_std_complex.getRealFlt(f) != 6) throw new Exception("getRealFlt failed");
    if (li_std_complex.getImaginaryFlt(f) != 8) throw new Exception("getImaginaryFlt failed");
    if (li_std_complex.getMagnitudeFlt(f) != 10) throw new Exception("getMagnitudeFlt failed");

    // uppercast works!
    if (li_std_complex.getReal(f) !=  6) throw new Exception("getReal of float failed");
    if (li_std_complex.getImaginary(f) != 8) throw new Exception("getImaginary of float failed");
    if (li_std_complex.getMagnitude(f) != 10) throw new Exception("getMagnitude of float failed");
  }
}
