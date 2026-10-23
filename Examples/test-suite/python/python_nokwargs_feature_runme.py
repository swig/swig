# Exercises the interaction between a module-wide %feature("kwargs") and
# per-symbol %nokwargs opt-outs across constructors, instance methods,
# static methods, and global functions.

import python_nokwargs_feature as m
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

# Functions covered by the global %feature("kwargs") accept named args.
swig_check(m.KwargsClass(a=3, b=4).value, 3004)
swig_check(m.KwargsClass(b=4).value, 10004)
swig_check(m.KwargsClass().instance_method(a=3, b=4), 34)
swig_check(m.KwargsClass().instance_method(b=4), 14)
swig_check(m.KwargsClass.static_method(a=3, b=4), 304)
swig_check(m.KwargsClass.static_method(b=4), 104)
swig_check(m.kw_global(a=3, b=4), 30004)
swig_check(m.kw_global(b=4), 10004)

# %nokwargs opts a symbol out: kwargs raise TypeError under -builtin. Without
# -builtin, the generated Python proxy accepts named arguments and forwards
# them positionally, masking the C wrapper level rejection.
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
