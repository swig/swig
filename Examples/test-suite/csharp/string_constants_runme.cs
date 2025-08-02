using System;
using string_constantsNamespace;

public class runme {
  static void Main() {
    assert( string_constants.QQ1 == "\x000800! \x00018b00!" );
    assert( string_constants.QQ2 == "\x000800! \x00018b00!" );
  }
  static void assert(bool assertion) {
    if (!assertion)
      throw new ApplicationException("test failed");
  }
}
