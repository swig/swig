require("import")
import_to_globs("li_std_pair")

intPair = makeIntPair(7, 6)
assert(intPair.first==7 and intPair.second==6)

intPairPtr = makeIntPairPtr(7, 6)
assert(intPairPtr.first==7 and intPairPtr.second==6)

intPairRef = makeIntPairRef(7, 6)
assert(intPairRef.first == 7 and intPairRef.second == 6)

intPairConstRef = makeIntPairConstRef(7, 6)
assert(intPairConstRef.first == 7 and intPairConstRef.second == 6)

-- call fns
assert(product1(intPair) == 42)
assert(product2(intPair) == 42)
assert(product3(intPair) == 42)

-- also use the pointer version
assert(product1(intPairPtr) == 42)
assert(product2(intPairPtr) == 42)
assert(product3(intPairPtr) == 42)

-- or the other types
assert(product1(intPairRef) == 42)
assert(product2(intPairRef) == 42)
assert(product3(intPairRef) == 42)
assert(product1(intPairConstRef) == 42)
assert(product2(intPairConstRef) == 42)
assert(product3(intPairConstRef) == 42)
