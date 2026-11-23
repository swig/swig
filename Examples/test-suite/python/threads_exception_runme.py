import threads_exception

from swig_test_utils import swig_run_threaded

t = threads_exception.Test()
try:
    t.unknown()
except RuntimeError as e:
    pass

try:
    t.simple()
except RuntimeError as e:
    if e.args[0] != 37:
        raise RuntimeError

try:
    t.message()
except RuntimeError as e:
    if e.args[0] != "I died.":
        raise RuntimeError

# This is expected fail with -builtin option
# Throwing builtin classes as exceptions not supported
if not threads_exception.is_python_builtin():
    try:
        t.hosed()
    except threads_exception.Exc as e:
        code = e.code
        if code != 42:
            raise RuntimeError("bad... code: %d" % code)
        msg = e.msg
        if msg != "Hosed":
            raise RuntimeError("bad... msg: '%s' len: %d" % (msg, len(msg)))

for i in range(1, 4):
    try:
        t.multi(i)
    except RuntimeError as e:
        pass
    except threads_exception.Exc as e:
        pass

# Concurrent exceptions with -threads must each reach the raising thread.
# Issue #3212: the error was set on a temporary thread state and lost when
# it was released, so the wrapper returned without an error and crashed.
def check_threaded():
    try:
        t.simple()
    except RuntimeError as e:
        if e.args[0] != 37:
            raise RuntimeError("wrong threaded exception: %r" % (e.args,))
    else:
        raise RuntimeError("no exception raised in thread")

swig_run_threaded(check_threaded)
