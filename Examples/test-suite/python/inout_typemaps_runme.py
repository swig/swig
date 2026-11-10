import inout_typemaps
from swig_test_utils import swig_check

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

swig_check(inout_typemaps.SuppressedTwo(1), [11, 12])
swig_check(inout_typemaps.SuppressedOne(1), 11)
swig_check(inout_typemaps.SuppressedNone(1), None)
swig_check(inout_typemaps.VoidNone(), None)
swig_check(inout_typemaps.VoidOne(), [None, 11])
swig_check(inout_typemaps.VoidTwo(), [None, 11, 12])
