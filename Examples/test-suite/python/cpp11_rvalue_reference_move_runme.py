from cpp11_rvalue_reference_move import *

# Function containing rvalue reference parameter
Counter.reset_counts()
mo = MovableCopyable(222)
Counter.check_counts(1, 0, 0, 0, 0, 0)
MovableCopyable.movein(mo)
Counter.check_counts(1, 0, 0, 1, 0, 2)
if not MovableCopyable.is_nullptr(mo):
    raise RuntimeError("is_nullptr check")
del mo
Counter.check_counts(1, 0, 0, 1, 0, 2)

# Move constructor test
Counter.reset_counts()
mo = MovableCopyable(222)
Counter.check_counts(1, 0, 0, 0, 0, 0)
mo_moved = MovableCopyable(mo)
Counter.check_counts(1, 0, 0, 1, 0, 1)
if not MovableCopyable.is_nullptr(mo):
    raise RuntimeError("is_nullptr check")
del mo
Counter.check_counts(1, 0, 0, 1, 0, 1)
del mo_moved
Counter.check_counts(1, 0, 0, 1, 0, 2)

# Move assignment operator test
Counter.reset_counts()
mo111 = MovableCopyable(111)
mo222 = MovableCopyable(222)
Counter.check_counts(2, 0, 0, 0, 0, 0)
mo111.MoveAssign(mo222)
Counter.check_counts(2, 0, 0, 0, 1, 1)
if not MovableCopyable.is_nullptr(mo222):
    raise RuntimeError("is_nullptr check")
del mo222
Counter.check_counts(2, 0, 0, 0, 1, 1)
del mo111
Counter.check_counts(2, 0, 0, 0, 1, 2)

# null check
Counter.reset_counts()
exception_thrown = False
try:
    MovableCopyable.movein(None)
except TypeError as e:
    if "invalid null reference" not in str(e):
        raise RuntimeError("incorrect exception message:" + str(e))
    exception_thrown = True
if not exception_thrown:
    raise RuntimeError("Should have thrown null error")
Counter.check_counts(0, 0, 0, 0, 0, 0)

# output
Counter.reset_counts()
mc = MovableCopyable.moveout(1234)
Counter.check_counts(2, 0, 0, 0, 1, 1)
MovableCopyable.check_numbers_match(mc, 1234)

exception_thrown = False
try:
    MovableCopyable.movein(mc)
except RuntimeError as e:
    if "cannot release ownership as memory is not owned" not in str(e):
        raise RuntimeError("incorrect exception message:" + str(e))
    exception_thrown = True
if not exception_thrown:
    raise RuntimeError("Should have thrown 'Cannot release ownership as memory is not owned' error")
Counter.check_counts(2, 0, 0, 0, 1, 1)
