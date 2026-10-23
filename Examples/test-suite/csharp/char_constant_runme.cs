using System;
using char_constantNamespace;

public class runme {
  static void Main() {
    if (char_constant.CHAR_CONSTANT != 'x')
      throw new Exception("Invalid value for CHAR_CONSTANT.");
    if (char_constant.STRING_CONSTANT != "xyzzy")
      throw new Exception("Invalid value for STRING_CONSTANT.");
    if (char_constant.ia != 97)
      throw new Exception("Invalid value for ia.");
    if (char_constant.ib != 98)
      throw new Exception("Invalid value for ib.");
    if (char_constant.iparen != ';')
      throw new Exception("Invalid value for iparen.");
  }
}
