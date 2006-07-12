import director_classic.*;

public class director_classic_runme {
  static {
    try {
        System.loadLibrary("director_classic");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) 
  {
    { 
      Person person = new Person();
      check(person, "Person");
      person.delete();
    }
    { 
      Person person = new Child();
      check(person, "Child");
      person.delete();
    }
    { 
      Person person = new GrandChild();
      check(person, "GrandChild"); 
      person.delete();
    }
    { 
      Person person = new TargetLangPerson();
      check(person, "TargetLangPerson"); 
      person.delete();
    }
    { 
      Person person = new TargetLangChild();
      check(person, "TargetLangChild"); 
      person.delete();
    }
    { 
      Person person = new TargetLangGrandChild();
      check(person, "TargetLangGrandChild"); 
      person.delete();
    }
  }

  static void check(Person person, String expected) {
    String ret;
    // Normal target language polymorphic call
    ret = person.id();
    if (debug) 
      System.out.println(ret);
    if (!ret.equals(expected))
      throw new RuntimeException("Failed. Received: " + ret + " Expected: " + expected);

    // Polymorphic call from C++
    Caller caller = new Caller();
    caller.setCallback(person);
    ret = caller.call();
    if (debug) 
      System.out.println(ret);
    if (!ret.equals(expected))
      throw new RuntimeException("Failed. Received: " + ret + " Expected: " + expected);

    // Polymorphic call of object created in target language and passed to C++ and back again
    Person baseclass = caller.baseClass();
    ret = baseclass.id();
    if (debug) 
      System.out.println(ret);
    if (!ret.equals(expected))
      throw new RuntimeException("Failed. Received: " + ret + " Expected: " + expected);

    caller.resetCallback();
    if (debug) 
      System.out.println("----------------------------------------");
  }
  static boolean debug = false;
}

class TargetLangPerson extends Person
{
  public TargetLangPerson()
  {
    super();
  }

  public String id()
  {
    String identifier = "TargetLangPerson";
    return identifier;
  }
}

class TargetLangChild extends Child
{
  public TargetLangChild()
  {
    super();
  }

  public String id()
  {
    String identifier = "TargetLangChild";
    return identifier;
  }
}

class TargetLangGrandChild extends GrandChild
{
  public TargetLangGrandChild()
  {
    super();
  }

  public String id()
  {
    String identifier = "TargetLangGrandChild";
    return identifier;
  }
}

