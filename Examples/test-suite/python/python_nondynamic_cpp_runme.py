import python_nondynamic_cpp

e = python_nondynamic_cpp.Element()
e.value = 42
ve = python_nondynamic_cpp.VectorElement((e,))
if ve[0].value != 42:
    raise RuntimeError("vector element not retrieved correctly")

try:
    ve[0].other = 1
    raise RuntimeError("Element in a vector is not static")
except AttributeError:
    pass
