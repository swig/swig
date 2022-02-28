import python_nondynamic

def debug_print(s):
    show_debug = False
    if show_debug:
        print(s)

aa = python_nondynamic.A()

aa.a = 1
aa.b = 2

# Check values are really set
if python_nondynamic.retrieve_A_a(aa) != 1: raise RuntimeError("a not set correctly")
if python_nondynamic.retrieve_A_b(aa) != 2: raise RuntimeError("b not set correctly")

try:
    aa.c = 2
    raise RuntimeError("A is not static")
except AttributeError as e:
    debug_print(e)
    pass

class PurePythonClass(object):
    def __init__(self):
        self.variables = dict()
    def __set__(self, name, value):
        self.variables[name] = value
    pass

class B(python_nondynamic.A):
    c = 4
    cc = PurePythonClass()
    cc.nnn = "new attrib"

    def __init__(self):
        python_nondynamic.A.__init__(self)
        pass
    pass

bb = B()
bb.a = 4
bb.b = 5
# Check values are really set
if python_nondynamic.retrieve_A_a(bb) != 4: raise RuntimeError("a not set correctly")
if python_nondynamic.retrieve_A_b(bb) != 5: raise RuntimeError("b not set correctly")

try:
    bb.c = 3
    raise RuntimeError("B.c class variable messes up nondynamic-ness of B bb.c={} B.c={}".format(bb.c, B.c))
except AttributeError as e:
    debug_print(e)
    pass

try:
    bb.d = 2
    raise RuntimeError("B is not static")
except AttributeError as e:
    debug_print(e)
    pass

cc = python_nondynamic.C()
cc.d = 3

# An inconsistency between builtin and non-builtin.
# Class variables cannot be set on builtin types, like other Python builtins, eg list.classvar=111 fails
if python_nondynamic.is_python_builtin():
    try:
        python_nondynamic.C.classvar = 111
        raise RuntimeError("C should not allow static variables to be added when using builtin")
    except AttributeError as e:
        debug_print(e)
        pass
else:
    python_nondynamic.C.classvar = 111

if not python_nondynamic.is_python_builtin():
    # Not working with builtin :(
    try:
        B.a = 10
        raise RuntimeError("B should not allow adding a class variable by setting it as an instance variable")
    except AttributeError as e:
        debug_print(e)
        pass

    try:
        python_nondynamic.A.a = 10
        raise RuntimeError("A should not allow adding a class variable by setting it as an instance variable")
    except AttributeError as e:
        debug_print(e)
        pass

if not python_nondynamic.is_python_builtin():
    try:
        bb.cc = 3
        raise RuntimeError("B.cc class variable messes up nondynamic-ness of B bb.cc={} B.cc={}".format(bb.cc, B.cc))
    except AttributeError as e:
        debug_print(e)
        pass

