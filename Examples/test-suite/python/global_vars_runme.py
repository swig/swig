import global_vars
from swig_test_utils import swig_check

global_vars.init()
b = global_vars.cvar.b
if b != "string b":
    raise RuntimeError("Unexpected string: " + b)
global_vars.cvar.b = "a string value"
b = global_vars.cvar.b
if b != "a string value":
    raise RuntimeError("Unexpected string: " + b)

x = global_vars.cvar.x
if x != 1234:
    raise RuntimeError("Unexpected x: " + str(x))
global_vars.cvar.x = 9876
x = global_vars.cvar.x
if x != 9876:
    raise RuntimeError("Unexpected string: " + str(x))

fail = True
try:
    global_vars.cvar.notexist = "something"
except AttributeError as e:
    fail = False
if fail:
    raise RuntimeError("AttributeError should have been thrown")

fail = True
try:
    g = global_vars.cvar.notexist
except AttributeError as e:
    fail = False
if fail:
    raise RuntimeError("AttributeError should have been thrown")

an = global_vars.A()
an.x = 42
global_vars.cvar.avp = an
swig_check(global_vars.cvar.avp.x, 42)
global_vars.cvar.avp = None
swig_check(global_vars.cvar.avp, None)

global_vars.cvar.a.x = 7
swig_check(global_vars.cvar.acvp.x, 7)
swig_check(global_vars.cvar.acpr.x, 7)

global_vars.assign_hp(global_vars.cvar.hcpr)
swig_check(global_vars.cvar.hp, global_vars.cvar.hcp)
