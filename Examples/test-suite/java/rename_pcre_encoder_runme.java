import rename_pcre_encoder.*;

public class rename_pcre_encoder_runme {
  static { System.loadLibrary("rename_pcre_encoder"); }

  public static void main(String argv[])
  {
    SomeWidget w = new SomeWidget();
    w.putBorderWidth(17);
    if ( w.getBorderWidth() != 17 )
      throw new RuntimeException(String.format("Border with should be 17, not %d",
                                               w.getBorderWidth()));
  }
}
