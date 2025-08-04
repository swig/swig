import sys

# don't bother with Python 2
if sys.version_info < (3,0):
    exit(0)

import pyabi311_bufferinterface

def check(what, expected, actual):
    if expected != actual:
        raise RuntimeError(
            "Failed: ", what, " Expected: ", expected, " Actual: ", actual)

# test not relevant unless certain conditions are met (builtin, limited API)
if not pyabi311_bufferinterface.buffers_supported():
    exit(0)

data = pyabi311_bufferinterface.ReadOnlyData()
view = memoryview(data)
check('readonly', view.readonly, True)
check('read data', view[:10], b"This string represents"[:10])
check('not released', data.released, False)
view.release()
check('released', data.released, True)

data = pyabi311_bufferinterface.ReadWriteData()
view = memoryview(data)
check('readonly', view.readonly, False)
text = b'Lorem ipsum dolor sit amet'
view[:len(text)] = b'Lorem ipsum dolor sit amet'
check('read data', view[:len(text)], text)
check('not released', data.released, False)
view.release()
check('released', data.released, True)

view = memoryview(data)
check('written data', view[:len(text)], text)
check('not released', data.released, False)
del view
check('released', data.released, True)
