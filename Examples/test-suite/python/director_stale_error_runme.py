# Test that catching DirectorException in C++ and calling clearPythonError()
# does not leave a stale Python error indicator (issue #2671).

from director_stale_error import *

class MyHandler(Handler):
    def handle(self, value):
        raise RuntimeError("error from director")

h = MyHandler()
inv = Invoker(h)

# The director method raises an exception. C++ catches DirectorException,
# calls clearPythonError(), and returns -1. No stale error should remain.
result = inv.call(42)
assert result == -1, "Expected -1, got %d" % result

# A second call should also work without SystemError.
result = inv.call(99)
assert result == -1, "Expected -1, got %d" % result

# Test that non-director calls still work normally.
class GoodHandler(Handler):
    def handle(self, value):
        return value + 1

h2 = GoodHandler()
inv2 = Invoker(h2)
result = inv2.call(10)
assert result == 11, "Expected 11, got %d" % result
