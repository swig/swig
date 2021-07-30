using System;
using System.Collections.Generic;
using nested_inheritance_interfaceNamespace;

public class nested_inheritance_interface_runme {

  static string SortArrayToString(string[] types) {
    Array.Sort<string>(types);
    return string.Join(" ", types);
  }

  static string SortArrayToString(Type[] types) {
    List<string> stypes = new List<string>();
    foreach (Type t in types)
      stypes.Add(t.Name);
    return SortArrayToString(stypes.ToArray());
  }

  private static void takeIA(IASwigInterface ia) {
  }

  public static void Main() {
    Type[] BNInterfaces = typeof(B.N).GetInterfaces();
    string expectedInterfacesString = "IASwigInterface IDisposable";
    string actualInterfacesString = SortArrayToString(BNInterfaces);
    if (expectedInterfacesString != actualInterfacesString)
      throw new Exception("Expected interfaces for " + typeof(B.N).Name + ": \n" + expectedInterfacesString + "\n" + "Actual interfaces: \n" + actualInterfacesString);

    if (!typeof(IASwigInterface).IsInterface)
      throw new Exception(typeof(IASwigInterface).Name + " should be an interface but is not");

    // overloaded methods check
    B.N d = new B.N();
    takeIA(d);
  }
}
