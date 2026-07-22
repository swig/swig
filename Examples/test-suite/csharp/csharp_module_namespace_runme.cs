// Test the C# namespace set via %module(namespace="...") in the interface file
// (issue #3495). The types below are only accessible via the SwigModuleNamespace
// namespace, which was set in csharp_module_namespace.i, not on the commandline.

using System;
using SwigModuleNamespace;

public class runme
{
  static void Main()
  {
    if (csharp_module_namespace.add(3, 4) != 7)
      throw new Exception("add failed");

    Number n = new Number(42);
    if (n.get() != 42)
      throw new Exception("Number failed");
  }
}
