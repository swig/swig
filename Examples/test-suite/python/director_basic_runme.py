import director_basic

class PyFoo(director_basic.Foo):
	def ping(self):
		return "PyFoo::ping()"


a = PyFoo()

if a.ping() != "PyFoo::ping()":
	raise RuntimeError, a.ping()

if a.pong() != "Foo::pong();PyFoo::ping()":
	raise RuntimeError, a.pong()

b = director_basic.Foo()

if b.ping() != "Foo::ping()":
	raise RuntimeError, b.ping()

if b.pong() != "Foo::pong();Foo::ping()":
	raise RuntimeError, b.pong()

a = director_basic.A1(1)

if a.rg(2) != 2:
	raise RuntimeError



class PyClass(director_basic.MyClass):
	def vmethod(self, b):
		b.x += 31
		return b


b = director_basic.Bar(3)
d = director_basic.MyClass()
c = PyClass()

cc = PyClass.get_self(c)
dd = PyClass.get_self(d)

bc = cc.cmethod(b)
bd = dd.cmethod(b)

if bc.x != 34:
	raise RuntimeError


if bd.x != 16:
	raise RuntimeError

