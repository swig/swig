from director_nested import *


class A(FooBar_int):
  def do_step(self):
    return "A::do_step;"
  
  def get_value(self):
    return "A::get_value"

  pass


a = A()
if a.step() != "Bar::step;Foo::advance;Bar::do_advance;A::do_step;":
  raise RuntimeError,"Bad A virtual resolution"


class B(FooBar_int):
  def do_advance(self):
    return "B::do_advance;" + self.do_step()

  def do_step(self):
    return "B::do_step;"
  
  def get_value(self):
    return "B::get_value"

  pass


b = B()

if b.step() != "Bar::step;Foo::advance;B::do_advance;B::do_step;":
  raise RuntimeError,"Bad B virtual resolution"

