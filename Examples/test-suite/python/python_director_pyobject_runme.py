import gc
import sys
import python_director_pyobject


class PyCallback(python_director_pyobject.Callback):
    def callback(self, param1):
        pass

    def callback_ptr(self, param1):
        pass

    def callback_var(self, param1):
        pass


handler = PyCallback()

# A bytearray is mutable, so it is never interned nor immortal and its
# reference count is always tracked.
obj = bytearray(b"test data")

callers = [
    python_director_pyobject.call_callback,
    python_director_pyobject.call_callback_ptr,
    python_director_pyobject.call_callback_var,
]

for caller in callers:
    before = sys.getrefcount(obj)
    for i in range(100):
        caller(handler, obj)
        after = sys.getrefcount(obj)
        if before != after:
            raise RuntimeError("%s changed the reference count at iteration %d: %d -> %d" % (caller.__name__, i, before, after))

# The object must still be usable, that is, not freed while in use.
if obj != bytearray(b"test data"):
    raise RuntimeError("object was corrupted")

# Same again with garbage collection in between the upcalls.
before = sys.getrefcount(obj)
for i in range(100):
    gc.collect()
    python_director_pyobject.call_callback(handler, obj)
    gc.collect()
after = sys.getrefcount(obj)
if before != after:
    raise RuntimeError("reference count changed after garbage collection: %d -> %d" % (before, after))

# A null PyObject * argument must not crash.
if python_director_pyobject.call_callback_null(handler):
    raise RuntimeError("call_callback_null should have failed the upcall")
