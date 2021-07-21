from li_std_pair import *

def check(flag):
    if not flag:
        raise RuntimeError("Check failed")

intPair = makeIntPair(7, 6)
check(isinstance(intPair, tuple))
check(len(intPair) == 2)
check(intPair[0] == 7)
check(intPair[1] == 6)

intPairConstRef = makeIntPairConstRef(7, 6)
check(isinstance(intPairConstRef, tuple))
check(intPairConstRef[0] == 7)
check(intPairConstRef[1] == 6)

#
# Each of these should return a reference to a wrapped
# std::pair<int, int> object (i.e. an IntPair instance).
#
intPairPtr = makeIntPairPtr(7, 6)
check(isinstance(intPairPtr, IntPair))
check(intPairPtr[0] == 7)
check(intPairPtr[1] == 6)

intPairRef = makeIntPairRef(7, 6)
check(isinstance(intPairRef, IntPair))
check(intPairRef[0] == 7)
check(intPairRef[1] == 6)
#
# Now test various input typemaps. Each of the wrapped C++ functions
# (product1, product2 and product3) is expecting an argument of a
# different type (see li_std_pair.i). Typemaps should be in place to
# convert this tuple into the expected argument type.
#
check(product1(intPair) == 42)
check(product2(intPair) == 42)
# check(product3(intPair) == 42) # TODO, if desirable to match Ruby wrappers behaviour. Requires equivalent to typemap(in) std::pair* in Lib/ruby/std_pair.i and further fixes to stop recursive calls to swig::asptr which this testcase shows. Plus further changes for any type of sequence type (including other STL containers) to be accepted by all methods taking an STL container to match Ruby behaviour.

#
# Similarly, each of the input typemaps should know what to do
# with an IntPair instance.
#
check(product1(intPairPtr) == 42)
check(product2(intPairPtr) == 42)
check(product3(intPairPtr) == 42)
