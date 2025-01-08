# file: runme.py

# This file illustrates the external runtime feature.

import example


class PyFunction(object):
    def __init__(self):
        self.__mesh = example.Mesh(42)
    def mesh(self):
        return self.__mesh

if not example.is_python_builtin():
    obj = PyFunction()
    f = example.Function(obj)
    value = f.meshValue()
    print(value)
    assert value == 42
    print('OK')

# All done.

print("")
print("python exit")
