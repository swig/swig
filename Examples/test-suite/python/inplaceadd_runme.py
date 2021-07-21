import inplaceadd
a = inplaceadd.A(7)

a += 5
if a.val != 12:
    raise RuntimeError("a.val: {}".format(a.val))

a -= 5
if a.val != 7:
    raise RuntimeError

a *= 2

if a.val != 14:
    raise RuntimeError

a += a
if a.val != 28:
    raise RuntimeError
