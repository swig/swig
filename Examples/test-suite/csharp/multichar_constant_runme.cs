using System;
using multichar_constantNamespace;

public class runme {
  static void Main() {
    // Multicharacter constants have type int, not char.
    if (multichar_constant.MULTICHAR_AB != multichar_constant.imulti_ab)
      throw new Exception("Invalid value for MULTICHAR_AB.");
  }
}
