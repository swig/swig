import cpp20_variable_templates as m

from swig_test_utils import swig_check

# Variable template initialised from a requires-expression - wrapped as a
# read only bool.  int satisfies 't + t', NotAddable doesn't.
swig_check(m.cvar.addable_int,        True)
swig_check(m.cvar.addable_notaddable, False)

# Read only check:
try:
    m.cvar.addable_int = False
except AttributeError:
    pass
else:
    raise RuntimeError("addable_int should be read only")
