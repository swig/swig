import director_abstract

class MyFoo(director_abstract.Foo):
	def ping(self):
		return "MyFoo::ping()"


a = MyFoo()

if a.ping() != "MyFoo::ping()":
	raise RuntimeError, a.ping()

if a.pong() != "Foo::pong();MyFoo::ping()":
	raise RuntimeError, a.pong()


