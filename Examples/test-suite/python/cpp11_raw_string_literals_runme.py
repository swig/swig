from cpp11_raw_string_literals import *
import inspect
from swig_test_utils import swig_check

if cvar.L != 100:
    raise RuntimeError

if cvar.u8 != 100:
    raise RuntimeError

if cvar.u != 100:
    raise RuntimeError

if UStruct.U != 100:
    raise RuntimeError


if cvar.R != 100:
    raise RuntimeError

if cvar.LR != 100:
    raise RuntimeError

if cvar.u8R != 100:
    raise RuntimeError

if cvar.uR != 100:
    raise RuntimeError

if URStruct.UR != 100:
    raise RuntimeError


if cvar.aa != "Wide string":
    raise RuntimeError

swig_check(ll, "Wide string constant")

if cvar.bb != "UTF-8 string":
    raise RuntimeError(cvar.wide)

if cvar.xx != ")I'm an \"ascii\" \\ string.":
    raise RuntimeError(cvar.xx)

if cvar.ee != ")I'm an \"ascii\" \\ string.":
    raise RuntimeError(cvar.ee)

if cvar.ff != "I'm a \"raw wide\" \\ string.":
    raise RuntimeError(cvar.ff)

if cvar.gg != "I'm a \"raw UTF-8\" \\ string.":
    raise RuntimeError(cvar.gg)

swig_check(nn, "I'm a \"raw wide\" \\ string constant.")
swig_check(cvar.ww, "I'm a \"raw wide\" \\ auto.")
swig_check(raw_wide_default_length(), 4)


def check(got, expected):
    expected_list = expected.split("\n")
    got_list = got.split("\n")

    if expected_list != got_list:
        raise RuntimeError("\n" + "Expected: " + str(expected_list) + "\n" + "Got     : " + str(got_list))

# When getting docstrings, use inspect.getdoc(x) instead of x.__doc__ otherwise the different options
# such as -O and -builtin may produce different initial indentation.
check(inspect.getdoc(RawStringDoc.WW), "Single line documentation comment")
check(inspect.getdoc(RawStringDoc.XX),
"""Multi-line
documentation
comment""")
check(inspect.getdoc(RawStringDoc.YY), """Single line "raw string" documentation comment""")
check(inspect.getdoc(RawStringDoc.ZZ),
r"""Documentation comment

as a "raw string"
on multiple lines including a \ backslash""")

check(mm, r""")I'm an "ascii" \ string constant with multiple

lines.""")
