import gc
import sys
import director_langobj

# A bytearray is mutable, so it is never interned nor immortal and its
# reference count is always tracked.
obj = bytearray(b"test data")

# Records whether each upcall received the object itself rather than a copy or a
# proxy. A bool is stored rather than the object so that the reference count of
# obj is not disturbed.
received = []


class PyCallback(director_langobj.Callback):
    def callback(self, param1):
        received.append(param1 is obj)

    def callback_ref(self, param1):
        received.append(param1 is obj)


handler = PyCallback()

callers = [
    director_langobj.call_callback,
    director_langobj.call_callback_ref,
]

for caller in callers:
    del received[:]
    before = sys.getrefcount(obj)
    for i in range(100):
        caller(handler, obj)
        after = sys.getrefcount(obj)
        if before != after:
            raise RuntimeError("%s changed the reference count at iteration %d: %d -> %d" % (caller.__name__, i, before, after))
    if received != [True] * 100:
        raise RuntimeError("%s did not pass the object itself to the director method" % caller.__name__)

# The object must still be usable, that is, not freed while in use.
if obj != bytearray(b"test data"):
    raise RuntimeError("object was corrupted")

# Same again with garbage collection in between the upcalls.
before = sys.getrefcount(obj)
for i in range(100):
    gc.collect()
    director_langobj.call_callback(handler, obj)
    gc.collect()
after = sys.getrefcount(obj)
if before != after:
    raise RuntimeError("reference count changed after garbage collection: %d -> %d" % (before, after))
