
using System;
using explicitcallNamespace;

public class explicitcall_runme {

  public static void Main() {

    GrandChild gc = new GrandChild();
    if (gc.talkPerson() != "Person")
      throw new Exception("Explicit Person");
    if (gc.talkChild() != "Child")
      throw new Exception("Explicit Child");
    if (gc.talkBambino() != "GrandChild")
      throw new Exception("Explicit GrandChild");

    if (gc.talk() != "GrandChild")
      throw new Exception("virtual GrandChild");

    {
      Person p = null;
      p = new Mother();
      if (p.talk() != "Person")
        throw new Exception("Mother");

      p = new Daughter();
      if (p.talk() != "Person:Child")
        throw new Exception("Daughter");

      p = new GrandDaughter();
      if (p.talk() != "Person:Child:GrandChild")
        throw new Exception("GrandDaughter");
    }

    {
      TemplateString t = new TemplateString();
      if (t.barTemplateString(0) != "Template")
        throw new Exception("Template");

      TDerived td = new TDerived();

      if (td.barTDerived() != "TDerived")
        throw new Exception("TDerived TDerived()");
      if (td.barTemplateString() != "Template")
        throw new Exception("TDerived Template()");

      if (td.barTDerived(0) != "TDerived")
        throw new Exception("TDerived TDerived(0)");
      if (td.barTemplateString(0) != "Template")
        throw new Exception("TDerived Template(0)");
    }
  }
}

// Test classic usage of the %explicitcall - using base class method from derived class
class Mother : Person {
  public override string talk() {
    return talkPerson();
  }
}

class Daughter : Child {
  public override string talk() {
    return talkPerson() + ":" + talkChild();
  }
}

class GrandDaughter : GrandChild {
  public override string talk() {
    return talkPerson() + ":" + talkChild() + ":" + talkBambino();
  }
}

