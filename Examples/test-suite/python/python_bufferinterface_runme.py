import python_bufferinterface

# test not relevant unless -builtin
if not python_bufferinterface.is_python_builtin():
    exit(0)

data = python_bufferinterface.Buffer()
view = memoryview(data)
