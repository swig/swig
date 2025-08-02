from director_nested import *


class A(FooBar_int):

    def do_step(self):
        return "A::do_step;"

    def get_value(self):
        return "A::get_value"

    pass


a = A()
if a.step() != "Bar::step;Foo::advance;Bar::do_advance;A::do_step;":
    raise RuntimeError("Bad A virtual resolution")


class B(FooBar_int):

    def do_advance(self):
        return "B::do_advance;" + self.do_step()

    def do_step(self):
        return "B::do_step;"

    def get_value(self):
        return 1

    pass


b = B()

if b.step() != "Bar::step;Foo::advance;B::do_advance;B::do_step;":
    raise RuntimeError("Bad B virtual resolution")


class C(FooBar_int):

    def do_advance(self):
        return "C::do_advance;" + FooBar_int.do_advance(self)

    def do_step(self):
        return "C::do_step;"

    def get_value(self):
        return 2

    def get_name(self):
        # We suppressed the warning:
        #  Warning 473: Returning a reference, pointer or pointer wrapper in a director method is not recommended.
        # An extra reference to the returned string is now required to keep it from being deleted as the C code
        # uses a pointer to the internal Python string which would otherwise be deleted and then the pointer would
        # point to garbage.
        self.hack_extra_reference = FooBar_int.get_name(self) + " hello"
        return self.hack_extra_reference

    pass

cc = C()
c = FooBar_int.get_self(cc)
c.advance()

if c.get_name() != "FooBar::get_name hello":
    raise RuntimeError

if c.name() != "FooBar::get_name hello":
    raise RuntimeError
