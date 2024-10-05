import inout_typemaps

a = inout_typemaps.AddOne1(1)
if a != 2:
    raise RuntimeError

a = inout_typemaps.AddOne3(1, 1, 1)
if a != [2, 2, 2]:
    raise RuntimeError

a = inout_typemaps.AddOne1p((1, 1))
if a != (2, 2):
    raise RuntimeError

a = inout_typemaps.AddOne2p((1, 1), 1)
if a != [(2, 2), 2]:
    raise RuntimeError

a = inout_typemaps.AddOne3p(1, (1, 1), 1)
if a != [2, (2, 2), 2]:
    raise RuntimeError

ret, out = inout_typemaps.NonVoidOut(-42)
if ret is not None:
    raise RuntimeError
if out != 0:
    raise RuntimeError
