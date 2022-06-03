using System;

namespace director_using_member_scopesNamespace {

public class runme
{
  static void Main()
  {
    runme r = new runme();
    r.run();
  }

  void run()
  {
    NativeWindowType nwt = new NativeWindowType();
    {
      MyApplicationContextSDL a = new MyApplicationContextSDL();

      if (ApplicationContextBase.call_setWindowGrab(a, nwt, true) != 100)
        throw new Exception("failed");

      if (ApplicationContextSDL.call_setWindowGrab(a, nwt, true) != 100)
        throw new Exception("failed");
    }

    {
      MyACSDL a = new MyACSDL();

      if (ACB.call_setWindowGrab(a, nwt, true) != 100)
        throw new Exception("failed");
      if (ACB.call_setWindowGrab(a, "hi", 0) != 200)
        throw new Exception("failed");

      if (ACSDL.call_setWindowGrab(a, nwt, true) != 100)
        throw new Exception("failed");
      if (ACSDL.call_setWindowGrab(a, "hi", 0) != 200)
        throw new Exception("failed");
    }
  }
}

class MyApplicationContextSDL: ApplicationContextSDL
{
  public MyApplicationContextSDL() : base()
  {
  }

  public override int setWindowGrab(NativeWindowType win, bool grab)
  {
    return 100;
  }
}

class MyACSDL: ACSDL
{
  public MyACSDL() : base()
  {
  }

  public override int setWindowGrab(NativeWindowType win, bool grab)
  {
    return 100;
  }
  public override int setWindowGrab(string s, int val)
  {
    return 200;
  }
}

}
