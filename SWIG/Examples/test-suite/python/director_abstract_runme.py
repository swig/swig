import director_abstract

class MyFoo(director_abstract.Foo):
	def __init__(self):
		director_abstract.Foo.__init__(self)
	def ping(self):
		return "MyFoo::ping()"


a = MyFoo()

if a.ping() != "MyFoo::ping()":
	raise RuntimeError, a.ping()

if a.pong() != "Foo::pong();MyFoo::ping()":
	raise RuntimeError, a.pong()


class MyExample(director_abstract.Example1):
	def __init__(self):
		director_abstract.Example1.__init__(self)
		pass
	
	def Color(self, r, g, b):
		return r

me = MyExample()

print me.Color(1,2,3)

