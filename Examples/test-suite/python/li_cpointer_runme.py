from li_cpointer import *


p = new_intp()
intp_assign(p,3)

if intp_value(p) != 3:
    raise RuntimeError

delete_intp(p)
