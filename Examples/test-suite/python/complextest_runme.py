import complextest

a = complex(-1, 2)

if complextest.Conj(a) != a.conjugate():
    raise RuntimeError, "bad complex mapping"

if complextest.Conjf(a) != a.conjugate():
    raise RuntimeError, "bad complex mapping"

if complextest.Conj2(a) != a.conjugate():
    raise RuntimeError, "bad complex mapping"

if complextest.Conjf2(a) != a.conjugate():
    raise RuntimeError, "bad complex mapping"


v = (complex(1, 2), complex(2, 3), complex(4, 3), 1)

if len(complextest.CopyHalf(v)) != 2:
    raise RuntimeError("CopyHalf failed")

if len(complextest.CopyHalfRef(v)) != 2:
    raise RuntimeError("CopyHalfRef failed")

p = complextest.ComplexPair()
p.z1 = complex(0, 1)
p.z2 = complex(0, -1)
if complextest.Conj(p.z2) != p.z1:
    raise RuntimeError, "bad complex mapping"
