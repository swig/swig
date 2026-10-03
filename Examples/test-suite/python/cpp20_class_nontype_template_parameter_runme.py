from cpp20_class_nontype_template_parameter import *

from swig_test_utils import swig_check, swig_assert_raises

def xy(p):
    return (p.x, p.y)

swig_check(xy(OriginDefaultDef().get()), (2, 3))
swig_check(origin_default_x(OriginDefaultDef()), 2)
swig_check(xy(OriginDefaultUnit().get()), (2, 3))
with swig_assert_raises(TypeError):
    origin_default_x(OriginDefaultUnit())

swig_check(xy(NamedOriginDefaultDef().get()), (0, 0))
swig_check(xy(NamedOriginDefaultUnit().get()), (1, 1))
