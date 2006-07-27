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

    // Semis - don't override id() in target language
    { 
      Person person = new TargetLangSemiPerson();
      check(person, "Person"); 
      person.Dispose();
    }
    { 
      Person person = new TargetLangSemiChild();
      check(person, "Child"); 
      person.Dispose();
    }
    { 
      Person person = new TargetLangSemiGrandChild();
      check(person, "GrandChild"); 
      person.Dispose();
    }

    // Orphans - don't override id() in C++
    { 
      Person person = new OrphanPerson();
      check(person, "Person"); 
      person.Dispose();
    }
    { 
      Person person = new OrphanChild();
      check(person, "Child"); 
      person.Dispose();
    }
    { 
      Person person = new TargetLangOrphanPerson();
      check(person, "TargetLangOrphanPerson"); 
      person.Dispose();
    }
    { 
      Person person = new TargetLangOrphanChild();
      check(person, "TargetLangOrphanChild"); 
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

// Semis - don't override id() in target language
public class TargetLangSemiPerson : Person
{
  public TargetLangSemiPerson()
    : base()
  {
  }
  // No id() override
}

public class TargetLangSemiChild : Child
{
  public TargetLangSemiChild()
    : base()
  {
  }
  // No id() override
}

public class TargetLangSemiGrandChild : GrandChild
{
  public TargetLangSemiGrandChild()
    : base()
  {
  }
  // No id() override
}

// Orphans - don't override id() in C++
class TargetLangOrphanPerson : OrphanPerson
{
  public TargetLangOrphanPerson()
    : base()
  {
  }

  public override String id()
  {
    String identifier = "TargetLangOrphanPerson";
    return identifier;
  }
}

class TargetLangOrphanChild : OrphanChild
{
  public TargetLangOrphanChild()
    : base()
  {
  }

  public override String id()
  {
    String identifier = "TargetLangOrphanChild";
    return identifier;
  }
}

}
