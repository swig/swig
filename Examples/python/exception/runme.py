# file: runme.py

# Throw a lot of exceptions

import example

t = example.Test()
try:
    t.unknown()
except RuntimeError as e:
    print("incomplete type %s" % e.args[0])

try:
    t.simple()
except RuntimeError as e:
    print(e.args[0])

try:
    t.message()
except RuntimeError as e:
    print(e.args[0])

if not example.is_python_builtin():
    try:
        t.hosed()
    except example.Exc as e:
        print("%s %s" % (e.code, e.msg))
else:
    try:
        t.hosed()
    except BaseException as e:
        # Throwing builtin classes as exceptions not supported (-builtin
        # option)
        print(e)

for i in range(1, 4):
    try:
        t.multi(i)
    except RuntimeError as e:
        print(e.args[0])
    except example.Exc as e:
        print("%s %s" % (e.code, e.msg))
