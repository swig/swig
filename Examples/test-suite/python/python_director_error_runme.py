import python_director_error

class MyException(Exception):
  pass

go_called_count = 0
class Derived(python_director_error.Foo):
  def go(self):
    global go_called_count
    go_called_count += 1
    raise MyException

if go_called_count != 0:
  raise RuntimeError, "go_called_count before"
if python_director_error.GetExceptionCount() != 0:
  raise RuntimeError, "GetExceptionCount() before"

f = Derived()
try:
  python_director_error.CallGo(f);
  raise RuntimeError  # Callee should have exited with an exception.
except MyException:
  pass

if go_called_count != 1:
  raise RuntimeError, "go_called_count after"
if python_director_error.GetExceptionCount() != 1:
  raise RuntimeError, "GetExceptionCount() after: %i" % python_director_error.GetExceptionCount()

