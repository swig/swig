from director_exception import *
from exceptions import *

class MyFoo(Foo):
	def ping(self):
		raise NotImplementedError, "MyFoo::ping() EXCEPTION"

class MyFoo2(Foo):
	def ping(self):
		return true
		pass # error: should return a string

ok = 0

a = MyFoo()
b = launder(a)

try:
	b.pong()
except NotImplementedError, e:
	ok = 1
except:
	pass

if not ok:
	raise RuntimeError

ok = 0

a = MyFoo2()
b = launder(a)

try:
	b.pong()
except:
	ok = 1


if not ok:
	raise RuntimeError


try:
	raise Exception2()
except Exception2:
	pass

try:
	raise Exception1()
except Exception1:
	pass
