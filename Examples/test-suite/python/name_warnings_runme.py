from name_warnings import *

def check(flag):
    if not flag:
        raise RuntimeError("Test failed")

four = double_an_int(2)
check(four == 4)

