// Mainly tests that directors are finalized correctly

import explicitcall.*;

public class explicitcall_runme {

  static {
    try {
      System.loadLibrary("explicitcall");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    GrandChild gc = new GrandChild();
    if (!gc.talkPerson().equals("Person"))
      throw new RuntimeException("Explicit Person");
    if (!gc.talkChild().equals("Child"))
      throw new RuntimeException("Explicit Child");
    if (!gc.talkBambino().equals("GrandChild"))
      throw new RuntimeException("Explicit GrandChild");

    if (!gc.talk().equals("GrandChild"))
      throw new RuntimeException("virtual GrandChild");

    {
      Person p = null;
      p = new Mother();
      if (!p.talk().equals("Person"))
        throw new RuntimeException("Mother");

      p = new Daughter();
      if (!p.talk().equals("Person:Child"))
        throw new RuntimeException("Daughter");

      p = new GrandDaughter();
      if (!p.talk().equals("Person:Child:GrandChild"))
        throw new RuntimeException("GrandDaughter");
    }

    {
      TemplateString t = new TemplateString();
      if (!t.barTemplateString(0).equals("Template"))
        throw new RuntimeException("Template");

      TDerived td = new TDerived();

      if (!td.barTDerived().equals("TDerived"))
        throw new RuntimeException("TDerived TDerived()");
      if (!td.barTemplateString().equals("Template"))
        throw new RuntimeException("TDerived Template()");

      if (!td.barTDerived(0).equals("TDerived"))
        throw new RuntimeException("TDerived TDerived(0)");
      if (!td.barTemplateString(0).equals("Template"))
        throw new RuntimeException("TDerived Template(0)");
    }
  }

}

// Test classic usage of the %explicitcall - using base class method from derived class
class Mother extends Person {
  public String talk() {
    return talkPerson();
  }
}

class Daughter extends Child {
  public String talk() {
    return talkPerson() + ":" + talkChild();
  }
}

class GrandDaughter extends GrandChild {
  public String talk() {
    return talkPerson() + ":" + talkChild() + ":" + talkBambino();
  }
}

