import using_member_multiple_inherit.*;

public class using_member_multiple_inherit_runme {
  static {
    try {
        System.loadLibrary("using_member_multiple_inherit");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[])
  {
    // Single inheritance three deep, only using declarations
    Susing3 s3 = new Susing3();
    s3.usingmethod(11);

    // Single inheritance three deep, overload using and methods
    Using3 u3 = new Using3();
    u3.usingmethod(11);
    u3.usingmethod(11, 22);
    u3.usingmethod(11, 22, 33);

    Musing3 m3 = new Musing3();
    m3.usingmethod(11);
    m3.usingmethod(11, 22);
    m3.usingmethod(11, 22, 33);

    Dusing3 d3 = new Dusing3();
    d3.usingmethod(11);
    d3.usingmethod(11, 22);

    // Multiple inheritance, multiple using declarations
    MultMiddleA ma = new MultMiddleA();
    ma.multmethod(123);
    ma.multmethod("hi");
    ma.multmethod(123, 234);

    MultBottomB mb = new MultBottomB();
    mb.multmethod(123);
    mb.multmethod("hi");
    mb.multmethod(123, 234);
    mb.multmethod(123, 345, 567);

    // Multiple inheritance, with no override on parent class. 
    Vusing2 vu = new Vusing2();
    vu.usingmethod(3);
    vu.usingmethod("hi");
  }
}
