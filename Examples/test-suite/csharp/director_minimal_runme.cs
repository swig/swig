using System;

namespace director_minimalNamespace {
class MyMinimal : Minimal
{
  public override bool run()
  {
    return true;
  }
}
public class runme {
  static void Main() {
    MyMinimal c = new MyMinimal();
    if (!c.get())
       throw new Exception("Should return true");
  }
}
}
