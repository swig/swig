import threading
import time
from director_gil_release import Foo


class PyFoo(Foo):
    pass


f = PyFoo()
done = False


def worker():
    global done
    f.blocking_call(300)
    done = True


t = threading.Thread(target=worker)
start = time.time()
t.start()
time.sleep(0.05)

# if GIL was released by blocking_call, ping() returns immediately
# if not, ping() can't be called until blocking_call(300) finishes (~300ms)
result = f.ping()
elapsed = time.time() - start

t.join()

# elapsed from start includes:
# - 50ms sleep (specified)
# - GIL wait time only if GIL was NOT released by the director method
# With GIL release: ~0.05s, without: ~0.30s
if elapsed > 0.2:
    raise RuntimeError("GIL was not released, total time %.3fs" % elapsed)

if result != 42:
    raise RuntimeError("Unexpected result: " + str(result))
