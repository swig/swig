import cpp_enum

f = cpp_enum.Foo()

if f.hola != f.Hello:
    raise RuntimeError("f.hola: {}".format(f.hola))

f.hola = f.Hi
if f.hola != f.Hi:
    raise RuntimeError("f.hola: {}".format(f.hola))

f.hola = f.Hello

if f.hola != f.Hello:
    raise RuntimeError("f.hola: {}".format(f.hola))

cpp_enum.cvar.hi = cpp_enum.Hello
if cpp_enum.cvar.hi != cpp_enum.Hello:
    raise RuntimeError("cpp_enum.cvar.hi: {}".format(cpp_enum.cvar.hi))
