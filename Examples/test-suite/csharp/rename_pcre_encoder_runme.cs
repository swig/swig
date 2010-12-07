using System;
using rename_pcre_encoderNamespace;

public class runme {
  static void Main() {
    SomeWidget w = new SomeWidget();
    w.putBorderWidth(17);
    if ( w.getBorderWidth() != 17 )
      throw new Exception(String.Format("Border with should be 17, not {0}",
                                        w.getBorderWidth()));
  }
}
