from director_shared_ptr import *


class director_shared_ptr_MyBarFoo(Foo):

  def ping(self):
    return "director_shared_ptr_MyBarFoo.ping()"

  def pong(self):
    return "director_shared_ptr_MyBarFoo.pong();" + self.ping()

  def upcall(self, fooBarPtr):
    return "override;" + fooBarPtr.FooBarDo()

  def makeFoo(self):
    return Foo()

class director_shared_ptr_MyBarFooDerived(FooDerived):

  def ping(self):
    return "director_shared_ptr_MyBarFooDerived.ping()"

  def pong(self):
    return "director_shared_ptr_MyBarFooDerived.pong();" + self.ping()

  def upcall(self, fooBarPtr):
    return "overrideDerived;" + fooBarPtr.FooBarDo()

  def makeFoo(self):
    return Foo()

def check(got, expected):
  if (got != expected):
    raise RuntimeError("Failed, got: " + got + " expected: " + expected)

fooBar = FooBar()

myBarFoo = director_shared_ptr_MyBarFoo()
check(myBarFoo.ping(), "director_shared_ptr_MyBarFoo.ping()")
check(Foo.callPong(myBarFoo), "director_shared_ptr_MyBarFoo.pong();director_shared_ptr_MyBarFoo.ping()")
check(Foo.callUpcall(myBarFoo, fooBar), "override;Bar::Foo2::Foo2Bar()")

myFoo = myBarFoo.makeFoo()
check(myFoo.pong(), "Foo::pong();Foo::ping()")
check(Foo.callPong(myFoo), "Foo::pong();Foo::ping()")
check(myFoo.upcall(FooBar()), "Bar::Foo2::Foo2Bar()")

myFoo2 = Foo().makeFoo()
check(myFoo2.pong(), "Foo::pong();Foo::ping()")
check(Foo.callPong(myFoo2), "Foo::pong();Foo::ping()")
check(myFoo2.upcall(FooBar()), "Bar::Foo2::Foo2Bar()")

myBarFooDerived = director_shared_ptr_MyBarFooDerived()
check(myBarFooDerived.ping(), "director_shared_ptr_MyBarFooDerived.ping()")
check(FooDerived.callPong(myBarFooDerived), "director_shared_ptr_MyBarFooDerived.pong();director_shared_ptr_MyBarFooDerived.ping()")
check(FooDerived.callUpcall(myBarFooDerived, fooBar), "overrideDerived;Bar::Foo2::Foo2Bar()")
