import varargs

if varargs.test("Hello") != "Hello":
    raise RuntimeError, "Failed"

f = varargs.Foo()
if f.test("Hello") != "Hello":
    raise RuntimeError, "Failed"
