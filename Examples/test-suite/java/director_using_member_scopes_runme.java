
import director_using_member_scopes.*;

public class director_using_member_scopes_runme {

  static {
    try {
      System.loadLibrary("director_using_member_scopes");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    NativeWindowType nwt = new NativeWindowType();

    {
      director_using_member_scopes_MyApplicationContextSDL a = new director_using_member_scopes_MyApplicationContextSDL();

      if (ApplicationContextBase.call_setWindowGrab(a, nwt, true) != 100)
        throw new RuntimeException("failed");

      if (ApplicationContextSDL.call_setWindowGrab(a, nwt, true) != 100)
        throw new RuntimeException("failed");
    }

    {
      director_using_member_scopes_MyACSDL a = new director_using_member_scopes_MyACSDL();

      if (ACB.call_setWindowGrab(a, nwt, true) != 100)
        throw new RuntimeException("failed");
      if (ACB.call_setWindowGrab(a, "hi", 0) != 200)
        throw new RuntimeException("failed");

      if (ACSDL.call_setWindowGrab(a, nwt, true) != 100)
        throw new RuntimeException("failed");
      if (ACSDL.call_setWindowGrab(a, "hi", 0) != 200)
        throw new RuntimeException("failed");
    }
  }
}

class director_using_member_scopes_MyApplicationContextSDL extends ApplicationContextSDL {
  @Override
  public int setWindowGrab(NativeWindowType win, boolean grab)
  {
    return 100;
  }
}

class director_using_member_scopes_MyACSDL extends ACSDL {
  @Override
  public int setWindowGrab(NativeWindowType win, boolean grab)
  {
    return 100;
  }

  @Override
  public int setWindowGrab(String s, int val)
  {
    return 200;
  }
}
