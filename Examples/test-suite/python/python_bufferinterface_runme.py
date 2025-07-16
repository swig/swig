import sys

# don't bother with Python 2
if sys.version_info < (3,0):
    exit(0)

import python_bufferinterface

# test not relevant unless certain conditions are met (builtin, limited API)
if not python_bufferinterface.buffers_supported():
    exit(0)

data = python_bufferinterface.ReadOnlyData()
view = memoryview(data)
assert(view.readonly == True)
assert(view[:10] == b"This string represents"[:10])
assert(python_bufferinterface.cvar.released == False)
view.release()
assert(python_bufferinterface.cvar.released == True)

data = python_bufferinterface.ReadWriteData()
view = memoryview(data)
assert(view.readonly == False)
text = b'Lorem ipsum dolor sit amet'
view[:len(text)] = b'Lorem ipsum dolor sit amet'
assert(view[:len(text)] == text)
assert(python_bufferinterface.cvar.released == False)
view.release()
assert(python_bufferinterface.cvar.released == True)

view = memoryview(data)
assert(view[:len(text)] == text)
assert(python_bufferinterface.cvar.released == False)
del view
assert(python_bufferinterface.cvar.released == True)
