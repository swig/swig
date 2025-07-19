import weakref

import python_weakref

ts = python_weakref.TestStruct()
ts_ref = weakref.ref(ts)
