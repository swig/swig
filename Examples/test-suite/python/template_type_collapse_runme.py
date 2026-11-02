from template_type_collapse import *
from swig_test_utils import swig_check

i = 1234
ci = DerivedConsterInt()
ci.cccc1(i)
ci.cccc2(i)
ci.cccc3(i)
ci.cccc4(i)

dci = DerivedConsterInt()
swig_check(dci.dddd(i), i)

swig_check(VolatilerConstInt().take_const(i), i)
swig_check(VolatilerConstInt().take_volatile(), 42)
swig_check(VolatilerVolatileInt().take_const(), 42)
swig_check(VolatilerConstVolatileInt().take_const(), 42)
swig_check(VolatilerConstVolatileInt().take_volatile(), 42)

swig_check(ArrayerInt3().take_const(), 42)
swig_check(ArrayerConstInt3().take_const(), 42)
swig_check(ArrayerVolatileInt3().take_const(), 43)
