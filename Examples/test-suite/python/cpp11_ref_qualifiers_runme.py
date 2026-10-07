import cpp11_ref_qualifiers
from swig_test_utils import swig_assert

h = cpp11_ref_qualifiers.Host()

# Basic testing
h.h1()
h.h2()
h.h6()
h.h7()

h.h()

th = cpp11_ref_qualifiers.TypedefHost()
th.t1()
swig_assert(not hasattr(th, "t2"), "t2 should be ignored")
swig_assert(not hasattr(th, "t3"), "t3 should be ignored")

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

# Default arguments
from swig_test_utils import swig_assert, swig_check

d = cpp11_ref_qualifiers.DefaultArgs()
swig_check(d.vol(), 100)
swig_check(d.vol(10), 100)
swig_check(d.vol(10, 20), 100)
swig_check(d.lref(), 200)
swig_check(d.lref(10), 200)
swig_check(d.lref(10, 20), 200)
swig_check(d.cvref_renamed(), 3)
swig_check(d.cvref_renamed(10), 12)
swig_check(d.cvref_renamed(10, 20), 30)
swig_check(d.rv(), 3)
swig_check(d.rv(10), 12)
swig_check(d.rv(10, 20), 30)
swig_assert(not hasattr(d, "cvref"), "cvref should be renamed")
swig_assert(not hasattr(d, "crv"), "crv should not be wrapped")
