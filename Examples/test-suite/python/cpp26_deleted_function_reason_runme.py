from cpp26_deleted_function_reason import *
from swig_test_utils import *

swig_check(freeFunction(1), 2)

w = Widget()
swig_check(w.value(), 42)

# The deleted functions are not wrapped
swig_assert(not hasattr(w, "oldValue"), "oldValue should not be wrapped")
swig_assert("oldFreeFunction" not in globals(), "oldFreeFunction should not be wrapped")
swig_assert(not hasattr(Widget, "oldFactory"), "oldFactory should not be wrapped")

# Only the non deleted overload is wrapped
w.overloaded(1)
