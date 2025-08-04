from char_binary_rev_len import *

t = Test()
if t.strlen("hile") != 4:
    raise RuntimeError("bad multi-arg typemap {}".format(t.strlen("hile")))

if t.strlen("hil\0") != 4:
    raise RuntimeError("bad multi-arg typemap")
