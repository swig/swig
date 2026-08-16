from cpp20_concepts_directors import *

from swig_test_utils import swig_check


class PyCallback(CallbackInt):

    def plain(self, x):
        return 100

    def arrow(self, x):
        return 200

    def overridable(self, x):
        return 300


class PyInherited(InheritedInt):

    def arrow_over(self, x):
        return 400

    def plain_over(self, x):
        return 500

    def overridable(self, x):
        return 600


c = PyCallback()

# plain and arrow are final, so the director does not override them and C++ keeps its own.
swig_check(call_plain(c, 1), 2)
swig_check(call_arrow(c, 1), 3)
swig_check(call_overridable(c, 1), 300)

d = PyInherited()

# arrow_over and plain_over are final overrides of inherited virtuals, so the director leaves
# them alone too, while a member inherited unchanged is still overridden.
swig_check(call_arrow_over(d, 1), 21)
swig_check(call_plain_over(d, 1), 31)
swig_check(call_overridable(d, 1), 600)
