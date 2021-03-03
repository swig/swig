import cpp11_shared_ptr_overload.*;

public class cpp11_shared_ptr_overload_runme {
  static {
    try {
      System.loadLibrary("cpp11_shared_ptr_overload");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) 
  {
    String ret = null;

    // ref
    ret = cpp11_shared_ptr_overload.UseA(new MyType("123"));
    if (!ret.equals("123 ref")) throw new RuntimeException("UseA fail:" + ret);

    ret = cpp11_shared_ptr_overload.UseB(0, new MyType("123"));
    if (!ret.equals("123 ref")) throw new RuntimeException("UseB fail:" + ret);

    ret = cpp11_shared_ptr_overload.UseC(0, new MyType("123"), new MyType("456"));
    if (!ret.equals("123 ref")) throw new RuntimeException("UseC fail:" + ret);

    // sharedptr
    ret = cpp11_shared_ptr_overload.UseX(new MyType("123"));
    if (!ret.equals("123 sharedptr")) throw new RuntimeException("UseX fail:" + ret);

    ret = cpp11_shared_ptr_overload.UseY(0, new MyType("123"));
    if (!ret.equals("123 sharedptr")) throw new RuntimeException("UseY fail:" + ret);

    ret = cpp11_shared_ptr_overload.UseZ(0, new MyType("123"), new MyType("456"));
    if (!ret.equals("123 sharedptr")) throw new RuntimeException("UseZ fail:" + ret);

    // Combo1-4
    ret = cpp11_shared_ptr_overload.Combo1(new MyType("XXX"));
    if (!ret.equals("XXXCombo1")) throw new RuntimeException("Combo1 fail:" + ret);

    ret = cpp11_shared_ptr_overload.Combo2(new MyType("XXX"));
    if (!ret.equals("XXXCombo2")) throw new RuntimeException("Combo2 fail:" + ret);

    ret = cpp11_shared_ptr_overload.Combo3(new MyType("XXX"));
    if (!ret.equals("XXXCombo3")) throw new RuntimeException("Combo3 fail:" + ret);

    ret = cpp11_shared_ptr_overload.Combo4(new MyType("XXX"));
    if (!ret.equals("XXXCombo4")) throw new RuntimeException("Combo4 fail:" + ret);

    // Combo5-7
    ret = cpp11_shared_ptr_overload.Combo5(new MyType("XXX"));
    if (!ret.equals("XXXCombo5")) throw new RuntimeException("Combo5 fail:" + ret);

    ret = cpp11_shared_ptr_overload.Combo6(new MyType("XXX"));
    if (!ret.equals("XXXCombo6")) throw new RuntimeException("Combo6 fail:" + ret);

    ret = cpp11_shared_ptr_overload.Combo7(new MyType("XXX"));
    if (!ret.equals("XXXCombo7")) throw new RuntimeException("Combo7 fail:" + ret);
  }
}
