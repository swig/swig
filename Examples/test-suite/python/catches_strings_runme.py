from catches_strings import *

exception_thrown = False
try:
    StringsThrower.charstring()
except RuntimeError as e:
    if "charstring message" not in str(e):
        raise RuntimeError("incorrect exception message:" + str(e))
    exception_thrown = True
if not exception_thrown:
    raise RuntimeError("Should have thrown an exception")
