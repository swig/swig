#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'director_shared_ptr'

include Director_shared_ptr

class Director_shared_ptr_MyBarFoo < Foo

  def ping()
    return "director_shared_ptr_MyBarFoo.ping()"
  end

  def pong()
    return "director_shared_ptr_MyBarFoo.pong();" + ping()
  end

  def upcall(fooBarPtr)
    return "override;" + fooBarPtr.FooBarDo()
  end

  def makeFoo()
    return Foo.new()
  end
end

class Director_shared_ptr_MyBarFooDerived < FooDerived

  def ping()
    return "director_shared_ptr_MyBarFooDerived.ping()"
  end

  def pong()
    return "director_shared_ptr_MyBarFooDerived.pong();" + ping()
  end

  def upcall(fooBarPtr)
    return "overrideDerived;" + fooBarPtr.FooBarDo()
  end

  def makeFoo()
    return Foo.new()
  end
end

def check(got, expected)
  if (got != expected)
    raise RuntimeError, "Failed, got: #{got} expected: #{expected}"
  end
end

fooBar = Director_shared_ptr::FooBar.new()

myBarFoo = Director_shared_ptr_MyBarFoo.new()
check(myBarFoo.ping(), "director_shared_ptr_MyBarFoo.ping()")
check(Foo.callPong(myBarFoo), "director_shared_ptr_MyBarFoo.pong();director_shared_ptr_MyBarFoo.ping()")
check(Foo.callUpcall(myBarFoo, fooBar), "override;Bar::Foo2::Foo2Bar()")

myFoo = myBarFoo.makeFoo()
check(myFoo.pong(), "Foo::pong();Foo::ping()")
check(Foo.callPong(myFoo), "Foo::pong();Foo::ping()")
check(myFoo.upcall(FooBar.new()), "Bar::Foo2::Foo2Bar()")

myFoo2 = Foo.new().makeFoo()
check(myFoo2.pong(), "Foo::pong();Foo::ping()")
check(Foo.callPong(myFoo2), "Foo::pong();Foo::ping()")
check(myFoo2.upcall(FooBar.new()), "Bar::Foo2::Foo2Bar()")

myBarFooDerived = Director_shared_ptr_MyBarFooDerived.new()
check(myBarFooDerived.ping(), "director_shared_ptr_MyBarFooDerived.ping()")
check(FooDerived.callPong(myBarFooDerived), "director_shared_ptr_MyBarFooDerived.pong();director_shared_ptr_MyBarFooDerived.ping()")
check(FooDerived.callUpcall(myBarFooDerived, fooBar), "overrideDerived;Bar::Foo2::Foo2Bar()")
