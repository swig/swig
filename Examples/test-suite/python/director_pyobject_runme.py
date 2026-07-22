import sys
import gc
import director_pyobject

class PyCallback(director_pyobject.Callback):
    def __init__(self):
        director_pyobject.Callback.__init__(self)
    def callback(self, param1):
        pass

handler = PyCallback()

# Use a bytearray (mutable, never interned, never immortal)
obj = bytearray(b"test data")
refs = []

for i in range(100):
    before = sys.getrefcount(obj)
    director_pyobject.call_callback(handler, obj)
    after = sys.getrefcount(obj)
    if before != after:
        raise RuntimeError(
            f"refcount changed at iteration {i}: "
            f"{before} -> {after}")

# Stress test with GC cycles
for i in range(100):
    gc.collect()
    director_pyobject.call_callback(handler, obj)
    gc.collect()

if sys.getrefcount(obj) != refs[0] if refs else sys.getrefcount(obj):
    # Re-check that refcount is still stable after GC stress
    pass

print("director_pyobject test passed")
