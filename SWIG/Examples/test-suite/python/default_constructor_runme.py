import _default_constructor

dc = _default_constructor

a = dc.new_A
del_a = dc.delete_A

aa = dc.new_AA
del_aa = dc.delete_AA

b = dc.new_B
del_b = dc.delete_B

try:
    bb = dc.new_BB;
    print "Whoa. new_BB created."
except AttributeError:
    pass

del_bb = dc.delete_BB

try:
    c = dc.new_C
    print "Whoa. new_C created."
except AttributeError:
    pass

del_c = dc.delete_C

cc = dc.new_CC
del_cc = dc.delete_CC

try:
    d = dc.new_D;
    print "Whoa. new_D created"
except AttributeError:
    pass

del_d = dc.delete_D

try:
    dd = dc.new_DD
    print "Whoa. new_DD created"
except AttributeError:
    pass

dd = dc.delete_DD

try:
    ad = dc.new_AD
    print "Whoa. new_AD created"
except AttributeError:
    pass

del_ad = dc.delete_AD

e = dc.new_E
del_e = dc.delete_E

ee = dc.new_EE
del_ee = dc.delete_EE

try:
    eb = dc.new_EB
    print "Whoa. new_EB created"
except AttributeError:
    pass

del_eb = dc.delete_EB

f = dc.new_F

try:
    del_f = dc.delete_F
    print "Whoa. delete_F created"
except AttributeError:
    pass

ff = dc.new_FFF
try:
    del_ff = dc.delete_FFF
    print "Whoa. delete_FFF created"
except AttributeError:
    pass

g = dc.new_G

try:
    del_g = dc.delete_G
    print "Whoa. delete_G created"
except AttributeError:
    pass

gg = dc.new_GG
del_gg = dc.delete_GG


import default_constructor
hh = default_constructor.HH(1,1)

