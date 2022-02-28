import director_property


class PyFoo(director_property.Foo):
    a = property(director_property.Foo.getA, director_property.Foo.setA)

    def ping(self):
        return "PyFoo::ping()"


foo = PyFoo()

foo.setA("BLABLA")
if foo.getA() != "BLABLA":
    raise RuntimeError

# test property addition in PyFoo
if foo.a != "BLABLA":
    raise RuntimeError

foo.a = "BIBI"
if foo.a != "BIBI":
    raise RuntimeError
if foo.getA() != "BIBI":
    raise RuntimeError



class MyFoo(director_property.Foo):
    def setA(self, a):
        director_property.Foo.setA(self, a + " set from MyFoo")
    def setAByRef(self, a):
        director_property.Foo.setA(self, a + " setAByRef from MyFoo")

a = MyFoo()
if (a.getA() != ""):
    raise RuntimeError("Test failed")
a.setA("Hello")
if (a.getA() != "Hello set from MyFoo"):
    raise RuntimeError("Test failed")
a.setAByRef("Hello")
if (a.getA() != "Hello setAByRef from MyFoo"):
    raise RuntimeError("Test failed")
del a

a_original = MyFoo()
a = director_property.Foo.get_self(a_original)
if (a.getA() != ""):
    raise RuntimeError("Test failed")
a.setA("Hello")
if (a.getA() != "Hello set from MyFoo"):
    raise RuntimeError("Test failed")
a.setAByRef("Hello")
if (a.getA() != "Hello setAByRef from MyFoo"):
    raise RuntimeError("Test failed")
del a
