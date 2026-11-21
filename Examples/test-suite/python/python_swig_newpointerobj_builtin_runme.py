from python_swig_newpointerobj_builtin import *

# SWIG_NewPointerObj used inside %inline C code should work without
# 'self' when using -builtin (issue #2613).
f = make_foo(42)
if f is None:
    raise RuntimeError("make_foo returned None")
if f.n != 42:
    raise RuntimeError("make_foo returned unexpected value")
