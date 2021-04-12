from director_exception import *


class MyException(Exception):

    def __init__(self, a, b):
        self.msg = a + b


class MyFoo(Foo):

    def ping(self):
        raise NotImplementedError("MyFoo::ping() EXCEPTION")


class MyFoo2(Foo):

    def ping(self):
        return True
        pass  # error: should return a string


class MyFoo3(Foo):

    def ping(self):
        raise MyException("foo", "bar")

class MyFoo4(Foo):

    def ping(self, *args):
        t = type("bad", "call") # throws TypeError message: type() takes 1 or 3 arguments
        return "Foo4.ping"


# Check that the NotImplementedError raised by MyFoo.ping() is returned by
# MyFoo.pong().
a = MyFoo()
b = launder(a)
try:
    b.pong()
    raise RuntimeError("Exception was not thrown")
except NotImplementedError as e:
    if not str(e) == "MyFoo::ping() EXCEPTION":
        raise RuntimeError("Unexpected error message: %s" % str(e))
except TypeError:
    pass


# Check that the director returns the appropriate TypeError if the return type
# is wrong.
a = MyFoo2()
b = launder(a)
try:
    b.pong()
    raise RuntimeError("Exception was not thrown")
except TypeError as e:
    # fastdispatch mode adds on Additional Information to the exception message - just check the main exception message exists
    if not str(e).startswith("SWIG director type mismatch in output value of type 'std::string'"):
        raise RuntimeError("Unexpected error message: %s" % str(e))


# Check that the director can return an exception which requires two arguments
# to the constructor, without mangling it.
a = MyFoo3()
b = launder(a)
try:
    b.pong()
    raise RuntimeError("Exception was not thrown")
except MyException as e:
    if e.msg != "foobar":
        raise RuntimeError("Unexpected error message: %s" % str(e))


# Check that the director returns the appropriate TypeError thrown in a director method
a = MyFoo4()
b = launder(a)
try:
    b.pong()
    raise RuntimeError("Exception was not thrown")
except TypeError as e:
    if not str(e).startswith("type() takes 1 or 3 arguments"):
        raise RuntimeError("Unexpected error message: %s" % str(e))


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
