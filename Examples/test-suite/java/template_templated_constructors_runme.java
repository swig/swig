
import template_templated_constructors.*;

public class template_templated_constructors_runme {

  static {
    try {
	System.loadLibrary("template_templated_constructors");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    TConstructor1 t1 = new TConstructor1(123);
    TConstructor2 t2a = new TConstructor2();
    TConstructor2 t2b = new TConstructor2(123);

    TClass1Int tc1 = new TClass1Int(123.4);
    TClass2Int tc2a = new TClass2Int();
    TClass2Int tc2b = new TClass2Int(123.4);

    DoublePair double_pair = new DoublePair(1.1, 2.2);
    ShortPair short_pair = new ShortPair((short)0, (short)1);
    StringPair string_pair = new StringPair("10", "11");
    IntPair ip1 = new IntPair();
    IntPair ip2 = new IntPair(20, 21);
    IntPair ip3 = new IntPair(ip1);
    IntPair ip4 = new IntPair(short_pair);
    // These next two use IntPair constructors, unlike Python which requires factory function calls
    IntPair ip5 = new IntPair(double_pair);
    IntPair ip6 = new IntPair(string_pair);
  }
}

