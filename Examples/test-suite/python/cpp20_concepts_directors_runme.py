from cpp20_concepts_directors import *

from swig_test_utils import swig_check


class PyCallback(CallbackInt):

    def plain(self, x):
        return 100

    def arrow(self, x):
        return 200

    def overridable(self, x):
        return 300


c = PyCallback()

# plain and arrow are final, so the director does not override them and C++ keeps its own.
swig_check(call_plain(c, 1), 2)
swig_check(call_arrow(c, 1), 3)
swig_check(call_overridable(c, 1), 300)
