using System;
using csharp_namespace_interfaceNamespace.A;

public class runme
{
  static void Main()
  {
    Implementer impl = new Implementer();

    Assert(impl.Method(), "Implemented A::B::Interface::Method");
  }

  private static void Assert(string s1, string s2)
  {
    if (s1 != s2)
      throw new Exception("assertion failure. " + s1 + " != " + s2);
  }
}
