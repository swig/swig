from cpp17_using_pack_expansion import *
from swig_test_utils import swig_check

# Direct call via %template proxy (C++17 pack expansion in a using-declaration).
ov = OverloadedIntDouble()
swig_check(ov.call(7), "Int:7")
swig_check(ov.call(2.5), "Double:2.500000")

# std::visit idiom using helper functions.
swig_check(visit_functors_int(7), "Int:7")
swig_check(visit_functors_double(2.5), "Double:2.500000")

# Pack expansion in a using-declaration with a nested qualifier 'Base<Ts>::operator()...;'.
mx = MixedIntDouble()
swig_check(mx.call(7), "T:7")
swig_check(mx.call(2.5), "T:2.500000")

# Empty pack: the using-declaration introduces no names, so the proxy class has no call method.
empty_overloaded = OverloadedEmpty()
empty_mixed = MixedEmpty()
swig_check(hasattr(empty_overloaded, "call"), False)
swig_check(hasattr(empty_mixed, "call"), False)

# Empty pack with member methods either side of the using-decl: the using-decl is removed
# and before_using()/after_using() remain intact in the proxy.
wm = WithMembersEmpty()
swig_check(wm.before_using(), "before")
swig_check(wm.after_using(), "after")
swig_check(hasattr(wm, "call"), False)
