import python_runtime_data_builtin as builtin
import python_runtime_data_nobuiltin as nobuiltin

def swig_assert(a):
    if not a:
        raise RuntimeError("Failed")

swig_assert(builtin.is_python_builtin())
swig_assert(not nobuiltin.is_python_builtin())

for i in range(1, 5):
    v1 = builtin.vectord([1.] * i)
    swig_assert(len(v1) == i)
    v2 = nobuiltin.vectord([1.] * i)
    swig_assert(len(v2) == i)
