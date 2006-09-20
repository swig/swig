using System;

namespace director_ignoreNamespace {

public class runme
{
  static void Main() 
  {
    runme r = new runme();
    r.run();
  }

  void run()
  {
  }
}

class DIgnoresDerived : DIgnores
{
  public DIgnoresDerived() : base()
  {
  }

  // These will give a warning if the %ignore is not working
  public virtual void OverloadedMethod(int n, int xoffset, int yoffset) {}
  public virtual void OverloadedMethod(int n, int xoffset) {}
  public virtual void OverloadedMethod(int n) {}

  public virtual void ProtectedMethod(int n, int xoffset, int yoffset) {}
  public virtual void ProtectedMethod(int n, int xoffset) {}
  public virtual void ProtectedMethod(int n) {}
}

}
