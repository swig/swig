from python_append import *
t=Test()
t.func()
t.static_func()

if grabpath() != os.path.dirname(mypath):
  raise RuntimeError

if grabstaticpath() != os.path.basename(mypath):
  raise RuntimeError

