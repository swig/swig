from cpp17_using_pack_alias_template import *
from swig_test_utils import swig_check

# Both overloads of g, inherited through the alias template base pack 'Identity<Ts>...' and re-exported
# by the using-declaration pack 'using Identity<Ts>::g...;', are wrapped.
o = OverAB()
swig_check(o.g(), 1)     # inherited from A through Identity<A>
swig_check(o.g(7), 7)    # inherited from B through Identity<B>

# Both inherited constructors, brought in through the alias template base pack
# 'using Identity<Ts>::Identity...;', are wrapped on the derived proxy.
CtorWrapIS(5)            # inherited CtorA(int)
swig_check(last_ctor(), 105)
CtorWrapIS(2, 3)         # inherited CtorB(int, int)
swig_check(last_ctor(), 205)
