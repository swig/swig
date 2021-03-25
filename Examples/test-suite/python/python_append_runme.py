from python_append import *


# test not relevant for -builtin
if is_python_builtin():
    exit(0)

t = Test()
t.funk()
t.static_func()

if grabpath() != os.path.dirname(mypath):
    raise RuntimeError("grabpath failed")

if grabstaticpath() != os.path.basename(mypath):
    raise RuntimeError("grabstaticpath failed")

clearstaticpath()
if grabstaticpath() != None:
    raise RuntimeError("Resetting staticfuncpath failed")
Test.static_func()
if grabstaticpath() != os.path.basename(mypath):
    raise RuntimeError("grabstaticpath failed")

# slots test
fs = ForSlots()
if fs.ValidVariable != 99:
    raise RuntimeError("ValidVariable failed")
fs.ValidVariable = 11
if fs.ValidVariable != 11:
    raise RuntimeError("ValidVariable failed")
try:
    fs.Invalid = 22
    raise RuntimeError("It should not be possible to set a random variable name")
except AttributeError:
    pass
