module director_classic_runme;

import tango.io.Stdout;
import director_classic.Caller;
import director_classic.Person;
import director_classic.Child;
import director_classic.GrandChild;
import director_classic.OrphanPerson;
import director_classic.OrphanChild;

const bool TRACE = false;

void main() {
  {
    scope person = new Person();
    check(person, "Person");
  }
  {
    scope person = new Child();
    check(person, "Child");
  }
  {
    scope person = new GrandChild();
    check(person, "GrandChild");
  }
  {
    scope person = new TargetLangPerson();
    check(person, "TargetLangPerson");
  }
  {
    scope person = new TargetLangChild();
    check(person, "TargetLangChild");
  }
  {
    scope person = new TargetLangGrandChild();
    check(person, "TargetLangGrandChild");
  }

  // Semis - don't override id() in target language
  {
    scope person = new TargetLangSemiPerson();
    check(person, "Person");
  }
  {
    scope person = new TargetLangSemiChild();
    check(person, "Child");
  }
  {
    scope person = new TargetLangSemiGrandChild();
    check(person, "GrandChild");
  }

  // Orphans - don't override id() in C++
  {
    scope person = new OrphanPerson();
    check(person, "Person");
  }
  {
    scope person = new OrphanChild();
    check(person, "Child");
  }
  {
    scope person = new TargetLangOrphanPerson();
    check(person, "TargetLangOrphanPerson");
  }
  {
    scope person = new TargetLangOrphanChild();
    check(person, "TargetLangOrphanChild");
  }

  // Duals - id() makes an upcall to the base id()
  {
    scope person = new TargetLangDualPerson();
    check(person, "TargetLangDualPerson + Person");
  }
  {
    scope person = new TargetLangDualChild();
    check(person, "TargetLangDualChild + Child");
  }
  {
    scope person = new TargetLangDualGrandChild();
    check(person, "TargetLangDualGrandChild + GrandChild");
  }

  // Mix Orphans and Duals
  {
    scope person = new TargetLangDualOrphanPerson();
    check(person, "TargetLangDualOrphanPerson + Person");
  }
  {
    scope person = new TargetLangDualOrphanChild();
    check(person, "TargetLangDualOrphanChild + Child");
  }
}

void check(Person person, char[] expected) {
  char[] ret;
  // Normal D polymorphic call.
  ret = person.id();
  if (TRACE)
    Stdout(ret).newline;
  if (ret != expected)
    throw new Exception("Failed. Received: " ~ ret ~ " Expected: " ~ expected);

  // Polymorphic call from C++.
  Caller caller = new Caller();
  caller.setCallback(person);
  ret = caller.call();
  if (TRACE)
    Stdout(ret).newline;
  if (ret != expected)
    throw new Exception("Failed. Received: " ~ ret ~ " Expected: " ~ expected);

  // Polymorphic call of object created in D and passed to C++ and back again.
  Person baseclass = caller.baseClass();
  ret = baseclass.id();
  if (TRACE)
    Stdout(ret).newline;
  if (ret != expected)
    throw new Exception("Failed. Received: " ~ ret ~ " Expected: " ~ expected);

  caller.resetCallback();
  if (TRACE)
    Stdout("----------------------------------------").newline;
}


// »Full« target language persons.
class TargetLangPerson : Person {
  public override char[] id() {
    return "TargetLangPerson";
  }
}

class TargetLangChild : Child {
  public override char[] id() {
    return "TargetLangChild";
  }
}

class TargetLangGrandChild : GrandChild {
  public override char[] id() {
    return "TargetLangGrandChild";
  }
}


// Semis - don't override id() in target language
class TargetLangSemiPerson : Person {
  // No id() override
}

class TargetLangSemiChild : Child {
  // No id() override
}

class TargetLangSemiGrandChild : GrandChild {
  // No id() override
}


// Orphans - don't override id() in C++
class TargetLangOrphanPerson : OrphanPerson {
  public override char[] id() {
    return "TargetLangOrphanPerson";
  }
}

class TargetLangOrphanChild : OrphanChild {
  public override char[] id() {
    return "TargetLangOrphanChild";
  }
}


// Duals - id() makes an upcall to the base id()
class TargetLangDualPerson : Person {
  public override char[] id() {
    return "TargetLangDualPerson + " ~ super.id();
  }
}

class TargetLangDualChild : Child {
  public override char[] id() {
    return "TargetLangDualChild + " ~ super.id();
  }
}

class TargetLangDualGrandChild : GrandChild {
  public override char[] id() {
    return "TargetLangDualGrandChild + " ~ super.id();
  }
}


// Mix Orphans and Duals
class TargetLangDualOrphanPerson : OrphanPerson {
  public override char[] id() {
    return "TargetLangDualOrphanPerson + " ~ super.id();
  }
}

class TargetLangDualOrphanChild : OrphanChild {
  public override char[] id() {
    return "TargetLangDualOrphanChild + " ~ super.id();
  }
}
