
import cpp11_ref_qualifiers.*;

public class cpp11_ref_qualifiers_runme {

  static {
    try {
      System.loadLibrary("cpp11_ref_qualifiers");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Host h = new Host();

    // Basic testing
    h.h1();
    h.h2();
    h.h6();
    h.h7();

    h.h();

    // %feature testing
    Features f = new Features();
    if (!f.F1().equals("F1")) throw new RuntimeException("Fail");
    if (!f.F2().equals("F2")) throw new RuntimeException("Fail");
    if (!f.F3().equals("F3")) throw new RuntimeException("Fail");

    if (!f.C1(0).equals("C1")) throw new RuntimeException("Fail");
    if (!f.C2(0).equals("C2")) throw new RuntimeException("Fail");
    if (!f.C3(0).equals("C3")) throw new RuntimeException("Fail");

    // %rename testing
    Renames r = new Renames();
    r.RR1();
    r.RR2();
    r.RR3();

    r.SS1(0);
    r.SS2(0);
    r.SS3(0);

    // Conversion operators
    String s = null;
    ConversionOperators co = new ConversionOperators();
    s = co.StringConvertCopy();
    s = co.StringConvertMove();

    ConversionOperators2 co2 = new ConversionOperators2();
    s = co2.StringConvertMove();

    // Default arguments
    DefaultArgs d = new DefaultArgs();
    if (d.vol() != 100 || d.vol(10) != 100 || d.vol(10, 20) != 100) throw new RuntimeException("vol");
    if (d.lref() != 200 || d.lref(10) != 200 || d.lref(10, 20) != 200) throw new RuntimeException("lref");
    if (d.cvref_renamed() != 3 || d.cvref_renamed(10) != 12 || d.cvref_renamed(10, 20) != 30) throw new RuntimeException("cvref_renamed");
    if (d.rv() != 3 || d.rv(10) != 12 || d.rv(10, 20) != 30) throw new RuntimeException("rv");
    for (java.lang.reflect.Method m : DefaultArgs.class.getMethods())
      if (m.getName().equals("cvref") || m.getName().equals("crv")) throw new RuntimeException(m.getName() + " should not be wrapped");
  }
}

