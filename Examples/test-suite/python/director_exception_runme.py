from director_exception import *


class MyException(Exception):

    def __init__(self, a, b):
        self.msg = a + b


class MyFoo(Foo):

    def ping(self):
        raise NotImplementedError, "MyFoo::ping() EXCEPTION"


class MyFoo2(Foo):

    def ping(self):
        return True
        pass  # error: should return a string


class MyFoo3(Foo):

    def ping(self):
        raise MyException("foo", "bar")

class MyFoo4(Foo):

    def ping(self, *args):
        print(type("bad", "call")) # throws TypeError message: type() takes 1 or 3 arguments
        return "Foo4.ping"


# Check that the NotImplementedError raised by MyFoo.ping() is returned by
# MyFoo.pong().
ok = 0
a = MyFoo()
b = launder(a)
try:
    b.pong()
except NotImplementedError, e:
    if str(e) == "MyFoo::ping() EXCEPTION":
        ok = 1
    else:
        print "Unexpected error message: %s" % str(e)
except:
    pass
if not ok:
    raise RuntimeError


# Check that the director returns the appropriate TypeError if the return type
# is wrong.
ok = 0
a = MyFoo2()
b = launder(a)
try:
    b.pong()
except TypeError, e:
    # fastdispatch mode adds on Additional Information to the exception message - just check the main exception message exists
    if str(e).startswith("SWIG director type mismatch in output value of type 'std::string'"):
        ok = 1
    else:
        print "Unexpected error message: %s" % str(e)
if not ok:
    raise RuntimeError


# Check that the director can return an exception which requires two arguments
# to the constructor, without mangling it.
ok = 0
a = MyFoo3()
b = launder(a)
try:
    b.pong()
except MyException, e:
    if e.msg == "foobar":
        ok = 1
    else:
        print "Unexpected error message: %s" % str(e)
if not ok:
    raise RuntimeError


# Check that the director returns the appropriate TypeError thrown in a director method
ok = 0
a = MyFoo4()
b = launder(a)
try:
    b.pong()
except TypeError as e:
    if str(e).startswith("type() takes 1 or 3 arguments"):
        ok = 1
    else:
        print "Unexpected error message: %s" % str(e)
if not ok:
    raise RuntimeError


# This is expected to fail with -builtin option
# Throwing builtin classes as exceptions not supported
if not is_python_builtin():
    try:
        raise Exception2()
    except Exception2:
        pass

    try:
        raise Exception1()
    except Exception1:
        pass
