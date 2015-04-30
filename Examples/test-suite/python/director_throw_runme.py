import director_throw

class MyException(Exception):
    pass

go_called_count = 0
class Derived(director_throw.Foo):
    def go(self):
        global go_called_count
        go_called_count += 1
        raise MyException

if go_called_count != 0:
    raise RuntimeError, "go_called_count before"
if director_throw.GetExceptionCount() != 0:
    raise RuntimeError, "GetExceptionCount() before"

f = Derived()
try:
    director_throw.CallGo(f);
    raise RuntimeError  # Callee should have exited with an exception.
except MyException:
    pass

if go_called_count != 1:
    raise RuntimeError, "go_called_count after"
if director_throw.GetExceptionCount() != 1:
    raise RuntimeError, "GetExceptionCount() after: %i" % director_throw.GetExceptionCount()

