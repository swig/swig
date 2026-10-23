import cpp14_variable_templates as m

from swig_test_utils import swig_check

# Variable template instantiations are wrapped as read only module level variables holding the value
swig_check(m.cvar.bits_in_char, 8)
swig_check(m.cvar.factorial_5,  120)
swig_check(m.cvar.factorial_10, 3628800)

# Read only check:
try:
    m.cvar.factorial_5 = 0
except AttributeError:
    pass
else:
    raise RuntimeError("factorial_5 should be read only")
