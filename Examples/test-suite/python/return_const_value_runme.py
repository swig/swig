import return_const_value
import sys

p = return_const_value.Foo_ptr.getPtr()
if (p.getVal() != 17):
    raise RuntimeError("Runtime test1 failed. p.getVal()={}".format(p.getVal()))

p = return_const_value.Foo_ptr.getConstPtr()
if (p.getVal() != 17):
    raise RuntimeError("Runtime test2 failed. p.getVal()={}".format(p.getVal()))
