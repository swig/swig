import director_basic

class MyFoo(director_basic.Foo):
	def ping(self):
		return "MyFoo::ping()"


a = MyFoo()

if a.ping() != "MyFoo::ping()":
	raise RuntimeError, a.ping()

if a.pong() != "Foo::pong();MyFoo::ping()":
	raise RuntimeError, a.pong()

b = director_basic.Foo()

if b.ping() != "Foo::ping()":
	raise RuntimeError, b.ping()

if b.pong() != "Foo::pong();Foo::ping()":
	raise RuntimeError, b.pong()

a = director_basic.A1(1)

if a.rg(2) != 2:
	raise RuntimeError

