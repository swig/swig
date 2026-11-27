import sys

from li_std_vector import *
from swig_test_utils import swig_check

if typedef_test(101) != 101:
    raise RuntimeError

try:
  sv = StructVector([None, None])
  raise RuntimeError("Using None should result in a TypeError")
except TypeError:
  pass


# Variables
vh = VariableHolder()
vector_append(vh.instance_variable, 10)
if vh.instance_variable[0] != 10:
    raise RuntimeError("instance_variable check")
vh.instance_variable.clear()
if len(vh.instance_variable) != 0:
    raise RuntimeError("instance_variable clear")

vector_append(cvar.VariableHolder_static_variable, 20)
if cvar.VariableHolder_static_variable[0] != 20:
    raise RuntimeError("static_variable check")
cvar.VariableHolder_static_variable.clear()
if len(cvar.VariableHolder_static_variable) != 0:
    raise RuntimeError("static_variable clear")

vector_append(cvar.global_variable, 30)
if cvar.global_variable[0] != 30:
    raise RuntimeError("global_variable check")
cvar.global_variable.clear()
if len(cvar.global_variable) != 0:
    raise RuntimeError("global_variable clear")

# Passing a wrapped vector where a sequence is expected does not leak a reference to its 'this'
iv = IntVector([1, 2, 3])
refs = sys.getrefcount(iv.this)
for i in range(10):
    swig_check(sum(iv), 6)
swig_check(sys.getrefcount(iv.this), refs)
