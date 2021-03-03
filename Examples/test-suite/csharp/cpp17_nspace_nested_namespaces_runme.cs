using System;
using cpp17_nspace_nested_namespacesNamespace;

public class cpp17_nspace_nested_namespaces_runme
{
    static void Main()
    {
      new cpp17_nspace_nested_namespacesNamespace.A1.A1Struct().A1Method();
      new cpp17_nspace_nested_namespacesNamespace.A1.B1.B1Struct().B1Method();
      new cpp17_nspace_nested_namespacesNamespace.A1.B1.C1.C1Struct().C1Method();
      cpp17_nspace_nested_namespaces.createA1Struct().A1Method();
      cpp17_nspace_nested_namespaces.createB1Struct().B1Method();
      cpp17_nspace_nested_namespaces.createC1Struct().C1Method();

      new cpp17_nspace_nested_namespacesNamespace.A2.B2.B2Struct().B2Method();
      new cpp17_nspace_nested_namespacesNamespace.A2.B2.C2.C2Struct().C2Method();
      cpp17_nspace_nested_namespaces.createB2Struct().B2Method();
      cpp17_nspace_nested_namespaces.createC2Struct().C2Method();

      new cpp17_nspace_nested_namespacesNamespace.A3.B3.B3Struct().B3Method();
      new cpp17_nspace_nested_namespacesNamespace.A3.B3.C3.C3Struct().C3Method();
      cpp17_nspace_nested_namespaces.createB3Struct().B3Method();
      cpp17_nspace_nested_namespaces.createC3Struct().C3Method();
    }
}
