import ccomplextest

a = complex(-1, 2)

if ccomplextest.has_c99_complex():
    if ccomplextest.Conj(a) != a.conjugate():
        raise RuntimeError("bad complex mapping")

    if ccomplextest.Conjf(a) != a.conjugate():
        raise RuntimeError("bad complex mapping")

    if ccomplextest.Conj2(a) != a.conjugate():
        raise RuntimeError("bad complex mapping")

    if ccomplextest.Conjf2(a) != a.conjugate():
        raise RuntimeError("bad complex mapping")

    if ccomplextest.Conj3(a) != a.conjugate():
        raise RuntimeError("bad complex mapping")

    if ccomplextest.Conjf3(a) != a.conjugate():
        raise RuntimeError("bad complex mapping")
