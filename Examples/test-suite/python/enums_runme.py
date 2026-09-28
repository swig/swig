
import _enums
from swig_test_utils import swig_check

_enums.bar2(1)
_enums.bar3(1)
_enums.bar1(1)

if _enums.cvar.enumInstance != 2:
    raise RuntimeError

if _enums.cvar.Slap != 10:
    raise RuntimeError

if _enums.cvar.Mine != 11:
    raise RuntimeError

if _enums.cvar.Thigh != 12:
    raise RuntimeError

swig_check(_enums.WideCharW, ord("w"))
swig_check(_enums.WideCharE, 0xE9)
swig_check(_enums.WideCharSmile, 0x263A)
