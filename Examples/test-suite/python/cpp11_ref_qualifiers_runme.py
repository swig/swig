import cpp11_ref_qualifiers

h = cpp11_ref_qualifiers.Host()

# Basic testing
h.h1()
h.h2()
h.h6()
h.h7()

h.h()

# %feature testing
f = cpp11_ref_qualifiers.Features()
if f.F1() != "F1":
    raise RuntimeException("Fail")
if f.F2() != "F2":
    raise RuntimeException("Fail")
if f.F3() != "F3":
    raise RuntimeException("Fail")

if f.C1(0) != "C1":
    raise RuntimeException("Fail")
if f.C2(0) != "C2":
    raise RuntimeException("Fail")
if f.C3(0) != "C3":
    raise RuntimeException("Fail")

# %rename testing
r = cpp11_ref_qualifiers.Renames()
r.RR1()
r.RR2()
r.RR3()

r.SS1(0)
r.SS2(0)
r.SS3(0)

# Conversion operators
co = cpp11_ref_qualifiers.ConversionOperators()
s = co.StringConvertCopy()
s = co.StringConvertMove()

co2 = cpp11_ref_qualifiers.ConversionOperators2()
s = co2.StringConvertMove()
