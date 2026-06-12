from swig_test_utils import swig_check
import injecting_base_class as m

# Each of these names the namespaced base Space::Base (or Space::Base2) without the namespace qualifier,
# from within a derived class - the C++ injected class name.  SWIG must resolve every spelling to the
# one base type.

d = m.Derived()
b = m.Base("x")

# Constructors taking the base.
swig_check(m.Derived(b).whoami(), "Base:x")
swig_check(m.MultiDerived(b, m.Base2(5)).whoami(), "Base:x")
swig_check(m.Derived2(b).whoami(), "Base:x")

d.member = m.Base("mm")
swig_check(d.member.whoami(), "Base:mm")
swig_check(d.sharedvar.whoami(), "Base:sharedvar")

swig_check(d.by_value(b).whoami(), "Base:x")
swig_check(d.by_pointer(b).whoami(), "Base:x")
swig_check(d.by_cref(b).whoami(), "Base:x")

swig_check(m.Derived.make("y").whoami(), "Base:y")
swig_check(m.Derived.static_id(b).whoami(), "Base:x")

# Named through the derived class (Derived::Base) at namespace scope.
swig_check(m.through_derived(b).whoami(), "Base:x")

# Multiple inheritance
md = m.MultiDerived()
swig_check(md.first(b).whoami(), "Base:x")
swig_check(md.second(m.Base2(42)).id, 42)

# Multi level inheritance: the indirect base named unqualified and through the derived class.
d2 = m.Derived2()
swig_check(d2.from_grandbase(b).whoami(), "Base:x")
swig_check(d2.from_grandbase_qualified(b).whoami(), "Base:x")

# Type unification: a value produced through any of the derived spellings is accepted by the function
# taking the fully qualified Space::Base / Space::Base2.
swig_check(m.canonical(m.Derived.make("z")).whoami(), "Base:z")
swig_check(m.canonical(d.by_value(b)).whoami(), "Base:x")
swig_check(m.canonical2(md.second(m.Base2(7))), 7)
