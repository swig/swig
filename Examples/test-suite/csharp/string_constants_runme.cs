using System;
using string_constantsNamespace;

public class runme {
  static void Main() {
    assert( string_constants.QQ1 == "\x000800! \x00018b00!" );
    assert( string_constants.QQ2 == "\x000800! \x00018b00!" );
    assert( string_constants.SS1 == "\u00C6\u00CEOU\n" );
    assert( string_constants.SS2 == "\u00C6\u00CEOU\n" );
    assert( string_constants.UU1 == "\u00C6\u00CEOU\n" );
    assert( string_constants.UU2 == "\u00C6\u00CEOU\n" );
    assert( things.SS5 == "\u00C6\u00CEOU\n" );
    assert( string_constants.EN1 == "a\0bc" );
    assert( string_constants.EN2 == "a\0bc" );
    assert( things.EN5 == "a\0bc" );
    assert( string_constants.WS1 != null && string_constants.WC1 != null && string_constants.WS2 != null && things.WS5 != null );
    assert( string_constants.OL1 == "\x00C0\x00A2" );
  }
  static void assert(bool assertion) {
    if (!assertion)
      throw new ApplicationException("test failed");
  }
}
