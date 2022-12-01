using System;
using catches_stringsNamespace;

public class catches_strings_runme {
  public static void Main()
  {
    {
      bool exception_thrown = false;
      try {
        StringsThrower.charstring();
      } catch (ApplicationException e) {
        if (!e.Message.Contains("charstring message"))
          throw new ApplicationException("incorrect exception message:" + e);
        exception_thrown = true;
      }
      if (!exception_thrown)
        throw new ApplicationException("Should have thrown an exception");
    }
    {
      bool exception_thrown = false;
      try {
        StringsThrower.stdstring();
      } catch (ApplicationException e) {
        if (!e.Message.Contains("stdstring message"))
          throw new ApplicationException("incorrect exception message:" + e);
        exception_thrown = true;
      }
      if (!exception_thrown)
        throw new ApplicationException("Should have thrown an exception");
    }
  }
}
