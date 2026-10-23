# Regression test for the %nokwargs / -keyword interaction.
#
# Built with -keyword so every function defaults to METH_VARARGS|METH_KEYWORDS.
# %nokwargs on a specific symbol must opt it back out to METH_VARARGS. Before
# the check_kwargs() fix, %nokwargs was silently ignored when use_kw was set.

import python_nokwargs_keyword as m
from swig_test_utils import swig_check, swig_assert_raises


# Positional calls always work.
swig_check(m.KwargsClass(3, 4).value, 3004)
swig_check(m.NoKwargsClass(3, 4).value, 3004)
swig_check(m.KwargsClass().instance_method(3, 4), 34)
swig_check(m.NoKwargsClass().instance_method(3, 4), 34)
swig_check(m.KwargsClass.static_method(3, 4), 304)
swig_check(m.NoKwargsClass.static_method(3, 4), 304)
swig_check(m.kw_global(3, 4), 30004)
swig_check(m.no_kw_global(3, 4), 30004)

# Functions covered by -keyword accept named args.
swig_check(m.KwargsClass(a=3, b=4).value, 3004)
swig_check(m.KwargsClass(b=4).value, 10004)
swig_check(m.KwargsClass().instance_method(a=3, b=4), 34)
swig_check(m.KwargsClass().instance_method(b=4), 14)
swig_check(m.KwargsClass.static_method(a=3, b=4), 304)
swig_check(m.KwargsClass.static_method(b=4), 104)
swig_check(m.kw_global(a=3, b=4), 30004)
swig_check(m.kw_global(b=4), 10004)

# %nokwargs must override -keyword: kwargs raise TypeError under -builtin.
# Without -builtin, the generated Python proxy accepts named arguments and
# forwards them positionally, masking the C wrapper level rejection.
if m.is_python_builtin():
    with swig_assert_raises(TypeError):
        m.NoKwargsClass(a=3, b=4)
    with swig_assert_raises(TypeError):
        m.NoKwargsClass(b=4)
    with swig_assert_raises(TypeError):
        m.NoKwargsClass().instance_method(a=3, b=4)
    with swig_assert_raises(TypeError):
        m.NoKwargsClass().instance_method(b=4)
    with swig_assert_raises(TypeError):
        m.NoKwargsClass.static_method(a=3, b=4)
    with swig_assert_raises(TypeError):
        m.NoKwargsClass.static_method(b=4)
    with swig_assert_raises(TypeError):
        m.no_kw_global(a=3, b=4)
    with swig_assert_raises(TypeError):
        m.no_kw_global(b=4)
