import struct_value

b = struct_value.Bar()

b.a.x = 3
if b.a.x != 3:
    raise RuntimeError

b.b.x = 3
if b.b.x != 3:
    raise RuntimeError


# Test dynamically added attributes - Github pull request #320
b.added = 123

if b.added != 123:
    raise RuntimeError("Wrong attribute value")

if "added" not in b.__dict__:
    raise RuntimeError("Missing added attribute in __dict__")


class PyBar(struct_value.Bar):

    def __init__(self):
        self.extra = "hi"
        struct_value.Bar.__init__(self)

pybar = PyBar()
if "extra" not in pybar.__dict__:
    raise RuntimeError("Missing extra attribute in __dict__")
if pybar.extra != "hi":
    raise RuntimeError("Incorrect attribute value for extra")

foo = struct_value.Foo()
foo.x = 10
error_message = ""
try:
    del foo.x
except AttributeError as e:
    error_message = str(e)

# Check for different error messages builtin vs non-builtin wrappers (error message changed in python-3.11)
if not ("Illegal member variable deletion" in error_message or "object has no deleter" in error_message or "can't delete attribute" in error_message):
    raise RuntimeError("Unexpected error message: {}".format(error_message))
