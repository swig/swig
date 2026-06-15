from swig_test_utils import swig_check
import cpp11_inheriting_constructors_typedef as m

# Plain non-template base via a plain typedef: overloaded constructor and a method through the typedef
swig_check(m.PlainTypedefBase(7).value(), 7)
swig_check(m.PlainTypedefBase(3, 4).value(), 7)

# Two typedef'd bases, an inheriting-constructor using-declaration from each
a = m.MultiTypedefBases(5)
swig_check(a.alpha(), 5)
swig_check(a.beta(), 0)
b = m.MultiTypedefBases(3, 4)
swig_check(b.alpha(), 0)
swig_check(b.beta(), 12)

# Base named through a three-level typedef chain
swig_check(m.DeepTypedefChain(9).value(), 9)

# Base named through a typedef declared in a different namespace
swig_check(m.CrossNsTypedef(11).value(), 11)
