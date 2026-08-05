import python_crossmod_a
import python_crossmod_b

c = python_crossmod_b.C()
if c.methA() != 1:
    raise RuntimeError("methA got {}".format(c.methA()))
if c.methB() != 2:
    raise RuntimeError("methB got {}".format(c.methB()))
if c.methC() != 3:
    raise RuntimeError("methC got {}".format(c.methC()))
