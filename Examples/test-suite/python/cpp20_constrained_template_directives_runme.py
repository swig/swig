import cpp20_constrained_template_directives as m

from swig_test_utils import swig_check

swig_check(m.prefixed(2.5), 2)
swig_check(m.getLastCalled(), "prefixed IsReal")

swig_check(m.trailing(3), 1)
swig_check(m.getLastCalled(), "trailing IsInt")

swig_check(m.typed(2.5), 2)
swig_check(m.mixed(3), 1)
swig_check(m.halved(2.5), 2)
swig_check(m.spelt(m.FiveBytes()), 1)
swig_check(m.packed(1.5, 2.5), 2)
swig_check(m.Picker().pick(2.5), 2)
swig_check(m.plain(3), 1)
