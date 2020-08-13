import _default_constructor

# This test is expected to fail with -builtin option.
# It uses the old static syntax (e.g., dc.new_A() rather than dc.A()),
# which is not provided with the -builtin option.
if _default_constructor.is_python_builtin():
    exit(0)

dc = _default_constructor

a = dc.new_A()
dc.delete_A(a)

aa = dc.new_AA()
dc.delete_AA(aa)

try:
    b = dc.new_B()
    raise RuntimeError("Whoa. new_BB created.")
except TypeError:
    pass

del_b = dc.delete_B

try:
    bb = dc.new_BB()
    raise RuntimeError("Whoa. new_BB created.")
except AttributeError:
    pass

del_bb = dc.delete_BB

try:
    c = dc.new_C()
    raise RuntimeError("Whoa. new_C created.")
except AttributeError:
    pass

del_c = dc.delete_C

cc = dc.new_CC()
dc.delete_CC(cc)

try:
    d = dc.new_D()
    raise RuntimeError("Whoa. new_D created")
except AttributeError:
    pass

del_d = dc.delete_D

try:
    dd = dc.new_DD()
    raise RuntimeError("Whoa. new_DD created")
except AttributeError:
    pass

dd = dc.delete_DD

try:
    ad = dc.new_AD()
    raise RuntimeError("Whoa. new_AD created")
except AttributeError:
    pass

del_ad = dc.delete_AD

e = dc.new_E()
dc.delete_E(e)

ee = dc.new_EE()
dc.delete_EE(ee)

try:
    eb = dc.new_EB()
    raise RuntimeError("Whoa. new_EB created")
except AttributeError:
    pass

del_eb = dc.delete_EB

f = dc.new_F()

try:
    del_f = dc.delete_F
    raise RuntimeError("Whoa. delete_F created")
except AttributeError:
    pass

dc.F_destroy(f)

g = dc.new_G()

try:
    del_g = dc.delete_G
    raise RuntimeError("Whoa. delete_G created")
except AttributeError:
    pass

dc.G_destroy(g)

gg = dc.new_GG()
dc.delete_GG(gg)


import default_constructor
hh = default_constructor.HH(1, 1)
