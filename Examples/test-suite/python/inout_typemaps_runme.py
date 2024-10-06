import inout_typemaps

a = inout_typemaps.AddOne1(1)
if a != 2:
    raise RuntimeError

a = inout_typemaps.AddOne3(10, 20, 30)
if a != [11, 21, 31]:
    raise RuntimeError

a = inout_typemaps.AddOne1p((10, 20))
if a != (11, 21):
    raise RuntimeError

a = inout_typemaps.AddOne2p((10, 20), 30)
if a != [(11, 21), 31]:
    raise RuntimeError

a = inout_typemaps.AddOne3p(10, (20, 30), 40)
if a != [11, (21, 31), 41]:
    raise RuntimeError

ret, out = inout_typemaps.NonVoidOut(-42)
if ret is not None:
    raise RuntimeError
if out != 0:
    raise RuntimeError
