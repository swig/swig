from python_abi3t import *
import sys
import sysconfig

f = Abi3tFoo(42)
if f.value != 42:
    raise RuntimeError("expected value 42, got " + str(f.value))
if f.getValue() != 42:
    raise RuntimeError("getValue() failed")

f.value = 100
if f.getValue() != 100:
    raise RuntimeError("setting value failed")

# exercises multiple inheritance, i.e. the linked-list of 'this' SwigPyObjects
if f.base1Value() != 111:
    raise RuntimeError("base1Value() failed")
if f.base2Value() != 222:
    raise RuntimeError("base2Value() failed")
if not isinstance(f, Abi3tBase1):
    raise RuntimeError("isinstance Abi3tBase1 failed")
if not isinstance(f, Abi3tBase2):
    raise RuntimeError("isinstance Abi3tBase2 failed")

repr(f)
del f

# exercises the swig_varlinkobject (cvar) global variable mechanism
if cvar.abi3t_global_counter != 7:
    raise RuntimeError("expected cvar.abi3t_global_counter == 7")
cvar.abi3t_global_counter = 99
if cvar.abi3t_global_counter != 99:
    raise RuntimeError("setting cvar.abi3t_global_counter failed")

# exercises SwigPyPacked (pointer-to-member wrapped as packed data)
repr(abi3t_get_getValue_ptr())

# stress test allocation/deallocation of SwigPyObject instances
for i in range(1000):
    obj = Abi3tFoo(i)
    if obj.getValue() != i:
        raise RuntimeError("stress loop failed at iteration " + str(i))
    del obj

# -abi3t alone (without -nogil) makes no thread-safety claim, so it must leave
# the GIL enabled; only meaningful when actually run under a free-threaded build.
if sysconfig.get_config_var("Py_GIL_DISABLED") and not sys._is_gil_enabled():
    raise RuntimeError("expected -abi3t alone (without -nogil) to leave the GIL enabled")
