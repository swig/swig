import class_scope_weird

f = class_scope_weird.Foo()
if f.bar(3) != 3:
    raise RuntimeError
