
using System;
using System.Reflection;
using csharp_prepostNamespace;

public class csharp_prepost_runme {

  public static void Main() {
    {
      double[] v;
      csharp_prepost.globalfunction(out v);
      Assert(v.Length, 3);
      Assert(v[0], 0.0);
      Assert(v[1], 1.1);
      Assert(v[2], 2.2);
    }
    {
      double[] v;
      new PrePostTest(out v);
      Assert(v.Length, 2);
      Assert(v[0], 3.3);
      Assert(v[1], 4.4);
    }
    {
      double[] v;
      PrePostTest p = new PrePostTest();
      p.method(out v);
      Assert(v.Length, 2);
      Assert(v[0], 5.5);
      Assert(v[1], 6.6);
    }
    {
      double[] v;
      PrePostTest.staticmethod(out v);
      Assert(v.Length, 2);
      Assert(v[0], 7.7);
      Assert(v[1], 8.8);
    }

    // Check attributes are generated for the constructor helper function
    {
      CsinAttributes c = new CsinAttributes(5);
      Assert(c.getVal(), 500);

      Type type = typeof(CsinAttributes);
      {
        MethodInfo member = (MethodInfo)type.GetMember("SwigConstructCsinAttributes", BindingFlags.NonPublic | BindingFlags.Static)[0];
        if (Attribute.GetCustomAttribute(member, typeof(CustomIntPtrAttribute)) == null)
          throw new Exception("No CustomIntPtr attribute for " + member.Name);
        ParameterInfo parameter = member.GetParameters()[0]; // expecting one parameter
        if (parameter.Name != "val")
          throw new Exception("Incorrect parameter name");
        Attribute attribute = Attribute.GetCustomAttributes(parameter)[0];
        if (attribute.GetType() != typeof(CustomIntAttribute))
          throw new Exception("Expecting CustomInt attribute");
      }
    }
  }
  private static void Assert(double d1, double d2) {
    if (d1 != d2)
      throw new Exception("assertion failure. " + d1 + " != " + d2);
  }
}

// Custom attribute classes
[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class CustomIntAttribute : Attribute {}

[AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = true)]
public class CustomIntPtrAttribute : Attribute {}
