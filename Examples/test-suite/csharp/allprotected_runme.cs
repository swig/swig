using System;
using allprotectedNamespace;

public class runme
{
  static void Main() 
  {
    runme r = new runme();
    r.run();
  }

  void run()
  {
    MyProtectedBase mpb = new MyProtectedBase("MyProtectedBase");
    mpb.accessProtected();
    try {
      // C++ destructor is protected
      mpb.Dispose();
      throw new Exception("failed to catch MethodAccessException");
    } catch (MethodAccessException) {
      // Exception message: C++ destructor does not have public access
    }
    ProtectedDerived pd = new ProtectedDerived("ProtectedDerived");
    // Destroying via the ProtectedDerived's destructor should work
    pd.Dispose();

    ProtectedBase pb = new ProtectedDerived("ProtectedDerived");
    // ProtectedDerived's destructor should be called via the Dispose(disposing) virtual call
    pb.Dispose();
  }
}

class MyProtectedBase : ProtectedBase
{
  public MyProtectedBase(string name) : base(name) {
  }
  public void accessProtected() {
    string s = virtualMethod();
    if (s != "ProtectedBase")
      throw new Exception("Failed");

    Klass k = instanceMethod(new Klass("xyz"));
    if (k.getName() != "xyz") 
      throw new Exception("Failed");

    k = instanceOverloaded(new Klass("xyz"));
    if (k.getName() != "xyz") 
      throw new Exception("Failed");

    k = instanceOverloaded(new Klass("xyz"), "abc");
    if (k.getName() != "abc") 
      throw new Exception("Failed");

    k = ProtectedBase.staticMethod(new Klass("abc"));
    if (k.getName() != "abc") 
      throw new Exception("Failed");

    k = ProtectedBase.staticOverloaded(new Klass("xyz"));
    if (k.getName() != "xyz") 
      throw new Exception("Failed");

    k = ProtectedBase.staticOverloaded(new Klass("xyz"), "abc");
    if (k.getName() != "abc") 
      throw new Exception("Failed");

    instanceMemberVariable = 30;
    int i = instanceMemberVariable;
    if (i != 30)
      throw new Exception("Failed");

    staticMemberVariable = 40;
    i = staticMemberVariable;
    if (i != 40)
      throw new Exception("Failed");

    i = staticConstMemberVariable;
    if (i != 20)
      throw new Exception("Failed");

    anEnum = ProtectedBase.AnEnum.EnumVal1;
    ProtectedBase.AnEnum ae = anEnum;
    if (ae != ProtectedBase.AnEnum.EnumVal1)
      throw new Exception("Failed");
  }
}
