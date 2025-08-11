from char_binary_rev_len import *

t = Test()
if t.strlen("hile") != 4:
    raise RuntimeError("bad multi-arg typemap 1")

if t.strlen("hil\0") != 4:
    raise RuntimeError("bad multi-arg typemap 2")

t2 = Test("hile")
if t2.getisize() != 4:
    raise RuntimeError("bad multi-arg typemap 3")

if t2.strlen("hil\0a") != 5:
    raise RuntimeError("bad multi-arg typemap 4")
