from python_append import *

# test not relevant for -builtin
if is_python_builtin():
  exit(0)

t=Test()
t.func()
t.static_func()

if grabpath() != os.path.dirname(mypath):
  raise RuntimeError("grabpath failed")

if grabstaticpath() != os.path.basename(mypath):
  raise RuntimeError("grabstaticpath failed")

