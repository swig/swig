from exception_order import *

# This test is expected to fail with -builtin option.
# Throwing builtin classes as exceptions not supported
if is_python_builtin():
    exit(0)

a = A()

try:
    a.foo()
except E1 as e:
    pass
except:
    raise RuntimeError("bad exception order")

try:
    a.bar()
except E2 as e:
    pass
except:
    raise RuntimeError("bad exception order")

try:
    a.foobar()
except RuntimeError as e:
    if e.args[0] != "postcatch unknown":
        raise RuntimeError("bad exception order {}".format(e.args))


try:
    a.barfoo(1)
except E1 as e:
    pass
except:
    raise RuntimeError("bad exception order")

try:
    a.barfoo(2)
except E2 as e:
    pass
except:
    raise RuntimeError("bad exception order")
