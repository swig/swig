from python_abi3t_nogil import *
import sys
import sysconfig

if abi3t_nogil_value() != 7:
    raise RuntimeError("abi3t_nogil_value() failed")

# -abi3t -nogil declares the module GIL-free, so it must leave the GIL disabled;
# only meaningful when actually run under a free-threaded build.
if sysconfig.get_config_var("Py_GIL_DISABLED") and sys._is_gil_enabled():
    raise RuntimeError("expected -abi3t -nogil to leave the GIL disabled")
