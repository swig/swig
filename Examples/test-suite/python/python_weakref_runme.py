import sys
import weakref

import python_weakref

def check(message, lhs, rhs):
    if lhs != rhs:
        raise RuntimeError(message, lhs, rhs)

callbacks = []
def callback(ref):
    callbacks.append(ref)

ts = python_weakref.TestStruct()

# plain weak reference
ts_ref = weakref.ref(ts)
check("deref'd weakref is not object", ts_ref() is ts, True)
check("wrong number of weak references", weakref.getweakrefcount(ts), 1)
ts_ref().x = 123

# delete the weakref
del ts_ref
check("wrong number of weak references", weakref.getweakrefcount(ts), 0)

# create it again
ts_ref = weakref.ref(ts)
check("wrong number of weak references", weakref.getweakrefcount(ts), 1)

# weak reference proxy with callback
ts_ref_cb = weakref.proxy(ts, callback)
check("wrong number of weak references", weakref.getweakrefcount(ts), 2)
if sys.version_info >= (3,0):
    # weakref proxy fails "is" but passes "=="
    check("deref'd weakref != object", ts_ref_cb, ts)
check("weakref proxy not usable", ts_ref_cb.x, 123)

# delete object
check("callback was called", callbacks, [])
del ts
check("callback wasn't called", callbacks, [ts_ref_cb])
check("deref'd weakref is not None", ts_ref() is None, True)
