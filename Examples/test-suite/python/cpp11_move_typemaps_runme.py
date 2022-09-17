from cpp11_move_typemaps import *

Counter.reset_counts()
mo = MoveOnly(111)
Counter.check_counts(1, 0, 0, 0, 0, 0)
MoveOnly.take(mo)
Counter.check_counts(1, 0, 0, 1, 0, 2)
del mo
Counter.check_counts(1, 0, 0, 1, 0, 2)

Counter.reset_counts()
mo = MovableCopyable(111)
Counter.check_counts(1, 0, 0, 0, 0, 0)
MovableCopyable.take(mo)
Counter.check_counts(1, 0, 0, 1, 0, 2)
del mo
Counter.check_counts(1, 0, 0, 1, 0, 2)

mo = MoveOnly(222)
MoveOnly.take(mo)
exception_thrown = False
try:
  MoveOnly.take(mo)
except RuntimeError as e:
    if "cannot release ownership as memory is not owned" not in str(e):
        raise RuntimeError("incorrect exception message:" + str(e))
    exception_thrown = True
if not exception_thrown:
    raise RuntimeError("Should have thrown 'Cannot release ownership as memory is not owned' error")
