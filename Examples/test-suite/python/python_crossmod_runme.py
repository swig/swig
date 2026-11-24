import sys
from swig_test_utils import swig_check
import python_crossmod_a
import python_crossmod_b

c = python_crossmod_b.C()
if c.methA() != 1:
    raise RuntimeError("methA got {}".format(c.methA()))
if c.methB() != 2:
    raise RuntimeError("methB got {}".format(c.methB()))
if c.methC() != 3:
    raise RuntimeError("methC got {}".format(c.methC()))

# Freeing a plain pointer wrapper made by the second module must leave the runtime data capsule refcount unchanged
runtime = [m for n, m in sys.modules.items() if n.startswith("swig_runtime_data")][0]
capsule = [getattr(runtime, a) for a in dir(runtime) if a.startswith("type_pointer_capsule")][0]
before = sys.getrefcount(capsule)
p = python_crossmod_b.get_int_ptr()
del p
swig_check(sys.getrefcount(capsule), before)

# The same for an owning wrapper made by the first module whose destructor is in the second module
before = sys.getrefcount(capsule)
b = python_crossmod_a.make_b()
swig_check(type(b).__name__, "B")
del b
swig_check(sys.getrefcount(capsule), before)
