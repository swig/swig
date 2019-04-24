using System;
using cpp17_nested_namespacesNamespace;

public class cpp17_nested_namespaces_runme
{
    static void Main()
    {
      new A1Struct().A1Method();
      new B1Struct().B1Method();
      new C1Struct().C1Method();
      cpp17_nested_namespaces.createA1Struct().A1Method();
      cpp17_nested_namespaces.createB1Struct().B1Method();
      cpp17_nested_namespaces.createC1Struct().C1Method();

      new B2Struct().B2Method();
      new C2Struct().C2Method();
      cpp17_nested_namespaces.createB2Struct().B2Method();
      cpp17_nested_namespaces.createC2Struct().C2Method();

      new B3Struct().B3Method();
      new C3Struct().C3Method();
      cpp17_nested_namespaces.createB3Struct().B3Method();
      cpp17_nested_namespaces.createC3Struct().C3Method();
    }
}
