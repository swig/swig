from swig_test_utils import swig_check
import cpp11_inheriting_constructors_typedef as m

# Inheriting constructor naming Base through a typedef (Derived3's unqualified-id is Base's own name)
swig_check(m.Derived1(7).value(), 7)
swig_check(m.Derived2(7).value(), 7)
swig_check(m.Derived3(7).value(), 7)
swig_check(m.Derived4(7).value(), 7)

# A using declaration naming a different base member imports it (a protected method), not a constructor
swig_check(m.ImportMember("hello").protectedvalue(), 5)

# Overloaded base constructor and a method inherited through a typedef
swig_check(m.OverloadDerived(7).overloadvalue(), 7)
swig_check(m.OverloadDerived(3, 4).overloadvalue(), 7)

# Two typedef'd bases, an inheriting constructor from each
a = m.MultiDerived(5)
swig_check(a.valuea(), 5)
swig_check(a.valueb(), 0)
b = m.MultiDerived(3, 4)
swig_check(b.valuea(), 0)
swig_check(b.valueb(), 12)

# Multi-level typedef chain
swig_check(m.ChainDerived(9).chainvalue(), 9)

# Typedef in a different namespace
swig_check(m.NsDerived(11).nsvalue(), 11)

# Over-flag guard: imports First's method Second, not a constructor
swig_check(m.OverflowGuard().Second(5), 50)
