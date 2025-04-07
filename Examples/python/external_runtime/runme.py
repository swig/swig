# file: runme.py

# This file illustrates the external runtime feature.

import example


class MeshHolder(object):
    def __init__(self):
        self.__mesh = example.Mesh(42)
    def mesh(self):
        return self.__mesh

if example.is_python_builtin():
    print("SWIG external runtime and builtin not currently working")
else:
    obj = MeshHolder()
    f = example.MeshCaller(obj)

print("All done")
