using System;

namespace director_classicNamespace {

public class runme
{
  static void Main() 
  {
    { 
      Person person = new Person();
      check(person, "Person");
      person.Dispose();
    }
    { 
      Person person = new Child();
      check(person, "Child");
      person.Dispose();
    }
    { 
      Person person = new GrandChild();
      check(person, "GrandChild"); 
      person.Dispose();
    }
    { 
      Person person = new TargetLangPerson();
      check(person, "TargetLangPerson"); 
      person.Dispose();
    }
    { 
      Person person = new TargetLangChild();
      check(person, "TargetLangChild"); 
      person.Dispose();
    }
    { 
      Person person = new TargetLangGrandChild();
      check(person, "TargetLangGrandChild"); 
      person.Dispose();
    }
  }

  static void check(Person person, String expected) {
    String ret;
    // Normal target language polymorphic call
    ret = person.id();
    if (debug) 
      Console.WriteLine(ret);
    if (ret != expected)
      throw new Exception("Failed. Received: " + ret + " Expected: " + expected);

    // Polymorphic call from C++
    Caller caller = new Caller();
    caller.setCallback(person);
    ret = caller.call();
    if (debug) 
      Console.WriteLine(ret);
    if (ret != expected)
      throw new Exception("Failed. Received: " + ret + " Expected: " + expected);

    // Polymorphic call of object created in target language and passed to C++ and back again
    Person baseclass = caller.baseClass();
    ret = baseclass.id();
    if (debug) 
      Console.WriteLine(ret);
    if (ret != expected)
      throw new Exception("Failed. Received: " + ret + " Expected: " + expected);

    caller.resetCallback();
    if (debug) 
      Console.WriteLine("----------------------------------------");
  }
  static bool debug = false;
}

public class TargetLangPerson : Person
{
  public TargetLangPerson()
    : base()
  {
  }

  public override String id()
  {
    String identifier = "TargetLangPerson";
    return identifier;
  }
}

public class TargetLangChild : Child
{
  public TargetLangChild()
    : base()
  {
  }

  public override String id()
  {
    String identifier = "TargetLangChild";
    return identifier;
  }
}

public class TargetLangGrandChild : GrandChild
{
  public TargetLangGrandChild()
    : base()
  {
  }

  public override String id()
  {
    String identifier = "TargetLangGrandChild";
    return identifier;
  }
}

}
