from director_classic import *

class TargetLangPerson(Person):
	def __init__(self):
		Person.__init__(self)
	def id(self):
		identifier = "TargetLangPerson"
                return identifier

class TargetLangChild(Child):
	def __init__(self):
		Child.__init__(self)
	def id(self):
		identifier = "TargetLangChild"
                return identifier

class TargetLangGrandChild(GrandChild):
	def __init__(self):
		GrandChild.__init__(self)
	def id(self):
		identifier = "TargetLangGrandChild"
                return identifier

def check(person, expected):

  debug = 0
  # Normal target language polymorphic call
  ret = person.id()
  if (debug):
    print(ret)
  if (ret != expected):
    raise ("Failed. Received: " + ret + " Expected: " + expected)

  # Polymorphic call from C++
  caller = Caller()
  caller.setCallback(person)
  ret = caller.call()
  if (debug):
    print(ret)
  if (ret != expected):
    raise ("Failed. Received: " + ret + " Expected: " + expected)

  # Polymorphic call of object created in target language and passed to C++ and back again
  baseclass = caller.baseClass()
  ret = baseclass.id()
  if (debug):
    print(ret)
  if (ret != expected):
    raise ("Failed. Received: " + ret + " Expected: " + expected)

  caller.resetCallback()
  if (debug):
    print("----------------------------------------")



person = Person();
check(person, "Person");
del person

person = Child();
check(person, "Child");
del person

person = GrandChild();
check(person, "GrandChild"); 
del person

person = TargetLangPerson();
check(person, "TargetLangPerson"); 
del person

person = TargetLangChild();
check(person, "TargetLangChild"); 
del person

person = TargetLangGrandChild();
check(person, "TargetLangGrandChild"); 
del person


