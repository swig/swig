import overload_extendc

f = overload_extendc.Foo()
if f.test(3) != 1:
    raise RuntimeError
if f.test("hello") != 2:
    raise RuntimeError
if f.test(3.5,2.5) != 3:
    raise RuntimeError
if f.test("hello",20) != 1020:
    raise RuntimeError
if f.test("hello",20,100) != 120:
    raise RuntimeError



