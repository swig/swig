import sys

# don't bother with Python 2
if sys.version_info < (3,0):
    exit(0)

import python_bufferinterface

# test not relevant unless -builtin
if not python_bufferinterface.should_work():
    exit(0)

data = python_bufferinterface.Buffer()
view = memoryview(data)
