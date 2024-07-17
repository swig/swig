import director_guard
import threading
import time

str2 = "tst2"

class MinCallback(director_guard.Callback):
    def run(self):
        return str2

class CallThread(threading.Thread):
    def __init__(self, caller):
        super(CallThread, self).__init__()
        self.caller = caller

    def run(self):
        for x in range(100):
            if self.caller.call() != "tst2":
                raise RuntimeError("Should return true")
            time.sleep(0.001) # 1 millisecond

callback = MinCallback()
caller = director_guard.Caller(callback)
threads = [ ]
for x in range(10):
    threads.append(CallThread(caller))

for t in threads:
    t.start()

for t in threads:
    t.join()
