import _default_constructor

dc = _default_constructor

# Old static syntax not supported
#a = dc.new_A()
#dc.delete_A(a)
a = dc.A()
del a

# Old static syntax not supported
#aa = dc.new_AA()
#dc.delete_AA(aa)
aa = dc.AA()
del aa

try:
    # Old static syntax not supported
    #b = dc.new_B()
    b = dc.B()
    print "Whoa. new_BB created."
except:
    pass

# Old static syntax not supported.
# Swig builtin types have no tp_del entry (only tp_dealloc).
#del_b = dc.delete_B

try:
    # Old static syntax not supported.
    #bb = dc.new_BB();
    bb = dc.BB()
    print "Whoa. new_BB created."
except:
    pass

# Old static syntax not supported.
# Swig builtin types have no tp_del entry (only tp_dealloc).
#del_bb = dc.delete_BB

try:
    # Old static syntax not supported
    #c = dc.new_C()
    c = dc.C()
    print "Whoa. new_C created."
except:
    pass

# Old static syntax not supported.
# Swig builtin types have no tp_del entry (only tp_dealloc).
#del_c = dc.delete_C

# Old static syntax not supported.
#cc = dc.new_CC()
#dc.delete_CC(cc)
cc = dc.CC()
del cc

try:
    # Old static syntax not supported.
    #d = dc.new_D();
    d = dc.D()
    print "Whoa. new_D created"
except:
    pass

# Old static syntax not supported.
# Swig builtin types have no tp_del entry (only tp_dealloc).
#del_d = dc.delete_D

try:
    # Old static syntax not supported.
    #dd = dc.new_DD()
    dd = dc.DD()
    print "Whoa. new_DD created"
except:
    pass

# Old static syntax not supported.
# Swig builtin types have no tp_del entry (only tp_dealloc).
#dd = dc.delete_DD

try:
    # Old static syntax not supported.
    #ad = dc.new_AD()
    ad = dc.AD()
    print "Whoa. new_AD created"
except:
    pass

# Old static syntax not supported.
# Swig builtin types have no tp_del entry (only tp_dealloc).
#del_ad = dc.delete_AD

# Old static syntax not supported.
#e = dc.new_E()
#dc.delete_E(e)
e = dc.E()
del e

# Old static syntax not supported.
#ee = dc.new_EE()
#dc.delete_EE(ee)
ee = dc.EE()
del ee

try:
    # Old static syntax not supported.
    #eb = dc.new_EB()
    eb = dc.EB()
    print "Whoa. new_EB created"
except:
    pass

# Old static syntax not supported.
# Swig builtin types have no tp_del entry (only tp_dealloc).
#del_eb = dc.delete_EB

# Old static syntax not supported.
#f = dc.new_F()
f = dc.F()

try:
    del_f = dc.delete_F
    print "Whoa. delete_F created"
except AttributeError:
    pass

# Old static syntax not supported.
#dc.F_destroy(f)
f.destroy()

# Old static syntax not supported.
#ff = dc.new_FFF()
ff = dc.FFF()

try:
    del_ff = dc.delete_FFF
    print "Whoa. delete_FFF created"
except AttributeError:
    pass

# Old static syntax not supported.
#dc.F_destroy(ff)
ff.destroy()

# Old static syntax not supported.
#g = dc.new_G()
g = dc.G()

try:
    del_g = dc.delete_G
    print "Whoa. delete_G created"
except AttributeError:
    pass

dc.G.destroy(g)

# Old static syntax not supported.
#gg = dc.new_GG()
#dc.delete_GG(gg)
gg = dc.GG()
del gg

import default_constructor
hh = default_constructor.HH(1,1)

