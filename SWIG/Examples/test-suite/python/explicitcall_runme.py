from explicitcall import *


# Test classic usage of the %explicitcall - using base class method from derived class
class Mother(Person):
  def talk(self):
    return Person.talkPerson(self)

class Daughter(Child):
  def talk(self):
    return Person.talkPerson(self) + ":" + Child.talkChild(self)

class GrandDaughter(GrandChild):
  def talk(self):
    return Person.talkPerson(self) + ":" + Child.talkChild(self) + ":" + GrandChild.talkBambino(self)


gc = GrandChild()
if (gc.talkPerson() != "Person"):
  raise RuntimeError, "Explicit Person"
if (gc.talkChild() != "Child"):
  raise RuntimeError, "Explicit Child"
if (gc.talkBambino() != "GrandChild"):
  raise RuntimeError, "Explicit GrandChild"

if (gc.talk() != "GrandChild"):
  raise RuntimeError, "virtual GrandChild"


p = Mother()
if (p.talk() != "Person"):
  raise RuntimeError, "Mother"

p = Daughter()
if (p.talk() != "Person:Child"):
  raise RuntimeError, "Daughter"

p = GrandDaughter()
if (p.talk() != "Person:Child:GrandChild"):
  raise RuntimeError, "GrandDaughter"

t = TemplateString()
if (t.barTemplateString(0) != "Template"):
  raise RuntimeError, "Template"

td = TDerived()

if (td.barTDerived() != "TDerived"):
  raise RuntimeError, "TDerived TDerived()"
if (td.barTemplateString() != "Template"):
  raise RuntimeError, "TDerived Template()"

if (td.barTDerived(0) != "TDerived"):
  raise RuntimeError, "TDerived TDerived(0)"
if (td.barTemplateString(0) != "Template"):
  raise RuntimeError, "TDerived Template(0)"

